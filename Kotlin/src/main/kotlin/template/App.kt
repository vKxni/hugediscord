package template

import com.kotlindiscord.kord.extensions.ExtensibleBot
import com.kotlindiscord.kord.extensions.utils.env
import dev.kord.common.entity.Snowflake
import template.extensions.TestExtension

val TEST_SERVER_ID = Snowflake(
    env("TEST_SERVER").toLong()
)

private val TOKEN = env("bot token goes here") 

suspend fun main() {
    val bot = ExtensibleBot(TOKEN) {
        chatCommands {
            defaultPrefix = "?"
            enabled = true

            prefix { default ->
                if (guildId == TEST_SERVER_ID) {
                    "!"
                } else {
                    default
                }
            }
        }

        extensions {
            add(::TestExtension)
        }
    }

    bot.start()
}
