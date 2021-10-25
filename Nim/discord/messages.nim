import json, http, httpclient, uri, common, asyncdispatch

type
  MessageEvent* = distinct JsonNode

proc channelId*(msg: MessageEvent): string {.inline.} =
  JsonNode(msg)["channel_id"].getStr()

proc content*(msg: MessageEvent): string {.inline.} =
  JsonNode(msg)["content"].getStr()

proc sendMessage*(http: AsyncHttpClient, channelId: string, content: string, tts = false): auto =
  var payload = newJObject()
  payload["content"] = %content
  if tts: payload["tts"] = %true
  http.post(api / "channels" / channelId / "messages", payload)

proc sendFile*(http: AsyncHttpClient, channelId: string, data, filename: string, content = "", tts = false): auto =
  var multipart = newMultipartData()
  if content.len != 0:
    multipart.add("content", content)
  if tts:
    multipart.add("tts", "true")
  multipart.add("file", data, filename = filename)
  http.post($(api / "channels" / channelId / "messages"), multipart = multipart)

template reply*(http: AsyncHttpClient, msg: MessageEvent, content: string, tts = false): auto =
  http.sendMessage(msg.channelId, content, tts)

proc typing*(http: AsyncHttpClient, channelId: string) =
  discard waitFor(http.request($(api / "channels" / channelId / "typing"), HttpPost,
    when NimMajor <= 18: "{}" else: ""))

proc editMessage*(http: AsyncHttpClient, channelId, messageId: string, content: string, tts = false): auto =
  var payload = newJObject()
  payload["content"] = %content
  if tts: payload["tts"] = %true
  http.patch(api / "channels" / channelId / "messages" / messageId, payload)

proc deleteMessage*(http: AsyncHttpClient, channelId, messageId: string): auto =
  http.delete(api / "channels" / channelId / "messages" / messageId)

proc edit*(http: AsyncHttpClient, node: JsonNode, content: string, tts = false): auto =
  http.editMessage(node["channel_id"].getStr, node["id"].getStr, content, tts)