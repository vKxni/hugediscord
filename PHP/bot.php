<?php

define('DISCORDPHP_STARTTIME', microtime(true));

use Bot\Bot;
use Bot\Config;
use Discord\Discord;

include 'vendor/autoload.php';

$opts = getopt('', ['config::']);
$configfile = (isset($opts['config'])) ? $opts['config'] : $_SERVER['PWD'] . '/config.json';

echo "DiscordPHPBot\r\n";
echo "Loading config file from {$configfile}\r\n";

try {
	echo "Initilizing the bot...\r\n";
	$bot = new Bot($configfile);
	echo "Initilized bot.\r\n";
} catch (\Exception $e) {
	echo "Could not initilize bot. {$e->getMessage()}\r\n";
	die(1);
}

try {
	echo "Loading commands...\r\n";

	$commandResearch = glob('./src/Commands/*.php');
	$commandLoad = true;
	foreach($commandResearch as $file){
		include($file);
	}
	
	echo "Loaded commands.\r\n";
} catch (\Exception $e) {
	echo "Could not load commands. {$e->getMessage()}\r\n";
	die(1);
}

try {
	echo "Starting the bot...\r\n";
	$bot->start();
} catch (\Exception $e) {
	echo "Error while running or starting the bot. {$e->getMessage()}\r\n";
	die(1);
}