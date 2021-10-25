<?php

namespace Bot\Commands;
if(isset($commandLoad) && $commandLoad == true){
	$bot->addCommand('8ball', \Bot\Commands\Eightball::class, 1, 'Magic 8 Ball!', '');
}

class Eightball
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
		$choices = [
			'It is certain',
			'It is decidedly so',
			'Without a doubt',
			'Yes, definitely',
			'You may rely on it',
			'As I see it, yes',
			'Most likely',
			'Outlook good',
			'Yes',
			'Signs point to yes',
			'Reply hazy try again',
			'Ask again later',
			'Better not tell you now',
			'Cannot predict now',
			'Concentrate and ask again',
			'Don\'t count on it',
			'My reply is no',
			'My sources say no',
			'Outlook not so good',
			'Very doubtful',
		];

		$message->reply($choices[array_rand($choices)]);
	}
}