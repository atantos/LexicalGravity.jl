#using Base: Float64
module LexicalGravity

using TextAnalysis
using StaticArrays
using Counters
using Strs
using WordTokenizers
using Memoize

export Strings, RichnessBundle, ngramfirstcombine, f, g, ngram, ngramdirection, tokenizestr, bigramsinside, lexicalgravitypair

"""
    Strings = Union{Str,String,StringDocument, Vector{String}}

Create a Union of three types of strings that the functions of the package accepts; Str, String, TextAnalysis::StringDocument and  Vector{String}. 
"""
const Strings = Union{Str,String,StringDocument, Vector{String}, Vector{Vector{String}}}

"Create a new type that carries all relevant information needed for calculating the lexical gravity index: gdict is a feature that includes a dictionary
of the words and their lexical richness index."
struct RichnessBundle
    gdict::Dict{String, Float64}
    uniquecontext::Vector{String}
    bigrams::Vector{Vector{String}}
    word::String
end




"""
    ngramfirstcombine(x::Strings)

A new function that takes a Vector of strings and outputs a vector of string vectors with ngram combinations of the
    first member with all the other elements of the vector. It is the first step for implementing the lexical gravity.
    For more details, cf. (2004).

# Examples
```julia-repl
julia> ngramfirstcombine(["σε", "νόμιμες", "ενέργειες", "κατά"], 4)
3-element Vector{Vector{String}}:
 ["σε", "νόμιμες"]
 ["σε", "ενέργειες"]
 ["σε", "κατά"]
```
"""
@memoize function ngramfirstcombine(str::Strings)
    ngramArray::Vector{Vector{String}} = []
    for i in 1:(length(str) - 1)
        push!(ngramArray, [str[1], str[1 + i]])
    end
    return ngramArray
end

tokenizestr(s::String) = tokenize(s)
tokenizestr(s::StringDocument) =  tokenize(text(s))

#ngram_simple(s::Strings_simple1, n::Integer) = [s[i:i+n-1] for i=1:length(s)-n+1]
# s must be first tokenized 
ngram(s::Strings, n::Integer) = [s[i:i+n-1] for i=1:length(s)-n+1]

@memoize function ngramdirection(mydata::Strings; n = 4, direction = "forward")
    if direction == "forward"
        str = ngram(mydata, n)
        ngramfirstcombine.(str)
    elseif  direction == "backward"
        str = reverse.(ngram(mydata, n))
        ngramfirstcombine.(str)
    end       
end


# tokenizedtext

@memoize function bigramsinside3(word, text::Strings, ngram)
    typeof(text) == Vector{String} || (text = tokenizestr(text))
    wordbigrams = filter(x -> x[1][1] == word, ngram)
    return wordbigrams  
end

"""
    g(text::Strings; mode = "forward") 

A function that takes a Vector of strings and outputs a vector of string vectors with ngram combinations of the
    first member with all the other elements of the vector. It is the first step for implementing the lexical gravity.
    For more details, cf. (2004).

# Examples
```julia-repl
julia> g(text)
2-element Vector{RichnessBundle}:
RichnessBundle(Dict("Στα" => 0.3475), ["Στα", "δικαστήρια", "θα", "αναζητήσει"], [["Στα", "δικαστήρια"], ["Στα", "θα"], ["Στα", "αναζητήσει"]], "Στα")
 RichnessBundle(Dict("δικαστήρια" => 0.3215), ["δικαστήρια", "θα", "αναζητήσει", "το"], [["δικαστήρια", "θα"], ["δικαστήρια", "αναζητήσει"], ["δικαστήρια", "το"]], "δικαστήρια")
```
"""
@memoize function g(text::Strings; mode = "forward") 
    lexicalrichness = Vector{Union{RichnessBundle, Dict}}(undef, 0)
    text = lowercase(text)
    tokenized_text2 = tokenizestr(text)
    tokenized_text = unique(tokenizestr(text))
    ngrams = ngramdirection2(tokenized_text2, direction = mode)
    overallgdict = Dict()
    for word in tokenized_text
        gdict = Dict()
        bigrams = bigramsinside3(word, tokenized_text2, ngrams)
        if length(bigrams) > 0
            # unique words in the context of word within a 4-gram.
            uniquecontext = unique(collect(Iterators.flatten(bigrams)))
            g = size(bigrams, 1) / (length(uniquecontext) - 1)
            println(g)
            push!(gdict, word => g)
            push!(overallgdict, word => g)
            println(typeof(uniquecontext), typeof(allbigrams), typeof(word))
            push!(lexicalrichness, RichnessBundle(gdict, uniquecontext, bigrams, word))
        end
    end
    push!(lexicalrichness, overallgdict)
    return lexicalrichness
end

# For getting the g of a specific word for the denominators in the lexicalgravitypair() function.
@memoize function g(word::String, text::Strings; mode = "forward")
    word = lowercase(word)
    return gsimple2(text, mode=mode)[end][word]
end

"""
    f(x::String, y::String, text::Strings)

A function that returns bigram frequency of words (x, y) within a 3-word span from x onwards in the right direction. The type **Strings** 
    Union{Str,String,StringDocument, Vector{String}}. For this type of frequency, plase cf. XXX(2004).

# Examples
```julia-repl
julia> f("η", "τιμή", mytext)
2
```
"""
@memoize function f(x::String, y::String, lexicalrichness::Vector{Union{RichnessBundle, Dict}})
    ind = [lowercase(x) == lexicalrichness[i].word for i=1:length(lexicalrichness)]
    freqxy = counter([x[2] for x in lexicalrichness[ind][1].bigrams])[y]
    return freqxy
end


"""
    lexicalgravitypair(x::String, y::String, text::Strings) 

A function that takes a Vector of strings and outputs a vector of string vectors with ngram combinations of the
    first member with all the other elements of the vector. It is the first step for implementing the lexical gravity.
    For more details, cf. (2004).

# Examples
```julia-repl
julia> f("η", "τιμή")
2
```
"""
@memoize function lexicalgravitypair(x::String, y::String, text::Strings) 
    f_xy = f(x,y,g(text)[1:end-1])
    log(f_xy/g(x, text)) + log(f_xy/g(x, text, mode = "backward"))
end

# intermediatearray = Array{String, 1}()
# finalarray = Array{Array{String}, 1}()
# for ngram in ngram(tokenizestr(lowertextdata)[4:end-3], 2)
#     # i need to first clean and normalize the data before applying the lexicalgravitypair() function.
#     ngram = lowercase.(ngram)
#     #println(ngram)
#     if lexicalgravitypair(ngram[1], ngram[2], lowertextdata) <= 5.5
#         println("next")
#         intermediatearray = Array{String, 1}()
#     else
#         push!(intermediatearray, ngram[1], ngram[2])
#         push!(finalarray, intermediatearray)
#         println("ngram")
        
#     end 
# end


end