module Gundyr.Commands.Reamojis
  ( reamojiGroup,
    listReamojis,
    newReamoji,
    listReamojisForLabel,
    removeReamoji,
  )
where

import Calamity hiding (Member)
import Calamity.Commands
import Calamity.Commands.Context (FullContext)
import Control.Lens hiding (Context)
import Control.Monad
import Data.Text.Lazy (Text)
import qualified Data.Text.Lazy as L
import Database.Beam
import Gundyr.Commands.Permissions
import Gundyr.Db as DB
import Gundyr.Util
import Polysemy (Member, Sem)
import TextShow (showtl)

reamojiGroup :: (BotC r, Member DBEff r) => Sem (DSLState FullContext r) ()
reamojiGroup = void
  . help (const "group for emoji reaction - role assignment stuff")
  . requireManageRole
  . groupA "reamoji" ["rea"]
  $ do
    listReamojis
    newReamoji
    listReamojisForLabel
    removeReamoji

listReamojis :: (BotC r, Member DBEff r) => Sem (DSLState FullContext r) ()
listReamojis = void
  . help (const "list all reamojis")
  . command @'[] "list"
  $ \ctx -> do
    infot "Retrieving reamojis"
    res <-
      usingConn . runSelectReturningList . select
        . orderBy_
          (asc_ . (^. #label) . fst)
        $ allReamojiWithMsg
    unless (null res) . void . tellt ctx . L.unlines
      . map
        ( \r ->
            codeline
              (label . fst $ r)
              <> " + "
              <> codeline (showtl (DB.emoji . snd $ r))
              <> " -> "
              <> mention (role_id . snd $ r)
        )
      $ res

newReamoji :: (BotC r, Member DBEff r) => Sem (DSLState FullContext r) ()
newReamoji = void
  . help (const "create new reamoji")
  . command
    @'[ Named "label" Text,
        Named "emoji" RawEmoji,
        Named "role" (Snowflake Role)
      ]
    "new"
  $ \ctx label emo role -> do
    infot "adding new reamoji"
    msg' <-
      usingConn
        . runSelectReturningOne
        . selectMatchingLabel
        $ label
    case msg' of
      Nothing -> do
        infot "label not found"
        void $ tellt ctx "label not found"
      Just msg -> do
        usingConn . runInsert $ addReamoji (msg ^. #msg_id) emo role
        void . invoke $
          CreateReaction
            (msg ^. #channel_id)
            (msg ^. #msg_id)
            emo
        infot "done"

listReamojisForLabel :: (BotC r, Member DBEff r) => Sem (DSLState FullContext r) ()
listReamojisForLabel = void
  . help (const "list reamojis for a bot message")
  . commandA @'[Named "Label" Text] "for-label" ["for"]
  $ \ctx label -> do
    infot $ "listing reamojis for label: " <> label
    res <-
      fmap snd
        <$> (usingConn . runSelectReturningList . select $ reamojiWithLabel label)
    unless
      (null res)
      ( void . tellt ctx . L.unlines
          . map
            (\r -> showtl (DB.emoji r) <> " -> " <> mention (role_id r))
          $ res
      )

removeReamoji :: (BotC r, Member DBEff r) => Sem (DSLState FullContext r) ()
removeReamoji = void
  . help (const "remove a reamoji")
  . command
    @'[ Named "label" Text,
        Named "emoji" RawEmoji
      ]
    "remove"
  $ \_ label emo -> do
    infot $
      "removing reamoji for msg: " <> label <> " emoji: "
        <> showtl emo
    res <-
      usingConn . runSelectReturningOne . select $
        reamojiWithLabelAndEmoji label emo
    case res of
      Just (msg, _) -> do
        usingConn . runDelete $ deleteReamoji label emo
        void . invoke $ DeleteOwnReaction (msg ^. #channel_id) (msg ^. #msg_id) emo
        infot "done"
      _ -> return ()
