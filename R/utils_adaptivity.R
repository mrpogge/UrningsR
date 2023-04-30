#--------------------------------------------------
#creates a matrix of values proportional to the selection
#probability of an item and a player with a given urnings
#--------------------------------------------------

calculate_normal_selection = function(R_i, R_j, n_i, n_j, mu, sigma){
  if(mu == 0){
    return(exp(-sigma*(log((R_i + 1) / (n_i-R_i+1)) - log((R_j + 1) / (n_j - R_j + 1)))^2))
  } else {
    return(exp(-sigma*(log((R_i + 1) / (n_i-R_i+1)) - log((R_j + 1) / (n_j - R_j + 1)) - log(mu/(1-mu)))^2))
  }
}


#--------------------------------------------------
#creates a matrix of values proportional to the selection
#probability of an item and a player with a given urnings
#--------------------------------------------------

init_adaptivity_matrix = function(player_urn_size, item_urn_size, mu, sigma){
  adaptive_matrix_binned = matrix(0, player_urn_size + 1, item_urn_size + 1)
  for(p in 0:(player_urn_size)){
    for(i in 0:(item_urn_size)){
      adaptive_matrix_binned[p+1,i+1] = calculate_normal_selection(p,i,player_urn_size, item_urn_size, mu, sigma)
    }
  }
  return(adaptive_matrix_binned)
}

#--------------------------------------------------
#creates a vector with length equal to the maximum urnings + 1, and contains the
#number of items with the given urnings value.
#--------------------------------------------------

init_item_bins = function(items, item_urn_size){
  item_bins = numeric(length = item_urn_size + 1)
  for(i in 1:length(items)){
    place = items[[i]][["score"]]
    item_bins[place+1] = item_bins[place+1] + 1
  }
  return(item_bins)
}

#--------------------------------------------------
#extracts the item difficulty from the item objects and stores it in a vector
#--------------------------------------------------

init_item_difficulties = function(items){
  item_difficulty_score = numeric(length = length(items))
  for(i in 1:length(items)){
    item_difficulty_score[i] = items[[i]][["score"]]
  }
  return(item_difficulty_score)
}


#--------------------------------------------------
#selects agent randomly
#--------------------------------------------------
select_agent = function(items,
                        probability = NULL,
                        player_idx = NULL,
                        adaptivity_matrix = NULL,
                        item_bins = NULL,
                        item_scores = NULL){
  if(is.null(probability)){
    probability = rep(1, length(items))
  }
  new_agent_index = sample(seq(length(items)), 1, prob = probability)
  return(new_agent_index)
}

#--------------------------------------------------
#selects agent adaptively
#--------------------------------------------------
select_agent_adaptive = function(items,
                                 probability = NULL,
                                 player_idx = NULL,
                                 adaptivity_matrix = NULL,
                                 item_bins = NULL,
                                 item_scores = NULL){
  probs = (adaptivity_matrix[player_idx, ] * item_bins) / sum(adaptivity_matrix[player_idx, ] * item_bins)
  new_agent_score = sample(seq(length(probs)), 1, prob = probs) - 1
  agent_idx_with_score = which(item_scores == new_agent_score)
  new_agent_idx = sample(agent_idx_with_score, 1)
  return(new_agent_idx)
}
