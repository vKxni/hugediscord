import uri, tables, json, httpclient, websocket

type
  Dispatcher* = concept d
    d.dispatch(string, JsonNode)

const
  discordUserAgent* = "NimBot (1.0 https://github.com/hlaaftana/pkpsgpsg)"
  api* = "https://discordapp.com/api/v6/".parseUri()
  messageEvent* = "MESSAGE_CREATE"