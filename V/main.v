import json
import os
import discordv as vd
import net.http

const (
    prefix = '.'
)

fn main() {

	token := os.getenv('BOT_TOKEN')
    println(token)
    if token == '' {
        println('Please provide a valid bot token using BOT_TOKEN environment variable')
        return
    }

    mut client := vd.new(token: token, intents: 515) ?
    client.on_ready(on_ready)
    client.on_message_create(on_message_create)
    client.open() ?

}

fn on_ready (mut client vd.Client, evt &vd.Ready) {
    println('Bot ready!')
}

fn on_message_create(mut client vd.Client, evt &vd.MessageCreate) {

    if !evt.content.starts_with(prefix) {
        return
    }

    mut arguments := evt.content.substr(1, evt.content.len).split(' ')
    cmd_name := arguments[0]
    arguments = arguments[1..arguments.len]

    
    if cmd_name == '!ping' {
        client.channel_message_send(evt.channel_id, content: 'pong!')
    }

}