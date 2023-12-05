package pipeline

import future.keywords.every
default template_exists = false
default template_id = "account.prod_approval"

######################### APPROVAL STAGE OPA #########################
# Check if first step has ANY templateRef in approval stage - complete
deny[msg] {
  # Find all stages that are Approvals ...
  contains_stage_type(input.pipeline.stages,"Approval")
  # and does not have the template array - this means the step is not a template if it errors
  not has_key(input.pipeline.stages[i].stage.spec.execution.steps[0].step,"template")
  # Show a human-friendly error message
  msg := sprintf("Approval stage '%s' does not have template approval '%s' as first step", [input.pipeline.stages[i].stage.name,template_id])
}

# Check if first step has CORRECT templateRef in approval stage - complete
deny[msg] {
  contains_stage_type(input.pipeline.stages,"Approval")
  has_key(input.pipeline.stages[i].stage.spec.execution.steps[0].step.template,"templateRef")
  input.pipeline.stages[i].stage.spec.execution.steps[0].step.template.templateRef != template_id
  msg := sprintf("Approval stage '%s' has incorrect first step template '%s', should be '%s'", [input.pipeline.stages[i].stage.name,input.pipeline.stages[i].stage.spec.execution.steps[0].step.template.templateRef, template_id])
}

######################### DEPLOY STAGE OPA #########################
# Check if first step has ANY templateRef in deploy stage - complete
deny[msg] {
  # ignore if there exists an approval stage
  not contains_stage_type(input.pipeline.stages,"Approval")
  # Find all stages that are Deployments ...
  input.pipeline.stages[i].stage.type == "Deployment"
  not has_key(input.pipeline.stages[i].stage.spec.execution.steps[0].step,"template")
  msg := sprintf("Deploy stage '%s' does not have template approval '%s' as first step", [input.pipeline.stages[i].stage.name,template_id])
}

# Check if first step has CORRECT templateRef in deploy stage - complete
deny[msg] {
  not contains_stage_type(input.pipeline.stages,"Approval")
  input.pipeline.stages[i].stage.type == "Deployment"
  has_key(input.pipeline.stages[i].stage.spec.execution.steps[0].step,"template")
  input.pipeline.stages[i].stage.spec.execution.steps[0].step.template.templateRef != template_id
  msg := sprintf("Deploy stage '%s' has incorrect first step template '%s', should be '%s'", [input.pipeline.stages[i].stage.name,input.pipeline.stages[i].stage.spec.execution.steps[0].step.template.templateRef, template_id])
}

# Check if first parallel step has ANY templateRef in deploy stage - complete
deny[msg] {
  not contains_stage_type(input.pipeline.stages,"Approval")
  input.pipeline.stages[i].stage.type == "Deployment"
  has_key(input.pipeline.stages[i].stage.spec.execution.steps[0],"parallel")
  not has_key_parallel_array(input.pipeline.stages[i].stage.spec.execution.steps[0],"template")
  msg := sprintf("Deploy stage '%s' does not have template approval '%s' in first parallel step", [input.pipeline.stages[i].stage.name,template_id])
}

# Check if first parallel step has CORRECT templateRef in deploy stage - complete
deny[msg] {
  not contains_stage_type(input.pipeline.stages,"Approval")
  input.pipeline.stages[i].stage.type == "Deployment"
  has_key(input.pipeline.stages[i].stage.spec.execution.steps[0],"parallel")
  has_key_parallel_array(input.pipeline.stages[i].stage.spec.execution.steps[0],"template")
  not parallel_contains_atleast_one(input.pipeline.stages[i].stage.spec.execution.steps[0].parallel,template_id)
  msg := sprintf("Deploy stage '%s' has incorrect step template '%s' in first parallel step, atleast one should be '%s'", [input.pipeline.stages[i].stage.name,input.pipeline.stages[i].stage.spec.execution.steps[0].parallel[_].step.template.templateRef,template_id])
}

# Check if first stepgroup has ANY templateRef in deploy stage - complete
deny[msg] {
  not contains_stage_type(input.pipeline.stages,"Approval")
  input.pipeline.stages[i].stage.type == "Deployment"
  has_key(input.pipeline.stages[i].stage.spec.execution.steps[0],"stepGroup")
  not has_key(input.pipeline.stages[i].stage.spec.execution.steps[0].stepGroup.steps[0].step,"template")
  msg := sprintf("Deploy stage '%s' does not have template approval '%s' in first stepgroup", [input.pipeline.stages[i].stage.name,template_id])
}

# Check if first stepgroup has CORRECT templateRef in deploy stage - complete
deny[msg] {
  not contains_stage_type(input.pipeline.stages,"Approval")
  input.pipeline.stages[i].stage.type == "Deployment"
  has_key(input.pipeline.stages[i].stage.spec.execution.steps[0],"stepGroup")
  has_key(input.pipeline.stages[i].stage.spec.execution.steps[0].stepGroup.steps[0].step,"template")
  input.pipeline.stages[i].stage.spec.execution.steps[0].stepGroup.steps[0].step.template.templateRef != template_id
  msg := sprintf("Deploy stage '%s' has incorrect first stepgroup template step '%s', should be '%s'", [input.pipeline.stages[i].stage.name,input.pipeline.stages[i].stage.spec.execution.steps[0].stepGroup.steps[_].step.template.templateRef,template_id])
}

# Check if first parallel stepgroup has ANY templateRef in deploy stage - complete
deny[msg] {
  not contains_stage_type(input.pipeline.stages,"Approval")
  input.pipeline.stages[i].stage.type == "Deployment"
  has_key(input.pipeline.stages[i].stage.spec.execution.steps[0],"stepGroup")
  has_key(input.pipeline.stages[i].stage.spec.execution.steps[0].stepGroup.steps[0],"parallel")
  not has_key_parallel_array(input.pipeline.stages[i].stage.spec.execution.steps[0].stepGroup.steps[0],"template")
  msg := sprintf("Deploy stage '%s' does not have template approval '%s' in first parallel stepgroup", [input.pipeline.stages[i].stage.name,template_id])
}

# Check if first parallel stepgroup has CORRECT templateRef in deploy stage - WIP
deny[msg] {
  not contains_stage_type(input.pipeline.stages,"Approval")
  input.pipeline.stages[i].stage.type == "Deployment"
  has_key(input.pipeline.stages[i].stage.spec.execution.steps[0],"stepGroup")
  has_key(input.pipeline.stages[i].stage.spec.execution.steps[0].stepGroup.steps[0],"parallel")
  has_key_parallel_array(input.pipeline.stages[i].stage.spec.execution.steps[0].stepGroup.steps[0],"template")
  input.pipeline.stages[i].stage.spec.execution.steps[0].stepGroup.steps[0].parallel[_].step.template.templateRef != template_id
  msg := sprintf("Deploy stage '%s' has incorrect first parallel stepgroup template step '%s', atleast one should be '%s'", [input.pipeline.stages[i].stage.name,input.pipeline.stages[i].stage.spec.execution.steps[0].stepGroup.steps[0].parallel[_].step.template.templateRef,template_id])
}

######################### HELPER FUNCTIONS #########################
# determine if key exists
has_key(x, k) { _ = x[k] }

# determine if key exists within a parallel array
has_key_parallel_array(x, k) { _ = x.parallel[_].step[k] }

# determine parallel steps have template in any position
parallel_contains_atleast_one(parallelObj, template_id) {
  parallelObj[_].step.template.templateRef = template_id
}

#  check if stage type exists in pipeline
contains_stage_type(arr, elem) {
	arr[_].stage.type = elem
}

