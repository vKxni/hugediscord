<?php

namespace Bot\Commands;
if(isset($commandLoad) && $commandLoad == true){
	$bot->addCommand('restart', \Bot\Commands\Restart::class, 2, 'Restarts the bot.', '');
}

class Restart
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
		$message->channel->sendMessage('Bot is restarting...');

		exec("bash ./sv_restart.sh");
	}
}
