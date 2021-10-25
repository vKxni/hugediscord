module Gundyr.Util
  ( tellt,
    infot,
    debugt,
    coerceSnowflake',
  )
where

import Calamity
import Data.Text.Lazy (Text)
import DiPolysemy
import Polysemy

tellt :: (BotC r, Tellable t) => t -> Text -> Sem r (Either RestError Message)
tellt = tell

infot :: BotC r => Text -> Sem r ()
infot = info @Text

debugt :: BotC r => Text -> Sem r ()
debugt = info @Text

coerceSnowflake' :: forall b a. Snowflake a -> Snowflake b
coerceSnowflake' = coerceSnowflake
