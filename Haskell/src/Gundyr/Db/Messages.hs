module Gundyr.Db.Messages
  ( addMsg,
    matchingLabel,
    allMsg,
    selectAllMsg,
    selectMatchingLabel,
    removeMsg,
    updateMsg,
  )
where

import Calamity
import Control.Lens
import Data.Text.Lazy (Text)
import Database.Beam
import Database.Beam.Sqlite
import Gundyr.Db.Schema

addMsg ::
  Snowflake Message ->
  Snowflake Channel ->
  Text ->
  Text ->
  SqlInsert Sqlite BotMsgT
addMsg mid chid label body =
  insert (db ^. #botMessages) . insertValues $
    [BotMsg mid chid label body]

matchingLabel :: Text -> Q Sqlite BotDB s (BotMsgT (QExpr Sqlite s))
matchingLabel label =
  filter_ (\r -> r ^. #label ==. val_ label) allMsg

allMsg :: Q Sqlite BotDB s (BotMsgT (QExpr Sqlite s))
allMsg = all_ (db ^. #botMessages)

selectAllMsg :: SqlSelect Sqlite (BotMsgT Identity)
selectAllMsg = select allMsg

selectMatchingLabel :: Text -> SqlSelect Sqlite (BotMsgT Identity)
selectMatchingLabel = select . matchingLabel

removeMsg :: Text -> SqlDelete Sqlite BotMsgT
removeMsg label =
  delete
    (db ^. #botMessages)
    (\r -> (r ^. #label) ==. val_ label)

updateMsg :: Text -> Text -> SqlUpdate Sqlite BotMsgT
updateMsg label body =
  update
    (db ^. #botMessages)
    (\r -> (r ^. #msg_body) <-. val_ body)
    (\r -> (r ^. #label) ==. val_ label)
