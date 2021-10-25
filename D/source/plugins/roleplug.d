module plugins.roleplug;
import 	dscord.core,
       	dscord.util.process,
		dscord.util.emitter,
        dscord.types,
        std.conv,
        app,
        std.algorithm.searching,
        std.stdio,
        std.format,
        std.uni : isNumber, toLower;


enum UsageHelp = "```
%srole/pronoun/neuro name (name...)     - Set cosmetic roles for pronouns and neurodiverse traits.
%slistroles                             - List the available roles
```";

class RolePlugin : Plugin {

    this() {
        super();
    }

    @Command("rolehelp")
    void onRoleHelp(CommandEvent event) {
        if (!enforceBotChannel(event)) return;
        event.msg.reply(UsageHelp.format(CONFIG.prefix, CONFIG.prefix));
    }

    @Command("listroles")
    void onList(CommandEvent event) {
        if (!enforceBotChannel(event)) return;
        int index = 1;
        string roles;

        Guild guild = event.msg.guild();
        foreach(key, role; guild.roles) {

            if (!CONFIG.roles.allowedRoles.canFind(cast(long)key)) continue;

            roles ~= "%d - %s\n".format(index, role.name);
            index++;
        }
        event.msg.replyf("```\n%s\n```", roles);
    }

    @Command("role", "pronoun", "pronouns", "neurodiverse", "neuro")
    void onRole(CommandEvent event) {

        if (!enforceBotChannel(event)) return;

        Guild guild = event.msg.guild();
        foreach(item; event.args) {
            bool foundRole = false;
            foreach(key, role; guild.roles) {
                if (role.name.toLower == item.toLower) {
                    if (!CONFIG.roles.allowedRoles.canFind(role.id)) {
                        event.msg.replyf("I'm sorry %s, I'm afraid I can't do that.", event.msg.author.username);
                        return;
                    }        
            
                    GuildMember member = guild.getMember(event.msg.author);
                    member.addRole(role);
                    foundRole = true;
                }
            }

            if (!foundRole) {
                event.msg.replyf("Sorry %s, I could not find the role %s!", event.msg.author.username, item);
                return;
            }
        }
        
    }

    @Command("allowrole")
    void onAllowRole(CommandEvent event) {
        if (!enforceBotChannel(event)) return;

        // If user isn't admin, return immidiately.
        if (!enforceAdmin(event)) return;

        Guild guild = event.msg.guild();
        foreach(key, role; guild.roles) {
            if (role.name.toLower == event.contents.toLower || (isSnowflakeable(event.contents) && key == event.contents.to!Snowflake)) {
                CONFIG.roles.allowedRoles ~= key;
                CONFIG.save();
                return;
            }
        }

        event.msg.replyf("Sorry %s, I could not find the role %s!", event.msg.author.username, event.contents);
    }

    bool isSnowflakeable(string value) {
        foreach(c; value) {
            if (!isNumber(c)) return false;
        }
        return true;
    }

    bool enforceAdmin(CommandEvent event) {
        if (!isAdmin(event)) {
            event.msg.replyf("I'm sorry %s, I'm afraid I can't do that.", event.msg.author.username);
            return false;
        }
        return true;
    }

    bool isAdmin(CommandEvent event) {
        Guild guild = event.msg.guild();
        GuildMember member = guild.getMember(event.msg.author);
        foreach(adminRole; CONFIG.roles.adminRoles) {
            if (member.hasRole(adminRole)) return true;
        }
        return false;
    }

    bool enforceBotChannel(CommandEvent event) {
        if (event.msg.channelID != CONFIG.roles.botChannel) return false;
        return true;
    }

}
