{-# LANGUAGE DeriveAnyClass #-}
module Language.Markdown.Syntax where

import Prologue hiding (Text)
import Data.ByteString.Char8 (unpack)
import Data.JSON.Fields
import Diffing.Algorithm

newtype Document a = Document [a]
  deriving (Diffable, Eq, Foldable, Functor, GAlign, Generic1, Mergeable, Ord, Show, Traversable)

instance ToJSONFields1 Document

instance Eq1 Document where liftEq = genericLiftEq
instance Ord1 Document where liftCompare = genericLiftCompare
instance Show1 Document where liftShowsPrec = genericLiftShowsPrec


-- Block elements

newtype Paragraph a = Paragraph [a]
  deriving (Diffable, Eq, Foldable, Functor, GAlign, Generic1, Mergeable, Ord, Show, Traversable)

instance ToJSONFields1 Paragraph

instance Eq1 Paragraph where liftEq = genericLiftEq
instance Ord1 Paragraph where liftCompare = genericLiftCompare
instance Show1 Paragraph where liftShowsPrec = genericLiftShowsPrec

data Heading a = Heading { headingLevel :: Int, headingContent :: [a], sectionContent :: [a] }
  deriving (Diffable, Eq, Foldable, Functor, GAlign, Generic1, Mergeable, Ord, Show, Traversable)

instance ToJSONFields1 Heading

instance Eq1 Heading where liftEq = genericLiftEq
instance Ord1 Heading where liftCompare = genericLiftCompare
instance Show1 Heading where liftShowsPrec = genericLiftShowsPrec

newtype UnorderedList a = UnorderedList [a]
  deriving (Diffable, Eq, Foldable, Functor, GAlign, Generic1, Mergeable, Ord, Show, Traversable)

instance ToJSONFields1 UnorderedList

instance Eq1 UnorderedList where liftEq = genericLiftEq
instance Ord1 UnorderedList where liftCompare = genericLiftCompare
instance Show1 UnorderedList where liftShowsPrec = genericLiftShowsPrec

instance ToJSONFields1 OrderedList

newtype OrderedList a = OrderedList [a]
  deriving (Diffable, Eq, Foldable, Functor, GAlign, Generic1, Mergeable, Ord, Show, Traversable)

instance Eq1 OrderedList where liftEq = genericLiftEq
instance Ord1 OrderedList where liftCompare = genericLiftCompare
instance Show1 OrderedList where liftShowsPrec = genericLiftShowsPrec

instance ToJSONFields1 BlockQuote

newtype BlockQuote a = BlockQuote [a]
  deriving (Diffable, Eq, Foldable, Functor, GAlign, Generic1, Mergeable, Ord, Show, Traversable)

instance Eq1 BlockQuote where liftEq = genericLiftEq
instance Ord1 BlockQuote where liftCompare = genericLiftCompare
instance Show1 BlockQuote where liftShowsPrec = genericLiftShowsPrec

instance ToJSONFields1 ThematicBreak

data ThematicBreak a = ThematicBreak
  deriving (Diffable, Eq, Foldable, Functor, GAlign, Generic1, Mergeable, Ord, Show, Traversable)

instance Eq1 ThematicBreak where liftEq = genericLiftEq
instance Ord1 ThematicBreak where liftCompare = genericLiftCompare
instance Show1 ThematicBreak where liftShowsPrec = genericLiftShowsPrec

instance ToJSONFields1 HTMLBlock where
  toJSONFields1 (HTMLBlock b) = noChildren [ "as_string" .= unpack b ]

newtype HTMLBlock a = HTMLBlock ByteString
  deriving (Diffable, Eq, Foldable, Functor, GAlign, Generic1, Mergeable, Ord, Show, Traversable)

instance Eq1 HTMLBlock where liftEq = genericLiftEq
instance Ord1 HTMLBlock where liftCompare = genericLiftCompare
instance Show1 HTMLBlock where liftShowsPrec = genericLiftShowsPrec

newtype Table a = Table [a]
  deriving (Diffable, Eq, Foldable, Functor, GAlign, Generic1, Mergeable, Ord, Show, Traversable)

instance ToJSONFields1 Table

instance Eq1 Table where liftEq = genericLiftEq
instance Ord1 Table where liftCompare = genericLiftCompare
instance Show1 Table where liftShowsPrec = genericLiftShowsPrec

newtype TableRow a = TableRow [a]
  deriving (Diffable, Eq, Foldable, Functor, GAlign, Generic1, Mergeable, Ord, Show, Traversable)

instance ToJSONFields1 TableRow

instance Eq1 TableRow where liftEq = genericLiftEq
instance Ord1 TableRow where liftCompare = genericLiftCompare
instance Show1 TableRow where liftShowsPrec = genericLiftShowsPrec

newtype TableCell a = TableCell [a]
  deriving (Diffable, Eq, Foldable, Functor, GAlign, Generic1, Mergeable, Ord, Show, Traversable)

instance ToJSONFields1 TableCell

instance Eq1 TableCell where liftEq = genericLiftEq
instance Ord1 TableCell where liftCompare = genericLiftCompare
instance Show1 TableCell where liftShowsPrec = genericLiftShowsPrec


-- Inline elements

newtype Strong a = Strong [a]
  deriving (Diffable, Eq, Foldable, Functor, GAlign, Generic1, Mergeable, Ord, Show, Traversable)

instance ToJSONFields1 Strong

instance Eq1 Strong where liftEq = genericLiftEq
instance Ord1 Strong where liftCompare = genericLiftCompare
instance Show1 Strong where liftShowsPrec = genericLiftShowsPrec

newtype Emphasis a = Emphasis [a]
  deriving (Diffable, Eq, Foldable, Functor, GAlign, Generic1, Mergeable, Ord, Show, Traversable)

instance ToJSONFields1 Emphasis

instance Eq1 Emphasis where liftEq = genericLiftEq
instance Ord1 Emphasis where liftCompare = genericLiftCompare
instance Show1 Emphasis where liftShowsPrec = genericLiftShowsPrec

newtype Text a = Text ByteString
  deriving (Diffable, Eq, Foldable, Functor, GAlign, Generic1, Mergeable, Ord, Show, Traversable)

instance ToJSONFields1 Text where
  toJSONFields1 (Text s) = noChildren ["as_string" .= unpack s ]

instance Eq1 Text where liftEq = genericLiftEq
instance Ord1 Text where liftCompare = genericLiftCompare
instance Show1 Text where liftShowsPrec = genericLiftShowsPrec

data Link a = Link { linkURL :: ByteString, linkTitle :: Maybe ByteString }
  deriving (Diffable, Eq, Foldable, Functor, GAlign, Generic1, Mergeable, Ord, Show, Traversable)

-- TODO: Better ToJSONFields1 instance
instance ToJSONFields1 Link

instance Eq1 Link where liftEq = genericLiftEq
instance Ord1 Link where liftCompare = genericLiftCompare
instance Show1 Link where liftShowsPrec = genericLiftShowsPrec

data Image a = Image { imageURL :: ByteString, imageTitle :: Maybe ByteString }
  deriving (Diffable, Eq, Foldable, Functor, GAlign, Generic1, Mergeable, Ord, Show, Traversable)

-- TODO: Better ToJSONFields1 instance
instance ToJSONFields1 Image

instance Eq1 Image where liftEq = genericLiftEq
instance Ord1 Image where liftCompare = genericLiftCompare
instance Show1 Image where liftShowsPrec = genericLiftShowsPrec

data Code a = Code { codeLanguage :: Maybe ByteString, codeContent :: ByteString }
  deriving (Diffable, Eq, Foldable, Functor, GAlign, Generic1, Mergeable, Ord, Show, Traversable)

-- TODO: Better ToJSONFields1 instance
instance ToJSONFields1 Code

instance Eq1 Code where liftEq = genericLiftEq
instance Ord1 Code where liftCompare = genericLiftCompare
instance Show1 Code where liftShowsPrec = genericLiftShowsPrec

data LineBreak a = LineBreak
  deriving (Diffable, Eq, Foldable, Functor, GAlign, Generic1, Mergeable, Ord, Show, Traversable)

instance ToJSONFields1 LineBreak

instance Eq1 LineBreak where liftEq = genericLiftEq
instance Ord1 LineBreak where liftCompare = genericLiftCompare
instance Show1 LineBreak where liftShowsPrec = genericLiftShowsPrec

instance ToJSONFields1 Strikethrough

newtype Strikethrough a = Strikethrough [a]
  deriving (Diffable, Eq, Foldable, Functor, GAlign, Generic1, Mergeable, Ord, Show, Traversable)

instance Eq1 Strikethrough where liftEq = genericLiftEq
instance Ord1 Strikethrough where liftCompare = genericLiftCompare
instance Show1 Strikethrough where liftShowsPrec = genericLiftShowsPrec
