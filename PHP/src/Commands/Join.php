<?php

namespace Bot\Commands;
if(isset($commandLoad) && $commandLoad == true){
	$bot->addCommand('join', \Bot\Commands\Join::class, 1, 'Joins the specified server.', '<invite>');
}
class Join
{
	/**
	 * Handles the message.
	 *
	 * @param Message $message 
	 * @param array $params
	 * @param Discord $discord 
	 * @param Config $config 
	 * @return void 
	 */
	public static function handleMessage($message, $params, $discord, $config)
	{
		if (preg_match('/https:\/\/discord.gg\/(.+)/', $params[1], $matches)) {
			$invite = $discord->acceptInvite($matches[1]);
			$message->reply("Joined server {$invite->guild->name}");
		}
	}
}