package science.wasabi.tini.bot


import scala.collection.immutable.Iterable

import akka.NotUsed
import akka.stream.ActorMaterializer
import akka.stream.scaladsl.{Sink, Source}

import science.wasabi.tini._
import science.wasabi.tini.bot.commands._
import science.wasabi.tini.bot.discord.ingestion.{AkkaCordIngestion, Ingestion}
import science.wasabi.tini.bot.kafka.KafkaStreams
import science.wasabi.tini.config.Config


object BotMain extends App {
  println(Helper.greeting)

  implicit val config = Config.conf
  CommandRegistry.configure(config.bot.commands)

  case class Ping(override val args: String) extends Command(args) {}
  case class NoOp(override val args: String) extends Command(args) {}

  val ingestion: Ingestion = new AkkaCordIngestion

  import scala.concurrent.ExecutionContext.Implicits.global
  implicit val system = akka.actor.ActorSystem("kafka")
  implicit val materializer = ActorMaterializer()

  val kafka = new KafkaStreams

  // pipe to kafka
  def string2command(string: String): Iterable[Command] = CommandRegistry.getCommandsFor(string)
  val commandStream: Source[Command, NotUsed] = ingestion.source.mapConcat[Command](dmsg => string2command(dmsg.content))
  val commandTopicStream = commandStream.map(kafka.toCommandTopic)
  commandTopicStream
    .runWith(kafka.sink)
    .foreach(_ => println("Done Producing"))

  // read from kafka
  val commandStreamFromKafka = kafka.sourceFromCommandTopic()
  commandStreamFromKafka
    .map(command => println("out: " + command))
    .runWith(Sink.ignore)
    .foreach(_ => println("Done Consuming"))

  // TODO: add the reply steam thingy
}

