<?php

namespace Bot\Commands;
if(isset($commandLoad) && $commandLoad == true){
	$bot->addCommand('eval', \Bot\Commands\Evalu::class, 2, 'Evaluates some code.', '<code>');
}
class Evalu
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
	public static function handleMessage($message, $params, $discord, $config, $bot)
	{
		if (!isset($params[1])) {
			return;
		}
		
		try {
			eval('$response = '.implode(' ', $params).';');

			if (is_string($response)) {
				$response = str_replace(DISCORD_TOKEN, 'TOKEN-HIDDEN', $response);
				$response = str_replace($config['password'], 'PASSWORD-HIDDEN', $response);
				$response = str_replace($config['sudo_pass'], 'SUDO-HIDDEN', $response);
			}

			$message->reply("`{$response}`");
		} catch (\Exception $e) {
			$message->reply("Eval failed. {$e->getMessage()}");
		}
	}
}