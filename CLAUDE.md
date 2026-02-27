# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

This is a reference/example repository for Harness CI/CD YAML templates and configurations. It demonstrates various technologies used with Harness including pipeline definitions, Dockerfiles, Kubernetes manifests, and CI package manager examples. It is not a single application — it is a collection of independent examples.

## Build Commands

There is no single build system for the whole repo. Each subdirectory has its own tooling:

- **Maven (Java)**: `cd ci/maven/codecov-travis-maven-junit5-example && mvn clean test` — runs JUnit 5 tests with Jacoco coverage
- **Gradle**: `cd ci/gradle/gradle-example-multi-repos` — uses Gradle with JFrog Artifactory plugin
- **npm/pnpm**: `cd ci/npm && pnpm install && pnpm start` — Express.js app using pnpm 8.15.4

## Architecture

### Harness Git Experience Structure (`.harness/`)

Entities are organized by scope, then entity type:
- Account level: `.harness/<entity-type>/`
- Org level: `.harness/orgs/<org.identifier>/<entity-type>/`
- Project level: `.harness/orgs/<org.identifier>/projects/<project.identifier>/<entity-type>/`

Supported entity types: pipelines, templates, inputsets, environments, featureflags.

### Harness Template Hierarchy

Templates follow a nesting pattern: Pipeline templates → Stage templates → StepGroup templates → Step templates. Runtime inputs use `<+input>` placeholder syntax. See `.harness/top/` for organized template examples with AWS/GCP variants.

### Key Directories

- **`.harness/`** — Harness platform entities (pipelines, templates, ~4500 inputsets used for testing)
- **`ci/`** — CI build examples per package manager (Maven, Gradle, npm/pnpm, GitHub Actions)
- **`docker/`** — 13 Dockerfile variants demonstrating patterns: multi-stage builds, build secrets, SSH mounts, cache optimization, private registries
- **`kubernetes/`** — Deployment manifests in three flavors:
  - `manifests/` — raw Kubernetes YAML (Deployments, Services, Jobs, CRDs)
  - `helm/` — Helm chart (alpine) with values templating
  - `kustomize/` — base + overlays for dev/prod environments
- **`googlecloudrun/`** — Cloud Run function manifest
- **`buildpushdeployhelmservice/`** — End-to-end build-push-deploy pattern with Helm

### CI Examples

The `ci/github-actions/` directory contains custom GitHub Actions:
- `stackrox-scan/` — Container security scanning action
- `gh-app-token-create/` — Python script for GitHub App token generation
