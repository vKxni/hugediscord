import std.stdio;
import 	dscord.core,
       	dscord.util.process,
		dscord.util.emitter;
import vibe.data.serialization;
import vibe.data.sdl;
import sdlang.parser;
import vibe.core.core;
import plugins;
import fio = std.file;

struct RoleMgmtConfig {
    long[] adminRoles;

	@optional
    long[] allowedRoles;

	@optional
	long botChannel;
}

struct Config {
	string token;

	@optional
	string prefix = "!";

	@optional
	bool reqMention = false;

	@optional
	RoleMgmtConfig roles;

	void save() {
		fio.write("config.sdl", serializeSDLang!Config(this).toSDLDocument());
	}
}
__gshared static Config CONFIG;

void main()
{
	// Whenever the bot closes, save stuff.
	scope(exit) CONFIG.save();

	// Show memory exceptions on Linux.
	static if (is(typeof(registerMemoryErrorHandler)))
		registerMemoryErrorHandler();
	
	CONFIG = deserializeSDLang!Config(parseFile("config.sdl"));

	BotConfig cfg;
	cfg.token = CONFIG.token;
	cfg.cmdPrefix = CONFIG.prefix;
	cfg.features = BotFeatures.COMMANDS;
	cfg.levelsEnabled = false;
	cfg.cmdRequireMention = CONFIG.reqMention;

	Bot bot = new Bot(cfg, LogLevel.trace);

	bot.loadPlugin(new RolePlugin);
	
	bot.run();
	runEventLoop();
	return;
}
