# Contributing to the PIC Project

(PIC Model, PIC Spec, and PIC Protocol)

Thank you for your interest in contributing to the **Provenance Identity Continuity (PIC)** project.

The PIC project is structured across three distinct but related layers:

1. **PIC Model** — the formal theoretical model  
2. **PIC Spec** — the normative specification of the model  
3. **PIC Protocol** — concrete protocol encodings and interoperability profiles

This document explains **what can be contributed**, **how contributions are handled**, and **how authorship, attribution, and responsibility boundaries are preserved**.

---

## 1. Project Structure and Scope

### 1.1 PIC Model (Foundational Layer)

The **PIC Model** defines the core theoretical concepts, invariants, and impossibility results
(e.g., Provenance Identity Continuity, Proof of Continuity, CAT, PCA).

- The PIC Model is **original theoretical work** introduced by **Nicola Gallo**
- Authorship of the PIC Model is **historical, personal, and immutable**
- Contributions **do not** confer co-authorship of the PIC Model
- Nothing in this repository or contribution process transfers, licenses, or assigns
  any ownership or authorship of the PIC Model

Contributions MAY include:

- formal critique or validation
- clarifying explanations
- examples illustrating the model
- discussion of implications or limitations

Contributions MUST NOT:

- reassign authorship
- claim independent invention of the PIC Model
- redefine core invariants without explicit acknowledgment

---

### 1.2 PIC Spec (Normative Specification)

The **PIC Spec** formalizes the PIC Model into a normative, RFC-style document and is
**published, maintained, and stewarded by Nitro Agility S.r.l.**

Contributors MAY submit:

- editorial improvements
- clearer definitions or examples
- security analysis
- detection of ambiguities
- alignment fixes across sections
- non-normative appendices

Contributors MUST NOT:

- remove or obscure attribution
- alter the canonical status of the PIC Spec
- redefine the PIC Model indirectly
- reintroduce PoP-, token-, or credential-based authority models

Substantive semantic changes MUST be discussed via issues prior to submission.

---

### 1.3 PIC Protocol (Implementation Layer)

The **PIC Protocol** layer defines concrete encodings, message formats, and interoperability rules that implement the PIC Model.

Contributors MAY submit:

- protocol designs
- message schemas
- wire-format proposals
- reference flows or examples
- interoperability considerations

Contributors MUST:

- preserve PIC Model invariants
- clearly identify protocol-level assumptions
- document deviations, extensions, or profiles

Protocol work **DOES NOT alter** authorship of the PIC Model or the PIC Spec.

---

## 2. Authorship vs Contribution (Critical)

**Authorship of the PIC Model is personal, historical, and legally independent of:**

- repository ownership
- organizational governance
- maintainer or editor status
- contribution volume
- protocol implementations

By contributing, you explicitly acknowledge that:

- **Nicola Gallo** is the original and sole author of the PIC Model
- your contributions apply only to text, examples, reviews, or protocol material
- your contributions do **not** imply ownership, co-authorship, endorsement, warranty,
  or operational responsibility for the PIC Model

Contributors are credited for **their contributions only**, not as authors of the PIC Model.

---

## 3. Canonical Status

- The **Official PIC Spec** repositories define the canonical normative reference
- Forks, mirrors, or derivative works MAY exist
- Forks MUST NOT present themselves as canonical unless explicitly designated

Submitting a pull request:

- does not grant editorial authority
- does not change canonicity
- does not alter attribution rules
- does not create any legal, operational, or professional obligation for the
  PIC Model author

---

## 4. Licensing of Contributions

Unless stated otherwise, PIC repositories are licensed under **CC BY 4.0**.

By submitting a contribution, you agree that:

- your contribution is licensed under CC BY 4.0
- attribution requirements are preserved
- your contribution may be edited, reorganized, or declined
- attribution to the PIC Model author is mandatory and non-removable

You retain copyright to your contribution text,
subject to the repository license.

---

## 5. Use of Automated Language Assistance (LLMs)

Contributors MAY use automated language assistance tools solely for improving clarity,
structure, grammar, or phrasing.

Such tools are treated as **editorial assistants**, not sources of theory, authorship,
or legal responsibility.

The human contributor remains fully responsible for submitted content.

---

## 6. Contribution Process

1. Fork the repository  
2. Create a feature branch  
3. Make changes with clear, scoped commits  
4. Open a Pull Request  
5. Describe:
   - what the change addresses
   - whether it is editorial, semantic, or protocol-level
   - any impact on PIC invariants

Maintainers may request clarification, revision, or decline changes
that conflict with the PIC Model or project scope.

---

## 7. Behavioral Expectations

All participants must follow the
[Code of Conduct](CODE_OF_CONDUCT.md).

Good-faith technical disagreement is welcome.
Personal attacks, misrepresentation, authorship disputes, or attempts to
reassign responsibility are not.

---

## 8. Contributor Recognition & Governance Context

All contributions to this repository are governed by **Nitro Agility S.r.l.**  
and are incorporated under its stewardship.

Contributions made by employees, associates, contractors, or co-founders of
Nitro Agility S.r.l. — **regardless of the account (e.g., GitHub), platform, 
signing keys, or method used** — are made **on behalf of Nitro Agility S.r.l.** 
unless explicitly stated otherwise.

No contribution creates any personal legal, operational, or professional
obligation for the PIC Model author.

---

## 9. Questions and Discussion

If you are unsure where your contribution fits
(Model vs Spec vs Protocol),
open an issue before submitting a pull request.

Thank you for contributing to the PIC ecosystem.
