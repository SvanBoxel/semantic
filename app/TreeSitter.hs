module TreeSitter where

import Diff
import Range
import Syntax
import Term
import Control.Comonad.Cofree
import qualified OrderedMap as Map
import qualified Data.Set as Set
import Foreign
import Foreign.C
import Foreign.C.Types

data TSLanguage = TsLanguage deriving (Show, Eq)
foreign import ccall "prototype/doubt-difftool/doubt-difftool-Bridging-Header.h ts_language_c" ts_language_c :: Ptr TSLanguage
foreign import ccall "prototype/doubt-difftool/doubt-difftool-Bridging-Header.h ts_language_javascript" ts_language_javascript :: Ptr TSLanguage

data TSDocument = TsDocument deriving (Show, Eq)
foreign import ccall "prototype/External/tree-sitter/include/tree_sitter/runtime.h ts_document_make" ts_document_make :: IO (Ptr TSDocument)
foreign import ccall "prototype/External/tree-sitter/include/tree_sitter/runtime.h ts_document_set_language" ts_document_set_language :: Ptr TSDocument -> Ptr TSLanguage -> IO ()
foreign import ccall "prototype/External/tree-sitter/include/tree_sitter/runtime.h ts_document_set_input_string" ts_document_set_input_string :: Ptr TSDocument -> CString -> IO ()
foreign import ccall "prototype/External/tree-sitter/include/tree_sitter/runtime.h ts_document_parse" ts_document_parse :: Ptr TSDocument -> IO ()
foreign import ccall "prototype/External/tree-sitter/include/tree_sitter/runtime.h ts_document_free" ts_document_free :: Ptr TSDocument -> IO ()

data TSLength = TsLength { bytes :: CSize, chars :: CSize }
  deriving (Show, Eq)

data TSNode = TsNode { _data :: Ptr (), offset :: TSLength }
  deriving (Show, Eq)

instance Storable TSNode where
  alignment _ = 24
  sizeOf _ = 24
  peek _ = error "Haskell code should never read TSNode values directly."
  poke _ _ = error "Haskell code should never write TSNode values directly."

foreign import ccall "app/bridge.h ts_document_root_node_p" ts_document_root_node_p :: Ptr TSDocument -> Ptr TSNode -> IO ()
foreign import ccall "app/bridge.h ts_node_p_name" ts_node_p_name :: Ptr TSNode -> Ptr TSDocument -> IO CString
foreign import ccall "app/bridge.h ts_node_p_named_child_count" ts_node_p_named_child_count :: Ptr TSNode -> IO CSize
foreign import ccall "app/bridge.h ts_node_p_named_child" ts_node_p_named_child :: Ptr TSNode -> CSize -> Ptr TSNode -> IO CSize
foreign import ccall "app/bridge.h ts_node_p_pos_chars" ts_node_p_pos_chars :: Ptr TSNode -> IO CSize
foreign import ccall "app/bridge.h ts_node_p_size_chars" ts_node_p_size_chars :: Ptr TSNode -> IO CSize

-- | Given a term’s annotation and children, construct the term.
type Constructor = Info -> [Term String Info] -> Term String Info

keyedProductions :: Set.Set String
keyedProductions = Set.fromList [ "object" ]

fixedProductions :: Set.Set String
fixedProductions = Set.fromList [ "pair", "rel_op", "math_op", "bool_op", "bitwise_op", "type_op", "math_assignment", "assignment", "subscript_access", "member_access", "new_expression", "function_call", "function", "ternary" ]

-- | Given two sets of production names & a source string, produce a Constructor.
constructorForProductions :: Set.Set String -> Set.Set String -> String -> Constructor
constructorForProductions _ _ source info@(Info range _) [] = info :< Leaf (substring range source)
languageForType :: String -> Maybe (Ptr TSLanguage)
languageForType mediaType = case mediaType of
    ".h" -> Just ts_language_c
    ".c" -> Just ts_language_c
    ".js" -> Just ts_language_javascript
    _ -> Nothing

parseTreeSitterFile :: Ptr TSLanguage -> String -> IO (Term String Info)
parseTreeSitterFile language contents = do
  document <- ts_document_make
  ts_document_set_language document language
  withCString contents (\source -> do
    ts_document_set_input_string document source
    ts_document_parse document
    term <- documentToTerm document contents
    ts_document_free document
    return term)

documentToTerm :: Ptr TSDocument -> String -> IO (Term String Info)
documentToTerm document contents = alloca $ \root -> do
  ts_document_root_node_p document root
  snd <$> toTerm root where
    toTerm :: Ptr TSNode -> IO (String, Term String Info)
    toTerm node = do
      name <- ts_node_p_name node document
      name <- peekCString name
      children <- withNamedChildren node toTerm
      range <- range node
      annotation <- return . Info range $ Set.singleton name
      return (name, annotation :< case children of
        [] -> Leaf $ substring range contents
        _ | Set.member name keyedProductions -> Keyed . Map.fromList $ assignKey <$> children
        _ | Set.member name fixedProductions -> Fixed $ fmap snd children
        _ | otherwise -> Indexed $ fmap snd children)
        where assignKey ("pair", node@(_ :< Fixed (key : _))) = (getSubstring key, node)
              assignKey (_, node) = (getSubstring node, node)
              getSubstring (Info range _ :< _) = substring range contents

withNamedChildren :: Ptr TSNode -> (Ptr TSNode -> IO (String, a)) -> IO [(String, a)]
withNamedChildren node transformNode = do
  count <- ts_node_p_named_child_count node
  if count == 0
    then return []
    else mapM (alloca . getChild) [0..pred count] where
      getChild n out = do
        _ <- ts_node_p_named_child node n out
        transformNode out

range :: Ptr TSNode -> IO Range
range node = do
  pos <- ts_node_p_pos_chars node
  size <- ts_node_p_size_chars node
  let start = fromIntegral pos
      end = start + fromIntegral size
  return Range { start = start, end = end }
