package science.wasabi.tini.bot.discord.wrapper

trait DiscordObject {
  type Snowflake = String
  type Timestamp = String

  type User = DiscordObject
  type Role = DiscordObject
  type Attachment = DiscordObject
  type Embed = DiscordObject
  type Reaction = DiscordObject
}

case class User(id: String) extends DiscordObject

case class DiscordMessage(
  id: String = "",
  channel_id: String = "",
  author: User = null,
  content: String = "",
  timestamp: String = "",
  edited_timestamp: Option[String] = None,
  tts: Boolean = false,
  mention_everyone: Boolean = false,
  mentions: Seq[DiscordObject] = Seq.empty,
  mention_roles: Seq[DiscordObject] = Seq.empty,
  attachments: Seq[DiscordObject] = Seq.empty,
  embeds: Seq[DiscordObject] = Seq.empty,
  reactions: Seq[DiscordObject] = Seq.empty,
  nonce: Option[String]= None,
  pinned: Boolean = false,
  webhook_id: Option[String] = None
) extends DiscordObject {
  def createReply(newContent: String) = copy(content = newContent)
}

