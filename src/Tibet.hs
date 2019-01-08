module Tibet
       ( start
       ) where

import Control.DeepSeq (deepseq)
import Control.Monad (forever, when)
import Control.Monad.Trans.Class (lift)
import Control.Monad.Trans.State.Strict (evalStateT, execStateT, get, put, withStateT)
import Path (fromAbsFile)
import Path.Internal (Path (..))
import Path.IO (listDir)
import Paths_tibet (getDataFileName)
import System.Exit
import System.IO (stderr)

import Handlers (Dictionary, History, Title, mergeWithNum, searchInMap, selectDict, zipWithMap)
import Labels (labels)
import Prettify (blue, green, putTextFlush, red)
import Parse (fromTibetan)

import qualified Data.ByteString.Char8 as BC


-- | Iterator with state holding.
iterateM :: Monad m => (History -> m History) -> History -> m ()
iterateM f = evalStateT $ forever $ get >>= lift . f >>= put

start :: Maybe [Int] -> IO ()
start mSelectedId = do
    dir <- getDataFileName "dicts/"
    (_, files) <- listDir $ Path dir
    texts <- mapM (BC.readFile . fromAbsFile) files
    mappedFull <- zipWithMap texts files <$> labels
    let mapped = selectDict mSelectedId mappedFull
    let history = get
    mapped `deepseq` translator mapped history

-- | A loop handler of user commands.
translator :: [(Dictionary, (Title, Int))] -> History -> IO ()
translator mapped = iterateM $ \history -> do
    putTextFlush $ blue "Which a tibetan word to translate?"
    query <- BC.hPutStr stderr "> " >> BC.getLine
    case query of
        ":q" -> do
            putTextFlush $ green "Bye-bye!"
            exitSuccess
        ":h" -> do
            history' <- execStateT history []
            when (null history') (putTextFlush $ red "No success queries.")
            putTextFlush $ green "Success queries:"
            mapM_ (\h -> BC.putStrLn $ "- " <> h) history'
            putTextFlush ""
            pure history
        _    ->
            case fromTibetan query of
                Nothing -> do
                    nothingFound
                    pure history
                Just query' -> do
                    let dscValues = searchInMap query' mapped
                    if null dscValues then do
                        nothingFound
                        pure history
                    else do
                        putTextFlush $ mergeWithNum dscValues
                        pure $ withStateT (query :) history

nothingFound :: IO ()
nothingFound = do
    putTextFlush $ red "Nothing found."
    putTextFlush ""
