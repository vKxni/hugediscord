module Gundyr.Db.Reamojis
  ( addReamoji,
    allReamoji,
    joinWithMsg,
    allReamojiWithMsg,
    reamojiWithLabel,
    reamojiWithLabelAndEmoji,
    deleteReamoji,
    deleteReamojiById,
    reamojiByIdAndEmoji,
  )
where

import Calamity hiding (emoji)
import Control.Lens
import Data.Text.Lazy (Text)
import Database.Beam
import Database.Beam.Sqlite
import Gundyr.Db.Instances ()
import Gundyr.Db.Messages
import Gundyr.Db.Schema

addReamoji ::
  Snowflake Message ->
  RawEmoji ->
  Snowflake Role ->
  SqlInsert Sqlite ReamojiT
addReamoji mid emo rid =
  insert (db ^. #reamojis) . insertValues $
    [Reamoji (BotMsgKey mid) emo rid]

allReamoji :: Q Sqlite BotDB s (ReamojiT (QExpr Sqlite s))
allReamoji = all_ (db ^. #reamojis)

joinWithMsg ::
  Q Sqlite BotDB s (ReamojiT (QExpr Sqlite s)) ->
  Q Sqlite BotDB s (BotMsgT (QExpr Sqlite s), ReamojiT (QExpr Sqlite s))
joinWithMsg q = do
  rea <- q
  msg <- allMsg
  guard_ ((rea ^. #_msg_id) `references_` msg)
  return (msg, rea)

allReamojiWithMsg :: Q Sqlite BotDB s (BotMsgT (QExpr Sqlite s), ReamojiT (QExpr Sqlite s))
allReamojiWithMsg = joinWithMsg allReamoji

reamojiWithLabelAndEmoji ::
  Text ->
  RawEmoji ->
  Q Sqlite BotDB s (BotMsgT (QExpr Sqlite s), ReamojiT (QExpr Sqlite s))
reamojiWithLabelAndEmoji label emo = do
  res <- allReamoji
  labeled <- matchingLabel label
  guard_ ((res ^. #_msg_id) `references_` labeled)
  guard_ ((res ^. #emoji) ==. val_ emo)
  return (labeled, res)

reamojiWithLabel ::
  Text ->
  Q Sqlite BotDB s (BotMsgT (QExpr Sqlite s), ReamojiT (QExpr Sqlite s))
reamojiWithLabel label = do
  allrea <- allReamoji
  labeled <- matchingLabel label
  guard_ ((allrea ^. #_msg_id) `references_` labeled)
  return (labeled, allrea)

deleteReamoji :: Text -> RawEmoji -> SqlDelete Sqlite ReamojiT
deleteReamoji label emo = do
  delete (db ^. #reamojis) $
    \r ->
      (r ^. #emoji) ==. val_ emo
        &&. exists_
          ( do
              msg <- matchingLabel label
              guard_ (msg ^. #label ==. val_ label)
              guard_ ((r ^. #_msg_id) `references_` msg)
              return msg
          )

deleteReamojiById :: Snowflake Message -> RawEmoji -> SqlDelete Sqlite ReamojiT
deleteReamojiById mid emo = do
  delete (db ^. #reamojis)
  $ \r ->
    (r ^. #emoji) ==. val_ emo
      &&. (r ^. #_msg_id) ==. val_ (BotMsgKey mid)

reamojiByIdAndEmoji ::
  Snowflake Message ->
  RawEmoji ->
  Q Sqlite BotDB s (ReamojiT (QExpr Sqlite s))
reamojiByIdAndEmoji mid emo = do
  rea <- allReamoji
  guard_
    ( (rea ^. #_msg_id) ==. val_ (BotMsgKey mid)
        &&. (rea ^. #emoji) ==. val_ emo
    )
  return rea
