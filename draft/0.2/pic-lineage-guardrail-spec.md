# PIC Lineage Guardrail Specification

**Version:** 0.2 (Draft)  
**Status**: Draft – Not a Standard  
**Date:** 2026-07-19  
**Source:** [github.com/pic-protocol/pic-spec/draft/0.2/pic-lineage-guardrail-spec.md](https://github.com/pic-protocol/pic-spec/blob/main/draft/0.2/pic-lineage-guardrail-spec.md)  
**Editors:**

- **Nicola Gallo** (Nitro Agility S.r.l.) Lead Editor
- *Add your name via pull request (individual or organization) — listing is subject to editor approval (see [Section 7](#7-contributors)).*

**Contributors:**

- *Add your name via pull request (individual or organization) — listing is subject to editor approval (see [Section 7](#7-contributors)).*

## Abstract

This document is the **PIC Lineage Guardrail Specification**, a subordinate specification of the [PIC Specification](./pic-spec.md).

In the PIC Model a **lineage is an atomic execution**: one causal chain from an origin, along which authority only attenuates and stays bound
to that origin. Proof of Continuity governs a lineage *from the inside* and forbids **authority mixing** — authority from one lineage can
never be merged into another. That prohibition is what makes the confused-deputy class of failures unrepresentable.

Real applications, however, are rarely a single atomic lineage. An application-level execution is often **composed of several atomic
lineages** that must *participate together* to carry out one logical operation, each contributing its part under its own origin authority.
This **cross-lineage composition** is legitimate, and it is *participation, not authority mixing*: no authority is merged, and each lineage
keeps its own. The PIC Model, by design, does not govern it: continuity secures each lineage individually and says nothing about how they
combine.

A **lineage guardrail** is the construct that **governs cross-lineage composition**: the declarative rules under which multiple atomic
lineages may join and participate in a single application execution, and the bounds that composition must respect. With a guardrail,
cross-lineage composition becomes *governed* — which lineages may compose, under what conditions, and what the composed execution may do —
while each participating lineage keeps its own continuity and non-expansion, and authority mixing stays forbidden.

This revision establishes the concept and the standard requirements notation shared by the PIC specification set. The normative guardrail
construction — how a composed execution is declared, how atomic lineages join it, and how the bound is enforced — is developed in the
sections below. Guardrails build on the PCA format of the [PIC Prover and Verifier Specification](./pic-prover-verifier-spec.md) and are
consistent with the [PIC Revocation Specification](./pic-revocation-spec.md); they do not alter non-expansion of the signed state, Proof of
Relationship, or the rule that every PCA continues exactly one predecessor. In case of conflict, the **PIC Specification** is authoritative.

## Table of Contents

- [PIC Lineage Guardrail Specification](#pic-lineage-guardrail-specification)
  - [Abstract](#abstract)
  - [Table of Contents](#table-of-contents)
  - [1. Introduction](#1-introduction)
    - [1.1 Atomic Lineages and Composed Executions](#11-atomic-lineages-and-composed-executions)
    - [1.2 Requirements Notation](#12-requirements-notation)
  - [7. Contributors](#7-contributors)
  - [8. Legal Notices](#8-legal-notices)
  - [References](#references)

## 1. Introduction

This section is non-normative. It explains the concept the rest of the specification builds on.

### 1.1 Atomic Lineages and Composed Executions

In PIC, a **lineage is an atomic execution**: a single causal chain that begins at an origin (PCA0) and proceeds hop by hop, carrying an
authority context that only ever attenuates and remains bound to that origin. Proof of Continuity governs a lineage from the inside — each
hop is a valid, non-expansive continuation of the one that caused it — and it forbids **authority mixing**: authority from one lineage can
never be merged into another. That prohibition is what makes the confused-deputy class of failures unrepresentable.

Applications are rarely one atomic lineage. A single application-level operation is often **composed of several atomic lineages** that must
participate together: each is caused by its own origin, carries its own attenuated authority, and contributes one part of the whole — for
example a transaction whose steps are authorized by different origins, or an agent workflow in which a user-originated lineage and a
service-originated lineage must jointly complete one task. This **cross-lineage composition** is legitimate, and it is *participation, not
authority mixing*: no authority is merged, and each lineage keeps its own.

Continuity does not govern that composition. It secures each lineage *individually* and forbids authority mixing between them, yet the
application still needs those lineages to *compose* into one coherent execution. The open question is therefore: **how is cross-lineage
composition governed** so that the whole remains safe while each participating lineage keeps its own guarantees?

A **lineage guardrail** answers it. It is the declarative construct that **governs cross-lineage composition**: it defines a composed
application execution and the rules under which atomic lineages may join and participate in it — which lineages may compose, under what
conditions, and what the composition as a whole may do. With a guardrail, composing atomic lineages becomes *governed participation*, never
authority mixing: the guardrail bounds the composition without reaching inside any participating lineage, weakening its continuity, expanding
its authority, or merging authority across lineages.

> The concrete guardrail construction — how a composed execution and its participation rules are declared, carried, and enforced — is defined
> in the normative sections of this document.

### 1.2 Requirements Notation

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD", "SHOULD NOT", "RECOMMENDED", "NOT RECOMMENDED", "MAY", and
"OPTIONAL" are to be interpreted as described in BCP 14 [[2]](#references) [[3]](#references) when, and only when, they appear in all capitals,
and only within the normative sections of this document. Examples are illustrative and non-normative.

## 7. Contributors

The editors and contributors of this document are listed in the **document header** above. Listing is governed by Appendix B.7 of the
[PIC Legal Appendices](./pic-legal.md).

## 8. Legal Notices

The appendices governing:

- **A.** Use of Automated Language Assistance,
- **B.** Authorship, Stewardship, Attribution, and Derivative Works,
- **C.** Disclaimer and Limitation of Liability,
- **D.** Acknowledgements,

are maintained in a single canonical document, the **[PIC Legal Appendices](./pic-legal.md)** (`draft/0.2/pic-legal.md`), and are
**incorporated into this specification by reference** as if fully set forth herein.

In case of conflict between this document and the PIC Legal Appendices, the PIC Legal Appendices prevail for legal, governance, licensing,
and attribution matters.

This specification is subordinate to the [PIC Specification](./pic-spec.md), which defines the normative semantics of the PIC Model and is
the entry point of the specification set. This document does not introduce new conceptual authority, invariants, or authorship claims beyond
those defined in the PIC Legal Appendices.

## References

- [1] Gallo, N. (2026). *Proof-of-Continuity: A Temporal Model for Authority Propagation in Distributed Systems and AI Agents*. arXiv:2607.08906 [cs.CR]. [arxiv.org/abs/2607.08906](https://arxiv.org/abs/2607.08906)
- [2] Bradner, S. (1997). *Key words for use in RFCs to Indicate Requirement Levels*. BCP 14, RFC 2119. [rfc-editor.org/rfc/rfc2119](https://www.rfc-editor.org/rfc/rfc2119)
- [3] Leiba, B. (2017). *Ambiguity of Uppercase vs Lowercase in RFC 2119 Key Words*. BCP 14, RFC 8174. [rfc-editor.org/rfc/rfc8174](https://www.rfc-editor.org/rfc/rfc8174)
