source("./R/utils_adaptivity.R")
source("./R/utils_metropolis_correction.R")
source("./R/utils_pairedupdate.R")
source("./R/utils_rasch.R")
source("./R/utils_updating.R")
source("./R/create_agents.R")

#'
#' Assemble the simulation environment for unidimensional Urnings algorithm.
#'
#'
#'
#'
#'@export
urnings_game_sim = function(players,
                        items,
                        n_games,
                        test = TRUE,
                        alg_type,
                        adaptivity,
                        paired_update_bool,
                        mu = 0,
                        sigma = 2){
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

  #implement adaptivity
  adaptivity_algo = switch(
    adaptivity,
    "n_adaptive" = select_agent,
    "adaptive" = select_agent_adaptive
  )

  adaptivity_corrector = switch(
    adaptivity,
    "n_adaptive" = non_adaptive_corrector,
    "adaptive" = adaptive_corrector
  )

  if(paired_update_bool == TRUE){
    paired_update_rule = paired_update
  } else {
    paired_update_rule = no_paired_update
  }

  selected_functions = list(players = players,
                            items = items,
                            n_games = n_games,
                            test = test,
                            algorithm = algo,
                            updating_rule = updating_rule,
                            adaptivity_algorithm = adaptivity_algo,
                            metropolis_corrector = metropolis_corrector,
                            adaptivity_corrector = adaptivity_corrector,
                            paired_update_fun = paired_update_rule,
                            mu = mu,
                            sigma = sigma)
  class(selected_functions) = "game_type"

  return(selected_functions)
}

#'
#' Starting the simulation
#'
#'
#'
#'
#'@export
simulate = function(game_type){
  game = urnings_game_sim_handler(players = game_type[["players"]],
                                   items = game_type[["items"]],
                                   n_games = game_type[["n_games"]],
                                   test = game_type[["test"]],
                                   alg_type = game_type[["algorithm"]],
                                   updating_rule = game_type[["updating_rule"]],
                                   adaptivity = game_type[["adaptivity_algorithm"]],
                                   metropolis_correction = game_type[["metropolis_corrector"]],
                                   adaptivity_correction = game_type[["adaptivity_corrector"]],
                                   paired_update_rule = game_type[["paired_update_fun"]],
                                   mu = game_type[["mu"]],
                                   sigma = game_type[["sigma"]])
  return(game)
}


#-------------------------------------
#handler function for the unidimensional urnings simulation
#-------------------------------------
urnings_game_sim_handler = function(players,
                                     items,
                                     n_games = 1500,
                                     test = TRUE,
                                     alg_type,
                                     updating_rule,
                                     adaptivity,
                                     adaptivity_correction,
                                     metropolis_correction,
                                     paired_update_rule,
                                     mu,
                                     sigma){
  ######INITIALISATION#####
  n_players = length(players)
  adaptive_matrix = init_adaptivity_matrix(players[[1]][["urn_size"]], items[[1]][["urn_size"]], mu, sigma)
  item_bins = init_item_bins(items, items[[1]][["urn_size"]])
  item_difficulties = init_item_difficulties(items)
  queue_pos = rep(0, length(items))
  queue_neg = rep(0, length(items))


  ######SIMULATION#########
  for(ng in 1:n_games){
    if(ng %% 50 == 0){
      print(paste0("Est. game: " , ng))
    }

    if(test == TRUE){
      for(np in 1:n_players){
        curr_player = players[[np]]
        item_idx = adaptivity(items,
                              probability = NULL,
                              player_idx = curr_player[["score"]] + 1,
                              adaptivity_matrix = adaptive_matrix,
                              item_bins = item_bins,
                              item_scores = item_difficulties)
        curr_item = items[[item_idx]]

        ############URNINGS GAME################
        #----------Simulating the true response and calculating the expected response-----#
        result = draw_true_outcome(curr_player, curr_item)
        expected_result = alg_type(curr_player, curr_item, result)

        player_previous = curr_player[["score"]]
        item_previous = curr_item[["score"]]

        #---------Update the urnings ------------------------------------------#
        proposal = updating_rule(curr_player, curr_item, result, expected_result)

        #--------Calculating Metropolis correction ---------------------------#
        if(proposal[[1]] != curr_player[["score"]]){
          adaptivity_corrector = adaptivity_correction(curr_player, curr_item, proposal, adaptive_matrix, item_bins)
          metropolis_corrector = metropolis_correction(curr_player, curr_item, proposal)

          acceptance = min(1, metropolis_corrector * adaptivity_corrector)
          u = runif(1)

          if(u < acceptance){
            curr_player[["score"]] = proposal[[1]]
            curr_item[["score"]] = proposal[[2]]
            curr_player[["est"]] = curr_player[["score"]] / curr_player[["urn_size"]]
            curr_item[["est"]] = curr_item[["score"]] / curr_item[["urn_size"]]
          }
        }

        #--------Paired item update TODO ------------------------------------#
        player_diff = diff_recoder(curr_player[["score"]] - player_previous)
        item_diff = diff_recoder(curr_item[["score"]] - item_previous)

        #TODO: test this
        items = paired_update_rule(items, item_idx, item_diff, queue_neg, queue_pos)

        #---------Saving the results ----------------------------------------#
        curr_player[["estimate_container"]] = c(curr_player[["estimate_container"]], curr_player[["est"]])
        curr_item[["estimate_container"]] = c(curr_item[["estimate_container"]], curr_item[["est"]])

        curr_player[["differential_container"]] = c(curr_player[["differential_container"]], player_diff)
        curr_item[["differential_container"]] = c(curr_item[["differential_container"]], item_diff)

        curr_player[["match_history_items"]] = c(curr_player[["match_history_items"]], item_idx)
        curr_player[["match_history"]] = c(curr_player[["match_history"]], proposal[[1]])

        #---------updating the adaptivity components------------------------#
        item_difficulties[item_idx] = curr_item[["score"]]
        item_bins[curr_item[["score"]] + 1] = item_bins[curr_item[["score"]] + 1] + 1
        item_bins[item_previous + 1] = item_bins[item_previous + 1] - 1

        players[[np]] = curr_player
        items[[item_idx]] = curr_item
      }
    }
  }
  return(list(players, items))
}









