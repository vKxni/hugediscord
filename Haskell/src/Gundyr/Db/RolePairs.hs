module Gundyr.Db.RolePairs
  ( contradict,
    nocontradict,
    prereq,
    noprereq,
    removes,
    noremoves,
    allPrereqs,
    allPrereqs',
    allContradicts,
    allContradicts',
    allRemoves,
    allRemoves',
  )
where

import Calamity
import Control.Lens
import Database.Beam
import Database.Beam.Sqlite
import Gundyr.Db.Schema

contradict ::
  Snowflake Role ->
  Snowflake Role ->
  SqlInsert Sqlite RolePairT
contradict role_id1 role_id2 =
  insert (db ^. #contradicts) . insertValues $
    [RolePair role_id1 role_id2]

nocontradict ::
  Snowflake Role ->
  Snowflake Role ->
  SqlDelete Sqlite RolePairT
nocontradict role_id1 role_id2 = delete (db ^. #contradicts) $
  \r ->
    (r ^. #role_id1) ==. val_ role_id1
      &&. (r ^. #role_id2) ==. val_ role_id2

prereq ::
  Snowflake Role ->
  Snowflake Role ->
  SqlInsert Sqlite RolePairT
prereq role_id1 role_id2 =
  insert (db ^. #prereqs) . insertValues $
    [RolePair role_id1 role_id2]

noprereq ::
  Snowflake Role ->
  Snowflake Role ->
  SqlDelete Sqlite RolePairT
noprereq role_id1 role_id2 = delete (db ^. #prereqs) $
  \r ->
    (r ^. #role_id1) ==. val_ role_id1
      &&. (r ^. #role_id2) ==. val_ role_id2

removes ::
  Snowflake Role ->
  Snowflake Role ->
  SqlInsert Sqlite RolePairT
removes role_id1 role_id2 =
  insert (db ^. #removes) . insertValues $
    [RolePair role_id1 role_id2]

noremoves ::
  Snowflake Role ->
  Snowflake Role ->
  SqlDelete Sqlite RolePairT
noremoves role_id1 role_id2 = delete (db ^. #removes) $
  \r ->
    (r ^. #role_id1) ==. val_ role_id1
      &&. (r ^. #role_id2) ==. val_ role_id2

allPrereqs :: Snowflake Role -> Q Sqlite BotDB s (RolePairT (QExpr Sqlite s))
allPrereqs role =
  filter_
    (\r -> r ^. #role_id1 ==. val_ role)
    (all_ (db ^. #prereqs))

allPrereqs' :: Snowflake Role -> Q Sqlite BotDB s (RolePairT (QExpr Sqlite s))
allPrereqs' role =
  filter_
    (\r -> r ^. #role_id2 ==. val_ role)
    (all_ (db ^. #prereqs))

allContradicts :: Snowflake Role -> Q Sqlite BotDB s (RolePairT (QExpr Sqlite s))
allContradicts role =
  filter_
    (\r -> r ^. #role_id1 ==. val_ role)
    (all_ (db ^. #contradicts))

allContradicts' :: Snowflake Role -> Q Sqlite BotDB s (RolePairT (QExpr Sqlite s))
allContradicts' role =
  filter_
    (\r -> r ^. #role_id2 ==. val_ role)
    (all_ (db ^. #contradicts))

allRemoves :: Snowflake Role -> Q Sqlite BotDB s (RolePairT (QExpr Sqlite s))
allRemoves role =
  filter_
    (\r -> r ^. #role_id1 ==. val_ role)
    (all_ (db ^. #removes))

allRemoves' :: Snowflake Role -> Q Sqlite BotDB s (RolePairT (QExpr Sqlite s))
allRemoves' role =
  filter_
    (\r -> r ^. #role_id2 ==. val_ role)
    (all_ (db ^. #removes))
