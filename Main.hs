module Main where

import Data.List
import Search
import Markov
import System.Environment  
import System.Random
  
tweetModel :: Int -> Query -> IO Model
tweetModel k q = do 
  msgs <- retrieveAllTweets q
  return $ foldl' joinNewModel (emptyModel k) msgs
  where 
    joinNewModel l r = l `mergeModels` buildModel k r

generateFromTweets seed n k q = do
  m <- tweetModel k q
  return (generateText seed n m)
  
generateTweet = take 140
                
main :: IO ()
main = do
  seed <- randomIO
  [k, search] <- getArgs
  str <- fmap generateTweet $ generateFromTweets seed 50 (read k) (StrQuery search)
  putStrLn str 
  return ()
  