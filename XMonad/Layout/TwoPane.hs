{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE RecordWildCards #-}

-----------------------------------------------------------------------------
-- |
-- Module      :  XMonad.Layout.TwoPane
-- Copyright   :  (c) Spencer Janssen <spencerjanssen@gmail.com>
-- License     :  BSD3-style (see LICENSE)
--
-- Maintainer  :  Spencer Janssen <spencerjanssen@gmail.com>
-- Stability   :  unstable
-- Portability :  unportable
--
-- A layout that splits the screen horizontally and shows two windows.  The
-- left window is always the master window, and the right is either the
-- currently focused window or the second window in layout order.
--
-----------------------------------------------------------------------------

module XMonad.Layout.TwoPane (
                              -- * Usage
                              -- $usage
                              TwoPane (..)
                             ) where

import XMonad hiding (focus)
import XMonad.StackSet ( focus, up, down)

-- $usage
-- You can use this module with the following in your @~\/.xmonad\/xmonad.hs@:
--
-- > import XMonad.Layout.TwoPane
--
-- Then edit your @layoutHook@ by adding the TwoPane layout:
--
-- > myLayout = TwoPane (3/100) (1/2)  ||| Full ||| etc..
-- > main = xmonad def { layoutHook = myLayout }
--
-- For more detailed instructions on editing the layoutHook see:
--
-- "XMonad.Doc.Extending#Editing_the_layout_hook"

data TwoPane a = TwoPane
    { tp_delta :: Rational -- ^ 'Resize' by /this/ much
    , tp_split :: Rational -- ^ Size ratio of the master window
    } deriving ( Show, Read )

instance LayoutClass TwoPane a where
    doLayout TwoPane {..} r s = return (arrange r s,Nothing)
        where
          arrange rect st = case reverse (up st) of
                              (master:_) -> [(master,left),(focus st,right)]
                              [] -> case down st of
                                      (next:_) -> [(focus st,left),(next,right)]
                                      [] -> [(focus st, rect)]
              where (left, right) = splitHorizontallyBy tp_split rect

    handleMessage TwoPane {..} = return . fmap resize . fromMessage where
        resize how = case how of
            Shrink -> TwoPane { tp_split = tp_split - tp_delta, .. }
            Expand -> TwoPane { tp_split = tp_split + tp_delta, .. }

    description _ = "TwoPane"
