# Home

Documentation for LexicalGravity.jl

$\displaystyle lexicalgravity\ =\ log\left(\frac{f( x,y)}{g( x)} *\frac{f( x,y)}{g'( y)}\right)$

LexicalGravity.jl

LexicalGravity.jl is a package that implements the lexical gravity index, proposed by Daudaravičius & Marcinkevičienė. 2004), which takes type frequencies into consideration. The goal is to have a high-performance and parallelized symbolic algebra system that is directly extendable in the same language as the users.

# Installation

To install LexicalGravity.jl, use the Julia package manager:

```
using Pkg
Pkg.add("LexicalGravity")
```