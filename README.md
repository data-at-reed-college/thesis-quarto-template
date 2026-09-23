# Reed College Thesis Template (Quarto)

Write your thesis in Quarto (Markdown plus optional **R** or **Python** code) and produce a
Reed-formatted **PDF** (using `reedthesis.cls`) and **Word** document (using the Reed Word
template) from the same files.

## Getting started

### 1. One-time setup

Open this folder as an RStudio project (or open `_quarto.yml`), then in the R **Console** run:

```r
source("setup.R")
```

This checks Quarto, installs a per-user LaTeX (TinyTeX) plus the LaTeX packages the template
needs, and checks R/Python support. It needs no administrator rights and can take a few
minutes the first time. You only do it once per computer (or per account on
rstudio.reed.edu).

- **Your own computer:** install [Quarto](https://quarto.org/docs/get-started/) (bundled with
  recent RStudio) and R or Python first.
- **rstudio.reed.edu:** nothing to install beforehand; just run the setup line above.
- **Word output only?** You can skip the setup; only the PDF needs LaTeX.

### 2. Make your thesis

1. Edit `_quarto.yml`: title, author, date, division, department, advisor, and the front
   matter (acknowledgments, preface, abstract, dedication, abbreviations). Delete any front
   matter you don't want.
2. Write your chapters in the numbered `.qmd` files. Add or rename chapters in the
   `chapters:` list in `_quarto.yml`; appendices go under `appendices:`.
3. Put sources in `references.bib` and cite them with `[@key]`.

### 3. Render

```bash
quarto render --to docx
quarto render --to pdf --no-clean
```

The results are in `_book/`. Run the Word command first, then the PDF command with
`--no-clean`, so neither file is deleted by the other. (In RStudio, use the Terminal tab.)

## What's in this folder

| File | Purpose |
|---|---|
| `_quarto.yml` | Thesis details, front matter, bibliography style, output settings |
| `index.qmd`, `01-…` to `04-…` | Sample chapters (delete or rewrite them); `index.qmd` is the unnumbered Introduction |
| `90-appendix-a.qmd`, `91-…` | Appendices |
| `references.bib`, `csl/apa.csl` | Bibliography data and the Word citation style |
| `reedthesis.cls` | Reed LaTeX class (PDF) |
| `resources/template.tex` | Builds the PDF title page, front matter and bibliography |
| `resources/reference.docx`, `reed-docx.lua`, `postprocess-docx.py` | Word styles, front matter and page numbering |
| `Thesis_Template.docx` | The original Reed Word template (source of `reference.docx`) |
| `setup.R` | One-time setup script |

## Tips

- **Bibliography style:** change `bibstyle:` in `_quarto.yml` (`apa`, `chicago`, `ieee`, …) for
  the PDF, and `csl:` (a `.csl` file from [zotero.org/styles](https://www.zotero.org/styles))
  for Word.
- **Cross-references:** label things `{#sec-…}`, `{#fig-…}`, `{#tbl-…}`, `{#eq-…}` and refer to
  them with `@sec-…`, and so on.
- **R or Python?** Each `.qmd` file uses one language: write ```` ```{r} ```` chunks for R or
  ```` ```{python} ```` for Python. Different chapters can use different languages. Python
  needs Jupyter (`python3 -m pip install jupyter` or `quarto check jupyter` for help).
- **Spacing:** set `spacing:` in `_quarto.yml` (`singlespacing`, `onehalfspacing`,
  `doublespacing`); applies to the PDF.
- **Images:** use PNG or JPG. PDF images work in the PDF output but not in Word.
- **Unnumbered chapter:** add `{.unnumbered}` after its title.

## Word output notes

- The table of contents, list of tables and list of figures are Word fields. If they look
  empty or out of date, right-click them and choose **Update Field** (or accept the prompt when
  Word opens the file).
- Check the front pages and page numbering in Word before you submit; the Reed thesis
  requirements in the Senior Handbook are the authority.
- To rebuild the Word styles after editing `Thesis_Template.docx`:
  `python3 resources/make-reference-docx.py`.

## Troubleshooting

| Symptom | Fix |
|---|---|
| `Local TeX Live (2025) is older than remote repository (2026)` | Your TinyTeX is out of date. Run `source("setup.R")` and accept the reinstall, or `quarto install tinytex --update-path`. |
| `biber not found` / bibliography missing in PDF | Run `source("setup.R")`. |
| `File 'xxx.sty' not found` | Run `tlmgr install xxx` in the Terminal (or ask CUS), then render again. |
| PDF works but figures are missing in Word | Render the formats one at a time (see Render above). |
| Something else | Email cus@reed.edu with the full error message. |
