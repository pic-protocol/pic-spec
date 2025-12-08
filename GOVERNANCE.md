# PIC Project Governance

This document describes the governance model for the PIC ecosystem, including
the PIC Model, the PIC Spec, and related PIC Protocol specifications.

## 1. Scope

This governance document applies to:

- The `pic-spec` repository and other Official PIC Spec repositories.
- Official PIC Protocol specification repositories, when created.
- Supporting repositories under the official PIC organization (e.g. reference
  implementations, tooling, examples), unless stated otherwise in those
  repositories.

It governs **how changes are proposed, reviewed, and merged**, but **does not
alter authorship, licensing, or normative semantics**, which are defined in the
PIC Spec and applicable LICENSE files.

---

## 2. Roles

### 2.1 PIC Spec Author

- **Nicola Gallo** is the original and continuing author of the
  Provenance Identity Continuity (PIC) Model and all foundational theoretical
  work on which the PIC Spec and PIC Protocol designs are based.
- This role is **conceptual and historical** and is **not** granted, revoked,
  or modified by repository permissions, organization ownership, maintainer
  status, or changes to this governance document.
- Nothing in this document or in any project process MAY reassign or dilute
  authorship of the PIC Model as defined in the PIC Spec (Appendix B).

---

### 2.2 PIC Spec Lead Editor

- **Nicola Gallo** currently serves as **Lead Editor** of the PIC Spec.
- The Lead Editor:
  - Curates and maintains the normative specification text.
  - Determines when a change is sufficiently mature for inclusion in an
    official draft or release.
  - Coordinates with contributors and reviewers.

The Lead Editor role may evolve over time (for example, by adding co-editors),
but any such change **does not affect authorship** of the PIC Model.

---

### 2.3 Maintainers (PIC Spec Contributors)

- *Maintainers* are contributors with write and merge access to one or more
  official PIC repositories.
- Maintainers:
  - Review and merge pull requests.
  - Triage issues and manage labels.
  - Help enforce the Code of Conduct.

Maintainer status is **operational**, not conceptual, and **does not imply
authorship** of the PIC Model.

A current list of maintainers SHOULD be kept in the repository (for example, in
this document or in `MAINTAINERS.md`) and updated via pull request.

---

## 3. Decision-Making

### 3.1 Technical Changes to the PIC Spec

- All technical changes MUST be proposed via pull request.
- Substantive changes SHOULD:
  - include motivation and rationale,
  - describe security, continuity, and compatibility implications,
  - note any impact on existing implementations or PIC Protocol designs.

The Lead Editor (or a delegated editor) has final authority on whether a proposed
change is consistent with the PIC Model and appropriate for inclusion in the
normative PIC Spec.

Consensus is preferred. In case of disagreement:

- The Lead Editor acts as tie-breaker on **spec semantics**.
- Unresolved disagreements MAY result in:
  - a separate profile or extension document, or
  - a clearly labeled experimental or non-normative section.

---

### 3.2 PIC Protocol Specifications

- PIC Protocol specifications define concrete protocol encodings,
  interoperability profiles, and wire formats that implement the PIC Model
  as defined by the PIC Spec.
- Editors for PIC Protocol specifications are appointed from the contributor
  or maintainer community.
- PIC Protocol editors:
  - MUST NOT alter the core PIC Model invariants.
  - MUST clearly document any protocol-specific constraints, assumptions,
    or deviations.

---

## 4. Forks and Derivative Specifications

- Anyone MAY fork the PIC repositories and create derivative works under the
  terms of the Creative Commons Attribution 4.0 International (CC BY 4.0)
  license.
- Forks MUST:
  - clearly state that they are derivative works,
  - not represent themselves as the canonical PIC Spec or PIC Model,
  - comply with the attribution requirements defined in the PIC Spec
    (particularly Appendix B).

Governance of forks is the responsibility of their respective maintainers.

---

## 5. Changes to Governance

- Changes to this `GOVERNANCE.md` document MUST be proposed via pull request.
- Maintainers are encouraged to participate in review and discussion.
- Governance changes MUST remain consistent with:
  - the authorship and attribution requirements in the PIC Spec (Appendix B),
  - and the applicable LICENSE terms (CC BY 4.0).

---

## 6. Relationship to Legal and Normative Documents

This governance document defines project process and operational roles only.
It **does not override or modify**:

- The Creative Commons Attribution 4.0 International (CC BY 4.0) license
  under which the PIC Spec is published.
- The normative semantics, authorship statements, and attribution requirements
  defined in the PIC Spec, in particular Appendix B.
- The normative text of any Official PIC Protocol specifications.

**In case of conflict, the applicable LICENSE files and the normative text of the
PIC Spec and any Official PIC Protocol specifications take precedence over this
governance document.**
