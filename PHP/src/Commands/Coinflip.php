<?php

namespace Bot\Commands;
if(isset($commandLoad) && $commandLoad == true){
	$bot->addCommand('coinflip',\Bot\Commands\Coinflip::class, 1, 'Does a coinflip.', '');
}
class Coinflip
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
		$sides = ['Heads', 'Tails'];

		$message->reply($sides[array_rand($sides)]);
	}
}