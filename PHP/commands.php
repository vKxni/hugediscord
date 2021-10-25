<?php

// HELP COMMAND
function helpHandler($message, $discord, $commands)
{
	$str = "**Commands:**";
	foreach ($commands as $command => $class) {
		$str .= "{$command}, ";
	}
	$str = substr($str, -2);
}