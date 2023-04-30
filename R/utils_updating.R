source("./R/utils_rasch.R")
#-------------------------------------
#simulating true outcome in simulations
#-------------------------------------

draw_true_outcome = function(player, item){
  true_outcome  = rasch_response_probability(player[["true_value"]], item[["true_value"]])
  return(true_outcome)
}

#-------------------------------------
#expected outcome based on the original Urnings algorithm
#-------------------------------------
draw_urnings1 = function(player, item, true_outcome){
  expected_outcome = rasch_response_probability(player[["est"]], item[["est"]])
  return(expected_outcome)
}

#-------------------------------------
#expected outcome based on the Urnings2 algorithm
#-------------------------------------
draw_urnings2 = function(player, item, true_outcome){
  player_curr_est = (player[["score"]] + true_outcome) / (player[["urn_size"]] + 1)
  item_curr_est = (item[["score"]] + 1 - true_outcome) / (item[["urn_size"]] + 1)
  expected_outcome = rasch_response_probability(player_curr_est, item_curr_est)
  return(expected_outcome)
}

#-------------------------------------
#one dimensional updating
#-------------------------------------
updating_rule_1D = function(player, item, true_outcome, expected_outcome){
  player_proposal = player[["score"]] + true_outcome - expected_outcome
  item_proposal = item[["score"]] + (1 - true_outcome) - (1 - expected_outcome)
  #print(c(player_proposal, item_proposal))

  return(list(player_proposal, item_proposal))
}
