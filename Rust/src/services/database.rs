use serenity::prelude::TypeMapKey;

use tokio_postgres::{Client as DBClient, NoTls};

pub struct DataBase(DBClient);

impl TypeMapKey for DataBase {
    type Value = DBClient;
}

pub(crate) async fn connect(uri: &String) -> DBClient {
    let (db_client, connection) = tokio_postgres::connect(&uri, NoTls).await.unwrap();

    tokio::spawn(async move {
        if let Err(e) = connection.await {
            eprintln!("connection error: {}", e);
        }
    });

    db_client
}
