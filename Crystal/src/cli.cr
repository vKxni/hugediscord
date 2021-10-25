require "./gembot"
require "./plugins/*"
require "dotenv"

Dotenv.load
config = Gembot::Config.from_yaml(File.read("./config.yml"))
config.token = ENV["TOKEN"]
config.client_id = ENV["CLIENT_ID"].to_u64

bot = Gembot::Bot.new(config)
bot.plugins << Gembot::Plugins::Utilities.new(bot)
bot.plugins << Gembot::Plugins::Giveme.new(bot)
bot.plugins << Gembot::Plugins::Huehuehue.new(bot)
bot.load_plugins!
bot.run!
