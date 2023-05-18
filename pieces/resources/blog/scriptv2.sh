#!/bin/bash

log(){
  test "$verbose" = "true" && echo "$(date): $*" 1>&2
}

# Define a recursive function to flatten the JSON list and collect unique "type" values based on the "id" field
flatten_json_list(){
  flatten_json_list_ "{
    \"ids\": [],
    \"result\": []
  }" "$1" | jq -c .
}

flatten_json_list_() {
  local input result item ids

  input="$1"
  ids=$(echo "$input" | jq .ids)
  result=$(echo "$input" | jq .result)
  item="$2"

  log "input = $(echo "$1" | jq -c .))"

  log "item: $item"
  if [ "$(echo "${item}" | jq 'type=="array"')" = "true" ]; then
    local tmp_output tmp_ids tmp_result
    # If the item is another JSON list, recursively call this function on it
    for subitem in $(echo "${item}" | jq -c '.[]'); do
      log "array: $subitem"
      tmp_output=$(flatten_json_list_ "$input" "$subitem")
      tmp_ids=$(echo "$tmp_output" | jq .ids)
      tmp_result=$(echo "$tmp_output" | jq .result)
      input="{
        \"ids\": $(echo "${ids}" | jq -c ". + $tmp_ids"),
        \"result\": $(echo "${result}" | jq -c ". + $tmp_result")
      }"
    done
    ids=$(echo "$input" | jq .ids)
    result=$(echo "$input" | jq .result)
  else
    # If the item is not a JSON list, check if it's a JSON object with both "type" and "id" fields
    if [[ "$(echo "${item}" | jq 'type=="object"')" = "true" && $(echo "${item}" | jq '.type==null') == "false" && $(echo "${item}" | jq '.id==null') == "false" ]]; then
      log "json object"
      # If the item has both "type" and "id" fields, check if the id has already been added to the ids array
      local id type
      id=$(echo "${item}" | jq -r '.id')
      type=$(echo "${item}" | jq -r '.type')
      log "unknown id $id: $(echo "$ids" | jq -c .)"
      if [ "$(echo "$ids" | jq ". | index(\"$id\") == null")" = true ]; then
        # If the id hasn't been added yet, append the "type" value to the result array and add the id to the ids array
        log "result: $result: $type"
        result=$(echo "${result}" | jq -c ". + [\"$type\"]")
        ids=$(echo "${ids}" | jq -c ". + [\"$id\"]")
        log "ids end = $(echo "$ids" | jq -c .)"
      fi
    fi
  fi
  output="{
    \"ids\": $ids,
    \"result\": $result
  }"
  echo "$output"
}

verbose="false"

# Read in the JSON list from first positional argument or stdin (thanks to https://stackoverflow.com/a/2456870)
if [ -t 0 ]; then
    # ./scriptv2.sh '[{"type": "abc", "id": 3}, {"type": "xyz", "id":3}, {"type": "def", "id": 0}]'
    json_list=${1:?insert json}
else
    # echo '[{"type": "abc", "id": 3}, {"type": "xyz", "id":3}, {"type": "def", "id": 0}]' | ./scriptv2.sh 
    json_list=$(cat)
fi

# Call the flatten_json_list function on the JSON list
final_result=$(flatten_json_list "${json_list}")

# Print the final result
echo "$final_result"
