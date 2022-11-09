# from std/dom import window
import std/dom except Event
from std/uri import encodeUrl, decodeUrl
from std/strutils import replace, strip, join, split
from std/sugar import `->`
from std/strformat import fmt

include karax/prelude

from pkg/util/forHtml import genClass

from search/configs import loadConfig, mergeCustomConfig, SearchTopicLink
import search/history

const base = loadConfig()
let config = base.mergeCustomConfig decodeUrl $window.location.search


template searchTerm: string =
  if window.location.hash.len > 0:
    window.location.hash.`$`[1..^1].decodeUrl
  else:
    ""

var defaultCancelled = searchTerm.len == 0

proc query(url, term: string): string =
  url.replace("%s", encodeUrl term)

proc gotoUrl(url: string; target = "") =
  var a = document.createElement "a"
  a.setAttribute("href", url)
  a.setAttribute("target", target)
  click a

proc drawSearchPage(): VNode =
  result = buildHtml(main(class = "main")):
    style: text ":root{--default-delay: " & $config.default.delay & "ms;}"
    header(class = genClass({"top": searchTerm.len > 0})):
      h1: text "Ozzuu Search"
      tdiv(class = "input"):
        input(`type` = "text", placeholder = "Search term", value = searchTerm,
          list = "history", autofocus = ""):
          proc onInput(ev: Event; n: VNode) =
            window.location.hash = cstring n.value
        datalist(id = "history"):
          for i in countdown(hist.len - 1, 0):
            let item = hist[i]
            option(value = item.value)
    section(class = genClass({"topics": true, "hidden": searchTerm.len == 0})):
      for topic in config.searches:
        tdiv(class = "topic"):
          h2(class = "title"): text topic.name
          section(class = "searches"):
            for (name, data) in topic.links:
              proc b: VNode =
                buildHtml(bold(class = genClass({
                  "default": config.default.short == data.short,
                  "cancelled": defaultCancelled
                }))):
                  text name
              proc clickLink(ev: Event; n: VNode) {.closure.} =
                let short = n.getAttr "aria-label"
                var term = searchTerm
                if short.len > 0:
                  term = fmt"{short} {term}"
                discard hist.del term
                hist.add term
                save hist

              if data.short.len > 0:
                a(
                  href = data.url.query searchTerm,
                  `aria-label` = data.short,
                  `data-balloon-pos` = "up",
                  content = "no-referrer",
                  onclick = clickLink
                ): b()
              else:
                a(
                  href = data.url.query searchTerm,
                  content = "no-referrer",
                  onclick = clickLink
                ): b()
        hr()

proc drawAutoShort(search: string; data: SearchTopicLink): () -> VNode =
  result = proc: VNode =
    result = buildHtml(main(class = "main")):
      h1: text fmt"Searching '{search}' in {data.name}"

proc getSearch(short: string): SearchTopicLink =
  for topic in config.searches:
    for (name, data) in topic.links:
      if data.short == short:
        return (name, data)

proc defaultRedirect =
  if config.default.delay > 0:
    let term = searchTerm
    if term.len > 0:
      let srx = config.default.short.getSearch
      if srx.name.len > 0:
        let timeout = setTimeout((proc() =
          let fullTerm = fmt"{config.default.short} {term}"
          discard hist.del fullTerm
          hist.add fullTerm
          save hist
          gotoUrl srx.data.url.query term
        ), config.default.delay)
        let cancelProc = proc(ev: Event) =
          document.onclick = nil
          document.onmousemove = nil
          defaultCancelled = true
          redraw()
          clearTimeout timeout

        document.onclick = cancelProc
        document.onmousemove = cancelProc

when isMainModule:
  load hist
  block autoShort:
    let term = searchTerm
    if term.len > 0:
      let
        parts = term.strip.split " "
        search = parts[1..^1].join " "
        short = parts[0]
      let srx = short.getSearch
      if srx.name.len > 0:
        discard hist.del term
        hist.add term
        save hist
        setRenderer drawAutoShort(search, srx)
        gotoUrl srx.data.url.query search
        quit 0

  setRenderer drawSearchPage
  
  defaultRedirect()
