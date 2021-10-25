import websocket, httpclient, common, http, ws, asyncdispatch, json, tables, uri

type DiscordInstance* = object
  ws*: AsyncWebSocket
  http*: AsyncHttpClient
  gateway*: string
  lastSeq*: ref int

proc init*(dispatcher: Dispatcher, token: string, instance: var DiscordInstance) {.gcsafe.} =
  if instance.http.isNil:
    instance.http = newAsyncHttpClient(discordUserAgent)
  if instance.http.headers.isNil:
    instance.http.headers = newHttpHeaders({"Authorization": "Bot " & token})
  elif not instance.http.headers.hasKey("Authorization"):
    instance.http.headers.add("Authorization", "Bot " & token)
  if instance.ws.isNil:
    if instance.gateway.len == 0:
      let x = instance.http.get(api / "gateway")["url"].getStr()
      echo x
      instance.gateway = x.parseUri().hostname
    instance.ws = waitFor newAsyncWebsocketClient("wss://" & instance.gateway & ":443/?encoding=" & (when defined(etf): "etf" else: "json") & "&v=6")
  if instance.lastSeq.isNil:
    instance.lastSeq.new()
  asyncCheck read(dispatcher, instance.ws, token, instance.lastSeq)

type
  Listener* = proc(node: JsonNode): void
  ListenerDispatcher* = object
    listeners*: Table[string, seq[Listener]]
  UnifiedDispatcher*[T: proc(event: string, node: JsonNode)] = object
    hook*: T

proc init*(dispatcher: var ListenerDispatcher) =
  dispatcher.listeners = initTable[string, seq[Listener]](4)

proc addListener*(dispatcher: var ListenerDispatcher, event: string, listener: Listener) =
  dispatcher.listeners.mgetOrPut(event, @[]).add(listener)

proc dispatch*(dispatcher: ListenerDispatcher, event: string, node: JsonNode) =
  if dispatcher.listeners.hasKey(event):
    for listener in dispatcher.listeners[event]:
      listener(node)

proc dispatch*[T](dispatcher: UnifiedDispatcher[T], event: string, node: JsonNode) =
  if not dispatcher.hook.isNil:
    dispatcher.hook(event, node)