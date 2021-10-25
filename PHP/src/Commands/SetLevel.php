<?php

namespace Bot\Commands;
if(isset($commandLoad) && $commandLoad == true){
	$bot->addCommand('setlevel', \Bot\Commands\SetLevel::class, 2, 'Sets the auth level of a user.', '<user> [level=2]');
}
use Bot\Config;

class SetLevel
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
		if (isset($params[1])) {
			$user = $params[1];
			$level = (isset($params[2])) ? $params[2] : 2;

			if (preg_match('/<@([0-9]+)>/', $user, $matches)) {
				$user = $matches[1];
			}

			$config['perms']['perms'][$user] = $level;

			Config::saveConfig($config);

			$message->reply("Set user <@{$user}> auth level to {$config['perms']['levels'][$level]}");
		}
	}
}