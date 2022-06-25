library(discordr)
library(magrittr)
library(lubridate)
library(later)
library(jsonlite)

source(here::here("secrets.R")) # environment for bot token (secret)

BOT_CHANNEL_ID = "server-channel-id"

bot <- DiscordrBot$new(token)

bot$register_event_handler("MESSAGE_CREATE", function(msg){
  # avoid handling your own messages
  if (msg$author$id == "your-discord-id"){
    return()
  }
  # guard to work only in test channel
  if (msg$channel_id != BOT_CHANNEL_ID){
    return()
  }
  message <- paste("Hi,", msg$author$username, "Simple reply to your message: '", 
                   msg$content, "' (from your favourite discord bot")
  send_message(message, msg$channel_id, bot)
})

bot$start() 
