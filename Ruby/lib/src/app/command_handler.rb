module DiscordBot
  module CommandHandler
    def load_commands
      commands = []
      dirs =  Dir.entries($client.manager.commands_directory)
      dirs.each do |dir|
        next if dir == "." || dir == ".."
        Dir.entries("#{$client.manager.commands_directory}/#{dir}").each do |file|
          next if file == "." || file == ".."
          load "#{$client.manager.commands_directory}/#{dir}/#{file}"
          commands << File.basename(file, ".rb")
        end
      end
      commands
    end
    module_function :load_commands
  end
end
