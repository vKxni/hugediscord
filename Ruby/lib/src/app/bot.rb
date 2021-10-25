require_relative "app"

module DiscordBot
  class Client
    attr_reader :client
    attr_reader :data
    def initialize(token)
      Discordrb::Bot.attr_accessor :commands, :config, :manager
      @client = Discordrb::Bot.new(:token => token, :ignore_bots => true)
      @data = YAML.load(File.read("lib/src/private/data.yml"))
      @client.config = @data
      Thread.new do
        puts "Type '.exit' to exit"
        loop do
          next unless STDIN.gets.chomp == ".exit"
          exit
        end
      end
    end
  end
end