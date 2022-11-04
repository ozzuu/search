from std/json import parseJson, to, getStr, `{}`, pairs, items, getInt, JsonNode,
                      JsonParsingError, hasKey

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
  ConfigWithShorts = tuple[config: Config; usedShorts: seq[string]]

const configJson {.strdefine.} = ""

when configJson.len == 0:
  {.error: "Provide the config.json".}

proc loadConfig(node: JsonNode; usedShorts = newSeq[string]()): ConfigWithShorts =
  ## Loads all search methods from a JSON
  result.config.default.short = node{"default", "short"}.getStr
  result.config.default.delay = node{"default", "delay"}.getInt -1
  block searches:
    if node.hasKey "searches":
      result.usedShorts = usedShorts
      for topic in node{"searches"}:
        var top = SearchTopic(
          name: topic{"name"}.getStr
        )
        if topic.hasKey "links":
          for (name, obj) in topic{"links"}.pairs:
            let data = SearchLink(
              url: obj{"url"}.getStr,
              short: obj{"short"}.getStr,
            )
            if data.short in result.usedShorts:
              echo "The short of '" & name & "' duplicated"
              quit 1
            else:
              result.usedShorts.add data.short

            top.links.add (name, data)
        result.config.searches.add top

proc loadConfig*: ConfigWithShorts {.compileTime.} =
  loadConfig parseJson readFile configJson

proc mergeCustomConfig*(base: ConfigWithShorts; search: string): Config =
  ## Loads the config defined in query parameter
  result = base.config
  if search.len < 3:
    return
  var custom: Config
  try:
    custom = loadConfig(parseJson search[1..^1], base.usedShorts).config
  except JsonParsingError:
    return
    
  template set(x, val: untyped): untyped =
    when val is string:
      if val.len > 0:
        x = val
    when val is int:
      if val > 0:
        x = val
    else:
      x = val
  set result.default.short, custom.default.short
  set result.default.delay, custom.default.delay

  for searches in custom.searches:
    block addSearches:
      for sx in result.searches.mitems:
        if sx.name == searches.name:
          for link in searches.links:
            sx.links.add link
          break addSearches
      result.searches.add searches

when isMainModule:
  import std/[json, jsonutils]
  let conf = loadConfig()
  let a = stdin.readLine
  var all = conf.mergeCustomConfig "?" & $(%*{
    "default":{
      "short": "asdasda"
    },
    "searches": [
      {
        "name": "Search Engines",
        "links": {
          "Github": {
            "url": "https://github.com/search?q=%s",
            "short": "gh"
          },
          a: {
            "url": "https://githubs.c/search?q=%s",
            "short": "d"
          },
        }
      }
    ]
  })
  echo pretty toJson all
