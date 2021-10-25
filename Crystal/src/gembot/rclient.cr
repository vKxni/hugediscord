module Gembot
    class RClient
    def initialize(@client : Discord::Client, @cache : Discord::Cache)
    end

    def reply(to : Discord::Message, text)
      @client.create_message(to.channel_id, text)
    end

    def reply!(to : Discord::Message, text)
      @client.create_message(to.channel_id, mention(to.author) + ": " + text)
    end

    def dm(to : Discord::User, text)
      @client.create_message(@client.create_dm(to.id).id, text)
    end

    def create_role(guild : Discord::Guild, name : String?)
      role = @client.create_guild_role(guild.id)
      unless name.nil?
        role.name = name
        update_role(guild, role)
      end
      role
    end

    def get_role(guild : Discord::Guild, name : String)
      role = get_roles(guild).find {|r| r.name == name}
    end

    def get_roles(guild : Discord::Guild)
      @cache.guild_roles(guild.id).map {|r| @cache.resolve_role(r)}
    end

    def update_role(guild : Discord::Guild, role : Discord::Role)
      @client.modify_guild_role(guild.id, role.id, role.name, role.permissions, role.colour, role.position, role.hoist)
    end

    def fetch_or_create_role(guild : Discord::Guild, name : String)
      role = get_role(guild, name: name)
      if role.nil?
        role = create_role(guild, name)
      end
      role
    end

    def role_add_user(guild : Discord::Guild, role : Discord::Role, user : Discord::User)
      member = get_member(guild, user)
      @client.modify_guild_member(guild.id, user.id,
            nick: nil, roles: member.roles | [role.id], mute: nil, deaf: nil, channel_id: nil)
    end

    def guild_id_of(m : Discord::Message)
      @cache.resolve_channel(m.channel_id).guild_id
    end

    def guild_of(m : Discord::Message)
      @cache.resolve_guild(guild_id_of(m).not_nil!)
    end

    def get_member(guild : Discord::Guild, user : Discord::User)
      @cache.resolve_member(guild.id, user.id)
    end

    def mention(user : Discord::User)
      "<@#{user.id}>"
    end
  end
end