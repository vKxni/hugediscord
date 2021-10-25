import 'package:nyxx/nyxx.dart';
// ignore: library_prefixes
import 'package:discord_bot/guildPrefix.dart' as guildPrefix;

void ping() {
  // ignore: avoid_single_cascade_in_expression_statements
  guildPrefix.commander
    ..registerCommand('ping', (context, message) {
      context.reply(MessageBuilder.content('Pong!'));
    });
}
