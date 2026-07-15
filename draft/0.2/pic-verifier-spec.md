# PIC Verifier Specification

**Version:** 0.2 (Draft)  
**Status**: Draft – Not a Standard  
**Date:** 2026-07-15  
**Source:** [github.com/pic-protocol/pic-spec/draft/0.2/pic-verifier-spec.md](https://github.com/pic-protocol/pic-spec/blob/main/draft/0.2/pic-verifier-spec.md)  
**Editors:**

- **Nicola Gallo** (on behalf of Nitro Agility S.r.l.) — lead editor

**Contributors:**

- **Antonio Radesca** (on behalf of Nitro Agility S.r.l.)
- *Add your name via pull request (individual or organization) — listing is subject to editor approval (see [Section 3](#3-contributors)).*

---

## Abstract

This document is the **PIC Verifier Specification**, a subordinate
specification of the [PIC Specification](./pic-spec.md). It defines the
normative requirements for **PIC Verifiers**: the trusted components that
validate Proofs of Continuity and enforce the invariants of the
**Provenance Identity Continuity (PIC) Model** at verification time.

This document does not redefine, extend, or alter the PIC Model or the
normative semantics defined by the PIC Specification.

In case of conflict, the **PIC Specification** is authoritative.

---

## Relationship to the PIC Specification

- The **PIC Specification** ([pic-spec.md](./pic-spec.md)) is the entry point
  of the specification set and defines the normative semantics of the PIC
  Model.
- This **PIC Verifier Specification** is **subordinate** to the PIC
  Specification and covers the verifier domain only.

This document does not introduce new conceptual authority, invariants, or
authorship claims beyond those defined in the
[PIC Legal Appendices](./pic-legal.md).

---

## Table of Contents

- [PIC Verifier Specification](#pic-verifier-specification)
  - [Abstract](#abstract)
  - [Relationship to the PIC Specification](#relationship-to-the-pic-specification)
  - [Table of Contents](#table-of-contents)
  - [1. Introduction](#1-introduction)
  - [2. Verifier Requirements](#2-verifier-requirements)
  - [3. Contributors](#3-contributors)
  - [4. Legal Notices](#4-legal-notices)
  - [References](#references)

---

## 1. Introduction

*(To be written: scope of the PIC Verifier, its role in the Trust Plane,
relationship to CAT and Federation Bridge components, and the verification
responsibilities it assumes.)*

---

## 2. Verifier Requirements

*(To be written: normative requirements — validation of Proofs of Continuity,
challenge handling, replay protection, trust model assumptions, failure
semantics.)*

---

## 3. Contributors

The editors and contributors of this document are listed in the **document
header** above. Listing is governed by Appendix B.7 of the
[PIC Legal Appendices](./pic-legal.md).

---

## 4. Legal Notices

The appendices governing:

- **A.** Use of Automated Language Assistance,
- **B.** Authorship, Stewardship, Attribution, and Derivative Works,
- **C.** Disclaimer and Limitation of Liability,
- **D.** Acknowledgements,

are maintained in a single canonical document, the
**[PIC Legal Appendices](./pic-legal.md)** (`draft/0.2/pic-legal.md`), and are
**incorporated into this specification by reference** as if fully set forth
herein.

In case of conflict between this document and the PIC Legal Appendices, the
PIC Legal Appendices prevail for legal, governance, licensing, and attribution
matters.

---

## References

- [1] Gallo, N. (2026). *Proof-of-Continuity: A Temporal Model for Authority Propagation in Distributed Systems and AI Agents*. arXiv:2607.08906 [cs.CR]. [arxiv.org/abs/2607.08906](https://arxiv.org/abs/2607.08906)
