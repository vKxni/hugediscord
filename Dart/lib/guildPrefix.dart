import 'dart:async';

import 'package:nyxx/nyxx.dart';
import 'package:nyxx_commander/commander.dart';
// ignore: library_prefixes
import 'package:discord_bot/private/token.dart' as tokenBot;

final prefixes = <Snowflake, String>{};
const defaultPrefix = 'dart!';
final bot = Nyxx(tokenBot.token(), GatewayIntents.none);
var commander = Commander(bot, prefixHandler: prefixHandler);

FutureOr<String?> prefixHandler(Message message) {
  if (message is DMMessage) {
    return defaultPrefix;
  }

  final guildMessage = message as GuildMessage;
  final prefixForGuild = prefixes[guildMessage.guild.id];

  return prefixForGuild ?? defaultPrefix;
}

void guild() {
  // ignore: avoid_single_cascade_in_expression_statements
  commander
    ..registerCommand('setPrefix', (context, message) {
      if (context.guild == null) {
        context.reply(MessageBuilder.content('Cannot set prefix in DMs'));
        return;
      }

      final args = context.getArguments();

      if (args.isEmpty) {
        // ignore: prefer_single_quotes
        context.reply(MessageBuilder.content("""
        ```
*Command*: setPrefix
*Usage*: dart!setPrefix <newPrefix>
        ```
        """));
        return;
      }

      prefixes[context.guild!.id] = args.first;

      context.reply(MessageBuilder.content(
          'Prefix set to `${args.first}` successfully!'));
    });
}
