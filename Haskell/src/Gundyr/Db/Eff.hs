module Gundyr.Db.Eff
  ( DBEff (..),
    runDBEffPooled,
    usingConn,
  )
where

import Data.Pool
import Database.Beam.Sqlite (SqliteM, runBeamSqlite)
import Database.SQLite.Simple (Connection)
import Polysemy

data DBEff m a where
  UsingConn :: SqliteM a -> DBEff m a

makeSem ''DBEff

runDBEffPooled :: forall r a. Member (Embed IO) r => Pool Connection -> Sem (DBEff ': r) a -> Sem r a
runDBEffPooled pool = interpret \case UsingConn m -> embed $ withResource pool (flip runBeamSqlite m)
