package;

import com.raidandfade.haxicord.commands.CommandBot;
import com.raidandfade.haxicord.types.Message;

class Main extends CommandBot {

    static function main() {
        new Main("<token>",Main,"-"); 
    }

    @Command
    function ping(message:Message){
        message.react("✅"); 
        message.reply({content:"Pong!"}); 
    }
}