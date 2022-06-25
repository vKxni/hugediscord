library(discordr)
library(magrittr)
library(lubridate)
library(later)
library(jsonlite)

source(here::here("secrets.R")) # environment for bot token (secret)

bot <- DiscordrBot$new(token)

bot$register_event_handler("MESSAGE_CREATE", function(msg){
  message <- paste("Hi,", msg$author$username, "Simple reply to your message: '", 
                   msg$content, "' (from your favourite discord bot lol")
  send_message(message, msg$channel_id, bot)
})

bot$start() 
