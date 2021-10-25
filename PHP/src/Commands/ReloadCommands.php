<?php

namespace Bot\Commands;
if(isset($commandLoad) && $commandLoad == true){
	$bot->addCommand('reload',\Bot\Commands\Reload::class,2,'Reloads all commands','');
}

class Reload
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
		$loadedComms = count($discord->websocket->listeners(Event::MESSAGE_CREATE));
		$message->channel->sendMessage('-'.count($loadedComms).' COMMANDS BEFORE RELOAD -');
		$message->channel->sendMessage('Reloading all commands from disk...');
		
		$discord->websocket->removeAllListeners(Event::MESSAGE_CREATE);
		$commandResearch = glob('./src/Commands/*.php');
		$commandLoad = true;
		foreach($commandResearch as $file){
			include($file);
		}
		$currCommands = getCommands();
		foreach ($currCommands as $command => $data) {
			$discord->websocket->on(Event::MESSAGE_CREATE, function ($message, $discord, $new) use ($command, $data) {
				$content = explode(' ', $message->content);
				$config = Config::getConfig($discord->configfile);
				if ($content[0] == $config['prefix'] . $command) {
					Arr::forget($content, 0);
					$user_perms = @$config['perms']['perms'][$message->author->id];
					if (empty($user_perms)) {
						$user_perms = $config['perms']['default'];
					}
					if ($user_perms >= $data['perms']) {
						try {
							$data['class']::handleMessage($message, $content, $discord, $config, $this);
						} catch (\Exception $e) {
							$message->reply("There was an error running the command. `{$e->getMessage()}`");
						}
					} else {
						$message->reply('You do not have permission to do this!');
						echo "[Auth] User {$message->author->username} blocked from running {$config['prefix']}{$command}, <@{$message->author->id}>\r\n";
					}
				}
			});
		}
		$loadedComms = count($discord->websocket->listeners(Event::MESSAGE_CREATE));
		$message->channel->sendMessage('-'.count($loadedComms).' COMMANDS AFTER RELOAD -');
	}
}