module Handlers
       ( Title
       , Dictionary
       , makeTextMap
       , mergeWithNum
       , searchInMap
       , zipWithMap
       ) where

import           Data.ByteString.Char8 (ByteString)
import           Data.HashMap.Strict (HashMap)
import           Data.Maybe (isNothing)
import           Data.Text (Text)
import           Data.Text.Encoding (decodeUtf8)
import           Path (Abs, File, Path, filename, fromRelFile)

import           Prettify (blueCode, boldCode, cyanCode, greenCode, resetCode)

import qualified Data.ByteString.Char8 as BC
import qualified Data.HashMap.Strict as HMS
import qualified Data.Text as T


type Title = ByteString

type Dictionary = HashMap ByteString ByteString

-- | Make Map from raw file. Merge duplicates to on key without delete.
makeTextMap :: ByteString -> Dictionary
makeTextMap
    = HMS.fromListWith (\a1 a2 -> if a1 == a2 then a1 else BC.concat [a1, "\n", a2])
    . map ((\(y,x) -> (y, BC.drop 1 x))
    . BC.span (<'|'))
    . BC.lines

-- | Combine dictionary titles with mapped dictionaries.
zipWithMap :: [ByteString] -> [Path Abs File] -> [(Dictionary, Title)]
zipWithMap texts files = zip mapped titles
  where
    mapped :: [Dictionary]
    mapped = map makeTextMap texts

    titles :: [Title]
    titles = map (BC.drop 3 . BC.pack . fromRelFile . filename) files

-- Search in mapped dictionary.
searchInMap :: ByteString -> [(Dictionary, Title)] -> [(ByteString, Title)]
searchInMap query mapped = [(text, title) | (Just text, title) <- searched]
  where
    searched :: [(Maybe ByteString, Title)]
    searched = foldl (\ acc (x,y) -> if isNothing (search x) then acc else (search x, y) : acc) [] mapped

    search :: Dictionary -> Maybe ByteString
    search = HMS.lookup query

-- | Add numbers and flatten.
mergeWithNum :: [(ByteString, Title)] -> Text
mergeWithNum = T.unlines . zipWith flatten numbers
  where
    -- Add numbers.
    numbers :: [Text]
    numbers = map ((\x -> greenCode <> T.append (T.pack x) ". " <> resetCode) . show) [1::Int ..]

    flatten :: Text -> (ByteString, Title) -> Text
    flatten number (value, title) = T.append (T.append number (T.append (prettyT title) "\n")) (marked value)
    -- Paint title
    prettyT :: Title -> Text
    prettyT title = blueCode <> boldCode <> decodeUtf8 title <> resetCode

    marked :: ByteString -> Text
    marked value = T.unlines . map (\v -> cyanCode <> "► " <> resetCode <> v) $ T.lines (decodeUtf8 value)

