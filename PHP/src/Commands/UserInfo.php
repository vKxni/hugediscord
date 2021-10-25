<?php

namespace Bot\Commands;
if(isset($commandLoad) && $commandLoad == true){
	$bot->addCommand('userinfo', \Bot\Commands\UserInfo::class, 1, 'Shows information about yourself or the specified user.', '[user]');
}
use Discord\Helpers\Guzzle;
use Discord\Parts\User\User;

class UserInfo
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
		$id = (isset($params[1])) ? $params[1] : $message->author->id;

		if (preg_match('/<@(.+)>/', $id, $matches)) {
			$id = $matches[1];
		}

		$user = new User((array) Guzzle::get("users/{$id}"), true);

		$str  = "**{$user->username}:**\r\n";
		$str .= "**ID:** {$user->id}\r\n";
		$str .= "**Avatar URL:** {$user->avatar}\r\n";
		$str .= "**Discriminator:** {$user->discriminator}\r\n";
		$str .= "**Mention:** `{$user}`\r\n";

		$guildcount = 0;
		$servers = '';

		foreach ($discord->guilds as $guild) {
			foreach ($guild->members as $member) {
				if ($member->id == $user->id) {
					$guildcount++;
					$servers .= $guild->name . ", ";
				}
			}
		}

		$servers = rtrim($servers, ', ');

		$str .= "**Shared Servers:** {$guildcount} _({$servers})_\r\n";

		$level = (isset($config['perms']['perms'][$user->id])) ? $config['perms']['perms'][$user->id] : $config['perms']['default'];
		$level = $config['perms']['levels'][$level];
		
		$str .= "**User Level:** {$level}\r\n";

		$message->channel->sendMessage($str);
	}
}