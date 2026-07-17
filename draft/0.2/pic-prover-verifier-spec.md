# PIC Prover and Verifier Specification

**Version:** 0.2 (Draft)  
**Status**: Draft – Not a Standard  
**Date:** 2026-07-15  
**Source:** [github.com/pic-protocol/pic-spec/draft/0.2/pic-prover-verifier-spec.md](https://github.com/pic-protocol/pic-spec/blob/main/draft/0.2/pic-prover-verifier-spec.md)  
**Editors:**

- **Nicola Gallo** (Nitro Agility S.r.l.)
- *Add your name via pull request (individual or organization) — listing is subject to editor approval (see [Section 4](#4-contributors)).*

**Contributors:**

- *Add your name via pull request (individual or organization) — listing is subject to editor approval (see [Section 4](#4-contributors)).*

## Abstract

This document is the **PIC Prover and Verifier Specification**, a subordinate
specification of the [PIC Specification](./pic-spec.md). It defines the
normative requirements for the two complementary components of Proof of
Continuity handling:

- **PIC Provers**: the components that construct Proofs of Continuity for an
  execution hop;
- **PIC Verifiers**: the trusted components that validate Proofs of
  Continuity and enforce the invariants of the
  **Provenance Identity Continuity (PIC) Model** at verification time.

At every hop, a node acts in both roles: it **verifies** the proof received
from its predecessor and **proves** continuity to its successor by
constructing a new proof, which the next node in turn verifies.

This document does not redefine, extend, or alter the PIC Model or the
normative semantics defined by the PIC Specification.

In case of conflict, the **PIC Specification** is authoritative.

## Relationship to the PIC Specification

- The **PIC Specification** ([pic-spec.md](./pic-spec.md)) is the entry point
  of the specification set and defines the normative semantics of the PIC
  Model.
- This **PIC Prover and Verifier Specification** is **subordinate** to the
  PIC Specification and covers the prover and verifier domains only.

This document does not introduce new conceptual authority, invariants, or
authorship claims beyond those defined in the
[PIC Legal Appendices](./pic-legal.md).

## Table of Contents

- [PIC Prover and Verifier Specification](#pic-prover-and-verifier-specification)
  - [Abstract](#abstract)
  - [Relationship to the PIC Specification](#relationship-to-the-pic-specification)
  - [Table of Contents](#table-of-contents)
  - [1. Introduction](#1-introduction)
    - [1.1 The N+1 Executor Problem (Canonical Execution Model)](#11-the-n1-executor-problem-canonical-execution-model)
    - [1.2 The Execution Flow as Part of the Security Model](#12-the-execution-flow-as-part-of-the-security-model)
  - [2. Prover Requirements](#2-prover-requirements)
  - [3. Verifier Requirements](#3-verifier-requirements)
  - [4. Contributors](#4-contributors)
  - [5. Legal Notices](#5-legal-notices)
  - [References](#references)

## 1. Introduction

This specification defines how the **Provenance Identity Continuity (PIC)
Model** is implemented at each execution hop. The PIC Model — Proof of
Relationship (PoR), Proof of Continuity (PoC), and the resulting safety
guarantees — is formally defined in the companion paper
*Proof-of-Continuity: A Temporal Model for Authority Propagation in
Distributed Systems and AI Agents* [[1]](#references). Where the paper treats
the single-hop relationship evidence PoR as an abstract, unforgeable
primitive, this document specifies the components that realize it:

- the **PIC Prover** implements the *proving* role of the model: it constructs
  the Proof of Continuity that binds the current execution step to its causal
  predecessor and carries a non-expansive authority context forward;
- the **PIC Verifier** implements the *verifying* role of the model: it
  validates the proof received at a hop and enforces the PIC invariants —
  causal linkage and monotonic authority restriction — before any authority is
  exercised.

### 1.1 The N+1 Executor Problem (Canonical Execution Model)

This specification is explained and defined around a single canonical
execution model, referred to throughout as the **N+1 Executor Problem**.
Execution is a chain of discrete steps performed by executors — services,
workloads, functions, tools, or agents — each of which receives a request,
processes it, and may cause a further step:

```text
+----------------+      |      +----------------+      |      +----------------+
|  EXECUTOR n-1  |------|----->|   EXECUTOR n   |------|----->|  EXECUTOR n+1  |
+----------------+      |      +----------------+      |      +----------------+
                                    time x                        time x + y
```

Each `|` marks a hop boundary: the point where the predecessor's Prover emits
a Proof of Continuity and the successor's Verifier validates it.

The problem is the executor at position **n+1**. Executor `n` acts at time
`x`; executor `n+1` acts only at a later time `x + y` — and at time `x` it
**does not yet exist as a known party**: it need not be known, selected,
instantiated, or provisioned when executor `n` completes its step. Execution
is a sequence of causal steps in time, not of positions fixed by topology.
Consequently, no security mechanism that requires pre-binding authority to a
concrete successor — its identity, its key, or its channel — can be applied at
time `x`: there is no holder yet to bind to.

### 1.2 The Execution Flow as Part of the Security Model

The PIC Model resolves the N+1 Executor Problem by bringing the execution flow
itself — including the not-yet-existing executor `n+1` — **into the security
model**, rather than leaving the gap between `x` and `x + y` to application
logic. What must hold across that gap is not the identity of the successor,
nor a policy attached to it, but that its authority is a valid continuation of
the context that caused it:

- at time `x`, the Prover of executor `n` emits a continuation — a Proof of
  Continuity anchored to its own step, addressed to an unknown successor;
- at time `x + y`, whichever executor materializes as `n+1` presents that
  continuation to its Verifier, which accepts the hop only if it is causally
  linked to executor `n` (PoR) and its authority context is non-expansive
  with respect to the one received.

Under this discipline, the temporal gap is not an application concern to be
patched with perimeter assumptions, shared secrets, or out-of-band
coordination: it is the object the security model is built around. Authority
crosses the gap only as verified continuity, never as possession by a
pre-existing holder.

*(To be completed: roles of the Prover and Verifier in the Trust Plane, and
relationship to CAT and Federation Bridge components.)*

## 2. Prover Requirements

*(To be written: normative requirements — construction of Proofs of
Continuity, binding to the execution context, challenge response,
attestation handling.)*

## 3. Verifier Requirements

*(To be written: normative requirements — validation of Proofs of Continuity,
challenge handling, replay protection, trust model assumptions, failure
semantics.)*

## 4. Contributors

The editors and contributors of this document are listed in the **document
header** above. Listing is governed by Appendix B.7 of the
[PIC Legal Appendices](./pic-legal.md).

## 5. Legal Notices

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

## References

- [1] Gallo, N. (2026). *Proof-of-Continuity: A Temporal Model for Authority Propagation in Distributed Systems and AI Agents*. arXiv:2607.08906 [cs.CR]. [arxiv.org/abs/2607.08906](https://arxiv.org/abs/2607.08906)
