module Gundyr.Commands.Util where

import Calamity
import Calamity.Commands.Context (FullContext)
import Control.Lens hiding (Context)
import Data.Bitraversable

memAndGuildFromCtx :: FullContext -> Maybe (Member, Guild)
memAndGuildFromCtx ctx = bisequence (ctx ^. #member, ctx ^. #guild)
