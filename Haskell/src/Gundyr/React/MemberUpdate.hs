module Gundyr.React.MemberUpdate
  ( memRct,
    reactGuildMemberUpdateEvt,
  )
where

import Calamity as C
import Control.Lens
import Control.Monad
import qualified Data.Vector.Unboxing as VU
import Database.Beam
import Gundyr.Db
import Gundyr.Util
import qualified Polysemy as P
import TextShow

reactGuildMemberUpdateEvt :: (BotC r, P.Member DBEff r) => P.Sem r (P.Sem r ())
reactGuildMemberUpdateEvt = react @'GuildMemberUpdateEvt $ \case
  (mem, mem')
    | mem ^. #roles /= mem' ^. #roles -> reactMemberRoleUpdate mem mem'
    | otherwise -> return ()

reactMemberRoleUpdate :: (BotC r, P.Member DBEff r) => Member -> Member -> P.Sem r ()
reactMemberRoleUpdate mem mem'
  | VU.length (mem ^. #roles) < VU.length (mem' ^. #roles) = do
    infot "new role added"
    let newRole = VU.head . VU.filter (`VU.notElem` (mem ^. #roles)) $ mem' ^. #roles
    infot $ mention newRole <> showtl newRole
    rolesToRemove <- fmap (view #role_id2) <$> (usingConn . runSelectReturningList . select $ allRemoves newRole)
    infot $ showtl rolesToRemove <> " will be removed if exists."
    forM_ (VU.toList $ mem' ^. #roles) $ \role ->
      when (role `elem` rolesToRemove) $ void . invoke $ RemoveGuildMemberRole mem' mem' role
  | otherwise = return ()

memRct :: BotC r => P.Sem r (P.Sem r ())
memRct = react @'GuildMemberUpdateEvt \(mem, mem') ->
  when
    (roleInit `VU.elem` (mem ^. #roles) && roleMember `VU.elem` (mem' ^. #roles))
    (void . invoke $ RemoveGuildMemberRole mem mem roleInit)
  where
    roleInit = Snowflake @Role 764143270573375489
    roleMember = Snowflake @Role 763167512539955241
