#-------------------------------------
#calculates the expected outcome based on player and item estimates
#-------------------------------------
rasch_response_probability = function(pi_player, pi_item){
  if(pi_player == pi_item){
    prob = 0.5
  } else {
    numerator = pi_player * (1 - pi_item)
    denominator = numerator + pi_item * (1 - pi_player)
    prob = numerator/denominator
  }
  res = rbinom(1,1,prob)
  return(res)
}

#-------------------------------------
#calculates the probability of the player winning against the item
#based on player and item estimates
#-------------------------------------
rasch_model = function(pi_player, pi_item){
  if(pi_player == pi_item){
    prob = 0.5
  } else {
    numerator = pi_player * (1 - pi_item)
    denominator = numerator + pi_item * (1 - pi_player)
    prob = numerator/denominator
  }
  return(prob)
}
