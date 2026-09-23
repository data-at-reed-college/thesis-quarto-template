-- Builds the Reed thesis front matter for Word output from the project
-- metadata, using the paragraph styles in Thesis_Template.docx.
if FORMAT ~= "docx" then return {} end

local function esc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end
local function raw(x) return pandoc.RawBlock("openxml", x) end
local function para(style, text)
  if text and text ~= "" then
    return raw(string.format(
      '<w:p><w:pPr><w:pStyle w:val="%s"/></w:pPr><w:r><w:t xml:space="preserve">%s</w:t></w:r></w:p>',
      style, esc(text)))
  end
  return raw(string.format('<w:p><w:pPr><w:pStyle w:val="%s"/></w:pPr></w:p>', style))
end
local function section_break(numfmt, kind)
  local num = numfmt and string.format('<w:pgNumType w:fmt="%s" w:start="1"/>', numfmt) or ""
  return raw('<w:p><w:pPr><w:sectPr><w:type w:val="' .. kind .. '"/>' ..
    '<w:pgSz w:w="12240" w:h="15840"/>' ..
    '<w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="2160" w:header="720" w:footer="720" w:gutter="0"/>' ..
    num .. '<w:cols w:space="720"/></w:sectPr></w:pPr></w:p>')
end
local function page_break()
  return raw('<w:p><w:r><w:br w:type="page"/></w:r></w:p>')
end
local function field(instr)
  return raw('<w:p><w:r><w:fldChar w:fldCharType="begin" w:dirty="true"/></w:r>' ..
    '<w:r><w:instrText xml:space="preserve"> ' .. instr .. ' </w:instrText></w:r>' ..
    '<w:r><w:fldChar w:fldCharType="separate"/></w:r>' ..
    '<w:r><w:t>Right-click and choose Update Field to build this list.</w:t></w:r>' ..
    '<w:r><w:fldChar w:fldCharType="end"/></w:r></w:p>')
end

local S = pandoc.utils.stringify
local meta_text = {}

local function body_blocks(blocks)
  local out = {}
  for _, b in ipairs(blocks) do
    if b.t == "Para" or b.t == "Plain" then
      out[#out + 1] = pandoc.Div({ pandoc.Para(b.content) }, pandoc.Attr("", {}, { { "custom-style", "Body" } }))
    else
      out[#out + 1] = b
    end
  end
  return out
end

local function front_section(out, heading, content)
  if content == nil then return end
  out[#out + 1] = para("HeadingFrontMatter", heading)
  local blocks = content.t == "MetaBlocks" and content or pandoc.MetaBlocks({ pandoc.Para(pandoc.utils.blocks_to_inlines(content)) })
  for _, b in ipairs(body_blocks(blocks)) do out[#out + 1] = b end
end

function Pandoc(doc)
  local m = doc.meta
  local author = m.author
  if author and author[1] then
    author = author[1].name and S(author[1].name) or S(author[1])
  else
    author = ""
  end
  local title, date = S(m.title or ""), S(m.date or "")
  local division, department = S(m.division or ""), S(m.department or "")
  local advisor = S(m.advisor or "")
  local altadvisor = m.altadvisor and S(m.altadvisor) or nil

  local out = {}
  -- Title page
  for _, x in ipairs({
    { "TitlePageText", "" }, { "TitlePageText", title }, { "TitlePageLine", "" },
    { "TitlePageText", "A Thesis" }, { "TitlePageText", "Presented to" },
    { "TitlePageText", "The Division of " .. division }, { "TitlePageText", "Reed College" },
    { "TitlePageLine", "" }, { "TitlePageText", "In Partial Fulfillment" },
    { "TitlePageText", "of the Requirements for the Degree" }, { "TitlePageText", "Bachelor of Arts" },
    { "TitlePageLine", "" }, { "TitlePageText", author }, { "TitlePageText", date },
  }) do out[#out + 1] = para(x[1], x[2]) end
  out[#out + 1] = page_break()
  -- Approval page
  for _ = 1, 13 do out[#out + 1] = para("TitlePageText", "") end
  out[#out + 1] = para("TitlePageText", "Approved for the Division")
  out[#out + 1] = para("TitlePageText", "(" .. department .. ")")
  out[#out + 1] = para("TitlePageLine", "")
  out[#out + 1] = para("TitlePageText", advisor .. (altadvisor and ("   /   " .. altadvisor) or ""))
  out[#out + 1] = section_break(nil, "nextPage")

  -- Front matter (roman numerals)
  front_section(out, "Acknowledgments", m.acknowledgments)
  front_section(out, "Preface", m.preface)
  if m["abbrev-list"] then
    out[#out + 1] = para("HeadingFrontMatter", "List of Abbreviations")
    for _, a in ipairs(m["abbrev-list"]) do
      out[#out + 1] = raw(string.format(
        '<w:p><w:pPr><w:pStyle w:val="Body"/><w:tabs><w:tab w:val="left" w:pos="1440"/></w:tabs>' ..
        '<w:ind w:left="1440" w:hanging="1440"/></w:pPr><w:r><w:rPr><w:b/></w:rPr><w:t>%s</w:t></w:r>' ..
        '<w:r><w:tab/><w:t xml:space="preserve">%s</w:t></w:r></w:p>', esc(S(a.short)), esc(S(a.long))))
    end
  end
  out[#out + 1] = para("HeadingFrontMatter", "Table of Contents")
  out[#out + 1] = field('TOC \\o "2-4" \\t "Heading 1,1" \\h \\z')
  if m.lot and S(m.lot) == "true" then
    out[#out + 1] = para("HeadingFrontMatter", "List of Tables")
    out[#out + 1] = field('TOC \\h \\z \\t "Table Caption,1"')
  end
  if m.lof and S(m.lof) == "true" then
    out[#out + 1] = para("HeadingFrontMatter", "List of Figures")
    out[#out + 1] = field('TOC \\h \\z \\t "Image Caption,1"')
  end
  front_section(out, "Abstract", m.abstract)
  front_section(out, "Dedication", m.dedication)
  out[#out + 1] = section_break("lowerRoman", "oddPage")

  -- Main matter
  for _, b in ipairs(body_blocks(doc.blocks)) do out[#out + 1] = b end
  out[#out + 1] = pandoc.Header(1, { pandoc.Str("Bibliography") }, pandoc.Attr("bibliography", { "unnumbered" }))
  out[#out + 1] = pandoc.Div({}, pandoc.Attr("refs"))
  doc.blocks = out

  -- Keep pandoc from also writing its own title block.
  m.title, m.author, m.date, m.abstract, m.subtitle = nil, nil, nil, nil, nil
  return doc
end
