use log::info;
use serenity::{async_trait, model::prelude::*, prelude::*};

pub struct Handler;

#[async_trait]
impl EventHandler for Handler {
    async fn ready(&self, ctx: Context, ready: Ready) {
        let perms = Permissions::from_bits(0).unwrap();
        let user = &ready.user;
        info!(
            "
Ready as {}
 * Serving {} guilds
 * Invite URL: {}",
            user.tag(),
            ready.guilds.len(),
            user.invite_url(ctx, perms).await.unwrap(),
        );
    }
}
