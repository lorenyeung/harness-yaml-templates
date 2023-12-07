package pipeline

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

#default exempt_orgs_projects = [{"org","project"},{"org2","project2"}]

######################### APPROVAL STAGE OPA #########################
# 1. Check if first step has ANY and CORRECT step templateRef in approval stage - complete
deny[msg] {
  # Check that a stage template approval is not being used...
  not contains_approval_stage_template(input.pipeline.stages,template_as_stage_id)
  # Only validate for 'approval' type stages
  input.pipeline.stages[i].stage.type == "Approval"
  # shorten input variable for entity that we are checking against (step in this rule)
  array = input.pipeline.stages[i].stage.spec.execution.steps[0].step
  # check that a template is being used, and then the correct template ref and version label is being used
  not correct_template_id_and_version(array,template_as_step_id,template_as_step_version)
  # generate and display error message as applicable
  used_template = get_used_template_id_and_version(array,"step template",template_as_step_id,template_as_step_version)
  msg := sprintf("1. Approval stage '%s' %s", [input.pipeline.stages[i].stage.name,used_template])
}

# 2. Check if first step group has ANY and CORRECT step templateRef in approval stage - complete
deny[msg] {
  not contains_approval_stage_template(input.pipeline.stages,template_as_stage_id)
  input.pipeline.stages[i].stage.type == "Approval"
  array = input.pipeline.stages[i].stage.spec.execution.steps[0]
  # Only validate against first 'stepgroup'
  has_key(array,"stepGroup")
  not correct_template_id_and_version(array.stepGroup.steps[0].step,template_as_step_id,template_as_step_version)
  used_template = get_used_template_id_and_version(array.stepGroup.steps[0].step,"step template in first step group",template_as_step_id,template_as_step_version)
  msg := sprintf("2. Approval stage '%s' %s", [input.pipeline.stages[i].stage.name,used_template])
}

# 3. Check if first stepgroup template has CORRECT stepgroup templateRef in approval stage - complete
deny[msg] {
  not contains_approval_stage_template(input.pipeline.stages,template_as_stage_id)
  input.pipeline.stages[i].stage.type == "Approval"
  array = input.pipeline.stages[i].stage.spec.execution.steps[0]
  has_key(array,"stepGroup")
  # require extra check for template key because not all stepgroups have to be a template in approval stage (see 2)
  has_key(array.stepGroup,"template")
  not correct_template_id_and_version(array.stepGroup,template_as_stepgroup_id,template_as_stepgroup_version)
  msg := sprintf("3. Approval stage '%s' has incorrect first stepgroup template '%s:%s', should be '%s:%s'", [input.pipeline.stages[i].stage.name,array.stepGroup.template.templateRef,array.stepGroup.template.versionLabel,template_as_stepgroup_id,template_as_stepgroup_version])
}

######################### DEPLOY STAGE OPA #########################
# 1. Check if first step has ANY, then CORRECT templateRef in deploy stage - complete
deny[msg] {
  # Check that there is no approval type stage
  not contains_stage_type(input.pipeline.stages,"Approval")
  input.pipeline.stages[i].stage.type == "Deployment"
  array = input.pipeline.stages[i].stage.spec.execution.steps[0].step
  not correct_template_id_and_version(array,template_ds_step_id,template_ds_step_version)
  used_template = get_used_template_id_and_version(array,"step template",template_ds_step_id,template_ds_step_version)
  msg := sprintf("1. Deploy stage '%s' %s", [input.pipeline.stages[i].stage.name,used_template])
}

# 2. Check if first parallel step has ANY and CORRECT templateRef in deploy stage - 
deny[msg] {
  not contains_stage_type(input.pipeline.stages,"Approval")
  input.pipeline.stages[i].stage.type == "Deployment"
  array = input.pipeline.stages[i].stage.spec.execution.steps[0]
  has_key(array,"parallel")
  not parallel_contains_atleast_one(array,template_ds_step_id,template_ds_step_version)
  used_template = get_used_template_id_and_version(array.parallel[_].step,"step template (atleast one) in first parallel step",template_ds_step_id,template_ds_step_version)
  msg := sprintf("2. Deploy stage '%s' %s", [input.pipeline.stages[i].stage.name,used_template])
}

# 3. Check if first stepgroup has ANY and CORRECT templateRef in deploy stage - complete
deny[msg] {
  not contains_stage_type(input.pipeline.stages,"Approval")
  input.pipeline.stages[i].stage.type == "Deployment"
  array = input.pipeline.stages[i].stage.spec.execution.steps[0]
  has_key(array,"stepGroup")
  not correct_template_id_and_version(array.stepGroup.steps[0].step,template_ds_step_id,template_ds_step_version)
  used_template = get_used_template_id_and_version(array.stepGroup.steps[0].step,"step template in first step group",template_ds_step_id,template_ds_step_version)
  msg := sprintf("3. Deploy stage '%s' %s", [input.pipeline.stages[i].stage.name,used_template])
}

# 4. Check if first parallel stepgroup has CORRECT templateRef in deploy stage - complete
deny[msg] {
  not contains_stage_type(input.pipeline.stages,"Approval")
  input.pipeline.stages[i].stage.type == "Deployment"
  array = input.pipeline.stages[i].stage.spec.execution.steps[0]
  has_key(array,"stepGroup")
  has_key(array.stepGroup.steps[0],"parallel")
  not parallel_contains_atleast_one(array.stepGroup.steps[0],template_ds_step_id,template_ds_step_version)
  used_template = get_used_template_id_and_version(array.stepGroup.steps[0].parallel[_].step,"step template in first parallel step group",template_ds_step_id,template_ds_step_version)
  msg := sprintf("4. Deploy stage '%s' %s", [input.pipeline.stages[i].stage.name,used_template])
}

# 5. Check if first stepgroup template has ANY and CORRECT templateRef in deploy stage - WIP
# 6. Check if parallel step of stepgroups has correct templateRef in deploy stage - WIP

######################### HELPER FUNCTIONS #########################
# determine if key exists
has_key(x, k) { _ = x[k] }

# determine if key exists within a parallel array
has_key_parallel_array(x, k) { _ = x.parallel[_].step[k] }

# determine parallel steps have template in any position
parallel_contains_atleast_one(parallelObj, correct_id,correct_version) {
  has_key_parallel_array(parallelObj,"template")
  parallelObj.parallel[i].step.template.templateRef = correct_id
  parallelObj.parallel[i].step.template.versionLabel = correct_version
}

# check if stage type exists in pipeline
contains_stage_type(arr, elem) {
	arr[_].stage.type = elem
}

# check correct template version
correct_template_id_and_version(check,correct_id,correct_version){
  has_key(check,"template")
  check.template.versionLabel = correct_version
  check.template.templateRef = correct_id
}

# return used template and version if exists
get_used_template_id_and_version(check,type,id,version) = output {
  has_key(check,"template")
  output := concat("",["has incorrect first ",type," '",check.template.templateRef,":",check.template.versionLabel,"', should be '",id,":",version,"'"])
}

# return if empty if no template is used
get_used_template_id_and_version(check,type,id,version) = output {
  not has_key(check,"template")
  output := concat("",["does not have template approval '", id,":",version,"' as first ",type])
}

# check approval stage template
contains_approval_stage_template(arr, template_id) {
	arr[_].stage.template.templateRef = template_id
  arr[_].stage.template.versionLabel = template_as_stage_version
}