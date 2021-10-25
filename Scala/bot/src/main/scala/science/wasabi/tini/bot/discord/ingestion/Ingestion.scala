package science.wasabi.tini.bot.discord.ingestion


import akka.NotUsed
import akka.stream.scaladsl.Source

import science.wasabi.tini.bot.discord.wrapper.DiscordMessage


trait Ingestion {
  val source: Source[DiscordMessage, NotUsed]
}
