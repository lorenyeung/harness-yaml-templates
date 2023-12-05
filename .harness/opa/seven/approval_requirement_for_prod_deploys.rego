package pipeline

import future.keywords.every
default template_exists = false

#deploy stage default template ids
default template_ds_step_id = "account.prod_approval"
default template_ds_step_version = "v1"

#approval stage default template ids
default template_as_step_id = "account.approval_step_for_approval_stage"
default template_as_step_version = "v1"
default template_as_stepgroup_id = "account.approval_stepgroup"
default template_as_stepgroup_version = "v1"
default template_as_stage_id = "account.prod_approval_stage"
default template_as_stage_version = "v1"

default exempt_orgs_projects = [{"org","project"},{"org2","project2"}]

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
  msg := sprintf("Approval stage '%s' does not have template approval '%s:%s' as first step", [input.pipeline.stages[i].stage.name,template_as_step_id,template_as_step_version])
}

# 1b. Check if first step has CORRECT templateRef in approval stage - complete
deny[msg] {
  not contains_approval_stage_template(input.pipeline.stages,template_as_stage_id)
  input.pipeline.stages[i].stage.type == "Approval"
  array = input.pipeline.stages[i].stage.spec.execution.steps[0].step
  has_key(array,"template")
  not correct_template_id_and_version(array.template,template_as_step_id,template_as_step_version)
  msg := sprintf("Approval stage '%s' has incorrect first step template '%s:%s', should be '%s:%s'", [input.pipeline.stages[i].stage.name,array.template.templateRef,array.template.versionLabel, template_as_step_id,template_as_step_version])
}

# 2a. Check if first stepgroup has ANY templateRef in approval stage - complete
deny[msg] {
  not contains_approval_stage_template(input.pipeline.stages,template_as_stage_id)
  input.pipeline.stages[i].stage.type == "Approval"
  has_key(input.pipeline.stages[i].stage.spec.execution.steps[0],"stepGroup")
  not has_key(input.pipeline.stages[i].stage.spec.execution.steps[0].stepGroup.steps[0].step,"template")
  msg := sprintf("Approval stage '%s' does not have template approval step '%s:%s' in first stepgroup", [input.pipeline.stages[i].stage.name,template_as_step_id,template_as_step_version])
}

# 2b. Check if first stepgroup has CORRECT templateRef in approval stage - complete
deny[msg] {
  not contains_approval_stage_template(input.pipeline.stages,template_as_stage_id)
  input.pipeline.stages[i].stage.type == "Approval"
  array = input.pipeline.stages[i].stage.spec.execution.steps[0]
  has_key(array,"stepGroup")
  # and is not using template approval stepgroup
  not has_key(array.stepGroup,"template")
  has_key(array.stepGroup.steps[0].step,"template")
  not correct_template_id_and_version(array.stepGroup.steps[0].step.template,template_as_step_id,template_as_step_version)
  msg := sprintf("Approval stage '%s' has incorrect first step template in first stepgroup '%s:%s', should be '%s:%s'", [input.pipeline.stages[i].stage.name,array.stepGroup.steps[_].step.template.templateRef,array.stepGroup.steps[_].step.template.versionLabel,template_as_step_id,template_as_step_version])
}

# 3a. OPTIONAL: Check if first stepgroup template has ANY templateRef in approval stage - complete
# commented out as stepgroup may not have to be a template
#deny[msg] {
#  not contains_approval_stage_template(input.pipeline.stages,template_as_stage_id)
#  input.pipeline.stages[i].stage.type == "Approval"
#  has_key(input.pipeline.stages[i].stage.spec.execution.steps[0],"stepGroup")
#  not has_key(input.pipeline.stages[i].stage.spec.execution.steps[0].stepGroup,"template")
#  msg := sprintf("Approval stage '%s' does not have template approval '%s:%s' in first stepgroup template", [input.pipeline.stages[i].stage.name,template_as_stepgroup_id,template_as_stepgroup_version])
#}

# 3b. Check if first stepgroup template has CORRECT templateRef in approval stage - complete
deny[msg] {
  not contains_approval_stage_template(input.pipeline.stages,template_as_stage_id)
  input.pipeline.stages[i].stage.type == "Approval"
  array = input.pipeline.stages[i].stage.spec.execution.steps[0]
  has_key(array,"stepGroup")
  has_key(array.stepGroup,"template")
  not correct_template_id_and_version(array.stepGroup.template,template_as_stepgroup_id,template_as_stepgroup_version)
  msg := sprintf("Approval stage '%s' has incorrect stepgroup template '%s:%s', should be '%s:%s'", [input.pipeline.stages[i].stage.name,array.stepGroup.template.templateRef,array.stepGroup.template.versionLabel,template_as_stepgroup_id,template_as_stepgroup_version])
}

######################### DEPLOY STAGE OPA #########################
# 1a. Check if first step has ANY templateRef in deploy stage - complete
deny[msg] {
  # ignore if there exists an approval stage
  not contains_stage_type(input.pipeline.stages,"Approval")
  # Find all stages that are Deployments ...
  input.pipeline.stages[i].stage.type == "Deployment"
  not has_key(input.pipeline.stages[i].stage.spec.execution.steps[0].step,"template")
  msg := sprintf("Deploy stage '%s' does not have template approval '%s:%s' as first step", [input.pipeline.stages[i].stage.name,template_ds_step_id,template_ds_step_version])
}

# 1b. Check if first step has CORRECT templateRef in deploy stage - complete
deny[msg] {
  not contains_stage_type(input.pipeline.stages,"Approval")
  input.pipeline.stages[i].stage.type == "Deployment"
  array = input.pipeline.stages[i].stage.spec.execution.steps[0].step
  has_key(array,"template")
  not correct_template_id_and_version(array.template,template_ds_step_id,template_ds_step_version)
  msg := sprintf("Deploy stage '%s' has incorrect first step template '%s:%s', should be '%s:%s'", [input.pipeline.stages[i].stage.name,array.template.templateRef,array.template.versionLabel, template_ds_step_id,template_ds_step_version])
}

# 2a. Check if first parallel step has ANY templateRef in deploy stage - complete
deny[msg] {
  not contains_stage_type(input.pipeline.stages,"Approval")
  input.pipeline.stages[i].stage.type == "Deployment"
  has_key(input.pipeline.stages[i].stage.spec.execution.steps[0],"parallel")
  not has_key_parallel_array(input.pipeline.stages[i].stage.spec.execution.steps[0],"template")
  msg := sprintf("Deploy stage '%s' does not have template approval '%s:%s' in first parallel step", [input.pipeline.stages[i].stage.name,template_ds_step_id,template_ds_step_version])
}

# 2b. Check if first parallel step has CORRECT templateRef in deploy stage - complete
deny[msg] {
  not contains_stage_type(input.pipeline.stages,"Approval")
  input.pipeline.stages[i].stage.type == "Deployment"
  array = input.pipeline.stages[i].stage.spec.execution.steps[0]
  has_key(array,"parallel")
  has_key_parallel_array(array,"template")
  not parallel_contains_atleast_one(array.parallel,template_ds_step_id,template_ds_step_version)
  msg := sprintf("Deploy stage '%s' has incorrect step template '%s:%s' in first parallel step, atleast one should be '%s:%s'", [input.pipeline.stages[i].stage.name,array.parallel[_].step.template.templateRef,array.parallel[_].step.template.versionLabel,template_ds_step_id,template_ds_step_version])
}

# 3a. Check if first stepgroup has ANY templateRef in deploy stage - complete
deny[msg] {
  not contains_stage_type(input.pipeline.stages,"Approval")
  input.pipeline.stages[i].stage.type == "Deployment"
  array = input.pipeline.stages[i].stage.spec.execution.steps[0]
  has_key(array,"stepGroup")
  not has_key(array.stepGroup.steps[0].step,"template")
  msg := sprintf("Deploy stage '%s' does not have template approval '%s:%s' in first stepgroup", [input.pipeline.stages[i].stage.name,template_ds_step_id])
}

# 3b. Check if first stepgroup has CORRECT templateRef in deploy stage - complete
deny[msg] {
  not contains_stage_type(input.pipeline.stages,"Approval")
  input.pipeline.stages[i].stage.type == "Deployment"
  array = input.pipeline.stages[i].stage.spec.execution.steps[0]
  has_key(array,"stepGroup")
  has_key(array.stepGroup.steps[0].step,"template")
  not correct_template_id_and_version(array.stepGroup.steps[0].step.template,template_ds_step_id,template_ds_step_version)
  msg := sprintf("Deploy stage '%s' has incorrect step template in first stepgroup '%s:%s', should be '%s:%s'", [input.pipeline.stages[i].stage.name,array.stepGroup.steps[_].step.template.templateRef,array.stepGroup.steps[_].step.template.versionLabel,template_ds_step_id,template_ds_step_version])
}

# 4a. Check if first parallel stepgroup has ANY templateRef in deploy stage - complete
deny[msg] {
  not contains_stage_type(input.pipeline.stages,"Approval")
  input.pipeline.stages[i].stage.type == "Deployment"
  has_key(input.pipeline.stages[i].stage.spec.execution.steps[0],"stepGroup")
  has_key(input.pipeline.stages[i].stage.spec.execution.steps[0].stepGroup.steps[0],"parallel")
  not has_key_parallel_array(input.pipeline.stages[i].stage.spec.execution.steps[0].stepGroup.steps[0],"template")
  msg := sprintf("Deploy stage '%s' does not have template approval '%s:%s' in first parallel stepgroup", [input.pipeline.stages[i].stage.name,template_ds_step_id])
}

# 4b. Check if first parallel stepgroup has CORRECT templateRef in deploy stage - complete
deny[msg] {
  not contains_stage_type(input.pipeline.stages,"Approval")
  input.pipeline.stages[i].stage.type == "Deployment"
  array = input.pipeline.stages[i].stage.spec.execution.steps[0]
  has_key(array,"stepGroup")
  has_key(array.stepGroup.steps[0],"parallel")
  has_key_parallel_array(array.stepGroup.steps[0],"template")
  not parallel_contains_atleast_one(array.stepGroup.steps[0].parallel,template_ds_step_id,template_ds_step_version)
  msg := sprintf("Deploy stage '%s' has incorrect first parallel stepgroup template step '%s:%s', atleast one should be '%s:%s'", [input.pipeline.stages[i].stage.name,array.stepGroup.steps[0].parallel[_].step.template.templateRef,array.stepGroup.steps[0].parallel[_].step.template.versionLabel,template_ds_step_id,template_ds_step_version])
}

# 5a. Check if first stepgroup template has ANY templateRef in deploy stage - WIP
# 5b. Check if first stepgroup template has correct templateRef in deploy stage - WIP

######################### HELPER FUNCTIONS #########################
# determine if key exists
has_key(x, k) { _ = x[k] }

# determine if key exists within a parallel array
has_key_parallel_array(x, k) { _ = x.parallel[_].step[k] }

# determine parallel steps have template in any position
parallel_contains_atleast_one(parallelObj, correct_id,correct_version) {
  parallelObj[_].step.template.templateRef = correct_id
  parallelObj[_].step.template.versionLabel = correct_version
}

# check if stage type exists in pipeline
contains_stage_type(arr, elem) {
	arr[_].stage.type = elem
}

# check correct template version
correct_template_id_and_version(check,correct_id,correct_version) {
  check.versionLabel = correct_version
  check.templateRef = correct_id
}

# check approval stage template
contains_approval_stage_template(arr, template_id) {
	arr[_].stage.template.templateRef = template_id
  arr[_].stage.template.versionLabel = template_as_stage_version
}

