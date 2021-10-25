require_relative "app"

module DiscordBot::Utils
  def is_authorized?(id)
    $client.config[:authorized].include?(id.to_i)
  end

  def build_embed(e = Discordrb::Webhooks::Embed.new)
    e.title = $client.bot_app.name
    e.timestamp = Time.at(Time.now.to_i)
    e
  end

  def add_fields(e = Discordrb::Webhooks::Embed.new, fields, inline)
    if fields.respond_to?(:each)
      fields.each do |field|
        e.add_field(name: field[:name], value: field[:value], inline: (!!inline) )
        e
      end
    else false end
  end

  def get_command(command_name, props = { :boolean => false })
    if props[:boolean]
      return true if DiscordBot::Commands.respond_to?(command_name)
      return false unless DiscordBot::Commands.respond_to?(command_name)
    else
      if DiscordBot::Commands.respond_to?(command_name)
        DiscordBot::Commands.method(command_name).call
      else false end
    end
  end

  alias is_owner? is_authorized?
  alias find_command get_command
  module_function :is_authorized?, :is_owner?, :build_embed, :get_command, :find_command, :add_fields
end
