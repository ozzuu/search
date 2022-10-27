from std/json import parseJson, to, getStr, `{}`, pairs, items

type
  SearchTopic* = object
    name*: string
    links*: seq[SearchTopicLink]
  SearchTopicLink* = tuple[name: string; data: SearchLink]
  SearchLink* = object
    url*, short*: string
  SearchTopics* = seq[SearchTopic]

const searchesJson {.strdefine.} = ""

when searchesJson.len == 0:
  {.error: "Provide the searches.json".}

proc loadSearchTopics*: SearchTopics {.compileTime.} =
  ## Loads all search methods from a JSON
  let node = parseJson readFile searchesJson
  for topic in node:
    var top = SearchTopic(
      name: topic{"name"}.getStr
    )
    for (name, obj) in topic{"links"}.pairs:
      let data = SearchLink(
        url: obj{"url"}.getStr,
        short: obj{"short"}.getStr,
      )
      top.links.add (name, data)
    result.add top
