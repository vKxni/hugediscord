package science.wasabi.tini.config


import scala.io.Source

import com.typesafe.config.{Config => TypesafeConfig, ConfigFactory}


object Config {
  // Model for the config file
  case class TiniConfig(envExample: String, discordBotToken: String, killSecret: String, kafka: Kafka, bot: Bot)
  case class Kafka(server: String, port: String, topic: String)
  case class Bot(commands: Map[String, String])

  val conf: TiniConfig = {
    val confString: String = Source
      .fromFile("./application.conf")
      .getLines()
      .mkString("\n")

    val hocon: TypesafeConfig = ConfigFactory.parseString(confString).resolve()

    import pureconfig._

    loadConfigOrThrow[TiniConfig](hocon)
  }
}
