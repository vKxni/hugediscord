<?php

namespace Bot;

use Bot\Config;
use Discord\Discord;
use Discord\WebSockets\Event;
use Discord\WebSockets\WebSocket;
use Illuminate\Support\Arr;

class Bot
{
	/**
	 * The Discord instance.
	 *
	 * @var Discord 
	 */
	protected $discord;

	/**
	 * The Discord WebSocket instance.
	 *
	 * @var WebSocket 
	 */
	protected $websocket;

	/**
	 * The list of commands.
	 *
	 * @var array 
	 */
	protected $commands = [];

	/**
	 * The config file.
	 *
	 * @var string
	 */
	protected $configfile;

	/**
	 * Constructs the bot instance.
	 *
	 * @param string $configfile 
	 * @return void 
	 */
	public function __construct($configfile)
	{
		$this->configfile = $configfile;
		$config = Config::getConfig($this->configfile);
		$this->discord = new Discord($config['email'], $config['password']);
		$this->websocket = new WebSocket($this->discord);	
	}

	/**
	 * Adds a command.
	 *
	 * @param string $command 
	 * @param string $class 
	 * @param integer $perms
	 * @param string $description 
	 * @param string $usage 
	 * @return void 
	 */
	public function addCommand($command, $class, $perms, $description, $usage)
	{
		$this->commands[$command] = [
			'perms' => $perms,
			'class' => $class,
			'description' => $description,
			'usage'	=> $usage
		];
	}

	/**
	 * Starts the bot.
	 *
	 * @return void 
	 */
	public function start()
	{
		set_error_handler(function ($errno, $errstr) {
			if (!(error_reporting() & $errno)) {
				return;
			}

			echo "[Error] {$errno} {$errstr}\r\n";
			throw new \Exception($errstr, $errno);
		}, E_ALL);

		foreach ($this->commands as $command => $data) {
			$this->websocket->on(Event::MESSAGE_CREATE, function ($message, $discord, $new) use ($command, $data) {
				$content = explode(' ', $message->content);

				$config = Config::getConfig($this->configfile);

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

		$this->websocket->on('ready', function ($discord) {
			$discord->updatePresence($this->websocket, 'DiscordPHP '.Discord::VERSION, false);
		});

		$this->websocket->on('error', function ($error, $ws) {
			echo "[Error] {$error}\r\n";
		});

		$this->websocket->on('close', function () {
			echo "[Close] WebSocket was closed.\r\n";
			die;
		});

		$this->websocket->run();
	}

	/**
	 * Returns the list of commands.
	 *
	 * @return array 
	 */
	public function getCommands()
	{
		return $this->commands;	
	}

	/**
	 * Returns the config file.
	 *
	 * @return string 
	 */
	public function getConfigFile()
	{
		return $this->configfile;
	}
}