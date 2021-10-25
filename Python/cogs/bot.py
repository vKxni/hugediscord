import json
import os
import sys

from discord.ext import commands
from discord_slash import cog_ext, SlashContext

if not os.path.isfile("config.json"):
    sys.exit("'config.json' not found! Please add it and try again.")
else:
    with open("config.json") as file:
        config = json.load(file)


class Template(commands.Cog, name="template"):
    def __init__(self, bot):
        self.bot = bot

   
    @cog_ext.cog_slash(
        name="testcommand",
        description="This is a testing command that does nothing.",
    )
    async def testcommand(self, context: SlashContext):
        """
        This is a testing command that does nothing.
        """
        pass

def setup(bot):
    bot.add_cog(Template(bot))
