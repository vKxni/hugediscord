using Discord;
using Discord.Commands;
using Discord.WebSocket;
using System;
using System.Threading.Tasks;


namespace DiscordBotTemplate.Services
{
    public class CommandHandler
    {
        private readonly DiscordSocketClient _discord;
        private readonly CommandService _commands;
        private readonly IServiceProvider _provider;
        private readonly Configuration.Configuration _config;


        /// <summary>
        /// Creates a new <see cref="CommandHandler"/>.
        /// </summary>
        /// <param name="discord">The Discord socket client to use.</param>
        /// <param name="commands">The command service to use.</param>
        /// <param name="provider">The service provider to use.</param>
        /// <param name="config">The config to use.</param>
        public CommandHandler(
            DiscordSocketClient discord,
            CommandService commands,
            IServiceProvider provider,
            Configuration.Configuration config
        )
        {
            _discord = discord;
            _commands = commands;
            _provider = provider;
            _config = config;

            _discord.MessageReceived += OnMessageReceivedAsync;
        }


        /// <summary>
        /// Handles the given message.
        /// </summary>
        /// <param name="socketMessage">The socket message.</param>
        /// <returns>An awaitable task.</returns>
        private async Task OnMessageReceivedAsync(SocketMessage socketMessage)
        {
            SocketUserMessage message;


            // Ensure the message is from a user/bot.
            message = socketMessage as SocketUserMessage;

            // If the message is null, return.
            if (message == null)
            {
                return;
            }

            // Ignore self when checking commands.
            if (message.Author == _discord.CurrentUser)
            {
                return;
            }

            SocketCommandContext context;
            int argPos = 0;


            // Create the command context.
            context = new SocketCommandContext(_discord, message);

            // Check if the message has a valid command prefix.
            if (message.HasStringPrefix(_config.Prefix, ref argPos) || message.HasMentionPrefix(_discord.CurrentUser, ref argPos))
            {

                // Look at the second character of the command, if it's the same as the prefix then ignore it.
                // This gets around the bot treating a message like '...' as a command and trying to process it.
                if (!string.Equals(message.Content.Substring(1, 1), _config.Prefix))
                {
                    IResult result;


                    Console.WriteLine(message.Content.ToString());

                    // Execute the command.
                    result = await _commands.ExecuteAsync(context, argPos, _provider);

                    if (!result.IsSuccess)
                    {
                        EmbedBuilder embed;


                        embed = new EmbedBuilder();
                        embed.WithColor(Color.DarkRed);
                        embed.AddField(":warning: An unexpected error occurred.", $"The command: '{message.Content}' is not a registered command.");

                        // If not successful, reply with the error.
                        await context.Channel.SendMessageAsync("", embed: embed.Build());
                    }
                }
            }
        }
    }
}
