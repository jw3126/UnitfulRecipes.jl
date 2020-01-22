using Documenter, Literate, UnitfulRecipes

# generate tutorials and how-to guides using Literate
src = joinpath(@__DIR__, "src")
lit = joinpath(@__DIR__, "lit")

for (root, _, files) in walkdir(lit), file in files
    splitext(file)[2] == ".jl" || continue
    ipath = joinpath(root, file)
    opath = splitdir(replace(ipath, lit=>src))[1]
    Literate.markdown(ipath, opath, documenter = true)
end

# Documentation structure
ismd(f) = splitext(f)[2] == ".md" 
pages(folder) = [joinpath(folder, f) for f in readdir(joinpath(src, folder)) if ismd(f)]

makedocs(
    sitename="UnitfulRecipes.jl",
    doctest = false, # TODO guessing I should remove that when actually deploying?
    # options
    modules = [UnitfulRecipes],
    # organisation
    pages = Any[
        "Home" => "index.md",
        "Examples" => pages("examples")
    ]
)

# Deploy
deploydocs(
    repo = "github.com/jw3126/UnitfulRecipes.jl.git",
    push_preview = true
)

#=
To edit locally, make sure execute is set to false and run 

using LiveServer
servedocs(literate=joinpath("docs", "lit"), doc_env=true)

from the root of the package in development
=#
