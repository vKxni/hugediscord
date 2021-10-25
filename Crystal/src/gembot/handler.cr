module Gembot
  alias EventData = Discord::Message

  class Handler
    alias HandlerCallback = Proc(RClient, EventData, Nil)
    getter etype
    getter callback
    getter allow_pm

    @allow_pm = false

    def initialize(@etype : Symbol, @condition : Regex?, @callback : HandlerCallback)
    end

    def initialize(@etype : Symbol, @callback : HandlerCallback)
    end

    def triggered?(edat : EventData)
      case edat
      when Discord::Message
        return !(edat.content =~ @condition).nil?
      end
    end
  end
end
