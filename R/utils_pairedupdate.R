#----------------------------------------
# just an unnecessary function
#----------------------------------------
diff_recoder = function(diff){
  if(diff > 1){
    ret = 1
  } else if(diff < -1){
    ret = -1
  }
  return(diff)
}


#----------------------------------------
# original paired update algorithm proposed by Bolsinova et aal (2022)
# TODO: test whether the produces the right results
#----------------------------------------
paired_update = function(items, item_index, item_diff, queue_neg, queue_pos){
  if(item_diff == 1){
    if(all(queue_neg == 0)){
      queue_pos[item_index] = queue_pos[item_index] + 1
      if(items[[item_index]][["score"]] > 0){
        items[[item_index]][["score"]] = items[[item_index]][["score"]] - 1
        items[[item_index]][["est"]] = items[[item_index]][["score"]] / items[[item_index]][["urn_size"]]
      }
    } else {
      candidates = which(queue_neg >= 1)
      candidate_user_id = sample(candidates, 1)

      #settintg the items place in the queue to 0
      queue_neg[candidate_user_id] = 0
      items[[candidate_user_id]][["score"]] = items[[candidate_user_id]][["score"]] - 1
      items[[candidate_user_id]][["est"]] = items[[candidate_user_id]][["score"]] / items[[candidate_user_id]][["urn_size"]]
    }
  }

  if(item_diff == -1){
    if(all(queue_pos == 0)){
      queue_neg[item_index] = queue_neg[item_index] + 1
      if(items[[item_index]][["score"]] > items[[item_index]][["urn_size"]]){
        items[[item_index]][["score"]] = items[[item_index]][["score"]] + 1
        items[[item_index]][["est"]] = items[[item_index]][["score"]] / items[[item_index]][["urn_size"]]
      }
    } else {
      candidates = which(queue_pos >= 1)
      candidate_user_id = sample(candidates, 1)

      queue_pos[candidate_user_id] = 0
      items[[item_index]][["score"]] = items[[item_index]][["score"]] + 1
      items[[item_index]][["est"]] = items[[item_index]][["score"]] / items[[item_index]][["urn_size"]]
    }
  }
  return(items)
}

#----------------------------------------
# Placeholder function for the paired update process
#----------------------------------------

no_paired_update = function(items, item_index, item_diff, queue_neg, queue_pos){
  return(items)
}
