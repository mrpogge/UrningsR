#---------------------------------------------
#Placeholder function for the adaptivity correction part of the
#Metropolis step in nonadaptive simulations
#------------------------------------------------
non_adaptive_corrector = function(player, item, proposal, adaptive_matrix, item_bins){
  return(1)
}

#---------------------------------------------
#PFunction for the adaptivity correction part of the
#Metropolis step in adaptive simulations
#------------------------------------------------

adaptive_corrector = function(player, item, proposal, adaptive_matrix, item_bins){
  selection_kernel = adaptive_matrix[(player[["score"]] + 1), (item[["score"]] + 1)]
  normalising_constant = sum(adaptive_matrix[(player[["score"]] + 1), ] * item_bins)
  curr_selection_prob = selection_kernel / normalising_constant

  proposed_item_bins = item_bins

  proposed_item_bins[item[["score"]] + 1] = proposed_item_bins[item[["score"]] + 1] - 1
  proposed_item_bins[proposal[[2]] + 1] = proposed_item_bins[proposal[[2]] + 1] + 1

  selection_kernel_prop = adaptive_matrix[(proposal[[1]] + 1), (proposal[[2]] + 1)]
  normalising_constant_prop = sum(adaptive_matrix[(proposal[[1]] + 1), ] * proposed_item_bins)

  prop_selection_prob = selection_kernel_prop / normalising_constant_prop

  adaptivity_corrector = prop_selection_prob/curr_selection_prob
  return(adaptivity_corrector)
}

#---------------------------------------------
#Function for the correction part coming from the original Urnings algorithm
#------------------------------------------------
metropolis_corrector_U1 = function(player, item, proposal){
  player_proposal = proposal[[1]]
  item_proposal = proposal[[2]]
  old_score = player[["score"]] * (player[["urn_size"]] - item[["score"]]) + (item[["urn_size"]] - player[["score"]]) * item[["score"]]
  new_score = player_proposal * (player[["urn_size"]] - item_proposal) + (item[["urn_size"]] - player_proposal) * item_proposal

  return(old_score/new_score)
}

#---------------------------------------------
#Placeholder function for the correction part for Urnings2 algorithm
#------------------------------------------------
metropolis_corrector_U2 = function(player, item, proposal){
  return(1)
}
