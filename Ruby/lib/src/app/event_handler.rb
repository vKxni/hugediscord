require_relative "app"

module DiscordBot
  module EventHandler
    def load_events
      events = []
      dir = Dir.entries($client.manager.events_directory)
      dir.each do |file|
        next if file == "." || file == ".."
        load "#{$client.manager.events_directory}/#{file}"
        events << File.basename(file, ".rb")
      end
      events
    end


    module_function :load_events
  end
end
