module Gundyr.Commands.Permissions
  ( hasPermission,
    requireAdmin,
    requireManageRole,
  )
where

import Calamity
import Calamity.Commands
import Calamity.Commands.Context (FullContext)
import Control.Lens
import Data.Flags
import Data.Maybe
import Data.Text.Lazy (Text)
import Gundyr.Util
import Polysemy (Sem)
import TextShow

hasPermission ::
  BotC r =>
  Permissions ->
  Text ->
  Sem (DSLState FullContext r) a ->
  Sem (DSLState FullContext r) a
hasPermission perm noperm = requires' "manages roles" \ctx -> do
  infot "haspermission check"
  if isNothing $ ctx ^. #guild
    then return $ Just "not guild member or not in a guild"
    else do
      let (g, u) = (fromJust (ctx ^. #guild), fromJust $ ctx ^. #member)
          userPerms = permissionsIn (g :: Guild) u
      infot (showtl userPerms)
      if userPerms `containsAll` perm
        then return Nothing
        else return (Just noperm)

requireAdmin :: BotC r => Sem (DSLState FullContext r) a -> Sem (DSLState FullContext r) a
requireAdmin = hasPermission administrator "not an admin"

requireManageRole :: BotC r => Sem (DSLState FullContext r) a -> Sem (DSLState FullContext r) a
requireManageRole = hasPermission manageRoles "can't manage roles"
