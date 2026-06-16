module AST
    ( Name
    , Envr
    , Instr(..)
    , Expr(..) )
where

type Name = String
type Envr = [(Name, Expr)]

{-
 - Instruction
 -}
data Instr
    = Eval Expr
    | Bind Name Expr
    | Quit
    | Help
    | Info Name
    | Save FilePath
    | Load [FilePath]

{-
 - Expression
 -}
data Expr
    = Var Name
    | Lam Name Expr
    | Clo Name Expr Envr
    | App Expr Expr

instance Show Expr where
    show :: Expr -> String
    show (Var x)     = x
    show (Lam p b)   = "λ" ++ showLambda p b
    show (Clo p b e) = case foldr (subs 0) (Lam p b) e of
                         Lam p' b' -> "λ" ++ showLambda p' b'
                         f     -> show f
    show (App f a)   = showLeft f ++ " " ++ showRight a

showLambda :: Name -> Expr -> String
showLambda x (Lam y b)   = x ++ " " ++ showLambda y b
showLambda x (Clo y b _) = x ++ " " ++ showLambda y b
showLambda x b           = x ++ "." ++ show b

showLeft :: Expr -> String
showLeft f@(Lam _ _) = "(" ++ show f ++ ")"
showLeft f@(Clo _ _ _) = "(" ++ show f ++ ")"
showLeft e           = show e

showRight :: Expr -> String
showRight (Var x) = x
showRight e       = "(" ++ show e ++ ")"

subs :: Int -> (Name, Expr) -> Expr -> Expr
subs _ (t, r) (Var x)
    | t == x    = r
    | otherwise = Var x
subs i (t, r) (Lam p b)
    | t == p    = Lam p b
    | p `isVarOf` r = do
        let p' = p ++ show i
        let b' = subs (i + 1) (p, Var p') b
        Lam p' (subs (i + 1) (t, r) b')
    | otherwise = Lam p (subs i (t, r) b)
subs i r (Clo p b e) =
    Clo p (subs i r b) (map (\(k, v) -> (k, subs i r v)) e)
subs i r (App f a) =
    App (subs i r f) (subs i r a)

isVarOf :: Name -> Expr -> Bool
isVarOf x (Var y)     = x == y
isVarOf x (Lam p b)   = x /= p && x `isVarOf` b
isVarOf x (Clo p b e) = x /= p && x `notElem` map fst e && x `isVarOf` b
isVarOf x (App f a)   = x `isVarOf` f || x `isVarOf` a
