module enum-map

pub import hlib/typeclasses/enum
import hlib/ext/vector
import hlib/patterns/exit

abstract type enum-map<k,v>
  EnumMap
    pub values : vector<maybe<v>>
    pub enum : enum<k>

pub fun empty(?enum : enum<k>) : enum-map<k,v>
  EnumMap(vector/vector(enum.listed.length, Nothing), enum)

pub fun add(map : enum-map<k,v>, key : k, value : v) : exn enum-map<k,v>
  val EnumMap(values, enum) = map
  val values' = values.update(enum.int.(key), fn(_) Just(value))
  EnumMap(values', enum)

pub fun get(map : enum-map<k,v>, key : k) : exn maybe<v>
  val EnumMap(values, enum) = map
  values[enum.int.(key)]

pub fun contains(map : enum-map<k,v>, key : k) : exn bool
  map.get(key).is-just

pub fun remove(map : enum-map<k,v>, key : k) : exn enum-map<k,v>
  map.update(key) fn(m)
    Nothing

pub fun update(map : enum-map<k,v>, key : k, updater : (maybe<v>) -> <exn|e> maybe<v>) : <exn|e> enum-map<k,v>
  val EnumMap(values, enum) = map
  val values' = values.update(enum.int.(key), updater)
  EnumMap(values', enum)

pub fun map(map : enum-map<k,v>, f : (key : k, value : maybe<v>) -> <exn|e> maybe<w>) : <exn|e> enum-map<k,w>
  val EnumMap(values, enum) = map
  val values' = enum.listed.vector.map-indexed fn(i, x)
    f(x, values[i])
  EnumMap(values', enum)

pub fun entries(map : enum-map<k,v>) : list<(k,v)>
  map.enum.listed.zip(map.values.vector/list).filter-map fn(z)
    match z
      (k, Just(v)) -> Just((k, v))
      _ -> Nothing
    
pub fun (==)(l : enum-map<k,v>, r : enum-map<k,v>, ?k/(==) : (k, k) -> bool, ?v/(==) : (v, v) -> bool) : bool
  enum/(==)(l.enum, r.enum) && list/(==)(l.values.list, r.values.list)
