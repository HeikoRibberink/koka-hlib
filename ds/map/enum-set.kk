module enum-set

pub import hlib/ds/map/enum-map

pub alias enum-set<k> = enum-map<k,()>

pub fun add(set : enum-set<k>, key : k) : exn enum-set<k>
  set.enum-map/add(key, ())

pub fun keys(set : enum-set<k>) : list<k>
  set.entries.map fn((k, _)) k

pub fun show(set : enum-set<k>, ?show : k -> string) : string
  "{" ++ set.keys.map(show).join(",") ++ "}"
