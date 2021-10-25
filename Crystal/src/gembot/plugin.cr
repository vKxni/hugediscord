module Gembot
  class Plugin
    include Helpers

    classvar_getter description
    classvar_getter commands
    classvar_getter handlers

    @@description = uninitialized String
    @@commands = {} of String => Hash(Symbol, String)
    @@handlers = [] of Gembot::Handler

    macro description(value)
      @@description = {{value}}
    end

    def initialize(@bot : Gembot::Bot)
    end

    def regis
    end

    macro register_commands(&block)
      def regis
        super
        {{with self yield}} # set up hook descriptors and callbacks
      end
    end

    def on_message(matching : Regex, &block : Gembot::RClient, Discord::Message -> Nil)
      @@handlers << Gembot::Handler.new(:message, matching, block)
    end

    def on_message(cmatching : String, &block : Gembot::RClient, Discord::Message -> Nil)
      matchrx = "^\\#{@bot.config.prefix}#{cmatching}"

      @@handlers << Gembot::Handler.new(:message, /#{matchrx}/i, block)
    end

    def command(cmd, description)
      @@commands[cmd] = {:description => description}
    end
  end
end
