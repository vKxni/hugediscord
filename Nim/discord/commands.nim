import messages, json, strutils

type
  CommandProc*[T] = proc(cachedContent: string, args: string, obj: MessageEvent): T

  Command* = object
    prefix*, info*: string
    callback*: CommandProc[void]

  CommandHandler* = object
    commands*: seq[Command]
    allowMultiple*: bool
    prefixes*: seq[string]
    predicate*: CommandProc[bool]
    noMatch*: CommandProc[void]

proc handleCommand*(hndl: CommandHandler, msg: MessageEvent) =
  var matched: bool
  let cont = msg.content
  var curr = cont
  let hf = hndl.predicate
  if not hf.isNil and not hf(cont, curr, msg):
    return
  var success = false
  for hp in hndl.prefixes:
    if curr.startsWith(hp):
      curr.removePrefix(hp)
      success = true
      break
  if not success:
    return
  for cmd in hndl.commands:
    let p = cmd.prefix
    if curr.startsWith(p):
      var args = curr
      args.removePrefix(p)
      let ended = args.len == 0
      if ended or args[0] in Whitespace:
        matched = true
        if not ended:
          args = args.strip(trailing = false)
        cmd.callback(cont, args, msg)
        if not hndl.allowMultiple:
          return
  if not matched and not hndl.noMatch.isNil:
    hndl.noMatch(cont, curr, msg)