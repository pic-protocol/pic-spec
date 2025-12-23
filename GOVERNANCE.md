# PIC Project Governance

This document describes the governance model for the PIC ecosystem, including
the PIC Spec and related PIC Protocol specifications.

It defines **project process and operational roles only** and is fully aligned
with the authorship, attribution, ownership, and legal framework defined in the
PIC Specification (see Appendix B of the PIC Spec).

Nothing in this document creates, transfers, limits, or modifies any authorship,
ownership, or intellectual property rights in the PIC Model.

---

## 1. Scope

This governance document applies to:

- The `pic-spec` repository and other Official PIC Spec repositories.
- Official PIC Protocol specification repositories, when created.
- Supporting repositories under the official PIC organization
  (e.g., reference implementations, tooling, examples), unless stated otherwise
  in those repositories.

It governs **how changes are proposed, reviewed, and merged**, but **does not**
alter authorship, licensing, ownership, intellectual property, or normative
semantics, which are defined exclusively by the PIC Spec and applicable
LICENSE files.

---

## 2. Roles

### 2.1 Specification Steward

**Nitro Agility S.r.l.** is the **Specification Steward** of the PIC project.

The Specification Steward is responsible for:

- publication and maintenance of the PIC Specification,
- editorial decisions and normative text,
- contribution review and acceptance,
- release management and designation of canonical versions,
- specification governance and project process.

All operational authority for the PIC Spec and related repositories
resides with the Specification Steward.

Nothing in this role implies or affects authorship of the PIC Model, which
remains solely with its original author as defined in the PIC Spec.

---

### 2.2 Maintainers (PIC Spec Contributors)

*Maintainers* are contributors granted write and merge access to one or more
official PIC repositories by the Specification Steward.

Maintainers:

- review and merge pull requests,
- triage issues and manage labels,
- help enforce the Code of Conduct,
- support contributors and the review process.

Maintainer status is **operational only** and **does not imply**:

- authorship or co-authorship of the PIC Model,
- editorial ownership of the PIC Spec,
- control over canonical designation,
- any legal, professional, or operational responsibility for the PIC Model.

A current list of maintainers SHOULD be kept in the repository
(e.g., in this document or in `MAINTAINERS.md`) and updated via pull request.

---

## 3. Decision-Making

### 3.1 Technical Changes to the PIC Spec

All technical changes MUST be proposed via pull request.

Substantive changes SHOULD:

- include motivation and rationale,
- describe security, continuity, and compatibility implications,
- note any impact on existing implementations or PIC Protocol designs.

Final inclusion of changes into the normative PIC Specification is decided by
the Specification Steward.

Consensus is preferred.  
When consensus cannot be reached, the Specification Steward has final authority
on **specification semantics and inclusion**.

No governance process, maintainer action, or repository permission can modify
the authorship, ownership, or theoretical foundations of the PIC Model.

Unresolved disagreements MAY result in:

- a separate profile or extension document, or
- a clearly labeled experimental or non-normative section.

---

### 3.2 PIC Protocol Specifications

PIC Protocol specifications define concrete protocol encodings,
interoperability profiles, and wire formats that implement the PIC Model
as defined by the PIC Spec.

Editors for PIC Protocol specifications are appointed by the Specification
Steward from the contributor or maintainer community.

PIC Protocol editors:

- MUST preserve the core PIC Model invariants,
- MUST clearly document any protocol-specific constraints, assumptions,
  or deviations.

PIC Protocol work does **not** modify the PIC Model and does **not**
create any new authorship of the PIC Model.

---

## 4. Forks and Derivative Specifications

Anyone MAY fork the PIC repositories and create derivative works under the
terms of the Creative Commons Attribution 4.0 International (CC BY 4.0)
license.

Forks MUST:

- clearly state that they are derivative works,
- not represent themselves as the canonical PIC Spec or PIC Model,
- comply with the attribution requirements defined in the PIC Spec
  (particularly Appendix B).

Governance of forks is the responsibility of their respective maintainers.

Forking or contributing does not transfer any ownership, authorship, or
responsibility for the PIC Model.

---

## 5. Changes to Governance

Changes to this `GOVERNANCE.md` document MUST be proposed via pull request.

All governance changes MUST remain consistent with:

- the authorship and attribution requirements in the PIC Spec (Appendix B),
- the ownership and legal framework defined in the PIC Spec,
- and the applicable LICENSE terms (CC BY 4.0).

No governance change may ov
