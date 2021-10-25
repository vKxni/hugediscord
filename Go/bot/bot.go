package bot

import (
	"Test/config"
	"Test/utils"
	"fmt"
	"github.com/bwmarrin/discordgo"
	"os"
	"os/signal"
	"runtime"
	"strconv"
	"strings"
	"syscall"
)
var botID string
var client *discordgo.Session

func Start() {
	session, err := discordgo.New("Bot " + config.Token)
	if err != nil {
		fmt.Println(err)
		return
	}
	session.AddHandler(message)
	session.AddHandler(ready)

	fmt.Print("Bot is online")
	defer session.Close()
	if err = session.Open(); err != nil {
		fmt.Println(err)
		return
	}

	scall := make(chan os.Signal, 1)
	signal.Notify(scall, syscall.SIGINT, syscall.SIGTERM, syscall.SIGSEGV, syscall.SIGHUP)
	<-scall
}

func ready(bot *discordgo.Session, event *discordgo.Ready) {
	guildsSize := len(bot.State.Guilds)
	bot.UpdateGameStatus(0, strconv.Itoa(guildsSize) + " guilds!")
}

func message(bot *discordgo.Session, message *discordgo.MessageCreate) {
	if message.Author.Bot { return }
	switch {
	case strings.HasPrefix(message.Content, config.BotPrefix):
		ping := bot.HeartbeatLatency().Truncate(60)
		if message.Content == "&ping" {
			bot.ChannelMessageSend(message.ChannelID,`My latency is **` + ping.String() + `**!`)
		}
		if message.Content == "&author" {
			bot.ChannelMessageSend(message.ChannelID, "My author is Gonz#0001, I'm only a template discord bot made in golang.")
		}
		if message.Content == "&github" {
			embed := embed.NewEmbed().
				SetAuthor(message.Author.Username, message.Author.AvatarURL("1024")).
				SetThumbnail(message.Author.AvatarURL("1024")).
				SetTitle("My repository").
				SetDescription("You can find my repository by clicking [here](https://github.com/gonzyui/Discord-Template).").
				SetColor(0x00ff00).MessageEmbed
			bot.ChannelMessageSendEmbed(message.ChannelID, embed)
		}
		if message.Content == "&botinfo" {
			guilds := len(bot.State.Guilds)
			embed := embed.NewEmbed().
				SetTitle("My informations").
				SetDescription("Some informations about me :)").
				AddField("GO version:", runtime.Version()).
				AddField("DiscordGO version:", discordgo.VERSION).
				AddField("Concurrent tasks:", strconv.Itoa(runtime.NumGoroutine())).
				AddField("Latency:", ping.String()).
				AddField("Total guilds:", strconv.Itoa(guilds)).MessageEmbed
			bot.ChannelMessageSendEmbed(message.ChannelID, embed)
		}
	}
}
