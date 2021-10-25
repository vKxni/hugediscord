package science.wasabi.tini.bot.kafka


import java.io.{ByteArrayInputStream, ByteArrayOutputStream, ObjectInputStream, ObjectOutputStream}

import scala.concurrent.Future
import scala.util.Try

import akka.Done
import akka.actor.ActorSystem
import akka.kafka.scaladsl.{Consumer, Producer}
import akka.kafka.{ConsumerSettings, ProducerSettings, Subscriptions}
import akka.stream.scaladsl.{Sink, Source}

import org.apache.kafka.clients.consumer.ConsumerConfig
import org.apache.kafka.clients.producer.ProducerRecord
import org.apache.kafka.common.serialization.{ByteArrayDeserializer, ByteArraySerializer}

import science.wasabi.tini.bot.commands.Command
import science.wasabi.tini.bot.kafka.KafkaStreams.toBinary
import science.wasabi.tini.config.Config.TiniConfig


class KafkaStreams(implicit config: TiniConfig, system: ActorSystem) {
  val kafkaServer = s"${config.kafka.server}:${config.kafka.port}"

  // Producer Sink
  val sink: Sink[ProducerRecord[Array[Byte], Array[Byte]], Future[Done]] = {
    val producerSettings = ProducerSettings(system, new ByteArraySerializer, new ByteArraySerializer)
      .withBootstrapServers(kafkaServer)

    Producer.plainSink(producerSettings)
  }

  def toCommandTopic(command: Command): ProducerRecord[Array[Byte], Array[Byte]] = {
    println("in: " + command)

    new ProducerRecord[Array[Byte], Array[Byte]](config.kafka.topic, toBinary(command))
  }

  case class KafkaParseError(override val args: String) extends Command(args)

  def sourceFromCommandTopic(): Source[Command, Consumer.Control] = {
    // kafka consumer
    val consumerSettings = ConsumerSettings(system, new ByteArrayDeserializer, new ByteArrayDeserializer)
      .withBootstrapServers(kafkaServer)
      .withGroupId("group1")
      .withProperty(ConsumerConfig.AUTO_OFFSET_RESET_CONFIG, "earliest")

    val partition = 0
    val offset = 0L // starts from beginnning; TODO: save offset somewhere
    val subscription = Subscriptions.topics(config.kafka.topic)

    Consumer.plainSource(consumerSettings, subscription).map(record => {
      KafkaStreams.fromBinary(record.value).fold(
        throwable => KafkaParseError(throwable.getMessage),
        command => command
      )
    })
  }
}

object KafkaStreams {
  def toBinary(command: Command): Array[Byte] = {
    val out = new ByteArrayOutputStream()
    val os = new ObjectOutputStream(out)
    os.writeObject(command)
    os.close()
    out.toByteArray
  }
  def fromBinary(data: Array[Byte]): Try[Command] = Try {
    val in = new ByteArrayInputStream(data)
    val is = new ObjectInputStream(in)
    val obj = is.readObject()
    is.close()
    in.close()
    obj.asInstanceOf[Command]
  }

}
