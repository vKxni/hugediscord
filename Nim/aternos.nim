import asyncdispatch, asyncnet, websocket, httpclient, uri, json, random

type Aternos* = ref object
  ws*: AsyncWebSocket
  cookie*: string
  http*: AsyncHttpClient
  lastStatus*: JsonNode
  queuePending*: bool
  queue*: string

proc newAternos*(session: string): Aternos =
  new(result)
  result.http = newAsyncHttpClient()
  result.cookie = "ATERNOS_LANGUAGE=en; snhbFromEEA=false; ATERNOS_SESSION=" & session
  result.http.headers = newHttpHeaders({
    "Cookie": result.cookie,
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:70.0) Gecko/20100101 Firefox/70.0"
  })

proc connect*(aternos: Aternos) {.async.} =
  const hermes = parseUri("wss://aternos.org.hermes")
  let h = newAsyncHttpClient()
  h.headers = aternos.http.headers
  aternos.ws = await newAsyncWebsocketClient(hermes, h)

proc disconnect*(aternos: Aternos) {.async.} =
  await aternos.ws.close()
  aternos.ws = nil

proc randomStr: string =
  result = "0000000000000000"
  for i in 0..rand(range[9..13]):
    result[i] = sample({'0'..'9', 'a'..'z'})

proc request*(aternos: Aternos, path: string, meth = HttpGet, body = "",
    query: seq[(string, string)] = @[]): Future[JsonNode] {.async.} =
  var query = query
  let
    key = randomStr()
    value = randomStr()
  query.add(("ASEC", key & ":" & value))
  var headers = newHttpHeaders()
  headers["Cookie"] = aternos.cookie & ";ATERNOS_SEC_" &
    key & "=" & value & ";path=/panel/ajax/" & path & ".php"
  let resp = await aternos.http.request(
    "https://aternos.org/panel/ajax/" & path & ".php?" & encodeQuery(query),
    meth, body, headers)
  let body = await resp.body
  if body.len != 0:
    result = parseJson(body)

proc checkForConfirm*(aternos: Aternos, status = aternos.lastStatus) {.async.} =
  echo "d"
  echo status
  echo "e"
  echo aternos.queuePending
  echo "f"
  if aternos.queuePending and status["class"].getStr == "queueing" and
    status["queue"]["pending"].getStr != "pending":
    echo "a"
    await sleepAsync(rand(range[500..1300]))
    echo "b"
    asyncCheck aternos.request("confirm")
    echo "c"
  aternos.queuePending = status.hasKey("queue") and
    status["queue"]["pending"].getStr == "pending"

proc loop*(aternos: Aternos) {.async.} =
  while not aternos.ws.sock.isClosed:
    try:
      let (opcode, data) = await aternos.ws.readData()
      if opcode == Opcode.Text:
        let j = parseJson(data)
        case j["type"].getStr
        of "status":
          aternos.lastStatus = j["message"].getStr.parseJson
          await aternos.checkForConfirm()
        of "queue_reduced":
          aternos.queue = j["message"].getStr.parseJson()["total"].getStr
    except IOError:
      return