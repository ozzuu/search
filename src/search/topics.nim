from std/json import parseJson, to, getStr, `{}`, pairs, items, getInt

type
  Config* = object
    default*: DefaultSearch
    searches*: SearchTopics
  SearchTopic* = object
    name*: string
    links*: seq[SearchTopicLink]
  SearchTopicLink* = tuple[name: string; data: SearchLink]
  SearchLink* = object
    url*, short*: string
  SearchTopics* = seq[SearchTopic]
  DefaultSearch* = object
    short*: string
    delay*: int # in ms; negative to disable

const configJson {.strdefine.} = ""

when configJson.len == 0:
  {.error: "Provide the config.json".}

proc loadConfig*: Config {.compileTime.} =
  ## Loads all search methods from a JSON
  let node = parseJson readFile configJson
  result.default.short = node{"default", "short"}.getStr
  result.default.delay = node{"default", "delay"}.getInt -1
  block searches:
    var usedShorts: seq[string]
    for topic in node{"searches"}:
      var top = SearchTopic(
        name: topic{"name"}.getStr
      )
      for (name, obj) in topic{"links"}.pairs:
        let data = SearchLink(
          url: obj{"url"}.getStr,
          short: obj{"short"}.getStr,
        )
        if data.short in usedShorts:
          echo "The short of '" & name & "' duplicated"
          quit 1
        else:
          usedShorts.add data.short

        top.links.add (name, data)
      result.searches.add top
