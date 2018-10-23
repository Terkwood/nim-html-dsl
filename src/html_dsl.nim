## HTML-DSL
## ========
##
## - Nim HTML DSL, Domain Specific Language for HTML embedded on Nim lang code *(Not a template engine)*.
##
## .. image:: https://raw.githubusercontent.com/juancarlospaco/nim-html-dsl/master/temp.png
import macros except body
include tipos

const can_have_children = [
  nkAddress, nkArea, nkArticle, nkAside, nkAudio, nkB, nkBase, nkBdi, nkBdo,
  nkBig, nkBlockquote, nkButton, nkCanvas, nkCaption, nkCenter, nkCol,
  nkColgroup, nkData, nkDatalist, nkDd, nkDel, nkDetails, nkDfn, nkDialog,
  nkDiv, nkDl, nkDt, nkEm, nkEmbed, nkFieldset, nkFigure, nkFigcaption,
  nkFooter, nkForm, nkH1, nkH2, nkH3, nkH4, nkH5, nkH6, nkHeader, nkI, nkImg,
  nkIns, nkKbd, nkKeygen, nkLabel, nkLegend, nkLi, nkMain, nkMap, nkMark,
  nkMarquee, nkNav, nkObject, nkOl, nkOptgroup, nkOption, nkOutput, nkParam,
  nkPicture, nkPre, nkQ, nkRb, nkRp, nkRt, nkRtc, nkRuby, nkS, nkSamp,
  nkSection, nkSelect, nkSmall, nkSource, nkSpan, nkStrong, nkSub, nkSummary,
  nkSup, nkTable, nkTbody, nkTd, nkTemplate, nkTfoot, nkTh, nkThead, nkTr,
  nkTrack, nkTt, nkU, nkUl]  ## All Tags that can possibly have childrens.




func newHead*(title: HtmlNode, meta: varargs[HtmlNode], link: varargs[HtmlNode]): HtmlNode =
  result = HtmlNode(kind: nkHead, title: title, meta: @meta, link: @link)

macro head*(inner: untyped): HtmlNode =
  assert inner.len >= 1, "Head Error: Wrong number of inner elements:" & $inner.len
  result = newCall("newHead")
  if inner.len == 1:
    result.add(inner)
  inner.copychildrento(result)


func meta*(name, val: string): HtmlNode =
  HtmlNode(kind: nkMeta, name: name, content: val)

func title*(titulo: string): HtmlNode =
  HtmlNode(kind: nkTitle, val: titulo.strip.capitalizeAscii)

func p*(x: varargs[string, `$`]): Htmlnode =
  result = Htmlnode(kind: nkP, text: (@x).join(" "))


func newDiv*(sons: varargs[HtmlNode]): HtmlNode =
  result = HtmlNode(kind: nkDiv, sons: @sons)

macro dv*(inner: untyped): HtmlNode =
  assert inner.len >= 1, "Div Error: Wrong number of inner elements:" & $inner.len
  result = newCall("newDiv")
  if inner.len == 1:
    result.add(inner)
  inner.copychildrento(result)


func newBody*(sons: varargs[HtmlNode]): HtmlNode =
  result = HtmlNode(kind: nkBody, sons: @sons)

macro body*(inner: untyped): HtmlNode =
  assert inner.len >= 1, "Body Error: Wrong number of inner elements:" & $inner.len
  result = newCall("newBody")
  if inner.len == 1:
    result.add(inner)
  inner.copychildrento(result)



func newa*(href, val: string, rel="", id="", class=""): HtmlNode =
  result = HtmlNode(kind: nkA, href: href, text: val)
  result.id = id
  result.class = class
  result.rel = rel



func newHtml*(head, body: HtmlNode): HtmlNode =
  ## Create a new ``<html>`` tag Node, containing a ``<head>`` and ``<body>``.
  HtmlNode(kind: nkHtml, head: head, body: body)

macro html*(name: untyped, inner: untyped): typed =
  ## Macro to create a new call to ``newHtml()``, passing Head and Body as arg.
  var rs = newCall("newHtml", inner[0], inner[1])
  result = quote do:
    func `name`(): HtmlNode {.inline.} = `rs`

template render_indent(thingy, indentation_level: untyped): untyped =
  ## Render Pretty-Printed with indentation when build for Release,else Minified
  when defined(release): thingy
  else: indent(thingy, indentation_level)

func render*(this: HtmlNode): string =
  ## Render HtmlNode with indentation return string.
  var indentation_level: byte   # indent level, 0 ~ 255.
  case this.kind
  of nkhtml:                    # <html>
    result &= render_tag this
    inc indentation_level
    result &= render_indent(render(this.head), indentation_level)
    result &= render_indent(render(this.body), indentation_level)
    dec indentation_level
    result &= close_tag this
  of nkhead:                    # <head>
    result &= render_tag this
    inc indentation_level
    for meta_tag in this.meta:  # <meta ... >
      result &= render_indent(render_tag(meta_tag), indentation_level)
    for link_tag in this.link:  # <link ... >
      result &= render_indent(render_tag(link_tag), indentation_level)
    result &= render_indent(render_tag(this.title), indentation_level)
    dec indentation_level
    result &= close_tag this
  of nkBody:                    # <body>
    result &= render_tag this
    inc indentation_level
    for tag in this.sons:
      if tag.kind in can_have_children:
        result &= render_indent(render(tag), indentation_level)
      else:
        result &= render_indent(render_tag(tag), indentation_level)
    dec indentation_level
    result &= close_tag this
  of nkAddress, nkArea, nkArticle, nkAside, nkAudio, nkB, nkBase, nkBdi, nkBdo,
     nkBig, nkBlockquote, nkButton, nkCanvas, nkCaption, nkCenter, nkCol,
     nkColgroup, nkData, nkDatalist, nkDd, nkDel, nkDetails, nkDfn, nkDialog,
     nkDiv, nkDl, nkDt, nkEm, nkEmbed, nkFieldset, nkFigure, nkFigcaption,
     nkFooter, nkForm, nkH1, nkH2, nkH3, nkH4, nkH5, nkH6, nkHeader, nkI, nkImg,
     nkIns, nkKbd, nkKeygen, nkLabel, nkLegend, nkLi, nkMain, nkMap, nkMark,
     nkMarquee, nkNav, nkObject, nkOl, nkOptgroup, nkOption, nkOutput, nkParam,
     nkPicture, nkPre, nkQ, nkRb, nkRp, nkRt, nkRtc, nkRuby, nkS, nkSamp,
     nkSection, nkSelect, nkSmall, nkSource, nkSpan, nkStrong, nkSub, nkSummary,
     nkSup, nkTable, nkTbody, nkTd, nkTemplate, nkTfoot, nkTh, nkThead, nkTr,
     nkTrack, nkTt, nkU, nkUl:  # All other tags
    result &= render_tag this
    inc indentation_level
    for tag in this.sons:
      if tag.kind in can_have_children:
        result &= render_indent(render(tag), indentation_level)
      else:
        result &= render_indent(render_tag(tag), indentation_level)
    dec indentation_level
    result &= close_tag this
  else:
    assert false


when isMainModule:
  html page:
    head:
      title("Title")
    body:
      p("Hello")
      p("World")
      dv:
        p "Example"
  echo render(page())
