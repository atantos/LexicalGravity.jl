push!(LOAD_PATH,"../src/")

using Documenter
using LexicalGravity

makedocs(
    sitename = "LexicalGravity",
    # I need to have the prettyurls argument so that I can have right-linked side pages.
    format = Documenter.HTML(prettyurls = false),
    modules = [LexicalGravity]
)

# Documenter can also automatically deploy documentation to gh-pages.
# See "Hosting Documentation" and deploydocs() in the Documenter manual
# for more information.
#=deploydocs(
    repo = "<repository url>"
)=#
