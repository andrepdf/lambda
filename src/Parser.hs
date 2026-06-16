module Parser
    ( parse )
where

import AST                        ( Name, Instr(..), Expr(..) )

import qualified Text.Parsec as P ( parse )
import Text.Parsec hiding         ( parse ) -- TODO
import Text.Parsec.String         ( Parser )

parse :: String -> Either ParseError Instr
parse = P.parse (spaces *> instruction <* eof) ""

{-
 - Instruction
 -}
instruction :: Parser Instr
instruction = choice
    [ command
    , try binding
    , Eval <$> expression ]

{-
 - Binding
 -}
binding :: Parser Instr
binding = do
    x <- name
    _ <- (string "=" <|> string ":=") <* spaces
    e <- expression
    return $ Bind x e

{-
 - Commands
 -}
command :: Parser Instr
command = do
    _ <- char ':' <* spaces
    choice
        [ help
        , quit
        , info <*> name
        , save <*> path
        , load <*> paths ]

help :: Parser Instr
help = Help <$ strings ["help", "h"] <* spaces

quit :: Parser Instr
quit = Quit <$ strings ["quit", "q"] <* spaces

info :: Parser (Name -> Instr)
info = Info <$ strings ["info", "i"] <* spaces

save :: Parser (Name -> Instr)
save = Save <$ strings ["save", "s"] <* spaces

load :: Parser ([Name] -> Instr)
load = Load <$ strings ["load", "l"] <* spaces

{-
 - Expression
 -}
expression :: Parser Expr
expression = atom `chainl1` (return App)

atom :: Parser Expr
atom = choice
    [ inside '(' ')' expression
    , lambda
    , variable ]

lambda :: Parser Expr
lambda = do
    _ <- (char '\\' <|> char 'λ') <* spaces
    ps <- names
    _ <- char '.' <* spaces
    b <- expression
    return $ foldr Lam b ps

variable :: Parser Expr
variable = Var <$> name

{-
 - Utility
 -}
name :: Parser Name
name = ((:) <$> letter <*> many alphaNum) <* spaces

names :: Parser [Name]
names = many1 name

path :: Parser String
path = many1 (alphaNum <|> char '/' <|> char '.') <* spaces

paths :: Parser [String]
paths = many1 path

strings :: [String] -> Parser String
strings = choice . map (try . string)

inside :: Char -> Char -> Parser a -> Parser a
inside a b = between (char a <* spaces) (char b <* spaces)
