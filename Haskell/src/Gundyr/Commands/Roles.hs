module Gundyr.Commands.Roles
  ( roleGroup,
    addPrereq,
    addContradict,
    addRemove,
    removePrereq,
    removeContradict,
    removeRemove,
    roleInfo,
  )
where

import Calamity hiding (Member)
import Calamity.Commands
import Calamity.Commands.Context (FullContext)
import Control.Lens hiding (Context)
import Control.Monad
import qualified Data.Text.Lazy as L
import Database.Beam
import Gundyr.Commands.Permissions
import Gundyr.Db
import Gundyr.Util
import Polysemy (Member, Sem)

roleGroup :: (BotC r, Member DBEff r) => Sem (DSLState FullContext r) ()
roleGroup = help (const "group for managing role relationships")
  . requireManageRole
  . groupA "role" ["ro"]
  $ do
    roleInfo
    addPrereq
    addContradict
    addRemove
    removePrereq
    removeContradict
    removeRemove

addPrereq :: (BotC r, Member DBEff r) => Sem (DSLState FullContext r) ()
addPrereq = void
  . help (const "add prerequisite roles for a role.")
  . command
    @'[ Named "role" (Snowflake Role),
        Named "requirement" [Snowflake Role]
      ]
    "add-prereq"
  $ \_ role1 roles -> do
    mapM_ (usingConn . runInsert . (role1 `prereq`)) roles

addContradict :: (BotC r, Member DBEff r) => Sem (DSLState FullContext r) ()
addContradict = void
  . help (const "add contradicting roles for a role.")
  . command
    @'[ Named "role" (Snowflake Role),
        Named "contradicts" [Snowflake Role]
      ]
    "add-contradict"
  $ \_ role1 roles -> do
    mapM_ (usingConn . runInsert . (role1 `contradict`)) roles

addRemove :: (BotC r, Member DBEff r) => Sem (DSLState FullContext r) ()
addRemove = void
  . help (const "add roles to be removed upon receiving a role.")
  . command
    @'[ Named "role" (Snowflake Role),
        Named "to-be-removed" [Snowflake Role]
      ]
    "add-remove"
  $ \_ role1 roles -> do
    mapM_ (usingConn . runInsert . (role1 `removes`)) roles

removePrereq :: (BotC r, Member DBEff r) => Sem (DSLState FullContext r) ()
removePrereq = void
  . help (const "remove prereq roles for a role")
  . command
    @'[ Named "role" (Snowflake Role),
        Named "requirement" [Snowflake Role]
      ]
    "no-prereq"
  $ \_ role1 roles -> do
    mapM_ (usingConn . runDelete . (role1 `noprereq`)) roles

removeContradict :: (BotC r, Member DBEff r) => Sem (DSLState FullContext r) ()
removeContradict = void
  . help (const "remove contradicts roles for a role")
  . command
    @'[ Named "role" (Snowflake Role),
        Named "contradict" [Snowflake Role]
      ]
    "no-contradict"
  $ \_ role1 roles -> do
    mapM_ (usingConn . runDelete . (role1 `nocontradict`)) roles

removeRemove :: (BotC r, Member DBEff r) => Sem (DSLState FullContext r) ()
removeRemove = void
  . help (const "listed roles won't be removed upon receiving a role anymore")
  . command
    @'[ Named "role" (Snowflake Role),
        Named "requirement" [Snowflake Role]
      ]
    "no-remove"
  $ \_ role1 roles -> do
    mapM_ (usingConn . runDelete . (role1 `noremoves`)) roles

roleInfo :: (BotC r, Member DBEff r) => Sem (DSLState FullContext r) ()
roleInfo = void
  . help (const "show info about role")
  . command
    @'[ Named "role" (Snowflake Role)
      ]
    "info"
  $ \ctx role1 -> do
    infot "Retrieving "
    let selectUsing = usingConn . runSelectReturningList . select . ($ role1)
    res1 <-
      map (L.unwords . map (mention . (^. #role_id2)))
        <$> mapM selectUsing [allPrereqs, allContradicts, allRemoves]
    res2 <-
      map (L.unwords . map (mention . (^. #role_id1)))
        <$> mapM selectUsing [allPrereqs', allContradicts', allRemoves']
    case (res1, res2) of
      ([r1, r2, r3], [r1', r2', r3']) -> do
        void . tellt ctx $
          L.unlines
            [ "Role " <> mention role1,
              "Requires: " <> r1,
              "Cannot be given to: " <> r2,
              "Will remove " <> r3 <> " upon receival",
              "Is required by: " <> r1',
              "Inhibits user from receiving: " <> r2',
              "Is removed by " <> r3' <> " when received"
            ]
      _ -> void . tellt ctx $ "ERROR"
    return ()
