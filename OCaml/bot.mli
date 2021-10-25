open Async

val start :
  token : string ->
  ?timeout : float ->
  ?cpu_limit : float ->
  ?mem_limit : string ->
  unit ->
  unit Deferred.t
