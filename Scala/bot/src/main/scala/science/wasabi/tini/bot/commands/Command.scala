package science.wasabi.tini.bot.commands


import scala.util.{Failure, Success, Try}
import scala.collection.immutable.Iterable

import science.wasabi.tini.bot.BotMain.{NoOp, Ping}


object CommandRegistry {

  private var commandRegistry: Map[String, Class[_ <: Command]] = Map(
    "!ping" -> classOf[Ping],
    "" -> classOf[NoOp]
  )

  case class CommandClassNotFound(notUsed: String) extends Command(argsIn = notUsed) with Serializable

  def configure(commands: Map[String, String]): Unit = {
    def convertToClass(name: String): Class[Command] = Try(Class.forName(name)) match {
      case Success(commandClazz) => commandClazz.asInstanceOf[Class[Command]]
      case Failure(exception) =>
        exception.printStackTrace()
        classOf[CommandClassNotFound].asInstanceOf[Class[Command]]
    }

    commandRegistry = commandRegistry ++ commands.map {
      case (prefix: String, clazz: String) => (prefix, convertToClass(clazz))
    }

    println(s"Commands are: ${CommandRegistry.commandRegistry}")
  }

  def getCommandsFor(args: String): Iterable[Command] = commandRegistry
    .filter { case (string, _) => args.startsWith(string) }
    .map { case (string, clazz) => clazz
      .getConstructor(classOf[String])
      .newInstance(args.drop(string.length).trim)
    }

  def unapply(args: String): Option[Command] = commandRegistry
    .find { case (string, _) => args.startsWith(string) }
    .map { case (string, clazz) => clazz
      .getConstructor(classOf[String])
      .newInstance(args.drop(string.length).trim)
    }
}

abstract class Command(argsIn: String) extends Serializable {
  val args: String = argsIn
}

