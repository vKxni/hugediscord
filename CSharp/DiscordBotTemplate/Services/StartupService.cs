using Discord;
using Discord.Commands;
using Discord.WebSocket;
using System;
using System.Diagnostics;
using System.Reflection;
using System.Threading.Tasks;


namespace DiscordBotTemplate.Services
{
    public class StartupService
    {
        private readonly DiscordSocketClient _discord;
        private readonly CommandService _commands;
        private readonly Configuration.Configuration _config;


        /// <summary>
        /// Creates a new <see cref="StartupService"/>.
        /// </summary>
        /// <param name="discord">The Discord socket client to use.</param>
        /// <param name="commands">The command service to use.</param>
        /// <param name="config">The configuration object to use.</param>
        public StartupService(
            DiscordSocketClient discord,
            CommandService commands,
            Configuration.Configuration config
        )
        {
            _discord = discord;
            _commands = commands;
            _config = config;
        }


        /// <summary>
        /// Starts the bot.
        /// </summary>
        /// <returns>An awaitable task.</returns>
        public async Task StartAsync()
        {
            string discordToken;
            Func<Task> connected;
            Func<Task> loggedIn;
            Func<Task> clientReady;


            discordToken = _config.DiscordToken;

            if (string.IsNullOrWhiteSpace(discordToken))
            {
                throw new ArgumentNullException(nameof(discordToken));
            }

            connected = () =>
            {
                Console.WriteLine("--------------------------------------------------");
                Console.WriteLine("Gateway connected");
                Console.WriteLine("--------------------------------------------------");
                return Task.CompletedTask;
            };

            loggedIn = () =>
            {
                Console.WriteLine("--------------------------------------------------");
                Console.WriteLine("Logged in");
                Console.WriteLine("--------------------------------------------------");
                return Task.CompletedTask;
            };

            clientReady = () =>
            {
                Assembly assembly;
                FileVersionInfo fileVersionInfo;
                string version;


                Console.WriteLine("--------------------------------------------------");
                Console.WriteLine("Client ready");
                Console.WriteLine("--------------------------------------------------");

                assembly = Assembly.GetExecutingAssembly();
                fileVersionInfo = FileVersionInfo.GetVersionInfo(assembly.Location);
                version = fileVersionInfo.FileVersion;

                // Log the version of the assembly out as well just to give an indicator of updated versions.
                Console.WriteLine($"Version {version}");
                Console.WriteLine("--------------------------------------------------");

                return Task.CompletedTask;
            };

            _discord.Connected += connected;
            _discord.LoggedIn += loggedIn;
            _discord.Ready += clientReady;

            await _discord.LoginAsync(TokenType.Bot, discordToken);
            await _discord.StartAsync();

            // Load commands and modules into the command service.
            await _commands.AddModulesAsync(Assembly.GetEntryAssembly());
        }
    }
}
