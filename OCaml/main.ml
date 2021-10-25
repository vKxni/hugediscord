open Core
open Async

let main () : unit =
  let token = ref "" in
  let timeout = ref 15. in
  let cpu_limit = ref 0. in
  let mem_limit = ref "0" in

  let speclist = Arg.align [
      ("-t", Arg.Set_float timeout,
       "seconds The run time limit for each program");
      ("--cpu-limit", Arg.Set_float cpu_limit,
       "cores Maximum amount of CPU cores to use");
      ("--mem-limit", Arg.Set_string mem_limit,
       "memory Maximum amount of memory to use")
    ]
  in
  let usage = "Usage: discord-ocaml-bot [OPTION] TOKEN" in

  Arg.parse speclist (fun t -> token := t) usage;

  if String.is_empty !token then begin
    Arg.usage speclist usage;
    exit 2 >>> ignore
  end else
    Bot.start
      ~token:!token
      ~timeout:!timeout
      ~cpu_limit:!cpu_limit
      ~mem_limit:!mem_limit
      () >>> ignore

let _ =
  Scheduler.go_main ~main ()
