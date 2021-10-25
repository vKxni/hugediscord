require "../gembot"

module Gembot
  module Plugins
    class Utilities < Gembot::Plugin
      description ":tools: various useful utilities"

      register_commands do
        command "ping", description: "replies with pong and the response time to process/send the message"
        on_message cmatching: "ping" do |c, m|
          m = c.reply(m, "pong!~~~")
          time = Time.utc_now - m.timestamp
          @bot.client.edit_message(m.channel_id, m.id, "pong!*~~~*\nsendtime: **#{time.total_milliseconds}ms**")
        end

        command "hcf", description: "kills the bot"
        on_message cmatching: "hcf" do |c, m|
          c.reply(m, ":octagonal_sign: and catch :fire:")
          abort("i done got killed")
        end

        command "about", description: "print out info about the bot"
        on_message cmatching: "about" do |c, m|
          c.reply(m, "Bot written by Erin/barzamin in Crystal, a compiled and typed Ruby spinoff.
I'm open source, you can find my code at <https://github.com/barzamin/gembot>!
Yes, the Crystal Gems pun was intentional.")
        end
      end
    end
  end
end
