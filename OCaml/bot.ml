open Core
open Async
open Disml
open Models

type config = {
  container_id : string;
  ocaml_path : string;
  timeout : float;
}

let prefix_pattern = Pcre.regexp "^!ocaml(?:\\s|```)"
let command_pattern = Pcre.regexp
    "^!ocaml(?:\\s+|(?=```))(`{0,3})(?:(?<=```)ocaml\n)?([\\s\\S]+)\\1"

let ocaml_prepend = "#load \"unix.cma\";;\n"
let ocaml_top_append = ";;\n"

let run_ocaml_common args cfg =
  Process.create ~prog:"docker" ~args:([
      "exec"; "-i"; cfg.container_id;
      "timeout"; "-s"; "KILL"; string_of_float cfg.timeout;
      cfg.ocaml_path; "-color"; "never"] @ args) ()

let run_ocaml_script = run_ocaml_common ["-stdin"]
let run_ocaml_top = run_ocaml_common ["-noprompt"; "-no-version"]

let sanitize = Pcre.replace ~pat:"``" ~templ:"`\u{200B}`"

let toplevel (cfg : config) (code : string) : string Deferred.t =
  match%bind run_ocaml_top cfg with
  | Error e ->
    print_endline ("Error in toplevel: " ^ Error.to_string_hum e);
    return ""
  | Ok ps ->
    let stdin = Process.stdin ps in
    Writer.write_line stdin ocaml_prepend;
    Writer.write stdin code;
    Writer.write stdin ocaml_top_append;
    let%bind output = Process.collect_output_and_wait ps in
    match output.stdout |> String.strip |> sanitize with
    | "" -> return ""
    | stdout -> return ("```ocaml\n" ^ stdout ^ "\n```")

let run (cfg : config) (message : Message.t) (code : string) :
  Message.t Deferred.Or_error.t =
  let f ps =
    let stdin = Process.stdin ps in
    Writer.write_line stdin ocaml_prepend;
    Writer.write stdin code;
    let start = Unix.gettimeofday () in
    let%bind output = Process.collect_output_and_wait ps in
    let duration =
      Float.(Unix.gettimeofday () - start
             |> to_string_hum ~delimiter:',' ~decimals:2) ^ "s"
    in
    let exit_msg =
      match output.exit_status with
      | Error (`Exit_non_zero 137) ->
        "Timed out after " ^ duration
      | Error (`Exit_non_zero exit_code) ->
        "Exited with code " ^ string_of_int exit_code ^ " after " ^ duration
      | Error (`Signal signal) ->
        "Died from " ^ Signal.to_string signal ^ " signal after " ^ duration
      | Ok () ->
        "Exited normally after " ^ duration
    in
    let%bind out_msg =
      match output.exit_status, output.stdout, output.stderr with 
      | Ok (), "", "" -> toplevel cfg code
      | _, "", "" -> return ""
      | _, out, "" | _, "", out -> return ("```\n" ^ sanitize out ^ "\n```")
      | _, stdout, stderr -> return @@
        sprintf "stdout:```\n%s\n```stderr:```\n%s\n```"
          (sanitize stdout) (sanitize stderr)
    in
    let reply_msg = exit_msg ^ "\n" ^ out_msg in
    if String.length reply_msg <= 2000 then
      Message.reply_with ~reply_mention:true ~content:reply_msg message
    else
      Message.reply_with ~reply_mention:true ~content:exit_msg
        ~files:[("output.txt", reply_msg)] message
  in
  Deferred.Or_error.bind (run_ocaml_script cfg) ~f:f

let blank_emoji : Emoji.t = {
  id = None;
  name = "";
  roles = [];
  user = None;
  require_colons = false;
  managed = false;
  animated = false;
}

let check_command (cfg : config) (message : Message.t) : unit =
  if Pcre.pmatch ~rex:prefix_pattern message.content then
    if Option.is_empty message.guild_id then
      Message.reply message "Please don't slide into my DMs." >>> ignore
    else try
        let substrings = Pcre.exec ~rex:command_pattern message.content in
        let code = Pcre.get_substring substrings 2 in
        print_endline "Received valid command";
        let emoji = if Random.bool () then "🐪" else "🐫" in
        Message.add_reaction message {blank_emoji with name=emoji} >>> ignore;
        run cfg message code >>> function
        | Ok _ -> print_endline "Successfully replied to command"
        | Error e -> Error.to_string_hum e |> print_endline
      with Caml.Not_found ->
        Message.reply message "Error: Invalid command format" >>> ignore

let start
    ~token
    ?(timeout=15.)
    ?(cpu_limit=0.)
    ?(mem_limit="0")
    () : unit Deferred.t =
  let%bind _ =
    Process.run ~prog:"docker" ~args:["kill"; "discord-ocaml-bot"] ()
  in
  let%bind container =
    Process.run 
      ~prog:"docker"
      ~args:["run"; "-id"; "--rm"; "--read-only";
             "--cpus=" ^ string_of_float cpu_limit; "-m"; mem_limit;
             "--name"; "discord-ocaml-bot"; "ocaml/opam:discord"] ()
  in
  match container with
  | Error e ->
    print_endline "ERROR: Failed to start docker container";
    print_endline (Error.to_string_hum e);
    exit 1
  | Ok id ->
    let stripped_id = String.strip id in
    let%bind switch =
      Process.run_exn
        ~prog:"docker"
        ~args:["exec"; stripped_id; "opam"; "switch"; "show"] ()
    in
    let cfg = {
      container_id = stripped_id;
      ocaml_path = "/home/opam/.opam/" ^ String.strip switch ^ "/bin/ocaml";
      timeout = timeout;
    }
    in
    Client.message_create := check_command cfg;
    let _ = Client.start token in
    print_endline "Client launched";
    return ()
