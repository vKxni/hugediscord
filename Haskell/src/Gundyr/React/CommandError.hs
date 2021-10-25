module Gundyr.React.CommandError
  ( cmdErrRct,
  )
where

import Calamity
import Calamity.Commands
import Calamity.Commands.Context (FullContext)
import Control.Monad
import qualified Data.Text.Lazy as L
import DiPolysemy
import qualified Polysemy as P
import TextShow (showtl)

cmdErrRct :: BotC r => P.Sem r (P.Sem r ())
cmdErrRct = react @('CustomEvt (FullContext, CommandError)) \(ctx, e) -> do
  info $ "Command failed with reason: " <> showtl e
  case e of
    ParseError n r ->
      void . tell ctx $
        "Failed to parse parameter: " <> codeline (L.fromStrict n)
          <> ", with reason: "
          <> codeblock' Nothing r
    CheckError n r ->
      void . tell ctx $
        "The following check failed: " <> codeline (L.fromStrict n)
          <> ", with reason: "
          <> codeblock' Nothing r
    InvokeError n r ->
      void . tell ctx $
        "The command: " <> codeline (L.fromStrict n)
          <> ", failed with reason: "
          <> codeblock' Nothing r
