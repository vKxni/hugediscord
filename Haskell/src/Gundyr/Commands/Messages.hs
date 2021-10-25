module Gundyr.Commands.Messages
  ( messageGroup,
    sendMessage,
    listBotMsg,
    showBotMsg,
    deleteBotMsg,
    editBotMsg,
  )
where

import Calamity hiding (Member)
import Calamity.Commands
import Calamity.Commands.Context (FullContext)
import Control.Lens hiding (Context)
import Control.Monad
import Data.Text.Lazy (Text, toStrict)
import qualified Data.Text.Lazy as L
import Database.Beam
import Gundyr.Commands.Permissions
import Gundyr.Db
import Gundyr.Util
import Polysemy (Member, Sem)

messageGroup :: (BotC r, Member DBEff r) => Sem (DSLState FullContext r) ()
messageGroup = void
  . help (const "group for bot messages")
  . requireManageRole
  . groupA "msg" ["m"]
  $ do
    sendMessage
    listBotMsg
    showBotMsg
    deleteBotMsg
    editBotMsg

sendMessage :: (BotC r, Member DBEff r) => Sem (DSLState FullContext r) ()
sendMessage = void
  . help (const "send a new message to the channel, and store the message in db")
  . command
    @'[ Named "channel" (Snowflake Channel),
        Named "label" Text,
        Named "message" (KleenePlusConcat Text)
      ]
    "send"
  $ \ctx ch label msgText -> do
    infot "creating new message"
    dbres <- usingConn . runSelectReturningOne . select . matchingLabel $ label
    case dbres of
      Just _ -> do
        infot $ "Label: " <> label <> "already exists."
        void . tellt ctx $ "label already exists."
      Nothing -> do
        tellres <- tellt ch msgText
        case tellres of
          (Right msg) -> do
            void . usingConn . runInsert $ addMsg (msg ^. #id) ch label msgText
            infot "done"
          _ -> return ()

listBotMsg :: (BotC r, Member DBEff r) => Sem (DSLState FullContext r) ()
listBotMsg = void
  . help (const "list bot messages")
  . command @'[] "list"
  $ \ctx -> do
    infot "Retrieving bot messages"
    res <- usingConn . runSelectReturningList $ selectAllMsg
    unless (null res) . void . tellt ctx . ("Displaying bot messages:\n" <>)
      . L.unlines
      . map
        ( \r ->
            r ^. #label <> ": "
              <> L.take 20 (r ^. #msg_body)
        )
      $ res

showBotMsg :: (BotC r, Member DBEff r) => Sem (DSLState FullContext r) ()
showBotMsg = void
  . help (const "details for a bot message")
  . command @'[Named "label" Text] "show"
  $ \ctx label -> do
    infot $ "Retrieving bot message with label " <> label
    res' <- usingConn . runSelectReturningOne . selectMatchingLabel $ label
    case res' of
      Nothing -> do
        infot "label not found"
        void $ tellt ctx "label not found"
      Just res -> do
        void . tellt ctx . L.unlines $
          [ "Label: " <> res ^. #label,
            "Channel: " <> mention (res ^. #channel_id),
            "Body: " <> res ^. #msg_body
          ]
        infot "done"

deleteBotMsg :: (BotC r, Member DBEff r) => Sem (DSLState FullContext r) ()
deleteBotMsg = void
  . help (const "delete a bot message")
  . command @'[Named "label" Text] "delete"
  $ \ctx label -> do
    infot $ "Deleting bot message with label: " <> label
    res' <- usingConn . runSelectReturningOne . selectMatchingLabel $ label
    case res' of
      Nothing -> do
        infot "label not found"
        void $ tellt ctx "label not found"
      Just (BotMsg mid chid _ _) -> do
        void . usingConn . runDelete . removeMsg $ label
        void $ invoke (DeleteMessage chid mid)
        infot "done"

editBotMsg :: (BotC r, Member DBEff r) => Sem (DSLState FullContext r) ()
editBotMsg = void
  . help (const "edit a bot message")
  . command
    @'[ Named "label" Text,
        Named "body" Text
      ]
    "edit"
  $ \ctx label body -> do
    infot $ "Editing bot message: " <> label
    res' <- usingConn . runSelectReturningOne . selectMatchingLabel $ label
    case res' of
      Nothing -> do
        infot "label not found"
        void $ tellt ctx "label not found"
      Just (BotMsg mid chid _ _) -> do
        void . usingConn . runUpdate . updateMsg label $ body
        void . invoke $ EditMessage chid mid (editMessageContent (Just . toStrict $ body))
        infot "done"
