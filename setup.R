# One-time setup for the Reed Quarto thesis template.
# Run from the RStudio Console:  source("setup.R")
# Works on your own computer and on rstudio.reed.edu. No admin rights needed:
# TinyTeX (the LaTeX distribution used for PDF output) is installed in your home folder.

latex_packages <- c(
  "biblatex", "biber", "biblatex-apa", "biblatex-chicago", "babel-english",
  "hyphen-english", "fancyhdr", "ocgx2", "xstring", "bookmark", "logreq",
  "caption", "booktabs", "longtable", "setspace", "xurl", "etoolbox", "fancyvrb",
  "xcolor", "geometry", "hyperref", "amsmath", "amsthm", "amssymb"
)

say <- function(...) cat(..., "\n", sep = "")
ok  <- function(...) say("[ok]   ", ...)
bad <- function(...) say("[FIX]  ", ...)

# --- 1. Quarto ---------------------------------------------------------------
quarto <- Sys.which("quarto")
if (quarto == "") quarto <- Sys.getenv("RSTUDIO_QUARTO", "")   # RStudio's bundled copy
if (quarto == "" || !file.exists(quarto)) {
  stop("Quarto was not found. On your own computer install it from https://quarto.org/docs/get-started/ ",
       "(or update RStudio, which bundles it). On rstudio.reed.edu, contact CUS.", call. = FALSE)
}
ver <- trimws(system2(quarto, "--version", stdout = TRUE))
ok("Quarto ", ver, " (", quarto, ")")
if (numeric_version(ver) < "1.4") bad("Quarto is old; version 1.4 or newer is recommended.")

# --- 2. TinyTeX --------------------------------------------------------------
tex_bin_dirs <- function() {
  home <- path.expand("~")
  cand <- c(Sys.glob(file.path(home, "Library/TinyTeX/bin/*")),
            Sys.glob(file.path(home, ".TinyTeX/bin/*")),
            Sys.glob(file.path(Sys.getenv("APPDATA"), "TinyTeX/bin/*")),
            Sys.glob(file.path(Sys.getenv("APPDATA"), "Roaming/TinyTeX/bin/*")))
  cand[dir.exists(cand)]
}
tlmgr_path <- function() {
  found <- c(file.path(tex_bin_dirs(), "tlmgr"), file.path(tex_bin_dirs(), "tlmgr.bat"))
  found <- found[file.exists(found)]
  if (length(found)) found[1] else unname(Sys.which("tlmgr"))
}
run <- function(cmd, args) {
  out <- suppressWarnings(system2(cmd, args, stdout = TRUE, stderr = TRUE))
  list(out = out, status = attr(out, "status") %||% 0L)
}
`%||%` <- function(a, b) if (is.null(a)) b else a

install_tinytex <- function() {
  say("Installing TinyTeX with Quarto (a few minutes)...")
  system2(quarto, c("install", "tinytex", "--no-prompt", "--update-path"))
}

tlmgr <- tlmgr_path()
if (is.na(tlmgr) || tlmgr == "") {
  bad("No TinyTeX found.")
  install_tinytex()
  tlmgr <- tlmgr_path()
  if (is.na(tlmgr) || tlmgr == "") stop("TinyTeX install did not finish; see the messages above.", call. = FALSE)
}
ok("TinyTeX found (", tlmgr, ")")

# A TinyTeX from an earlier year cannot install packages once CTAN moves to the
# next TeX Live release ("Local TeX Live (2025) is older than remote repository (2026)").
probe <- run(tlmgr, c("install", "biblatex"))
if (any(grepl("older than remote", probe$out))) {
  bad("Your TinyTeX is from an older TeX Live release and can't download packages.")
  say("       Fix: reinstall TinyTeX (keeps your thesis files; only LaTeX is replaced).")
  go <- if (interactive()) utils::askYesNo("Reinstall TinyTeX now?", default = TRUE) else FALSE
  if (isTRUE(go)) {
    system2(quarto, c("uninstall", "tinytex", "--no-prompt"))
    install_tinytex()
    tlmgr <- tlmgr_path()
  } else {
    stop('Run  system2("quarto", c("install","tinytex","--update-path"))  in the Console, ',
         "then run source(\"setup.R\") again.", call. = FALSE)
  }
}

# --- 3. LaTeX packages the template needs -----------------------------------
say("Installing LaTeX packages (skips any you already have)...")
res <- run(tlmgr, c("install", latex_packages))
failed <- grep("^tlmgr: package .* not present in repository|not found", res$out, value = TRUE)
if (length(failed)) { bad("Some packages could not be installed:"); say("       ", failed) } else ok("LaTeX packages")
biber <- file.exists(file.path(dirname(tlmgr), "biber")) || file.exists(file.path(dirname(tlmgr), "biber.exe")) ||
         Sys.which("biber") != ""
if (biber) ok("biber (bibliography engine)") else bad("biber is missing; the PDF bibliography will fail. Ask CUS.")

# --- 4. R and Python for code chunks ----------------------------------------
for (pkg in c("knitr", "rmarkdown")) {
  if (requireNamespace(pkg, quietly = TRUE)) ok("R package ", pkg) else {
    bad("R package ", pkg, " is missing (needed for R code chunks).")
    if (interactive() && isTRUE(utils::askYesNo(paste("Install", pkg, "now?")))) utils::install.packages(pkg)
  }
}
jup <- suppressWarnings(system2(quarto, c("check", "jupyter"), stdout = TRUE, stderr = TRUE))
if (any(grepl("Jupyter: *[0-9]", jup))) ok("Python + Jupyter (for Python code chunks)") else
  say("[info] Python/Jupyter not detected. Only needed if you write Python chunks; see README.")

say("\nSetup finished. Render with:\n  quarto render --to docx\n  quarto render --to pdf --no-clean")
