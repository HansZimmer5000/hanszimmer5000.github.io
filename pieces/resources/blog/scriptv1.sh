#!/bin/bash

# Define a recursive function to flatten the JSON list and collect unique "type" values based on the "id" field
function flatten_json_list {
  local result=$1
  local item=$2
  local ids=()

  if [[ $(echo "${item}" | jq 'type') == "array" ]]; then
    # If the item is another JSON list, recursively call this function on it
    for subitem in $(echo "${item}" | jq -c '.[]'); do
      result=$(flatten_json_list "${result}" "${subitem}")
    done
  else
    # If the item is not a JSON list, check if it's a JSON object with both "type" and "id" fields
    if [[ $(echo "${item}" | jq 'type') == "object" && $(echo "${item}" | jq '.type' | grep -q -E '[^[:space:]]') && $(echo "${item}" | jq '.id' | grep -q -E '^[0-9]+$') ]]; then
      # If the item has both "type" and "id" fields, check if the id has already been added to the ids array
      local id=$(echo "${item}" | jq '.id')
      if ! echo "${ids[@]}" | grep -q -w "${id}"; then
        # If the id hasn't been added yet, append the "type" value to the result array and add the id to the ids array
        result=$(echo "${result}" | jq ". + [$(echo "${item}" | jq '.type')]")
        ids+=("${id}")
      fi
    fi
  fi

  echo "${result}"
}

# Read in the JSON list from stdin
json_list=$(cat)

# Call the flatten_json_list function on the JSON list
final_result=$(flatten_json_list "[]" "${json_list}")

# Print the final result
echo "${final_result}"