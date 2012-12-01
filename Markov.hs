module Markov where

import Data.List (tails)
import Data.Char
import Data.Function
import qualified Data.Map as M
import System.Random

type Model = (Int, M.Map String (Int, [String]))
             
find k (i, m) = M.lookup k m

buildModel :: Int -> String -> Model
buildModel k text = (k, M.map (\l -> (length l, l)) $ foldl add M.empty (tails . words $ text))
  where add m text 
          | length text > k = 
            M.insertWith (++) (mkKey text) (mkVal text) m
          | otherwise = m
        mkKey = (fmap toLower) . unwords . take k
        mkVal txt = [head $ drop k txt]
        
emptyModel k = (k, M.empty)
        
mergeModels :: Model -> Model -> Model
mergeModels (k1, m1) (k2, m2) 
  | k1 == k2 = (k1, M.unionWith (\(n1,l1) (n2,l2) -> (n1+n2, l1++l2)) m1 m2)
  | otherwise = (0, M.empty)
                    
pickRandomElt :: RandomGen a => a -> Int -> [t] -> (t, a)
pickRandomElt rgen n lst = let (i, g') = randomR (0, n-1) rgen
                           in (lst !! i, g')
                              
pickRandomVal :: RandomGen a => a -> Model -> (String, a)
pickRandomVal g model = nextWord g' model k
  where
    keys  = M.keys (snd model)
    nkeys = length keys
    (k,g') = pickRandomElt g nkeys keys
    
nextWord :: RandomGen a => a -> Model -> String -> (String, a)
nextWord g m k = case find (fmap toLower k) m of
  Nothing -> pickRandomVal g m
  Just (n, ss) -> pickRandomElt g n ss
                              
initialString :: RandomGen a => a -> Model -> (String, a)
initialString rgen (k, m) = pickRandomElt rgen num values
  where 
    values = M.keys m
    num  = length values
                              
generateText :: Int -> Int -> Model -> String
generateText seed n model = buildText g n (reverse $ words init)
  where 
    g0         = mkStdGen seed 
    (init, g)  = initialString g0  model
    buildText :: StdGen -> Int -> [String] -> String
    buildText g 0 strs = unwords . reverse $ strs
    buildText g n strs = buildText g' (n-1) (next : strs)
      where key = unwords . reverse . take (fst model) $ strs
            (next, g') = nextWord g model key