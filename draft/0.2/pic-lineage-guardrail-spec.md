# PIC Lineage Guardrail Specification

**Version:** 0.2 (Draft)  
**Status**: Draft – Not a Standard  
**Date:** 2026-07-19  
**Source:** [github.com/pic-protocol/pic-spec/draft/0.2/pic-lineage-guardrail-spec.md](https://github.com/pic-protocol/pic-spec/blob/main/draft/0.2/pic-lineage-guardrail-spec.md)  
**Editors:**

- **Nicola Gallo** (Nitro Agility S.r.l.) Lead Editor
- *Add your name via pull request (individual or organization) — listing is subject to editor approval (see [Contributors](#contributors)).*

**Contributors:**

- *Add your name via pull request (individual or organization) — listing is subject to editor approval (see [Contributors](#contributors)).*

## Abstract

This document is the **PIC Lineage Guardrail Specification**, a subordinate specification of the [PIC Specification](./pic-spec.md). It
introduces **lineage guardrails**: declarative, monotonic bounds on what an execution lineage is permitted to do, evaluated alongside the
continuity checks that already keep authority non-expansive and bound to its origin.

Where the PIC Model guarantees that authority only ever *attenuates* along a lineage, and the [PIC Revocation Specification](./pic-revocation-spec.md)
withdraws validity *after the fact*, a guardrail states *in advance* the conditions under which a lineage may continue at all: the bounds it
must stay within across its hops. Guardrails **constrain continuation**; they do not create authority, expand it, or alter the PIC Model
invariants.

This revision establishes the concept and the standard requirements notation shared by the PIC specification set. The normative guardrail
coordinates, their hop-by-hop continuity, and their enforcement are developed in the sections below. Guardrails build on the PCA format of
the [PIC Prover and Verifier Specification](./pic-prover-verifier-spec.md) and are consistent with the
[PIC Revocation Specification](./pic-revocation-spec.md); they do not alter non-expansion of the signed state, Proof of Relationship, or the
rule that every PCA continues exactly one predecessor. In case of conflict, the **PIC Specification** is authoritative.

## Table of Contents

- [PIC Lineage Guardrail Specification](#pic-lineage-guardrail-specification)
  - [Abstract](#abstract)
  - [Table of Contents](#table-of-contents)
  - [1. Introduction](#1-introduction)
    - [1.1 What Is a Lineage Guardrail](#11-what-is-a-lineage-guardrail)
    - [1.2 Requirements Notation](#12-requirements-notation)
  - [Contributors](#contributors)
  - [Legal Notices](#legal-notices)
  - [References](#references)

## 1. Introduction

This section is non-normative. It explains the concept the rest of the specification builds on.

### 1.1 What Is a Lineage Guardrail

A **lineage guardrail** is a bound placed on an execution lineage: a declarative rule that says what the lineage may and may not do as it
propagates, independently of which executor currently carries it. A guardrail is not authority; it is a *limit on the exercise of authority*
along the lineage.

Two mechanisms of the PIC Model already shape a lineage. **Proof of Continuity** keeps it causally bound to its origin and non-expansive:
authority only attenuates, never grows. **Revocation** ([PIC Revocation Specification](./pic-revocation-spec.md)) withdraws validity from a
lineage, or its future from a position, after an incident. A guardrail is the third, complementary mechanism: it keeps the lineage *within
stated bounds* for its whole life, checked at each hop as part of verification, before any authority is exercised.

Like attenuation and revocation, guardrails are **monotonic**: a lineage can inherit a guardrail and make it stricter, but it can never
loosen or remove one it inherited. A guardrail therefore travels with the lineage and bounds every hop that continues it, including the
not-yet-existing successor of the N+1 execution model.

> The concrete guardrail coordinates, their hop-by-hop continuity, and their enforcement are defined in the normative sections of this
> document.

### 1.2 Requirements Notation

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD", "SHOULD NOT", "RECOMMENDED", "NOT RECOMMENDED", "MAY", and
"OPTIONAL" are to be interpreted as described in BCP 14 [[2]](#references) [[3]](#references) when, and only when, they appear in all capitals,
and only within the normative sections of this document. Examples are illustrative and non-normative.

## Contributors

The editors and contributors of this document are listed in the **document header** above. Listing is governed by Appendix B.7 of the
[PIC Legal Appendices](./pic-legal.md).

## Legal Notices

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
