<?php

namespace Bot\Commands;
if(isset($commandLoad) && $commandLoad == true){
	$bot->addCommand('meme', \Bot\Commands\Meme::class, 1, 'dank memes', '');
}
class Meme
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
		$memes = json_decode(file_get_contents('./command_files/dank_memes.json'),true);
		
		$message->reply($memes[array_rand($memes)]);
		//$message->reply("Did I ever tell you what the definition of insanity is? Insanity is doing the exact... same fucking thing... over and over again expecting... shit to change... That. Is. Crazy. The first time somebody told me that, I dunno, I thought they were bullshitting me, so, I shot him. The thing is... He was right. And then I started seeing, everywhere I looked, everywhere I looked all these fucking pricks, everywhere I looked, doing the exact same fucking thing... over and over and over and over again thinking 'this time is gonna be different' no, no, no please... ");
	}
}
