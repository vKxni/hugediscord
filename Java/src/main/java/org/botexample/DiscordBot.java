package org.botexample;

import net.dv8tion.jda.api.JDA;
import net.dv8tion.jda.api.JDABuilder;
import net.dv8tion.jda.api.entities.Activity;
import net.dv8tion.jda.api.utils.cache.CacheFlag;

import javax.security.auth.login.LoginException;

public class DiscordBot {
    public static void main(String[] args) {
        if (args.length < 1) {
            throw new IllegalStateException("You have to provide a token as the first argument!");
        }
        JDABuilder jdaBotBuilder = JDABuilder.createDefault(args[0]);

        jdaBotBuilder.disableCache(CacheFlag.MEMBER_OVERRIDES, CacheFlag.VOICE_STATE);

        jdaBotBuilder.setBulkDeleteSplittingEnabled(false);

        jdaBotBuilder.setActivity(Activity.playing("with your heart"));

        jdaBotBuilder.addEventListeners(new MessageListener(), new ReadyListener());

        try {
            JDA discordBot = jdaBotBuilder.build();
            discordBot.awaitReady();
        } catch (LoginException | InterruptedException e) {
            System.err.println("Couldn't login.");
            e.printStackTrace();
        }
    }
}
