module Evaluator
    ( eval )
where

import AST ( Envr, Expr(..) )

eval :: Envr -> Expr -> Expr
eval env (Var x) =
    case lookup x env of
        Nothing -> Var x
        Just e  -> e
eval env (Lam p b) = Clo p b env
eval _ c@(Clo _ _ _) = c
eval env (App f a) = do
    let vf = eval env f
    let va = eval env a
    case vf of
        Clo p b e -> eval ((p, va) : e) b
        _         -> App vf va
