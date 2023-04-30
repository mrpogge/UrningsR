source("./R/utils_adaptivity.R")
source("./R/utils_metropolis_correction.R")
source("./R/utils_pairedupdate.R")
source("./R/utils_rasch.R")
source("./R/utils_updating.R")
source("./R/create_agents.R")


#'Function setting up the analysis environment
#'
#'
#'@export
urnings_game = function(scores,
                        urn_size_player = 16,
                        urn_size_item = 32,
                        init_value_player = 0.5,
                        init_value_items = 0.5,
                        alg_type = "Urnings2",
                        paired_update_bool = TRUE){

  players = map(unique(scores[,"player"]), ~create_real_player(.x, 5, 10, ngames = length(scores[,"player"] == .x))) %>%
              setNames(unique(scores[,"player"])) %>% list2env()
  items = map(unique(scores[,"item"]), ~create_real_player(.x, 16, 32, ngames = length(scores[,"item"] == .x))) %>%
              setNames(unique(scores[,"item"])) %>% list2env()

  #selecting alg_type function
  algo = switch(
    alg_type,
    "Urnings1" = draw_urnings1,
    "Urnings2" = draw_urnings2
  )

  updating_rule = updating_rule_1D

  metropolis_corrector = switch(
    alg_type,
    "Urnings1" = metropolis_corrector_U1,
    "Urnings2" = metropolis_corrector_U2
  )

  if(paired_update_bool == TRUE){
    paired_update_rule = paired_update
  } else {
    paired_update_rule = no_paired_update
  }

  analysis_setup = list(
    scores = scores,
    players = players,
    items = items,
    algorithm = algo,
    updating_rule = updating_rule,
    paired_update_fun = paired_update_rule
  )

  analysis_env = list2env(analysis_setup)

}
#'Function setting up the analysis environment
#'
#'
#'@exports
analyse = function(game_type){
  game = urnings_game_sim_handler(scores = game_type$scores,
                                  players = game_type$players,
                                  items = game_type$items,
                                  alg_type = game_type$algorithm,
                                  updating_rule = game_type$updating_rule,
                                  metropolis_correction = game_type$metropolis_corrector,
                                  paired_update_rule = game_type$paired_update_fun)
  return(game)
}

urnings_game_handler = function(scores,
                                players,
                                items,
                                alg_type,
                                updating_rule,
                                metropolis_correction,
                                paired_update_rule){

  for(ng in 1:nrow(scores)){

    curr_player = players[[scores[ng, "player"]]]
    curr_item = items[[scores[ng, "item"]]]

    result = scores[ng, "score"]
    expected_result = alg_type(curr_player, curr_item, result)

    player_previous = curr_player[["score"]]
    item_previous = curr_item[["score"]]

    #---------Update the urnings ------------------------------------------#
    proposal = updating_rule(curr_player, curr_item, result, expected_result)

    #--------Calculating Metropolis correction ---------------------------#
    if(proposal[[1]] != curr_player[["score"]]){
      metropolis_corrector = metropolis_correction(curr_player, curr_item, proposal)
      acceptance = min(1, metropolis_corrector)
      u = runif(1)

      if(u < acceptance){
        curr_player[["score"]] = proposal[[1]]
        curr_item[["score"]] = proposal[[2]]
        curr_player[["est"]] = curr_player[["score"]] / curr_player[["urn_size"]]
        curr_item[["est"]] = curr_item[["score"]] / curr_item[["urn_size"]]
      }
    }

    #--------Paired item update TODO ------------------------------------#
    #player_diff = diff_recoder(curr_player[["score"]] - player_previous)
    #item_diff = diff_recoder(curr_item[["score"]] - item_previous)

    #TODO: test this
    #items = paired_update_rule(items, item_idx, item_diff, queue_neg, queue_pos)

    #---------Saving the results ----------------------------------------#
    #this needs to be solved
    curr_player[["estimate_container"]] = c(curr_player[["estimate_container"]], curr_player[["est"]])
    curr_item[["estimate_container"]] = c(curr_item[["estimate_container"]], curr_item[["est"]])

    curr_player[["differential_container"]] = c(curr_player[["differential_container"]], player_diff)
    curr_item[["differential_container"]] = c(curr_item[["differential_container"]], item_diff)

    curr_player[["match_history_items"]] = c(curr_player[["match_history_items"]], item_idx)
    curr_player[["match_history"]] = c(curr_player[["match_history"]], proposal[[1]])

    #---------updating the adaptivity components------------------------#

    players[[scores[ng, "player"]]] = curr_player
    items[[scores[ng, "item"]]] = curr_item

  }

  return(list2env(list(players = players, items = items)))
}




