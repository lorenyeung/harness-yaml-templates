# Harness YAML Templates & Configurations

A collection of example YAML templates and configurations for [Harness](https://www.harness.io/) CI/CD pipelines. This repo demonstrates various technologies and deployment patterns including pipeline definitions, Dockerfiles, Kubernetes manifests, and CI build examples.

## Repository Structure

### `.harness/` — Harness Platform Entities

Pipeline definitions, templates, input sets, and infrastructure configurations organized using the [Harness Git Experience](https://developer.harness.io/docs/platform/git-experience/git-experience-overview/) folder structure:

```
.harness/
├── templates/          # Reusable pipeline, stage, and step group templates
├── inputsets/          # Runtime input sets for pipelines
├── steps/              # Step definitions
├── orgs/               # Org- and project-scoped entities
├── top/                # Template hierarchy examples (AWS/GCP variants)
└── *.yaml              # Account-level pipelines and infra definitions
```

Templates follow a nesting hierarchy: **Pipeline → Stage → StepGroup → Step**, with `<+input>` placeholders for runtime configuration.

### `ci/` — CI Build Examples

| Directory | Description |
|-----------|-------------|
| `maven/` | JUnit 5 project with Jacoco code coverage and Codecov integration |
| `gradle/` | Multi-repo example with JFrog Artifactory publishing |
| `npm/` | Express.js app using pnpm package manager |
| `npm-big/` | Large npm package example |
| `github-actions/` | Custom GitHub Actions (StackRox container scanning, GitHub App token creation) |

### `docker/` — Dockerfile Examples

13 Dockerfile variants demonstrating different patterns:

- Multi-stage builds (`Dockerfile.pnpm`, `Dockerfile.maven-private-multi-stage`)
- Private registry access (`Dockerfile.maven-private`)
- Build cache optimization (`Dockerfile.caching`)
- JFrog Artifactory integration (`Dockerfile.jfrog`)
- JUnit test containers (`Dockerfile.junit`)
- Java 8/17 builds (`Dockerfile.maven-java-8-17`)
- Library publishing (`Dockerfile.maven-library`)

### `kubernetes/` — Kubernetes Deployment Examples

Three deployment approaches:

- **`manifests/`** — Raw Kubernetes YAML (Deployments, Services, Jobs, CRDs, OpenShift Routes) for alpine, nginx, delegate, splunk, and other workloads
- **`helm/`** — Helm charts (alpine, nginx) with templated values
- **`kustomize/`** — Base configuration with dev/prod overlays

### `buildpushdeployhelmservice/` — End-to-End Example

Complete build, push, and deploy workflow using Docker and Helm.

### `googlecloudrun/` — Cloud Run

Google Cloud Function manifest (Python 3.11).

## Getting Started

Clone the repo and navigate to the relevant example directory:

```bash
git clone https://github.com/lorenyeung/harness-yaml-templates.git
cd harness-yaml-templates
```

### Running the Maven example

```bash
cd ci/maven/codecov-travis-maven-junit5-example
mvn clean test
```

### Running the npm/pnpm example

```bash
cd ci/npm
pnpm install
pnpm start
```

## License

MIT
