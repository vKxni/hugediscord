module Gundyr.Db.Schema
  ( BotMsgT (..),
    BotMsg,
    RolePairT (..),
    RolePair,
    ReamojiT (..),
    Reamoji,
    PrimaryKey (..),
    BotDB,
    db,
    module Gundyr.Db.Instances,
  )
where

import Calamity
import Control.Lens
import Data.Text.Lazy (Text)
import Database.Beam
import Database.Beam.Sqlite
import Gundyr.Db.Instances

data BotMsgT f = BotMsg
  { msg_id :: C f (Snowflake Message),
    channel_id :: C f (Snowflake Channel),
    label :: C f Text,
    msg_body :: C f Text
  }
  deriving (Generic, Beamable)

type BotMsg = BotMsgT Identity

deriving instance Show BotMsg

instance Table BotMsgT where
  data PrimaryKey BotMsgT f = BotMsgKey (C f (Snowflake Message))
    deriving (Generic, Beamable)
  primaryKey botmsg = BotMsgKey (botmsg ^. #msg_id)

data RolePairT f = RolePair
  { role_id1 :: C f (Snowflake Role),
    role_id2 :: C f (Snowflake Role)
  }
  deriving (Generic, Beamable)

type RolePair = RolePairT Identity

deriving instance Show RolePair

instance Table RolePairT where
  data PrimaryKey RolePairT f
    = RolePairKey (C f (Snowflake Role)) (C f (Snowflake Role))
    deriving (Generic, Beamable)
  primaryKey rt = RolePairKey (rt ^. #role_id1) (rt ^. #role_id2)

data ReamojiT f = Reamoji
  { _msg_id :: PrimaryKey BotMsgT f, --C f (Snowflake Message)
    emoji :: C f RawEmoji,
    role_id :: C f (Snowflake Role)
  }
  deriving (Generic, Beamable)

type PKBotMsg = PrimaryKey BotMsgT Identity

deriving instance Show PKBotMsg

type Reamoji = ReamojiT Identity

deriving instance Show Reamoji

instance Table ReamojiT where
  data PrimaryKey ReamojiT f
    = ReamojiKey (PrimaryKey BotMsgT f) (C f (Snowflake Role))
    deriving (Generic, Beamable)
  primaryKey reamoji = ReamojiKey (reamoji ^. #_msg_id) (reamoji ^. #role_id)

data BotDB f = BotDB
  { botMessages :: f (TableEntity BotMsgT),
    reamojis :: f (TableEntity ReamojiT),
    prereqs :: f (TableEntity RolePairT),
    removes :: f (TableEntity RolePairT),
    contradicts :: f (TableEntity RolePairT)
  }
  deriving (Generic, Database Sqlite)

db :: DatabaseSettings Sqlite BotDB
db =
  defaultDbSettings
    `withDbModification` dbModification
      { botMessages = setEntityName "messages",
        reamojis =
          modifyTableFields
            tableModification
              { _msg_id = BotMsgKey "msg_id"
              }
      }
