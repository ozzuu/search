include karax / prelude

from search/topics import loadSearchtopics

const searches = loadSearchTopics()

echo searches
var searchTerm = kstring""

proc createDom(): VNode =
  result = buildHtml(tdiv):
    text searchTerm
    tdiv(class = "input"):
      input(`type` = "text", placeholder = "Search term"):
        proc onInput(ev: Event; n: VNode) =
          searchTerm = n.value
      button: text "Search"
    tdiv(class = "topics"):
      for topic in searches:
        h2(class = "title"): text topic.name
        tdiv(class = "searches"):
          for (name, data) in topic.links:
            a(href = data.url): text name



when isMainModule:
  setRenderer createDom
