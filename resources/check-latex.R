# Runs before every render (see `pre-render` in _quarto.yml). Only prints a hint; never blocks
# a render, so Word-only users are unaffected.
home <- path.expand("~")
bins <- c(Sys.glob(file.path(home, "Library/TinyTeX/bin/*")), Sys.glob(file.path(home, ".TinyTeX/bin/*")),
          Sys.glob(file.path(Sys.getenv("APPDATA"), "TinyTeX/bin/*")))
have <- function(f) any(file.exists(file.path(bins, f))) || Sys.which(sub("\\.exe$", "", f)) != ""
if (!have("biber") && !have("biber.exe")) {
  message("\nNOTE: 'biber' was not found. PDF output needs it. In the R Console run:  source(\"setup.R\")\n",
          "      (Word output does not need it.)\n")
}
