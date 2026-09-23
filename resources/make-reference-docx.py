#!/usr/bin/env python3
"""Build resources/reference.docx from Thesis_Template.docx.

Pandoc only uses a reference doc for its styles and the final section's
page setup/headers/footers, so we keep the template as-is and patch two
things: chapter headings start on a new page, an "Image Caption" style is added, and the document body is
emptied (leaving the last section's properties in place).
"""
import re, shutil, sys, zipfile

src = sys.argv[1] if len(sys.argv) > 1 else "Thesis_Template.docx"
dst = sys.argv[2] if len(sys.argv) > 2 else "resources/reference.docx"

with zipfile.ZipFile(src) as zin, zipfile.ZipFile(dst, "w", zipfile.ZIP_DEFLATED) as zout:
    for item in zin.infolist():
        data = zin.read(item.filename)
        if item.filename == "word/styles.xml":
            s = data.decode("utf8")
            s = re.sub(r'(<w:style [^>]*w:styleId="Heading1".*?<w:pPr>)(<w:keepNext/>)',
                       r'\1<w:keepNext/><w:pageBreakBefore/>', s, count=1, flags=re.S)
            # Pandoc's caption style is missing from the Reed template; add it
            # (figure and table captions both use it, see postprocess-docx.py).
            caption = ('<w:style w:type="paragraph" w:customStyle="1" w:styleId="ImageCaption">'
                       '<w:name w:val="Image Caption"/><w:basedOn w:val="Normal"/><w:qFormat/>'
                       '<w:pPr><w:keepLines/><w:spacing w:before="0" w:after="200"/>'
                       '<w:ind w:left="720" w:right="720"/></w:pPr><w:rPr><w:sz w:val="20"/></w:rPr></w:style>')
            s = s.replace("</w:styles>", caption + "</w:styles>")
            data = s.encode("utf8")
        elif item.filename == "word/document.xml":
            d = data.decode("utf8")
            body = re.search(r"<w:body>(.*)</w:body>", d, flags=re.S).group(1)
            final = re.search(r"<w:sectPr(?:(?!<w:sectPr).)*?</w:sectPr>\s*$", body, flags=re.S).group(0)
            d = d.replace(body, "<w:p/>" + final)
            data = d.encode("utf8")
        zout.writestr(item, data)
print("wrote", dst)
