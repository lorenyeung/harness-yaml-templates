# Git Experience
## Folder Structure
Everything is organised by scope, followed by entity type. So for example, if an OPA policy is configured at the account level, it will exist at:
```
.harness/policies/policy.rego
```
likewise, org level:
```
.harness/orgs/<+org.identifier>/policies/policy.rego
```
likewise, project level:
```
.harness/orgs/<+org.identifier>/projects/<+project.identifier>/policies/policy.rego
```
## Entities
Entities supported today:
* environments
* inputsets
* featureflags
* pipelines
* templates
