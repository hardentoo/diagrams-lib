{-# LANGUAGE DeriveDataTypeable         #-}
{-# LANGUAGE FlexibleInstances          #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE MultiParamTypeClasses      #-}
{-# LANGUAGE RankNTypes                 #-}
{-# LANGUAGE TypeFamilies               #-}
{-# LANGUAGE TypeOperators              #-}
{-# LANGUAGE TypeSynonymInstances       #-}
{-# LANGUAGE ConstraintKinds            #-}

{-# OPTIONS_GHC -fno-warn-orphans #-}
-----------------------------------------------------------------------------
-- |
-- Module      :  Diagrams.TwoD.Types
-- Copyright   :  (c) 2011 diagrams-lib team (see LICENSE)
-- License     :  BSD-style (see LICENSE)
-- Maintainer  :  diagrams-discuss@googlegroups.com
--
-- Basic types for two-dimensional Euclidean space.
--
-----------------------------------------------------------------------------

module Diagrams.TwoD.Types
       ( -- * 2D Euclidean space
         r2, unr2, mkR2, r2Iso
       , p2, mkP2, unp2, p2Iso
       , R2Basis
       , R2Ish
       ) where

import           Control.Lens           (Iso', Rewrapped, Wrapped (..), iso, (^.),  _1, _2)


import           Diagrams.Angle
import           Diagrams.Direction
import           Diagrams.Coordinates
import           Diagrams.Core

import           Data.AffineSpace.Point
import           Data.Basis
import           Data.MemoTrie          (HasTrie (..))
import           Data.VectorSpace

import           Data.Data

-- | Basis for 2D Euclidean space
data R2Basis = XB | YB deriving (Eq, Ord, Enum)

instance HasTrie R2Basis where
    data R2Basis :->: x = R2Trie x x
    trie f = R2Trie (f XB) (f YB)
    untrie (R2Trie x _y) XB = x
    untrie (R2Trie _x y) YB = y
    enumerate (R2Trie x y)  = [(XB,x),(YB,y)]

type R2Ish v = (HasBasis v, Basis v ~ R2Basis)

-- | Construct a 2D vector from a pair of components.  See also '&'.
r2 :: (R2Ish v) => (Scalar v, Scalar v) -> v
r2 (x,y) = recompose [(XB,x),(YB,y)]

-- | Convert a 2D vector back into a pair of components.  See also 'coords'.
unr2 :: (R2Ish v) => v -> (Scalar v, Scalar v)
unr2 v = (decompose' v XB, decompose' v YB)

-- | Curried form of `r2`.
mkR2 :: (R2Ish v) => Scalar v -> Scalar v -> v
mkR2 = curry r2

r2Iso :: (R2Ish v) => Iso' v (Scalar v, Scalar v)
r2Iso = iso unr2 r2

-- | Construct a 2D point from a pair of coordinates.  See also '^&'.
p2 :: (R2Ish v) => (Scalar v, Scalar v) -> Point v
p2 = P . r2

-- | Convert a 2D point back into a pair of coordinates.  See also 'coords'.
unp2 :: (R2Ish v) => Point v -> (Scalar v, Scalar v)
unp2 (P v) = unr2 v

-- | Curried form of `p2`.
mkP2 :: (R2Ish v) => Scalar v -> Scalar v -> Point v
mkP2 = curry p2

p2Iso :: (R2Ish v) => Iso' (Point v) (Scalar v, Scalar v)
p2Iso = iso unp2 p2

-- | Types which can be expressed in polar 2D coordinates, as a magnitude and an angle.
class Polar t where
    polar :: Iso' t (Scalar (V t), Angle (Scalar (V t)))
