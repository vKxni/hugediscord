require "discordrb"
require "json"
require "yaml"
require_relative "bot"
require_relative "logger"
require_relative "error"
require_relative "command_handler"
require_relative "event_handler"
require_relative "command"
require_relative "manager"

module DiscordBot
  include Discordrb
  include JSON
  include YAML
  CONSOLE_LOGGER = Logger.new(:console)
  FILE_LOGGER = Logger.new(:file)
end


$discord_bot = DiscordBot::Client.new(YAML.load(File.read("lib/src/private/data.yml"))[:token])
$client = $discord_bot.client

$client.manager = DiscordBot::Manager.new({
                                           :commands_directory => "tests/commands",
                                           :events_directory => "tests/events"
                                         })
$client.manager.load