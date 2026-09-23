#!/usr/bin/env python3
"""Quarto post-render step: patch the Word output that pandoc can't express.

- Table captions get the "Table Caption" style (pandoc gives every caption
  "Image Caption"), so the List of Tables and List of Figures can tell them apart.
- The main matter restarts page numbering at 1 (front matter is roman).
- The front matter section reuses the main matter's headers/footers (the template
  puts the page numbers in the headers), except the first-page ones.

Safe to run repeatedly; does nothing if there is no .docx in the output.
"""
import glob, os, re, shutil, sys, zipfile

outdir = os.environ.get("QUARTO_PROJECT_OUTPUT_DIR", "_book")
for path in glob.glob(os.path.join(outdir, "*.docx")):
    with zipfile.ZipFile(path) as z:
        parts = {i.filename: (i, z.read(i.filename)) for i in z.infolist()}
    doc = parts["word/document.xml"][1].decode("utf8")

    # 1. Table captions
    def fix_caption(m):
        p = m.group(0)
        text = "".join(re.findall(r"<w:t[^>]*>([^<]*)</w:t>", p))
        if re.match(r"\s*Table\s+[\dA-Z]", text):
            p = p.replace('<w:pStyle w:val="ImageCaption"', '<w:pStyle w:val="TableCaption"')
        return p
    doc = re.sub(r"<w:p[ >](?:(?!</w:p>).)*?w:val=\"ImageCaption\".*?</w:p>", fix_caption, doc, flags=re.S)

    sects = list(re.finditer(r"<w:sectPr\b.*?</w:sectPr>", doc, flags=re.S))
    if len(sects) >= 3:
        last, front = sects[-1], sects[1]
        # 2. Restart numbering in the main matter
        new_last = last.group(0)
        if "<w:pgNumType" not in new_last:
            new_last = new_last.replace("<w:cols", '<w:pgNumType w:start="1"/><w:cols', 1)
        # 3. Headers/footers for the front matter (page numbers)
        new_front = front.group(0)
        refs = "".join(r for r in re.findall(r"<w:(?:header|footer)Reference [^>]*/>", last.group(0))
                       if 'w:type="first"' not in r)
        if refs and "Reference" not in new_front:
            new_front = re.sub(r"(<w:sectPr\b[^>]*>)", lambda m: m.group(1) + refs, new_front, count=1)
            new_front = new_front.replace("</w:sectPr>", "<w:titlePg/></w:sectPr>")
        # Replace the later section first so the earlier offsets stay valid.
        doc = doc[:last.start()] + new_last + doc[last.end():]
        doc = doc[:front.start()] + new_front + doc[front.end():]

    tmp = path + ".tmp"
    with zipfile.ZipFile(tmp, "w", zipfile.ZIP_DEFLATED) as out:
        for name, (info, data) in parts.items():
            out.writestr(info, doc.encode("utf8") if name == "word/document.xml" else data)
    shutil.move(tmp, path)
    print("post-processed", path)
