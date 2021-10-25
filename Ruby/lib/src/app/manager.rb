module DiscordBot
  class Manager
    attr_accessor :commands_directory, :events_directory
    def initialize(dirs = {
          :commands_directory => "",
          :events_directory => ""
        })
      @commands_directory, @events_directory = dirs[:commands_directory], dirs[:events_directory]
    end
    def load
      puts "Loading.."
      $client.commands = DiscordBot::CommandHandler.load_commands
      events = DiscordBot::EventHandler.load_events

      events.each do |evt|
        DiscordBot::Events.method(evt).call
      end
      puts "Loaded!"
    end
  end
end
