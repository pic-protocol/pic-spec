# PIC Project Governance

This document defines project process and operational roles for the PIC Specification and related protocol documents. Licensing is defined by
`LICENSE`; attribution information is summarized in `NOTICE.md`; contribution terms are defined by `CONTRIBUTING.md`; and the dated research
record is maintained in the PIC Specification.

## Scope

This governance applies to the `pic-spec` repository and to related repositories explicitly placed under the same governance by the
Specification Steward. It governs how changes are proposed, reviewed, accepted, released, and identified as canonical. It does not change the
license or the historical research record.

## Roles

### Specification Steward

**Nitro Agility S.r.l.** is the current Specification Steward. The steward is responsible for:

- publication and maintenance of the PIC Specifications;
- appointment of document editors and repository maintainers;
- contribution review and acceptance;
- release management and designation of canonical versions; and
- coordination of future submission to an external standards process, if pursued.

Stewardship is an operational and editorial role. The scientific origin of the PIC Model is recorded separately in the PIC Specification.

### Document Editors

Editors maintain one or more specification documents, resolve editorial issues, coordinate technical review, and prepare release text.
Editors are listed in document metadata and remain responsible for responding to review of the versions they edit.

### Maintainers

Maintainers have repository permissions granted by the Specification Steward. They review changes, merge accepted pull requests, manage
issues, and enforce repository policy. Repository permissions do not independently confer editorial control over released specifications.

### Contributors

Contributors provide text, review, analysis, implementation reports, examples, or other project material under `CONTRIBUTING.md`. Significant
contributions should be credited in the affected document or repository history according to their concrete nature.

## Decision Process

Technical changes are proposed through issues and pull requests. Substantive changes should include motivation, security and privacy impact,
compatibility impact, implementation impact, and any effect on the mathematical model or conformance claims.

Consensus is preferred. When consensus cannot be reached, the Specification Steward decides whether a change enters the canonical project
release. Unresolved designs may remain experimental or be developed as separate profiles without altering the core invariants.

## Canonical Releases

A document becomes canonical only through a release explicitly designated by the Specification Steward. Branch contents, pull requests,
forks, mirrors, generated previews, and implementation experiments are not canonical releases by themselves.

Release records should identify the source revision, publication date, version, generated artifacts, and any immutable archive or DOI. These
records allow technical and conformance statements to identify the exact document reviewed.

## Forks and Adaptations

The repository license permits forks and adapted material subject to its terms. A fork or adaptation must not represent itself as an official
or canonical PIC release or imply endorsement. Governance of a fork belongs to its maintainers.

## External Standards Work

If a PIC document enters an external standards-development process, the Specification Steward and editors will apply that process's
contribution, disclosure, authorship, change-control, and publication rules. Repository contributors must have granted the rights described in
`CONTRIBUTING.md`; additional confirmation will be obtained where existing or third-party material requires it.

Transfer of document change control to an external process requires an explicit project decision and a recorded transition plan. Until such a
decision is published, the PIC documents remain independent public drafts governed by this repository.

## Changes to Governance

Changes to this document are proposed by pull request and approved by the Specification Steward. They must remain consistent with the
repository license, contribution terms, canonical release policy, and technical invariants of the PIC Specification.
