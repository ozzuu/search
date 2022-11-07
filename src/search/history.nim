from std/times import getTime, toUnix
from std/json import `%*`, `%`, `$`, parseJson, to
when defined js:
  from std/dom import window, getItem, setItem

const searchHistory = cstring "search_history"

type
  History* = seq[HistoryItem]
  HistoryItem* = object
    time*: int64 # unix time
    value*: string
    id*: int

using
  self: var History
  value: string
  id: int

var hist*: History

proc initHistoryItem(id; value): HistoryItem =
  ## Initialize new history item
  result.id = id
  result.value = value
  result.time = getTime().toUnix

proc add*(self; value) =
  ## Adds new item to history
  self.add self.len.initHistoryItem value

proc del*(self; id): bool =
  ## Deletes the history item by id
  result = false
  for i, it in self:
    if it.id == id:
      self.delete i
      return true

proc del*(self; value): bool =
  ## Deletes all `value`s of history
  result = false
  var toDel: seq[int]
  for i, it in self:
    if it.value == value:
      toDel.add i
  echo toDel
  for i in countdown(toDel.len - 1, 0):
    echo self[toDel[i]]
    self.delete toDel[i]
  if toDel.len < 0:
    result = true

proc save*(self) =
  ## Save the history in localstorage
  let data = $(%*self)
  when defined js:
    window.localStorage.setItem(searchHistory, cstring data)
  else:
    echo "Saving: " & data

proc load*(self) =
  ## Get the history of localstorage
  when defined js:
    let
      d = window.localStorage.getItem searchHistory
      data = if d.len > 0: $d else: "[]"
  else:
    let data = """[{"time":1667826459,"value":"test1","id":0},{"time":1667826459,"value":"test3","id":2},{"time":1667826459,"value":"test4","id":3},{"time":1667826459,"value":"test3","id":4}]"""
    echo "loaded: " & data
  self = data.parseJson.to History

when isMainModule:
  load hist
  echo hist.del 0
  echo hist.del "test3"
  save hist
