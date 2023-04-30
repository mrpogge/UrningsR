#'Function for creating player objects in simulation
#'
#'
#'@export
create_player = function(id, true_ability, starting_value, urn_size){
  player_object = list(
    id = id,
    true_value = true_ability,
    score = starting_value,
    urn_size = urn_size,
    est = starting_value / urn_size,

    #containers
    urnings_container = c(urn_size),
    estimate_container = c(starting_value / urn_size),
    differential_container = c(0),
    match_history_items = c("init"),
    match_history = c(0)
  )

  class(player_object) = "player"
  return(player_object)
}

#'Function for creating item objects in simulation
#'
#'
#'@export
create_item = function(id, true_ability, starting_value, urn_size){
  item_object = list(
    id = id,
    true_value = true_ability,
    score = starting_value,
    urn_size = urn_size,
    est = starting_value / urn_size,

    #containers
    urnings_container = c(urn_size),
    estimate_container = c(starting_value / urn_size),
    differential_container = c(0)
  )

  class(item_object) = "item"
  return(item_object)
}

create_real_player = function(id, starting_value, urn_size, ngames){
  player_object = list(
    id = id,
    score = starting_value,
    urn_size = urn_size,
    est = starting_value / urn_size,

    #containers
    estimate_container = numeric(length = ngames),
    match_history_items = character(length = ngames),
    match_history = numeric(length = ngames)
  )

  player_env = list2env(player_object)
  return(player_env)
}

create_real_item = function(item_id, starting_value, urn_size, ngames){
  item_object = list(
    id = item_id,
    score = starting_value,
    urn_size = urn_size,
    est = starting_value / urn_size,

    #containers
    estimate_container = numeric(length = ngames)
  )
  item_env = list2env(item_object)
  return(item_env)
}


