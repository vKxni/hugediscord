package science.wasabi.tini.bot.discord.wrapper

object DiscordWrapperConverter {
  object AkkaCordConverter {
    import net.katsstuff.akkacord.data.{Message => AkkaCordMessage}
    implicit def convertMessage(message: AkkaCordMessage): DiscordMessage = DiscordMessage(
      message.id.toString,
      message.channelId.toString,
      User(""), // TODO: proper handling of this stuff
      message.content,
      message.timestamp.toString,
      message.editedTimestamp.map(_.toString),
      message.tts,
      message.mentionEveryone,
      pinned = message.pinned
    )
  }
}
