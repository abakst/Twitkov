module Search where

import Network.HTTP
import Text.JSON
import Text.JSON.String

data Query = StrQuery String
             
-- Twitter Stuff --
resource = "http://search.twitter.com/search.json"
buildQuery q n page = resource ++ "?q=" ++ stringify q ++ options
  where stringify (StrQuery str)  = str
        options = "&rpp=" ++ (show n) ++ "&page=" ++ (show page)
        
maxPages = 15
maxTweets = 100
      
retrieveAllTweets :: Query -> IO [String]
retrieveAllTweets q = loop 1 (return [])
  where 
    loop n strs 
      | n > maxPages = strs
      | otherwise = do 
        s <- retrieveTweets q maxTweets n
        if s == [] then strs else loop (n + 1) (fmap (s ++) strs)
                          
           
retrieveTweets :: Query -> Int -> Int -> IO [String]
retrieveTweets q n page = do
  let response = simpleHTTP (getRequest str) >>= getResponseBody
  -- response >>= putStrLn
  fmap extractMessages response
  -- simpleHTTP (getRequest str) >>= fmap extractMessages . getResponseBody
  where str = buildQuery q n page 
        
extractMessages str = 
  case runGetJSON readJSObject str of
    Left err -> error err
    Right (JSObject obj) -> 
      case valFromObj "results" obj :: Result [JSObject JSValue] of
        Error err -> error err
        Ok v      -> map getMessages v
    where getMessages o = 
            case valFromObj "text" o :: Result JSString of
              Error err -> error err
              Ok v -> fromJSString v 
  