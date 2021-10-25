use crate::services::{config::Config, database};
use events::Handler;
use log::warn;
use serenity::{framework::standard::StandardFramework, prelude::TypeMapKey, Client};

mod commands;
mod events;
mod utils;

impl TypeMapKey for Config {
    type Value = Config;
}

pub async fn start(config: Config) {
    let framework = StandardFramework::new()
        .configure(|c| {
            c.prefix(&config.prefix);
            c.allow_dm(true);
            c.case_insensitivity(true);
            return c;
        })
        .group(&commands::COMMANDS_GROUP);

    let mut client = Client::new(&config.token)
        .framework(framework)
        .event_handler(Handler)
        .await
        .expect("Failed to create a new client");

    let db_client = database::connect(&config.db_uri).await;

    {
        let mut data = client.data.write().await;
        data.insert::<Config>(config);
        data.insert::<database::DataBase>(db_client);
    }

    if let Err(e) = client.start().await {
        warn!("Failed to login, is the token correct?\n{}", e);
    }
}
