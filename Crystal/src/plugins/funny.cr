module Gembot
  module Plugins
    class Huehuehue < Gembot::Plugin
      description ":rofl: random amusing stuff"

      register_commands do
        command "karkat", description: "deliver a Karkat-style insult"
        on_message cmatching: "karkat" do |c, m|
          c.reply(m, Gembot::LanguageUtilities.swear_karkat().upcase)
        end
      end
    end
  end
end
