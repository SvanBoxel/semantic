{-# LANGUAGE GeneralizedNewtypeDeriving #-}
module Data.Semigroup.App
( App(..)
, AppMerge(..)
) where

import Control.Applicative
import Data.Semigroup

-- $setup
-- >>> import Test.QuickCheck
-- >>> instance Arbitrary (f a) => Arbitrary (App f a) where arbitrary = App <$> arbitrary ; shrink = map App . shrink . runApp
-- >>> instance Arbitrary (f a) => Arbitrary (AppMerge f a) where arbitrary = AppMerge <$> arbitrary ; shrink = map AppMerge . shrink . runAppMerge

-- | 'Semigroup' under '*>'.
newtype App f a = App { runApp :: f a }
  deriving (Alternative, Applicative, Bounded, Enum, Eq, Foldable, Functor, Monad, Ord, Show, Traversable)

-- $ Associativity:
--   prop> \ a b c -> a <> (b <> c) == (a <> b) <> (c :: App Maybe Integer)
instance Applicative f => Semigroup (App f a) where
  App a <> App b = App (a *> b)

instance (Applicative f, Monoid a) => Monoid (App f a) where
  mempty = App (pure mempty)
  mappend = (<>)


-- | 'Semigroup' under '<*>' and '<>'.
newtype AppMerge f a = AppMerge { runAppMerge :: f a }
  deriving (Alternative, Applicative, Bounded, Enum, Eq, Foldable, Functor, Monad, Ord, Show, Traversable)

-- $ Associativity:
--   prop> \ a b c -> a <> (b <> c) == (a <> b) <> (c :: AppMerge Maybe String)
instance (Applicative f, Semigroup a) => Semigroup (AppMerge f a) where
  AppMerge a <> AppMerge b = AppMerge ((<>) <$> a <*> b)

instance (Applicative f, Monoid a, Semigroup a) => Monoid (AppMerge f a) where
  mempty = AppMerge (pure mempty)
  mappend = (<>)
