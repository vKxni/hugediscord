require_relative "app/app"
require_relative "app/utils"

begin
  $client.run
rescue DiscordBot::DiscordBotError => e
  DiscordBot::CONSOLE_LOGGER.error(e.message)
end