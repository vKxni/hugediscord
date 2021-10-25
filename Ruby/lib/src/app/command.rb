module DiscordBot
  class Command
    attr_reader :run
    attr_accessor :props

    def initialize(props, &run)
      @props, @run = props, run
      @props = load_attributes
      {
        :props => load_attributes,
        :run => @run
      }
    end

    private def load_attributes
      Command.attr_accessor :name, :aliases, :description, :args, :use_example, :required_permissions, :required_bot_permissions, :category
      if @props[:name] then @name = @props[:name] end

      @props[:aliases] ||= :default
      if @props[:aliases]
        if @props[:aliases].class == Array or @props[:aliases].class == String
          @aliases = @props[:aliases]
        elsif @aliases == :default
          @aliases = []
        else
          @aliases = []
        end
      end
      if @props[:description] then @description = @props[:description].to_s end
      if @props[:args] then @args = @props[:args].to_a end
      if @props[:use_example] then @use_example = @props[:use_example] end

      if @props[:required_permissions] == :default
        @required_permissions = []
      else
        if @props[:required_permissions].respond_to?(:to_a)
          @required_permissions = @props[:required_permissions].to_a
        else @required_permissions = []
        end
      end

      @required_bot_permissions ||= []
      @props[:required_bot_permissions] = [] unless @props[:required_bot_permissions].class == Array
      if @props[:required_bot_permissions] == :default or !@props[:required_bot_permissions] or @props[:required_bot_permissions].empty?

        @required_bot_permissions.push(
          :add_reactions,
          :send_messages,
          :embed_links,
          :attach_files,
          :use_external_emoji
        )
      else
        if @props[:required_bot_permissions].respond_to?(:to_a)
          @required_bot_permissions = @props[:required_bot_permissions].to_a
        else @required_bot_permissions = []
        end
      end

      if @props[:category] then @category = @props[:category] end

      if @use_example == :default then @use_example = "#{$client.config[:prefix]}#{@name}" end
      if @required_permissions == :default then @required_permissions = [] end

      if @category == :default or !@category
        Dir.entries($client.manager.commands_directory).each do |dir|
          next if dir == "." || dir == ".."
          if Dir.entries("#{$client.manager.commands_directory}/#{dir}").include?("#{@name}.rb")
            @category = dir.upcase
            break
          end
        end
      end
      Hash[
        :name => @name,
        :aliases => @aliases,
        :description => @description,
        :args => @args,
        :required_permissions => @required_permissions,
        :required_bot_permissions => @required_bot_permissions,
        :use_example => @use_example,
        :category => @category
      ]
    end
  end
end
