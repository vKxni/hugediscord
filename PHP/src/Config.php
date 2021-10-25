<?php

namespace Bot;

class Config
{
	/**
	 * Gets the config file.
	 *
	 * @param string $filename 
	 * @return array 
	 */
	public static function getConfig($filename = 'config.json')
	{
		$file = file_get_contents($filename);
		$arr = json_decode($file, true);
		$arr['filename'] = $filename;

		return $arr;
	}

	/**
	 * Saves the config file.
	 *
	 * @param array $config 
	 * @param string $filename
	 * @return array 
	 */
	public static function saveConfig($config, $filename = 'config.json')
	{
		unset($config['filename']);
		$json = json_encode($config);
		
		file_put_contents($filename, $json);

		return $json;
	}
}