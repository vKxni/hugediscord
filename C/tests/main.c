#include <crow/client.h>
#include <crow/types.h>
#include <crow/rest.h>

#include <stdio.h>

int startsWith(const char *a, const char *b)
{
   if(strncmp(a, b, strlen(b)) == 0) return 1;
   return 0;
}

void 
on_discord_message(client_t *bot, message_t msg) 
{

	if (strcmp(msg.author.id, bot->self.id)) 
	{
		if (startsWith(msg.content, PREFIX)) 
		{

			msg.content = msg.content + strlen(PREFIX);

			if (!strcmp("ping", msg.content)) 
			{
				send_message(msg.channel_id, "Pong!");
			}

			if (!strcmp("ok", msg.content)) 
			{
				add_reaction(msg.channel_id, msg.id, "trumpLUL:237288619088412683");
			}

			if (!strcmp("debug_channel", msg.content)) 
			{
				guild_channel_t channel = get_channel(msg.channel_id);

				char to_send[1024];

				snprintf(to_send, sizeof(to_send), "This channel: \nID: %s\nGuildID: %s\nType: %d\nTopic: %s ", channel.id, channel.guild_id, channel.type, channel.topic);

				send_message(msg.channel_id, to_send);
			}

			if (startsWith(msg.content, "echo")) 
			{
				send_message(msg.channel_id, msg.content);
			}

			if (!strcmp("hi", msg.content)) 
			{
				char to_send[1024];

				snprintf(to_send, sizeof(to_send), "Hi, %s!", msg.author.username);

				send_message(msg.channel_id, to_send);
			}

			if (!strcmp("reconnect", msg.content)) 
			{
				send_message(msg.channel_id, "Reconnecting...");

				crow_reconnect(bot);
			}

		}
	}

}

int main(void) 
{
	client_t *bot = crow_new();

	// TODO: map?
	bot->on_message = &on_discord_message;

	crow_run(bot);

	return 0;
}