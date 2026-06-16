module Repl
    ( repl
    , load )
where

import AST                      ( Envr, Instr(..) )
import Evaluator                ( eval )
import Parser                   ( parse )

import Control.Monad            ( foldM )
import Control.Monad.IO.Class   ( liftIO )
import System.Console.Haskeline -- TODO

repl :: Envr -> IO ()
repl = (runInputT defaultSettings) . loop

loop :: Envr -> InputT IO ()
loop env = do
    minput <- getInputLine "λ> "
    case minput of
        Nothing    -> loop env
        Just input ->
            case parse input of
                Left err          -> outputShowLn err             >> loop env
                Right (Eval expr) -> outputShowLn (eval env expr) >> loop env
                Right (Bind x e)  -> loop ((x, eval env e) : env)
                Right Help        -> outputStr help               >> loop env
                Right Quit        -> return ()
                Right (Info x)    -> do
                    case lookup x env of
                        Nothing -> outputStrLn $ "<!> \"" ++ x ++ "\" is not defined."
                        Just e  -> outputShowLn e
                    loop env
                Right (Save p)  -> liftIO (save env p)            >> loop env
                Right (Load ps) -> liftIO (foldM load env ps)     >>= loop

{-
 - Utility
 -}
outputShowLn :: Show a => a -> InputT IO () 
outputShowLn = outputStrLn . show

showEnv :: Envr -> String
showEnv = unlines . reverse . map (\(x,e) -> x ++ " := " ++ show e)
-- TODO: use foldr

save :: Envr -> FilePath -> IO ()
save env path = do
    writeFile path $ showEnv env

load :: Envr -> FilePath -> IO Envr
load env path = do
    content <- readFile path
    let ls = lines content
    return $ foldl loadLine env ls

loadLine :: Envr -> String -> Envr
loadLine env line =
    case parse line of
        Right (Bind x e) -> (x, eval env e) : env
        _                -> env

help :: String
help = unlines
    [ " ================================================================================ "
    , " # Commands:                                                                    # "
    , " #                                                                              # "
    , " #     :help                   show commands                                    # "
    , " #     :quit                   exit repl                                        # "
    , " #     :info <name>            show information about <name>                    # "
    , " #     :save <path>            save bindings to <path>                          # "
    , " #     :load [<path>]          load source file(s)                              # "
    , " ================================================================================ " ]
