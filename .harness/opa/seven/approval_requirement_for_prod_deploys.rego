package pipeline

import future.keywords.every

default template_exists = false
default template_id = "account.prod_approval"


## APPROVAL STAGE OPA
# check if a template key exists at all as first step in approval stage - alpha complete (need check for versioning as OR)
deny[msg] {
	# Find all stages that are Approvals ...
  input.pipeline.stages[i].stage.type == "Approval"
  # and does not have the template array - this means the step is not a template if it errors
  not has_key(input.pipeline.stages[i].stage.spec.execution.steps[0].step,"template")
	# Show a human-friendly error message
	msg := sprintf("Approval stage '%s' does not have the correct first template step '%s'", [input.pipeline.stages[i].stage.name,template_id])
}

# Deny pipelines that don't have an approval step template in approval stage
deny[msg] {
	input.pipeline.stages[i].stage.type == "Approval"
  has_key(input.pipeline.stages[i].stage.spec.execution.steps[0].step.template,"templateRef")
  input.pipeline.stages[i].stage.spec.execution.steps[0].step.template.templateRef != template_id
	msg := sprintf("Approval stage '%s' does not have a HarnessApproval step '%s', found '%s'", [input.pipeline.stages[i].stage.name, template_id,input.pipeline.stages[i].stage.spec.execution.steps[0].step.template.templateRef])
}

## DEPLOYMENT STAGE OPA
# check if a template key exists at all as first step in deployment stage - alpha complete (need check for versioning as OR)
deny[msg] {
  # ignore if there exists an approval stage
  not input.pipeline.stages[i].stage.type == "Approval"
	# Find all stages that are Deployments ...
	input.pipeline.stages[i].stage.type == "Deployment"
  not has_key(input.pipeline.stages[i].stage.spec.execution.steps[0].step,"template")
	msg := sprintf("deployment stage '%s' does not have the correct first template step '%s'", [input.pipeline.stages[i].stage.name,template_id])
}

# Deny pipelines that don't have an approval step template as first step in deployment stage
deny[msg] {
  not input.pipeline.stages[i].stage.type == "Approval"
	input.pipeline.stages[i].stage.type == "Deployment"
  has_key(input.pipeline.stages[i].stage.spec.execution.steps[0].step,"template")
  input.pipeline.stages[i].stage.spec.execution.steps[0].step.template.templateRef != template_id
	msg := sprintf("deployment stage '%s' does not have a HarnessApproval step '%s', found '%s'", [input.pipeline.stages[i].stage.name, template_id,input.pipeline.stages[i].stage.spec.execution.steps[0].step.template.templateRef])
}

# check if first stepgroup has template at all in deployment stage - alpha complete (need check for versioning as OR)
deny[msg] {
	#not input.pipeline.stages[i].stage.type == "Approval"
	input.pipeline.stages[i].stage.type == "Deployment"
  has_key(input.pipeline.stages[i].stage.spec.execution.steps[0],"stepGroup")
  not has_key(input.pipeline.stages[i].stage.spec.execution.steps[0].stepGroup.steps[0].step,"template")
	msg := sprintf("deployment stage '%s' does not have the correct first stepgroup template '%s'", [input.pipeline.stages[i].stage.name,template_id])
}

# check if a stepgroup is first key in deployment stage - alpha complete (need check for versioning as OR)
deny[msg] {
	not input.pipeline.stages[i].stage.type == "Approval"
	input.pipeline.stages[i].stage.type == "Deployment"
  has_key(input.pipeline.stages[i].stage.spec.execution.steps[0],"stepGroup")
  has_key(input.pipeline.stages[i].stage.spec.execution.steps[0].stepGroup.steps[0].step,"template")
  input.pipeline.stages[i].stage.spec.execution.steps[0].stepGroup.steps[0].step.template.templateRef != template_id
	msg := sprintf("deployment stage '%s' does not have the correct first stepgroup template step '%s', has '%s'", [input.pipeline.stages[i].stage.name,template_id,input.pipeline.stages[i].stage.spec.execution.steps[0].stepGroup.steps[_].step.template.templateRef])
}

# check if a parallel stepgroup has any templates in deployment stage (prior check)
deny[msg] {
	not input.pipeline.stages[i].stage.type == "Approval"
	input.pipeline.stages[i].stage.type == "Deployment"
  # With env type production ...
  # input.pipeline.stages[i].stage.spec.infrastructure.environment.type == "Production"
  has_key(input.pipeline.stages[i].stage.spec.execution.steps[0],"stepGroup")
  has_key(input.pipeline.stages[i].stage.spec.execution.steps[0].stepGroup.steps[0],"parallel")
  not has_key_parallel_array(input.pipeline.stages[i].stage.spec.execution.steps[0].stepGroup.steps[0],"template")
  #input.pipeline.stages[i].stage.spec.execution.steps[0].stepGroup.steps[0].parallel[_].step.template.templateRef != template_id

	# Show a human-friendly error message
	msg := sprintf("deployment stage '%s' does not have the correct first parallel stepgroup template step '%s', has '%s'", [input.pipeline.stages[i].stage.name,template_id,input.pipeline.stages[i].stage.name])
}

# check if a parallel stepgroup has right template in deployment stage
deny[msg] {
	not input.pipeline.stages[i].stage.type == "Approval"
	input.pipeline.stages[i].stage.type == "Deployment"
  # With env type production ...
  # input.pipeline.stages[i].stage.spec.infrastructure.environment.type == "Production"
  has_key(input.pipeline.stages[i].stage.spec.execution.steps[0],"stepGroup")
  has_key(input.pipeline.stages[i].stage.spec.execution.steps[0].stepGroup.steps[0],"parallel")
  has_key_parallel_array(input.pipeline.stages[i].stage.spec.execution.steps[0].stepGroup.steps[0],"template")
  input.pipeline.stages[i].stage.spec.execution.steps[0].stepGroup.steps[0].parallel[_].step.template.templateRef != template_id

	# Show a human-friendly error message
	msg := sprintf("deployment stage '%s' does not have the correct parallel stepgroup template step '%s', has '%s'", [input.pipeline.stages[i].stage.name,template_id,input.pipeline.stages[i].stage.name])
}

# check if a parallel steps has any templates in deployment stage (prior check)
deny[msg] {
	not input.pipeline.stages[i].stage.type == "Approval"
	input.pipeline.stages[i].stage.type == "Deployment"
  has_key(input.pipeline.stages[i].stage.spec.execution.steps[0],"parallel")
  not has_key_parallel_array(input.pipeline.stages[i].stage.spec.execution.steps[0],"template")
	msg := sprintf("deployment stage '%s' does not have the correct first parallel template step '%s', has '%s'", [input.pipeline.stages[i].stage.name,template_id,input.pipeline.stages[i].stage.name])
}

# check if a parallel steps has correct template in deployment stage
deny[msg] {
	not input.pipeline.stages[i].stage.type == "Approval"
	input.pipeline.stages[i].stage.type == "Deployment"
  has_key(input.pipeline.stages[i].stage.spec.execution.steps[0],"parallel")
  has_key_parallel_array(input.pipeline.stages[i].stage.spec.execution.steps[0],"template")
  not parallel_contains_atleast_one(input.pipeline.stages[i].stage.spec.execution.steps[0].parallel,template_id)
	msg := sprintf("deployment stage '%s' does not have the correct parallel template step '%s', has '%s'", [input.pipeline.stages[i].stage.name,template_id,input.pipeline.stages[i].stage.spec.execution.steps[0].parallel[_].step.template.templateRef])
}

# helper function to determine if key exists
has_key(x, k) { _ = x[k] }
# helper function to determine if key exists within a parallel array
has_key_parallel_array(x, k) { _ = x.parallel[_].step[k] }

parallel_contains_atleast_one(parallelObj, template_id) {
  parallelObj[_].step.template.templateRef = template_id
}

