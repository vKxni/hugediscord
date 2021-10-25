use crate::bot::utils::reply;
use crate::services::Config;
use crate::services::DataBase;
use serenity::{
    framework::standard::{
        macros::{command, group},
        CommandResult,
    },
    model::channel::Message,
    prelude::*,
};

#[group()]
#[commands(ping, db_test, prefix)]
pub struct Commands;

#[command]
async fn ping(ctx: &Context, msg: &Message) -> CommandResult {
    reply(&ctx, &msg, &String::from("Pong!")).await;
    Ok(())
}

#[command]
async fn prefix(ctx: &Context, msg: &Message) -> CommandResult {
    let data = ctx.data.read().await;
    let config = data.get::<Config>().unwrap();

    if let Err(why) = msg
        .channel_id
        .send_message(&ctx.http, |m| {
            m.embed(|embed| {
                embed.title("Prefix");
                embed.description(format!("My prefix is: `{}`", &config.prefix));
                embed.color(0xffa500)
            });
            m
        })
        .await
    {
        println!(
            "Failed to send message in #{} because\n{:?}",
            msg.channel_id, why
        );
    };

    Ok(())
}

#[command]
async fn db_test(ctx: &Context, msg: &Message) -> CommandResult {
    let data = ctx.data.read().await;
    let db = data.get::<DataBase>().unwrap();

    let rows = db.query("SELECT test FROM test", &[]).await.unwrap();

    reply(&ctx, &msg, &rows[0].get(0)).await;
    Ok(())
}
