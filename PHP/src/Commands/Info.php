<?php

namespace Bot\Commands;
if(isset($commandLoad) && $commandLoad == true){
	$bot->addCommand('info', \Bot\Commands\Info::class, 1, 'Shows information about the bot.', '');
}
use Carbon\Carbon;
use Discord\Discord;

class Info
{
	/**
	 * Handles the message.
	 *
	 * @param Message $message 
	 * @param array $params
	 * @param Discord $discord 
	 * @param Config $config 
	 * @param Bot $bot 
	 * @return void 
	 */
	public static function handleMessage($message, $params, $discord, $config)
	{
		$str  = "**DiscordPHP Bot**\r\n";
		$str .= "**Library:** _DiscordPHP_ ".Discord::VERSION."\r\n";

		$sha = substr(exec('git rev-parse HEAD'), 0, 7);

		$str .= "**Current Revision:** `{$sha}`\r\n";
		$str .= "**PHP Version:** ".PHP_VERSION."\r\n";

		$uptime = Carbon::createFromTimestamp(DISCORDPHP_STARTTIME);
		$diff = $uptime->diff(Carbon::now());

		$str .= "**Uptime:** {$diff->d} day(s), {$diff->h} hour(s), {$diff->i} minute(s), {$diff->s} second(s)\r\n";

		$ram  = round(memory_get_usage(true)/1000000, 2);
		
		$str .= "**Memory Usage:** {$ram}mb\r\n";

		$str .= "**OS Info:** ".php_uname()."\r\n";

		$str .= "**Source:** https://github.com/uniquoooo/DiscordPHPBot\r\n";

		$str .= "\r\n**Author:** Uniquoooo `<@78703938047582208>`\r\n";
		$str .= "**Server Count:** {$discord->guilds->count()}\r\n";

		$message->reply($str);	
	}
}