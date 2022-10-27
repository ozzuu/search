# from std/dom import window
import std/dom
from std/uri import encodeUrl, decodeUrl
from std/strutils import replace, strip, join, split
from std/sugar import `->`
from std/strformat import fmt

include karax/prelude

from pkg/util/forHtml import genClass

from search/topics import loadSearchTopics, SearchTopicLink

const searches = loadSearchTopics()

template searchTerm: string =
  if window.location.hash.len > 0:
    window.location.hash.`$`[1..^1].decodeUrl
  else:
    ""

proc query(url, term: string): string =
  url.replace("%s", encodeUrl term)

proc gotoUrl(url: string; target = "") =
  var a = document.createElement "a"
  a.setAttribute("href", url)
  a.setAttribute("target", target)
  click a

proc drawSearchPage(): VNode =
  result = buildHtml(main(class = "main")):
    header(class = genClass({"top": searchTerm.len > 0})):
      h1: text "Ozzuu Search"
      tdiv(class = "input"):
        input(`type` = "text", placeholder = "Search term", value = searchTerm):
          proc onInput(ev: Event; n: VNode) =
            window.location.hash = cstring n.value
    section(class = genClass({"topics": true, "hidden": searchTerm.len == 0})):
      for topic in searches:
        tdiv(class = "topic"):
          h2(class = "title"): text topic.name
          section(class = "searches"):
            for (name, data) in topic.links:
              if data.short.len > 0:
                a(
                  href = data.url.query searchTerm,
                  `aria-label` = data.short,
                  `data-balloon-pos` = "up"
                ):
                  bold: text name
              else:
                a(href = data.url.query searchTerm):
                  bold: text name
        hr()

proc drawAutoShort(search: string; link: SearchTopicLink): () -> VNode =
  result = proc: VNode =
    result = buildHtml(main(class = "main")):
      h1: text fmt"Searching '{search}' in {link.name}"

when isMainModule:
  block autoShort:
    let term = searchTerm
    if term.len > 0:
      let
        parts = term.strip.split " "
        search = parts[1..^1].join " "
        short = parts[0]
      for topic in searches:
        for (name, data) in topic.links:
          if data.short == short:
            setRenderer drawAutoShort(search, (name, data))
            window.location.hash = search
            gotoUrl data.url.query search
            quit 0

  setRenderer drawSearchPage
