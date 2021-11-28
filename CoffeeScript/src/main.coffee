config = require("./config.json")

Eris = require("eris")
client = new Eris(config.token)
client.config = config

client.on 'ready', ->
    console.log """
        Logged as #{client.user.username}##{client.user.discriminator}
    """

client.connect()