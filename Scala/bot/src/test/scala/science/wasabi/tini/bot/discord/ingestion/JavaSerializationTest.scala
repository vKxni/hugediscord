package science.wasabi.tini.bot.discord.ingestion

import java.io.{ByteArrayInputStream, ByteArrayOutputStream, ObjectInputStream, ObjectOutputStream}

import org.specs2.mutable.Specification

sealed trait Vehicle
case class Car(isNew: Boolean) extends Vehicle
case class Airplane(mileage: Double) extends Vehicle

class JavaSerializationTest extends Specification {
  override def is =
    s2"""
Serialization
     in avro $e0
"""

  def e0 = true must beTrue

  def e1 = {
    val car = Car(true)

    val out = new ByteArrayOutputStream()
    val os = new ObjectOutputStream(out)
    os.writeObject(car)
    os.close()

    val bytes = out.toByteArray

    val in = new ByteArrayInputStream(bytes)
    val is = new ObjectInputStream(in)

    val obj = is.readObject()
    is.close()

    car must_==(obj)
  }
}
