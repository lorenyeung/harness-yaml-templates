package pipeline

import future.keywords.every
default template_exists = false

#deploy stage default template ids
default template_ds_step_id = "account.prod_approval"

#approval stage default template ids
default template_as_step_id = "account.approval_step_for_approval_stage"
default template_as_stepgroup_id = "account.approval_stepgroup"
default template_as_stage_id = "account.prod_approval_stage"

######################### APPROVAL STAGE OPA #########################
# 1a. Check if first step has ANY templateRef in approval stage - complete
deny[msg] {
  # if not using global stage template
  not contains_approval_stage_template(input.pipeline.stages,template_as_stage_id)
  # Find all stages that are Approvals ...
  input.pipeline.stages[i].stage.type == "Approval"
  # and does not have the template array - this means the step is not a template if it errors
  has_key(input.pipeline.stages[i].stage.spec.execution.steps[0].step,"template")
  # Show a human-friendly error message
  msg := sprintf("Approval stage '%s' does not have template approval '%s' as first step", [input.pipeline.stages[i].stage.name,template_as_step_id])
}

# 1b. Check if first step has CORRECT templateRef in approval stage - complete
deny[msg] {
  not contains_approval_stage_template(input.pipeline.stages,template_as_stage_id)
  input.pipeline.stages[i].stage.type == "Approval"
  has_key(input.pipeline.stages[i].stage.spec.execution.steps[0].step,"template")
  input.pipeline.stages[i].stage.spec.execution.steps[0].step.template.templateRef != template_as_step_id
  msg := sprintf("Approval stage '%s' has incorrect first step template '%s', should be '%s'", [input.pipeline.stages[i].stage.name,input.pipeline.stages[i].stage.spec.execution.steps[0].step.template.templateRef, template_as_step_id])
}

# 2a. Check if first stepgroup has ANY templateRef in deploy stage - complete
deny[msg] {
  not contains_approval_stage_template(input.pipeline.stages,template_as_stage_id)
  input.pipeline.stages[i].stage.type == "Approval"
  has_key(input.pipeline.stages[i].stage.spec.execution.steps[0],"stepGroup")
  not has_key(input.pipeline.stages[i].stage.spec.execution.steps[0].stepGroup.steps[0].step,"template")
  msg := sprintf("Approval stage '%s' does not have template approval '%s' in first stepgroup", [input.pipeline.stages[i].stage.name,template_as_step_id])
}

# 2b. Check if first stepgroup has CORRECT templateRef in deploy stage - complete
deny[msg] {
  not contains_approval_stage_template(input.pipeline.stages,template_as_stage_id)
  input.pipeline.stages[i].stage.type == "Approval"
  has_key(input.pipeline.stages[i].stage.spec.execution.steps[0],"stepGroup")
  # and is not using template approval stepgroup
  not has_key(input.pipeline.stages[i].stage.spec.execution.steps[0].stepGroup,"template")
  has_key(input.pipeline.stages[i].stage.spec.execution.steps[0].stepGroup.steps[0].step,"template")
  input.pipeline.stages[i].stage.spec.execution.steps[0].stepGroup.steps[0].step.template.templateRef != template_as_step_id
  msg := sprintf("Approval stage '%s' has incorrect first stepgroup template in first stepgroup step '%s', should be '%s'", [input.pipeline.stages[i].stage.name,input.pipeline.stages[i].stage.spec.execution.steps[0].stepGroup.steps[_].step.template.templateRef,template_as_step_id])
}

# 3a. OPTIONAL: Check if first stepgroup template has ANY templateRef in deploy stage - complete
# commented out as stepgroup may not have to be a template
#deny[msg] {
#  not contains_approval_stage_template(input.pipeline.stages,template_as_stage_id)
#  input.pipeline.stages[i].stage.type == "Approval"
#  has_key(input.pipeline.stages[i].stage.spec.execution.steps[0],"stepGroup")
#  not has_key(input.pipeline.stages[i].stage.spec.execution.steps[0].stepGroup,"template")
#  msg := sprintf("Approval stage '%s' does not have template approval '%s' in first stepgroup", [input.pipeline.stages[i].stage.name,template_as_stepgroup_id])
#}

# 3b. Check if first stepgroup template has CORRECT templateRef in deploy stage - complete
deny[msg] {
  not contains_approval_stage_template(input.pipeline.stages,template_as_stage_id)
  input.pipeline.stages[i].stage.type == "Approval"
  has_key(input.pipeline.stages[i].stage.spec.execution.steps[0],"stepGroup")
  has_key(input.pipeline.stages[i].stage.spec.execution.steps[0].stepGroup,"template")
  input.pipeline.stages[i].stage.spec.execution.steps[0].stepGroup.template.templateRef != template_as_stepgroup_id
  msg := sprintf("Approval stage '%s' has incorrect stepgroup template '%s', should be '%s'", [input.pipeline.stages[i].stage.name,input.pipeline.stages[i].stage.spec.execution.steps[0].stepGroup.steps[_].step.template.templateRef,template_as_stepgroup_id])
}

######################### DEPLOY STAGE OPA #########################
# Check if first step has ANY templateRef in deploy stage - complete
deny[msg] {
  # ignore if there exists an approval stage
  not contains_stage_type(input.pipeline.stages,"Approval")
  # Find all stages that are Deployments ...
  input.pipeline.stages[i].stage.type == "Deployment"
  not has_key(input.pipeline.stages[i].stage.spec.execution.steps[0].step,"template")
  msg := sprintf("Deploy stage '%s' does not have template approval '%s' as first step", [input.pipeline.stages[i].stage.name,template_ds_step_id])
}

# Check if first step has CORRECT templateRef in deploy stage - complete
deny[msg] {
  not contains_stage_type(input.pipeline.stages,"Approval")
  input.pipeline.stages[i].stage.type == "Deployment"
  has_key(input.pipeline.stages[i].stage.spec.execution.steps[0].step,"template")
  input.pipeline.stages[i].stage.spec.execution.steps[0].step.template.templateRef != template_ds_step_id
  msg := sprintf("Deploy stage '%s' has incorrect first step template '%s', should be '%s'", [input.pipeline.stages[i].stage.name,input.pipeline.stages[i].stage.spec.execution.steps[0].step.template.templateRef, template_ds_step_id])
}

# Check if first parallel step has ANY templateRef in deploy stage - complete
deny[msg] {
  not contains_stage_type(input.pipeline.stages,"Approval")
  input.pipeline.stages[i].stage.type == "Deployment"
  has_key(input.pipeline.stages[i].stage.spec.execution.steps[0],"parallel")
  not has_key_parallel_array(input.pipeline.stages[i].stage.spec.execution.steps[0],"template")
  msg := sprintf("Deploy stage '%s' does not have template approval '%s' in first parallel step", [input.pipeline.stages[i].stage.name,template_ds_step_id])
}

# Check if first parallel step has CORRECT templateRef in deploy stage - complete
deny[msg] {
  not contains_stage_type(input.pipeline.stages,"Approval")
  input.pipeline.stages[i].stage.type == "Deployment"
  has_key(input.pipeline.stages[i].stage.spec.execution.steps[0],"parallel")
  has_key_parallel_array(input.pipeline.stages[i].stage.spec.execution.steps[0],"template")
  not parallel_contains_atleast_one(input.pipeline.stages[i].stage.spec.execution.steps[0].parallel,template_ds_step_id)
  msg := sprintf("Deploy stage '%s' has incorrect step template '%s' in first parallel step, atleast one should be '%s'", [input.pipeline.stages[i].stage.name,input.pipeline.stages[i].stage.spec.execution.steps[0].parallel[_].step.template.templateRef,template_ds_step_id])
}

# Check if first stepgroup has ANY templateRef in deploy stage - complete
deny[msg] {
  not contains_stage_type(input.pipeline.stages,"Approval")
  input.pipeline.stages[i].stage.type == "Deployment"
  has_key(input.pipeline.stages[i].stage.spec.execution.steps[0],"stepGroup")
  not has_key(input.pipeline.stages[i].stage.spec.execution.steps[0].stepGroup.steps[0].step,"template")
  msg := sprintf("Deploy stage '%s' does not have template approval '%s' in first stepgroup", [input.pipeline.stages[i].stage.name,template_ds_step_id])
}

# Check if first stepgroup has CORRECT templateRef in deploy stage - complete
deny[msg] {
  not contains_stage_type(input.pipeline.stages,"Approval")
  input.pipeline.stages[i].stage.type == "Deployment"
  has_key(input.pipeline.stages[i].stage.spec.execution.steps[0],"stepGroup")
  has_key(input.pipeline.stages[i].stage.spec.execution.steps[0].stepGroup.steps[0].step,"template")
  input.pipeline.stages[i].stage.spec.execution.steps[0].stepGroup.steps[0].step.template.templateRef != template_ds_step_id
  msg := sprintf("Deploy stage '%s' has incorrect template in first stepgroup step '%s', should be '%s'", [input.pipeline.stages[i].stage.name,input.pipeline.stages[i].stage.spec.execution.steps[0].stepGroup.steps[_].step.template.templateRef,template_ds_step_id])
}

# Check if first parallel stepgroup has ANY templateRef in deploy stage - complete
deny[msg] {
  not contains_stage_type(input.pipeline.stages,"Approval")
  input.pipeline.stages[i].stage.type == "Deployment"
  has_key(input.pipeline.stages[i].stage.spec.execution.steps[0],"stepGroup")
  has_key(input.pipeline.stages[i].stage.spec.execution.steps[0].stepGroup.steps[0],"parallel")
  not has_key_parallel_array(input.pipeline.stages[i].stage.spec.execution.steps[0].stepGroup.steps[0],"template")
  msg := sprintf("Deploy stage '%s' does not have template approval '%s' in first parallel stepgroup", [input.pipeline.stages[i].stage.name,template_ds_step_id])
}

# Check if first parallel stepgroup has CORRECT templateRef in deploy stage - WIP
deny[msg] {
  not contains_stage_type(input.pipeline.stages,"Approval")
  input.pipeline.stages[i].stage.type == "Deployment"
  has_key(input.pipeline.stages[i].stage.spec.execution.steps[0],"stepGroup")
  has_key(input.pipeline.stages[i].stage.spec.execution.steps[0].stepGroup.steps[0],"parallel")
  has_key_parallel_array(input.pipeline.stages[i].stage.spec.execution.steps[0].stepGroup.steps[0],"template")
  input.pipeline.stages[i].stage.spec.execution.steps[0].stepGroup.steps[0].parallel[_].step.template.templateRef != template_ds_step_id
  msg := sprintf("Deploy stage '%s' has incorrect first parallel stepgroup template step '%s', atleast one should be '%s'", [input.pipeline.stages[i].stage.name,input.pipeline.stages[i].stage.spec.execution.steps[0].stepGroup.steps[0].parallel[_].step.template.templateRef,template_ds_step_id])
}

######################### HELPER FUNCTIONS #########################
# determine if key exists
has_key(x, k) { _ = x[k] }

# determine if key exists within a parallel array
has_key_parallel_array(x, k) { _ = x.parallel[_].step[k] }

# determine parallel steps have template in any position
parallel_contains_atleast_one(parallelObj, template_ds_step_id) {
  parallelObj[_].step.template.templateRef = template_ds_step_id
}

# check if stage type exists in pipeline
contains_stage_type(arr, elem) {
	arr[_].stage.type = elem
}

# check approval stage template
contains_approval_stage_template(arr, elem) {
	arr[_].stage.template.templateRef = elem
}

