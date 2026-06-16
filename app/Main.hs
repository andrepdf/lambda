module Main
    ( main )
where

import Repl               ( repl, load )

import System.Environment ( getArgs )

main :: IO ()
main = do
    args <- getArgs
    if "--no-std" `elem` args
        then repl []
        else load [] "std/std.lambda" >>= repl
