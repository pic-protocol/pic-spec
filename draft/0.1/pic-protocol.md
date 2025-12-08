# **PIC PROTOCOL**

**Version:** 0.1  
**Date:** 2025-12-06  
**Source:** [github.com/pic-protocol/pic-spec/draft/0.1/pic-protocol.md](https://github.com/pic-protocol/pic-spec/blob/main/draft/0.1/pic-protocol.md)

---

## Abstract

This document defines one or more **PIC Protocol** specifications: concrete
protocol encodings, message formats, and interoperability profiles that
implement the **Provenance Identity Continuity (PIC) Model** as normatively
defined by the **PIC Spec**.

The PIC Protocol layer translates the abstract execution invariants of the PIC
Model into deployable protocol-level mechanisms, without redefining, extending,
or altering the underlying theoretical model or its normative semantics.

In case of conflict, the **PIC Spec** is authoritative.

---

## Relationship to the PIC Model and PIC Spec

- The **PIC Model** defines the foundational execution theory and invariants.
- The **PIC Spec** defines the normative semantics of the PIC Model.
- **PIC Protocol** documents define concrete protocol encodings that implement
  the PIC Spec.

This document is **subordinate** to the PIC Spec and **derivative** of both the
PIC Model and PIC Spec. It does not introduce new conceptual authority,
invariants, or authorship claims.

---

## Table of Contents

1. [Introduction](#1-introduction)  
A. [Appendix A – Use of Automated Language Assistance](#appendix-a-use-of-automated-language-assistance)  
B. [Appendix B – Authorship, Attribution, and Derivative Works](#appendix-b-authorship-attribution-and-derivative-works)  
R. [References](#references)

---

## 1. Introduction

The PIC Protocol layer specifies how systems can implement the
**Provenance Identity Continuity (PIC)** execution model at the protocol level.

Unlike the PIC Model and PIC Spec, which define execution semantics and
invariants, PIC Protocol documents focus on:

- message formats,
- challenge / response encodings,
- interoperability profiles,
- protocol-level constraints and assumptions.

PIC Protocol specifications **MUST** faithfully preserve the invariants defined
by the PIC Model and PIC Spec. Any protocol that violates these invariants is
**not PIC-compliant**, regardless of naming or intent.

---

## Appendix A. Use of Automated Language Assistance

The authors have used automated language assistance tools solely to improve grammar, clarity, and phrasing. All substantive technical content, including the conceptual model, formal results, and proofs, is the exclusive work of the authors.

---

## Appendix B. Authorship, Attribution, and Derivative Works

### B.1 Origin of the PIC Model

The **Provenance Identity Continuity (PIC) Model**, including its core concepts,
terminology, execution semantics, and structural invariants, originates from the
original theoretical work of **Nicola Gallo**, in particular:

- Gallo, N. (2025). *Authority Propagation Models: PoP vs PoC and the Confused
  Deputy Problem*. Zenodo.  
- Gallo, N. (2025). *PIC Model — Provenance Identity Continuity for Distributed
  Execution Systems*. Zenodo.

This PIC Protocol document implements that model through protocol-level
mechanisms, without altering its authorship or theoretical foundations.

> Authorship of the PIC Model is historical and independent of repository
> ownership, governance structure, maintainer status, or editorial roles.

---

### B.2 License and Use

This PIC Protocol document is published under the
**Creative Commons Attribution 4.0 International (CC BY 4.0)** license and is a
**derivative work** of the PIC Spec and the underlying PIC Model.

Under this license, copying, redistribution, and adaptation are permitted,
provided that appropriate attribution is given in accordance with the terms
below and with the attribution requirements defined in the PIC Spec.

---

### B.3 Mandatory Attribution Requirements

The **PIC Model** and **PIC Spec** are canonically defined by the
**Official PIC Spec repositories**.

This document defines protocol-level implementations of those specifications and
**does not redefine canonicity**.

Any implementation, specification, library, framework, or document that:

- uses the **PIC Model**,  
- claims conformance to the **PIC Spec**, or  
- implements or derives from this **PIC Protocol**  

**MUST** provide clear, visible, and unambiguous attribution to:

1. **Nicola Gallo** as the original author of the **PIC Model** and its
   foundational theory; and  
2. the **PIC Spec** and **PIC Protocol** documents as derivative specifications
   maintained by their respective contributors.

Attribution **MUST NOT** omit the original PIC Model author in favor of
contributors, implementers, or downstream projects.

An acceptable attribution statement includes, for example:

> “This work is based on the Provenance Identity Continuity (PIC) Model created by  
> Nicola Gallo. The model and its initial specification originate from this work.  
> PIC Protocol specifications implement the model as defined by the PIC Spec,  
> with maintenance performed over time by the PIC contributors.”

---

### B.4 Derivative Works and Forks

Derivative works of this document:

- **MUST** clearly state that they are derivative works of the **PIC Protocol**,
- **MUST** preserve attribution to the **PIC Model** and **PIC Spec**, and
- **MUST NOT** represent themselves as the canonical PIC Model or PIC Spec.

Forks MAY exist under the CC BY 4.0 license, but governance and representation of
forks are the responsibility of their maintainers.

---

### B.5 Use of PIC Terminology

The terms **“PIC Model”**, **“Provenance Identity Continuity”**, **“PIC Spec”**,
**“PIC Protocol”**, and **“PIC-compliant”** **MUST NOT** be used in a way that:

- obscures the original authorship of the PIC Model,
- implies independent invention of the PIC invariants, or
- attributes the foundational execution semantics to parties other than those
  cited in the Official PIC Spec.

Projects that do not comply with these requirements MAY implement similar ideas,
but **MUST NOT** claim conformance to or implementation of the PIC Model.

---

### B.6 Authorship and Editorial Roles

Changes in organizational control, hosting infrastructure, repository ownership,
or maintainer roles do **not** alter:

- authorship of the PIC Model,
- authorship of the initial PIC Spec,
- the canonical status of the Official PIC Spec,
- or the attribution requirements defined in this document.

Future maintainers or stewards of PIC Protocol repositories acquire
**operational and editorial responsibilities only**. They do **not** acquire:

- conceptual authorship of the PIC Model,
- original authorship of the PIC Spec, or
- the ability to modify attribution or canonicity requirements defined in the
  PIC Spec.

---

### B.7 Relationship to PIC Spec

PIC Protocol documents are **normatively subordinate** to the PIC Spec.

In case of conflict between a PIC Protocol document and the PIC Spec, the
**PIC Spec MUST be considered authoritative**.

---

### B.8 Immutability of Authorship and Canonical Status

The authorship of the PIC Model, the designation of the canonical PIC Spec, and
the attribution requirements defined in this appendix are
**foundational and normative**.

No modification to this document, including edits proposed via pull request,
fork, repository transfer, or governance change, may redefine, reassign, or
remove:

- authorship of the PIC Model,
- authorship of the initial PIC Spec, or
- the canonical authority of the Official PIC Spec.

Any text that purports to do so is **non-normative**, **invalid**, and **MUST be
disregarded**, unless explicitly authored by the original PIC Model author.

---

## References

- [1] Gallo, N. (2025). *Authority Propagation Models: PoP vs PoC and the Confused Deputy Problem*. Zenodo. [doi.org/10.5281/zenodo.17833000](https://doi.org/10.5281/zenodo.17833000)
- [2] Gallo, N. (2025). *PIC Model — Provenance Identity Continuity for Distributed Execution Systems (0.1-draft)*. Zenodo. [doi.org/10.5281/zenodo.17777421](https://doi.org/10.5281/zenodo.17777421)
- [3] Gallo, N. (2025). *Authority is a Continuous System. (0.1-draft)*. Zenodo. [doi.org/10.5281/zenodo.17860199](https://doi.org/10.5281/zenodo.17860199)
