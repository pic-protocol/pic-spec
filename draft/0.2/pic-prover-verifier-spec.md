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

This document is the **PIC Prover and Verifier Specification**, a subordinate specification of the [PIC Specification](./pic-spec.md). It
defines the normative requirements for the two complementary components of Proof of Continuity handling:

- **PIC Provers**: the components that construct Proofs of Continuity for an execution hop;
- **PIC Verifiers**: the trusted components that validate Proofs of Continuity and enforce the invariants of the
  **Provenance Identity Continuity (PIC) Model** at verification time.

At every hop, a node acts in both roles: it **verifies** the proof received from its predecessor and **proves** continuity to its successor
by constructing a new proof, which the next node in turn verifies.

This document does not redefine, extend, or alter the PIC Model or the normative semantics defined by the PIC Specification.

In case of conflict, the **PIC Specification** is authoritative.

## Table of Contents

- [PIC Prover and Verifier Specification](#pic-prover-and-verifier-specification)
  - [Abstract](#abstract)
  - [Table of Contents](#table-of-contents)
  - [1. Introduction](#1-introduction)
    - [1.1 Security Guarantees of the Model](#11-security-guarantees-of-the-model)
    - [1.2 Delegating the Future](#12-delegating-the-future)
    - [1.3 The N+1 Executor Problem (Canonical Execution Model)](#13-the-n1-executor-problem-canonical-execution-model)
    - [1.4 Cross-Lineage Authority Composition](#14-cross-lineage-authority-composition)
    - [1.5 The Execution Flow as Part of the Security Model](#15-the-execution-flow-as-part-of-the-security-model)
    - [1.6 Attribute Attestations](#16-attribute-attestations)
    - [1.7 Requirements Notation](#17-requirements-notation)
    - [1.8 Origin Authority Context (PCA0)](#18-origin-authority-context-pca0)
  - [2. Prover Requirements](#2-prover-requirements)
  - [3. Verifier Requirements](#3-verifier-requirements)
  - [4. Contributors](#4-contributors)
  - [5. Legal Notices](#5-legal-notices)
  - [References](#references)

## 1. Introduction

This section is non-normative. It describes the problem this specification addresses and is independent of any concrete implementation.
Normative requirements are defined in Section 2 (Prover) and Section 3 (Verifier).

Current authorization models lack a formal execution continuity model: they define who may hold authority, but not how authority remains
valid across the steps of a distributed execution. This specification defines how the **Provenance Identity Continuity (PIC) Model** is
implemented at each execution hop to close that gap. The model, including
Proof of Relationship (PoR), Proof of Continuity (PoC), and the resulting safety guarantees, is formally defined in the companion paper
[[1]](#references) and formally verified with the Lean theorem prover [[2]](#references). The paper treats PoR as an abstract, unforgeable
primitive. This document specifies the two components that realize it:

- The **PIC Prover** constructs the PoR, the evidence binding the current execution step to its causal predecessor, and uses it to construct
  the PoC handed to the next hop. A PoC is valid only if it satisfies the PIC invariants: causal linkage witnessed by PoR at every hop, and a
  non-expansive authority context.
- The **PIC Verifier** validates both proofs at the receiving hop: the PoR, which establishes that the incoming step is a genuine
  continuation of its predecessor, and the PoC, which establishes that the invariants hold along the entire received lineage. If either
  proof is invalid, the hop is rejected before any authority is exercised.

### 1.1 Security Guarantees of the Model

An authority-propagation protocol guarantees the validity of authority states, not the physical behavior of executors. PIC guarantees that
no actor can cause another executor to create, accept, or propagate an invalid authority state: an operation is accepted only if it can be
represented as a valid continuation of the authority carried by the request.

Physical behavior is outside this guarantee, for PIC as for any security protocol. No authorization model can guarantee that an application
is free of bugs or that an executor behaves correctly: an executor that receives authority to `READ`, ignores it, and physically performs
`DELETE` fails as an implementation, locally. What the protocol guarantees is that such a fault remains local: executor `n+1` cannot
continue, as valid, an authority state that the model defines as invalid.

The same applies to the cryptographic assumptions. Capability and token systems, such as OAuth, rest on the unforgeability of their
credentials: if the underlying cryptography is broken, none of their properties survive. PIC rests on the same cryptographic assumptions,
and so does the Proof of Relationship: the relationship evidence is assumed unforgeable, and a break of the underlying cryptography is
outside the model, as it is for every protocol in this space.

This boundary is what distinguishes PIC. If authority from two independent lineages can be composed into a new state that remains valid
under a model, that model relies on correct executor behavior to avoid the composition. Under PIC such a mixed state is invalid by
construction: the damage of a buggy or compromised executor is confined to its local step and cannot propagate as valid authority at the
next hop.

### 1.2 Delegating the Future

Software that must support implementations that do not exist yet does not hard-code future components. It defines an interface. The
interface specifies the contract, and any future implementation can participate, provided it proves that it satisfies the contract.

PIC applies the same principle to distributed execution. A continuation does not name or preselect its successor. It defines the execution
contract instead:

- the authority that may continue;
- the constraints that must remain non-expansive;
- the execution characteristics the successor must satisfy;
- the causal relationship with the previous execution state.

When a successor materializes, it proves that it satisfies those conditions and may continue the execution. No identity needs to be known
in advance, and nothing binds the contract to a single successor: a continuation may be taken up by zero, one, or many executors, possibly
in parallel. The future being delegated ranges from no continuation at all to an unbounded number of them. Identity may still support
authentication, audit, and accountability, but it is not the primitive that preserves authority across execution.

The contract defines the continuation. The executor proves conformance. Continuity, not identity, delegates the future.

### 1.3 The N+1 Executor Problem (Canonical Execution Model)

The N+1 Executor Problem is future delegation made concrete. This specification is explained and defined around this single canonical
execution model. Execution is a chain of discrete steps performed by executors, such as services, workloads, functions, tools, or agents.
Each executor receives a request, processes it, and may cause a further step:

```text
+----------------+      |      +----------------+      |      +----------------+
|  EXECUTOR n-1  |------|----->|   EXECUTOR n   |------|----->|  EXECUTOR n+1  |
+----------------+      |      +----------------+      |      +----------------+
                                    time x                        time x + y
```

Each `|` marks a hop boundary: the point where the predecessor's Prover emits its proofs and the successor's Verifier validates them. Each
boundary is an act of future delegation, and the linear chain is the minimal case: a step may delegate to several successors in parallel.

The problem is the executor at position n+1. Executor `n` acts at time `x`. Executor `n+1` acts at a later time `x + y`, and at time `x` it
does not yet exist as a known party: it need not be known, selected, instantiated, or provisioned when executor `n` completes its step.
Consequently, no security mechanism that requires pre-binding authority to a concrete successor (its identity, its key, or its channel) can
be applied at time `x`: there is no holder yet to bind to.

The problem does not require a long chain: it already holds for `n = 0`. The first hop, from the origin that expresses an intent to the
first executor that serves it, crosses the same temporal gap, since that executor too may not exist or be known at the time the intent is
expressed. A single-hop execution is the smallest instance of the N+1 Executor Problem. Multi-hop chains repeat it at every boundary, where
its consequences become most visible.

### 1.4 Cross-Lineage Authority Composition

An executor may serve more than one lineage at the same time. Each lineage carries its own authority context, attenuated along its own
chain. A bug, or an adversarially influenced agent, can compose authority across those lineages: a privilege carried by one lineage is
attached to the continuation of another.

```text
LINEAGE A:  { READ-ALL, BACKUP }       ---->  { READ-ALL }
                                                   |
                                                   |  cross-lineage composition (bug)
                                                   v
LINEAGE B:  { READ-FOO, SHARE-FILES }  ---->  { SHARE-FILES }  ---->  { READ-ALL, SHARE-FILES }
                                                                         EXECUTOR n+1
```

In a possession-based model the resulting state is valid. Every privilege presented at executor `n+1` is genuinely possessed and correctly
signed; nothing in the model distinguishes them by origin. The bug has created a valid security state, and `READ-ALL` combined with
`SHARE-FILES` is now exercisable in a lineage that was never granted it.

Under PIC the same state cannot be represented as valid. `READ-ALL` is absent from the origin context of lineage B, and no valid
continuation can expand an authority context: the composed proof does not satisfy the lineage, and the Verifier at executor `n+1` rejects
it. The bug can still execute locally, as stated in Section 1.1, but the state it produces is invalid and stops at that hop.

### 1.5 The Execution Flow as Part of the Security Model

The PIC Model resolves the N+1 Executor Problem by bringing the execution flow itself, including the not-yet-existing executor `n+1`, into
the security model, rather than leaving the gap between `x` and `x + y` to application logic. What must hold across that gap is not the
identity of the successor, but that its authority is a valid continuation of the context that caused it. At time `x` the Prover of executor
`n` emits PoR and PoC addressed to an unknown successor. At time `x + y` whichever executor materializes as `n+1` presents them to its
Verifier, which accepts the hop only if both are valid. The temporal gap is therefore not an application concern to be patched with
perimeter assumptions or out-of-band coordination. It is the object the security model is built around: authority crosses it only as
verified continuity, never as possession by a pre-existing holder.

**To be completed:** roles of the Prover and Verifier in the Trust Plane, and relationship to CAT and Federation Bridge components.

### 1.6 Attribute Attestations

To describe the model, this specification uses one illustrative construct: the signed attribute attestation. It is a document, signed by an
issuer, that binds a subject to a set of attributes for a validity period. The examples in this document follow a single running scenario:
a backup service operating in the European region under compliance constraints, authorized for the operations `READ-ALL` and `BACKUP`.

```json
{
  "subject": "did:example:workloads:eu:backup-service",
  "attributes": {
    "role": "backup-service",
    "compliance": ["GDPR"],
    "accountableParty": "Example Corp",
    "serviceAgreements": [
      "https://legal.example.com/agreements/dpa-2026-001"
    ],
    "environment": "production",
    "region": "eu-1",
    "availabilityZone": "eu-1a",
    "executionModel": "deterministic"
  },
  "issuedAt": "2026-07-17T10:00:00Z",
  "expiresAt": "2026-08-17T10:00:00Z",
  "issuer": "did:example:org-authority"
}
```

The scenario includes a second executor: a summary service implemented as an AI agent. It produces summaries of documents, and its
execution is not deterministic. Its attestation differs in role, accountable party, network placement, and execution model:

```json
{
  "subject": "did:example:workloads:eu:summary-service",
  "attributes": {
    "role": "summary-service",
    "compliance": ["GDPR"],
    "accountableParty": "Acme AI Ltd",
    "serviceAgreements": [
      "https://legal.acme.example/agreements/asa-2026-042"
    ],
    "environment": "production",
    "region": "eu-1",
    "availabilityZone": "eu-1b",
    "executionModel": "agentic"
  },
  "issuedAt": "2026-07-17T10:00:00Z",
  "expiresAt": "2026-08-17T10:00:00Z",
  "issuer": "did:example:org-authority"
}
```

The identifiers in the examples use DIDs. This choice is illustrative, not normative: the model does not depend on DIDs, and any equivalent
mechanism can be used, including Verifiable Credentials, X.509 certificates, or workload identity documents. A plain attestation document
was chosen to keep the examples easy to follow.

### 1.7 Requirements Notation

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD", "SHOULD NOT", "RECOMMENDED", "NOT RECOMMENDED", "MAY", and
"OPTIONAL" in this document are to be interpreted as described in BCP 14 [[3]](#references) [[4]](#references) when, and only when, they
appear in all capitals, as shown here.

Examples in this document are illustrative and non-normative.

### 1.8 Origin Authority Context (PCA0)

A lineage begins when a principal expresses an intent within its privileges. The result is a **PIC Context of Authority (PCA)**: the signed
document that carries the authority context of a lineage. The PCA of the origin, **PCA0**, contains no Proof of Relationship: there is no
predecessor to relate to. Every later hop continues, and may only attenuate, what the PCA0 grants.

In the running scenario, Alice connects to the backup SaaS. The service agreement confirms that the service is operated in Europe by an
accountable party and does not use agentic execution. On those terms she grants access to all her files for backup. Her client produces a
PCA0, signed by Alice:

```json
{
  "issuer": "did:example:users:alice",
  "operations": ["READ-ALL", "BACKUP"],
  "executionContract": {
    "role": "backup-service",
    "compliance": ["GDPR"],
    "serviceAgreements": [
      "https://legal.example.com/agreements/dpa-2026-001"
    ],
    "executionModel": "deterministic"
  },
  "issuedAt": "2026-07-17T10:00:00Z",
  "expiresAt": "2026-07-18T10:00:00Z"
}
```

Later, Alice uses the same SaaS to summarize a document. The terms are different this time: the service runs in the United States and uses
an AI agent. She accepts them, but only for the file `foo`. The resulting PCA0 grants less and constrains differently:

```json
{
  "issuer": "did:example:users:alice",
  "operations": ["READ-FOO", "SHARE-FILES"],
  "executionContract": {
    "role": "summary-service",
    "serviceAgreements": [
      "https://legal.acme.example/agreements/asa-2026-042"
    ],
    "executionModel": "agentic"
  },
  "issuedAt": "2026-07-17T10:00:00Z",
  "expiresAt": "2026-07-18T10:00:00Z"
}
```

Each PCA0 starts a distinct lineage, with its own operations and its own execution contract, and no later hop can expand either. These are
the two lineages of Section 1.4.

A PCA0 may also be derived from an existing token, for example from a JWT through a custom token-exchange profile; such derivations are out
of scope for this specification. Wherever it comes from, the derivation is where a PCA0 is born, and execution starts from there.

## 2. Prover Requirements

**To be written:** normative requirements covering construction of PoR and PoC, binding to the execution context, challenge response, and attestation handling.

## 3. Verifier Requirements

**To be written:** normative requirements covering validation of PoR and PoC, challenge handling, replay protection, trust model assumptions, and failure semantics.

## 4. Contributors

The editors and contributors of this document are listed in the **document header** above. Listing is governed by Appendix B.7 of the
[PIC Legal Appendices](./pic-legal.md).

## 5. Legal Notices

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
- [2] Gallo, N. (2026). *PIC Lean Verification*. Lean 4 formalization of the definitions and theorems of [1]. [github.com/ngallo/pic-model/draft/0.1/pic-model-math/pic-lean](https://github.com/ngallo/pic-model/tree/main/draft/0.1/pic-model-math/pic-lean)
- [3] Bradner, S. (1997). *Key words for use in RFCs to Indicate Requirement Levels*. BCP 14, RFC 2119. [rfc-editor.org/rfc/rfc2119](https://www.rfc-editor.org/rfc/rfc2119)
- [4] Leiba, B. (2017). *Ambiguity of Uppercase vs Lowercase in RFC 2119 Key Words*. BCP 14, RFC 8174. [rfc-editor.org/rfc/rfc8174](https://www.rfc-editor.org/rfc/rfc8174)
