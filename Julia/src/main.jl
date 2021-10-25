
using Discord
#using Client

c = Client("bot token")


function handler(c::Client, e::MessageCreate)
   
    println("Received message: $(e.message.content)")
    println("Received message from: $(e.message.author.username)")
    create(c, Reaction, e.message, '👍')

   # code here if you want ...

end


add_handler!(c, MessageCreate, handler)
open(c)
wait(c)
