from pydantic_settings import BaseSettings
import discord
import logging
from discord import ui
from discord.ext import commands

LOGGER = logging.getLogger(__name__)



class DiscordSettings(BaseSettings):
    bot_token: str
    discord_guild: int
    discord_channel: int

    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"
        case_sensitive = False

class DiscordBot(commands.Bot):
    def __init__(self, *args, discord_settings=None, **kwargs):
        super().__init__(*args, **kwargs)
        self.settings = discord_settings

    async def log_message(self, message: str):
        print(message)
        LOGGER.info(message)

    async def get_members_in_guild(self, guild_id: int):
        guild = discord.utils.find(lambda g: g.id == guild_id, self.guilds)
        if guild:
            return [member.name for member in guild.members]
        else:
            raise ValueError(f"Guild with ID {guild_id} not found.")

    async def on_ready(self):
        try:
            await self.log_message(f"Logged in as {self.user} (ID: {self.user.id})")
            members = await self.get_members_in_guild(self.settings.discord_guild)
            await self.log_message(f"Members in guild: {'\n'.join([f'- {member}' for member in members])}")
            guild = discord.utils.find(lambda g: g.id == self.settings.discord_guild, self.guilds)
            if guild and guild.text_channels:
                channel = guild.text_channels[0]
                await self.log_message(
                    f"My permissions in {guild.name}: " +
                    ", ".join([name for name, value in channel.permissions_for(guild.me) if value])
                )
            command_sync = await self.tree.sync(guild=discord.Object(id=self.settings.discord_guild))
            await self.log_message(f"Synced {len(command_sync)} commands to the guild.")
        except Exception as e:
            await self.log_message(f"An error occurred while logging in: {e}")
            raise

    async def on_member_join(self, member) -> None:
        await member.create_dm()
        await member.dm_channel.send(
            f'Howdy there {member.name}, welcome to my resturant!'
        )

class Questionnaire(ui.Modal, title='Chef Kawasaki Questionnaire'):
    name = ui.TextInput(label='Name')
    answer = ui.TextInput(label='Answer', style=discord.TextStyle.paragraph)

    async def on_submit(self, interaction: discord.Interaction):
        channel = interaction.client.get_channel(discord.Object(id=interaction.client.settings.discord_channel))
        if channel:
            await channel.send(f"Questionnaire response from {self.name}:\n{self.answer}")
        await interaction.response.send_message(f'Thanks for your response, {self.name}!', ephemeral=True)


class Poll(ui.View):
    def __init__(self, question: str, options: list[str]):
        super().__init__()
        self.question = question
        self.options = options
        self.add_item(PollSelect(options))

class PollSelect(ui.Select):
    def __init__(self, options: list[str]):
        select_options = [discord.SelectOption(label=opt) for opt in options]
        super().__init__(placeholder="Choose your answer...", min_values=1, max_values=1, options=select_options)

    async def callback(self, interaction: discord.Interaction):
        await interaction.response.send_message(f"You voted for: {self.values[0]}", ephemeral=True)

intents = discord.Intents.default()
intents.members = True
intents.message_content = True
discord_settings = DiscordSettings()
client = DiscordBot(intents=intents, discord_settings=discord_settings, command_prefix='!')

@client.tree.command(name='chef-kawasakis-questionaire', description='Open a questionnaire modal', guild=discord.Object(id=discord_settings.discord_guild))
async def chef_kawasakis_questionaire(interaction: discord.Interaction):
    modal = Questionnaire()
    await interaction.response.send_modal(modal)

@client.tree.command(name='chef-kawasakis-poll', description='Open a poll', guild=discord.Object(id=discord_settings.discord_guild))
async def chef_kawasakis_poll(interaction: discord.Interaction):
    question = "What's your favirite food of mine!?"
    options = ["Chocolate Candy", "Sushi", "Monsters!", "Salmon"]
    view = Poll(question, options)
    await interaction.response.send_message(f"**{question}**", view=view, ephemeral=True)

client.run(discord_settings.bot_token)
