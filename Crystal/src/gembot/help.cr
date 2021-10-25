module Gembot
  class Help
    def self.generate_from(config : Config, plugins : Array(Plugin)) : String
      help = "**Gembot (v#{Gembot::VERSION}) help:**\n" \
        + plugins.map { |p| generate_plugin_help(config, p) }.join("\n")
    end

    def self.generate_plugin_help(config, plugin : Plugin) : String
      "⟹ #{plugin.class.name.split("::").last}: #{plugin.description}\n" \
        + plugin.commands.map { |n, o| "   » **#{config.prefix}#{n}** ➩ #{o[:description]}" }.join("\n") + "\n"
    end
  end
end
