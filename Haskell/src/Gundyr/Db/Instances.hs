{-# OPTIONS_GHC -Wno-orphans #-}

module Gundyr.Db.Instances where

import Calamity
import qualified Data.Aeson as A
import qualified Data.ByteString as B
import qualified Data.ByteString.Lazy as L
import Data.Maybe
import Data.Text.Lazy (Text, unpack)
import Data.Word
import Database.Beam
import Database.Beam.Backend.SQL
import Database.Beam.Backend.SQL.AST
import Database.Beam.Sqlite
import Database.Beam.Sqlite.Syntax

newtype Roles = Roles [Snowflake Role] deriving (Eq, Show)

type Alias = Text

deriving via Word64 instance HasSqlValueSyntax Value (Snowflake a)

deriving via Word64 instance HasSqlValueSyntax SqliteValueSyntax (Snowflake a)

deriving via Word64 instance FromBackendRow Sqlite (Snowflake a)

instance HasSqlEqualityCheck Sqlite (Snowflake a)

instance HasSqlEqualityCheck Sqlite RawEmoji

instance HasSqlValueSyntax be B.ByteString => HasSqlValueSyntax be RawEmoji where
  sqlValueSyntax emo = sqlValueSyntax . L.toStrict . A.encode $ emo

instance FromBackendRow Sqlite RawEmoji where
  fromBackendRow = fromMaybe (UnicodeEmoji "error") . A.decode @RawEmoji <$> fromBackendRow

instance HasSqlValueSyntax be String => HasSqlValueSyntax be Roles where
  sqlValueSyntax (Roles xs) = sqlValueSyntax . unwords $ show . fromSnowflake <$> xs

instance FromBackendRow Sqlite Roles where
  fromBackendRow = Roles . map (Snowflake . read) . words . unpack <$> fromBackendRow
