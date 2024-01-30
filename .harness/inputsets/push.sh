for file in *; do
    echo $file
    identifier=$(yq '.inputSet | .identifier' $file)
    
curl -i -X POST \
  'https://app.harness.io/v1/orgs/default/projects/technical_exercise/input-sets/'$identifier'/import?pipeline=ci_bad_inputset_id' \
  -H 'Content-Type: application/json' \
  -H 'Harness-Account: WqS38aeyQjayoqy6mzwceA' \
  -H 'x-api-key: '$1'' \
  -d '{
    "git_import_info": {
      "connector_ref": "account.ghconnectoracc",
      "repo_name": "harness-yaml-templates",
      "branch_name": "main",
      "file_path": ".harness/inputsets/'$file'",
      "is_force_import": true
    },
    "input_set_import_request": {
      "input_set_name": "example",
      "input_set_description": "string"
    }
  }'

done
