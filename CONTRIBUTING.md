# Contributing to the PIC Project

(PIC Model, PIC Spec, and PIC Protocol)

Thank you for your interest in contributing to the **Provenance Identity Continuity (PIC)** project.

The PIC project is structured across three distinct but related layers:

1. **PIC Model** — the formal theoretical model
2. **PIC Spec** — the normative specification of the model
3. **PIC Protocol** — concrete protocol encodings and interoperability profiles

This document explains **what can be contributed**, **how contributions are handled**, and **how authorship and attribution are preserved**.

---

## 1. Project Structure and Scope

### 1.1 PIC Model (Foundational Layer)

The **PIC Model** defines the core theoretical concepts, invariants, and impossibility results
(e.g., Provenance Identity Continuity, Proof of Continuity, CAT, PCA).

- The PIC Model is **original theoretical work** introduced by **Nicola Gallo**
- Authorship of the PIC Model is **historical and immutable**
- Contributions **do not** confer co-authorship of the PIC Model

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

The **PIC Spec** formalizes the PIC Model into a normative, RFC-style document.

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

**Authorship of the PIC Model is historical and independent of:**

- repository ownership
- organizational governance
- maintainer or editor status
- contribution volume
- protocol implementations

By contributing, you acknowledge that:

- **Nicola Gallo** is the original author of the PIC Model
- contributions apply only to text, examples, review, or protocol material
- contributions do NOT imply ownership of the model or its invariants

Contributors are credited for **their contributions**, not as authors of the PIC Model.

---

## 3. Canonical Status

- The **Official PIC Spec** repositories define the canonical normative reference
- Forks, mirrors, or derivative works MAY exist
- Forks MUST NOT present themselves as canonical unless explicitly designated

Submitting a pull request:

- does not grant editorial authority
- does not change canonicity
- does not alter attribution rules

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

Contributors MAY use automated language assistance tools (including large
language models, spell checkers, or grammar aids) **solely for the purpose of
improving clarity, structure, grammar, or phrasing** of their contributions.

Such tools are treated as **editorial assistants**, not as sources of ideas,
theory, or authorship.

Contributors MUST ensure that:

- all substantive ideas, technical arguments, designs, and interpretations
  originate from the contributor themselves;
- no contribution claims novelty, authorship, or conceptual invention
  attributable to an automated system;
- use of automated assistance does not obscure or alter the authorship of the
  PIC Model or its foundational concepts.

Use of automated tools **does not confer co-authorship**, contributor status,
or attribution to such tools, and **does not affect authorship claims** defined
by the PIC Spec.

In case of ambiguity, the human contributor submitting the pull request is
considered fully responsible for the content.

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
that conflict with the PIC Model or the project scope.

---

## 7. Behavioral Expectations

All participants must follow the
[Code of Conduct](CODE_OF_CONDUCT.md).

Good-faith technical disagreement is welcome.
Personal attacks, misrepresentation, or authorship disputes are not.

---

## 8. Contributor Recognition

Accepted contributors MAY be listed in the appropriate
**Contributors** section of the relevant document (Model, Spec, or Protocol).

Being listed as a contributor:

- does not imply authorship of the PIC Model
- does not imply editorial control
- does not supersede attribution rules

---

## 9. Questions and Discussion

If you are unsure where your contribution fits
(Model vs Spec vs Protocol),
open an issue before submitting a pull request.

Thank you for contributing to the PIC ecosystem.
