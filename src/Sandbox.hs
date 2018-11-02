module Sandbox where

import           Data.Text (Text)
import           Prettify (putTextFlush)
import           System.IO (hPrint, stderr)

import qualified Data.Text as T
import qualified Data.Text.IO as IO


-- | Show duplicates and write to file.
getDubs :: IO ()
getDubs = do
    berzin <- IO.readFile "dics/03-Berzin"
    putTextFlush "Berzin file is loaded"
    let dubs = findDups berzin
    IO.writeFile "dics/dubs" $ T.pack $ show dubs
    hPrint stderr dubs

-- | List tuples of duplicates only from raw file.
findDups :: Text -> [(Text,Text)]
findDups
    = dups
    . map ((\(y,x) -> (y, T.drop 1 x))
    . T.span (<'|'))
    . T.lines

-- | Get duplicate tuples only.
dups :: Eq k => [(k,v)] -> [(k,v)]
dups []     = []
dups (x:xs) =  d ++ dups r
  where
    (d,r) = (resultDub x, filter (\(y,_) -> fst x /= y) xs)
    isDub = filter (\(y,_) -> fst x == y) xs
    resultDub first | null isDub = []
                    | otherwise  = first : isDub

-- | Remove empty answers
mapMaybeTuple :: (a -> Maybe b) -> [(a,t)] -> [(b,t)]
mapMaybeTuple _ [] = []
mapMaybeTuple f ((x, t):xs) =
    let rs = mapMaybeTuple f xs in
    case (f x, t) of
        (Nothing, _) -> rs
        (Just r, n)  -> (r,n):rs

-- | Combine answers with numbering for raw text.
zipWithRaw :: [Text] -> [Path Abs File] -> [(Text, Title)]
zipWithRaw texts files = zip texts titles
  where
    titles :: [Text]
    titles = map (T.drop 3 . T.pack . fromRelFile . filename) files

-- | Search in raw dictionary files.
searchInRaw :: Text -> [(Text, Title)] -> [(Text, Title)]
searchInRaw query = foldl (\ acc (x,y) -> if search x == "" then acc else (search x, y) : acc) []
  where
    search :: Text -> Text
    search
        = T.unlines
        . map (T.append (cyanCode <> "༔ " <> resetCode) . T.drop 1 . T.dropWhile (/= '|'))
        . filter (T.isPrefixOf (T.append query "|"))
        . T.lines