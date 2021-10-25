import strutils

type
  Arguments* = object
    all*: string
    index*: int

proc newArguments*(str: string): Arguments =
  result.all = str
  result.index = 0

proc rest*(arguments: Arguments): string =
  if arguments.index >= arguments.all.len:
    result = ""
  else:
    result = arguments.all[arguments.index .. ^1]

proc next*(arguments: var Arguments): string =
  if arguments.index >= arguments.all.len:
    return ""

  result = ""
  var
    currentQuote = '\0'
    escaped = false
  while arguments.index < arguments.all.len:
    let ch = arguments.all[arguments.index]
    inc arguments.index
    if not escaped and currentQuote != '\0' and ch == currentQuote:
      currentQuote = '\0'
      break
    elif not escaped and ch in {'"', '\''}:
      currentQuote = ch
    elif currentQuote == '\0' and ch in Whitespace:
      if result.len != 0: break
    else:
      escaped = not escaped and ch == '\\'
      if not escaped: result.add(ch)
  if result.len == 0:
    result = arguments.next

proc goBack*(arguments: var Arguments, i: int) =
  arguments.index -= i

proc goBack*(arguments: var Arguments, str: string) =
  arguments.all.add(str)
  arguments.index -= str.len

proc hasNext*(arguments: Arguments): bool =
  arguments.index < arguments.all.len

proc splitArgs*(arguments: string, keepQuotes = false): seq[string] =
  result = @[""]
  var
    currentQuote = '\0'
    escaped = false
  for ch in arguments:
    if currentQuote != '\0':
      if not escaped and ch == currentQuote:
        currentQuote = '\0'
        if keepQuotes:
          result[^1].add(ch)
      else:
        escaped = not escaped and ch == '\\'
        if not escaped: result[^1].add(ch)
    elif not escaped and ch in {'"', '\''}:
      currentQuote = ch
      if keepQuotes: result[^1].add(ch)
    else:
      escaped = not escaped and ch == '\\'
      if not escaped:
        if ch in Whitespace:
          result.add("")
        else:
          result[^1].add(ch)

proc splitArgs*(arguments: string, max: int, keepQuotes = false): seq[string] =
  result.newSeq(max)
  var
    i = 0
    currentQuote = '\0'
    escaped = false
  result[i] = ""
  for ch in arguments:
    if i == max - 1:
      result[i].add(ch)
    elif currentQuote != '\0':
      if not escaped and ch == currentQuote:
        currentQuote = '\0'
        if keepQuotes:
          result[i].add(ch)
      else:
        escaped = not escaped and ch == '\\'
        if not escaped: result[i].add(ch)
    elif not escaped and ch in {'"', '\''}:
      currentQuote = ch
      if keepQuotes: result[i].add(ch)
    else:
      escaped = not escaped and ch == '\\'
      if not escaped:
        if ch in Whitespace:
          inc i
          result[i] = ""
        else:
          result[i].add(ch)