# OPA Policy

This OPA policy enforces checks on Harness pipelines where-ever the policy is set - i.e. if deployed at the account level, it will govern all pipelines accross orgs/projects.

## Approval stages
Rules trigger if there exists an approval stage, but exits if there is a global approval stage template in the pipeline.

Checks for the following conditions:
Every entity being checked will be against the first one in the stage:
* first step
* first stepgroup
* first stepgroup template

ensuring that the approval exists in the approval stage. Each entity will first do a check for existence of a template, followed by checking if it is the correct 'allowed' template (defined in the variables up top). This double rule for each type is done due to rego not returning the correct true/false condition if the 'template' key does not exist.


## Deploy stages
Rules trigger if there does not exist any approval stage in the pipeline.

Checks for the following conditions:
To reduce chances of ordering mishaps, every entity being checked will be against the first one in the stage:
* first step
* first stepgroup
* first parallel step
* first stepgroup with parallel steps

ensuring that the approval exists before the deploy step. Each entity will first do a check for existence of a template, followed by checking if it is the correct 'allowed' template (defined in the variables up top). This double rule for each type is done due to rego not returning the correct true/false condition if the 'template' key does not exist.

The step template for deploy stages will ideally be created with a conditional execution in mind, where the type is set to 'prod', for example:

```
template:
  name: prod_approval
  type: Step
  spec:
    type: HarnessApproval
    spec:
      approvalMessage: Please review the following information and approve the pipeline progression
      includePipelineExecutionHistory: true
      isAutoRejectEnabled: false
      approvers:
        userGroups: <+input>
        minimumCount: 1
        disallowPipelineExecutor: false
      approverInputs: []
    timeout: 1d
    when:
      stageStatus: Success
      condition: <+env.type> == "Production"
  identifier: prod_approval
  versionLabel: v1
```
