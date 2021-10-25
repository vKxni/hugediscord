#include <string>
#include <fstream>
#include <streambuf>
#include "sleepy_discord\sleepy_discord.h"


extern "C"
{
    char* OnMessageASM(char*);
    //int hello(void);
    //char* = charpointer
}


class MyClientClass : public SleepyDiscord::DiscordClient {
public:
    using SleepyDiscord::DiscordClient::DiscordClient;
    void onMessage(SleepyDiscord::Message message) override {
        char buff[100];
        char* buff2;
        snprintf(buff, sizeof(buff), "%s", message.content.c_str());
        buff2 = OnMessageASM(buff);
        if (buff2 != NULL) {
            std::string buff2AsStdStr = buff2;
            sendMessage(message.channelID, buff2AsStdStr);
        }

    }
};

int main() {
    std::ifstream t("Token.txt");
    std::string token((std::istreambuf_iterator<char>(t)),
        std::istreambuf_iterator<char>());
    MyClientClass client(token, SleepyDiscord::USER_CONTROLED_THREADS);
    client.run();
}




