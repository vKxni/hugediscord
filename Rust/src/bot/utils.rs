use log::warn;
use serenity::model::channel::Message;
use serenity::prelude::Context;

pub(crate) async fn reply<T: std::fmt::Display>(ctx: &Context, msg: &Message, content: T) {
    if let Err(why) = msg.channel_id.say(&ctx, &content).await {
        warn!(
            "Failed to send message in #{} because\n{:?}",
            msg.channel_id, why,
        );
    }
}

/*
pub(crate) async fn reply_embed<T>(ctx: &Context, msg: &Message, embed: T) {
    if let Err(why) = msg.channel_id.send_message(&ctx.http, &embed).await {
        println!("Failed to send message in #{} because\n{:?}",
                 msg.channel_id, why
        );
    }
}
*/
