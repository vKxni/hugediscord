using Discord.Commands;
using System.Threading.Tasks;


namespace DiscordBotTemplate.Modules
{
    /// <summary>
    /// Defines a command module.
    /// </summary>
    [Name("Test")]
    public class Module1 : ModuleBase<SocketCommandContext>
    {

        /// <summary>
        /// Gives a cookie to the current user.
        /// </summary>
        /// <returns>An awaitable task.</returns>
        [Command("cookie")]
        public async Task GiveCookie()
        {
            await ReplyAsync($"Here {Context.User.Mention}, have a cookie :cookie:");
        }


        /// <summary>
        /// Gives a cookie to the tagged user.
        /// </summary>
        /// <param name="username">The user to give a cookie to.</param>
        /// <returns>An awaitable task.</returns>
        [Command("cookie")]
        public async Task GiveCookie(string username)
        {
            await ReplyAsync($"Here {username}, have a cookie :cookie:");
        }

    }
}
