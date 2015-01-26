module Data.Argonaut.Combinators
  ( (:=)
  , (?:=)
  , (~>)
  , (?~>)
  , (?>>=)
  , (.?)
  ) where

  import Data.Argonaut.Core
    ( foldJsonObject
    , fromObject
    , jsonSingletonObject
    , Json()
    , JAssoc()
    , JObject()
    )
  import Data.Argonaut.Encode (encodeJson, EncodeJson)
  import Data.Argonaut.Decode (DecodeJson, decodeJson)
  import Data.Either (Either(..))
  import Data.Maybe (Maybe(..), maybe)
  import Data.Tuple (Tuple(..))

  import qualified Data.StrMap as M

  infix 7 :=
  infix 7 .?
  infixr 6 ~>
  infixl 1 ?>>=

  (:=) :: forall a. (EncodeJson a) => String -> a -> JAssoc
  (:=) k v = Tuple k $ encodeJson v

  (?:=) :: forall a. (EncodeJson a) => String -> Maybe a -> Maybe JAssoc
  (?:=) k v = ((:=) k) <<< encodeJson <$> v

  (?~>) :: forall a. (EncodeJson a) => Maybe JAssoc -> a -> Json
  (?~>) (Just kv) x = kv ~> x
  (?~>) Nothing   x = encodeJson x

  (~>) :: forall a. (EncodeJson a) => JAssoc -> a -> Json
  (~>) (Tuple k v) a = foldJsonObject (jsonSingletonObject k v) (M.insert k v >>> fromObject) (encodeJson a)

  (?>>=) :: forall a b. Maybe a -> String -> Either String a
  (?>>=) (Just x) _   = Right x
  (?>>=) _        str = Left $ "Couldn't decode " ++ str

  -- obj .? "foo"
  (.?) :: forall a. (DecodeJson a) => JObject -> String -> Either String a
  (.?) o s = maybe (Left $ "Expected field " ++ show s) decodeJson (M.lookup s o)
