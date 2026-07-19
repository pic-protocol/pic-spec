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

In the PIC Model, a **lineage** is a single-origin authority-propagation structure: every PCA continues exactly one predecessor, and
authority only attenuates and remains bounded by its origin. A complete PIC implementation secures each lineage individually — origin
binding, Proof of Relationship at every hop, non-expansion — and forbids **cross-lineage authority composition**: authority from one lineage
can never be represented as a valid continuation of another. That prohibition is what makes the confused-deputy class of failures
unrepresentable as valid authority states.

Two problems remain outside that guarantee. First, no security protocol constrains the physical behavior of an executor: a buggy,
compromised, or malicious executor can still act locally, even though the resulting invalid authority state cannot propagate as a valid PIC
continuation. Second, one execution may legitimately involve several independent lineages — of the same application or of different
applications — each contributing its own authority without importing it into another lineage: a **cross-lineage execution**.
*Participation, not authority mixing.*

A **cross-lineage execution guardrail** is an externally configured runtime control that evaluates and enforces constraints on the proposed
actions and transitions of a cross-lineage execution. Each individual lineage is already secured by the PIC Model; the guardrail controls
their joint participation. Guardrails do not make an invalid PCA valid, do not merge authorities, and do not alter lineage invariants.

This revision establishes the concept and the standard requirements notation shared by the PIC specification set; the normative guardrail
construction and enforcement requirements will be defined in forthcoming revisions. Guardrails build on the PCA format of the
[PIC Prover and Verifier Specification](./pic-prover-verifier-spec.md) and are consistent with the
[PIC Revocation Specification](./pic-revocation-spec.md); they do not alter non-expansion of the signed state, Proof of Relationship, or the
rule that every PCA continues exactly one predecessor. In case of conflict, the **PIC Specification** is authoritative.

## Table of Contents

- [PIC Lineage Guardrail Specification](#pic-lineage-guardrail-specification)
  - [Abstract](#abstract)
  - [Table of Contents](#table-of-contents)
  - [1. Introduction](#1-introduction)
    - [1.1 Execution Lineage](#11-execution-lineage)
    - [1.2 Cross-Lineage Execution Guardrails](#12-cross-lineage-execution-guardrails)
    - [1.3 Requirements Notation](#13-requirements-notation)
  - [7. Contributors](#7-contributors)
  - [8. Legal Notices](#8-legal-notices)
  - [References](#references)

## 1. Introduction

This section is non-normative. It explains the two concepts the rest of this specification builds on, both within the PIC specification
set: the execution lineage, whose safety a complete implementation of the PIC Model provides, and the cross-lineage execution guardrail,
which controls executions in which two or more lineages participate:

```text
PIC
===

EXECUTION LINEAGE SAFETY
------------------------
secures each execution lineage

- one origin authority context
- PoR continuity
- non-expansion
- no imported authority
- no invalid PCA accepted downstream


CROSS-LINEAGE EXECUTION GUARDRAIL
---------------------------------
controls executions where two or more
lineages participate

- observe the proposed action or transition
- inspect participating lineage semantics
- evaluate configured policies
- enforce the decision
- permit, deny, block, suspend, or interrupt
- authorities remain separate; never merged
- each action keeps an authorizing lineage
```

### 1.1 Execution Lineage

A lineage begins when a **permissioned entity** — a human identity, a workload, a service, an AI agent, a role, a service account, or
another authenticated entity associated with permissions — expresses an **intent** and selects an **origin authority context** from its
permissions. The result is an origin PCA, the PCA0. Every later PCA is produced by an executor and continues exactly one predecessor, and
successors need not be known in advance: each hop delegates to an N+1 executor that may not yet exist when its predecessor completes
([PIC Prover and Verifier Specification](./pic-prover-verifier-spec.md), Section 1.3).

A lineage is an independently secured unit of authority propagation rooted in one origin authority context. Its topology may branch under
fan-out ([PIC Revocation Specification](./pic-revocation-spec.md), Section 1.1), so it is not necessarily one linear chain. Even when
execution branches:

- every PCA continues exactly one predecessor, witnessed by PoR;
- every path remains bound to the same origin;
- non-expansion holds at every hop, so authority remains origin-bounded;
- unrelated authority cannot be introduced into the lineage.

```text
+------------------------+
| PERMISSIONED ENTITY A  |
+------------------------+
            |
          intent
            |
            v
+------------------------+
| ORIGIN PCA0-A          |
| authority context C0-A |
+------------------------+
            |
            | PoR
            v
+------------------------+
| PCA1-A                 |
| C1-A <= C0-A           |
+------------------------+
            |
       +----+----+
       |         |
       v         v
    PCA2-A1   PCA2-A2

One origin.
Each PCA continues exactly one predecessor.
Authority only narrows.
```

These properties make the confused deputy unrepresentable as a valid authority state. Distinct authorities may travel together in the same
envelope or application process; they remain logically distinct and are never merged. The formal definitions and proofs are in the PIC Model
[[1]](#references); the lineage construction — Provers, Verifiers, and the PCA format — is defined by the
[PIC Prover and Verifier Specification](./pic-prover-verifier-spec.md), and revocation within a lineage by the
[PIC Revocation Specification](./pic-revocation-spec.md). This document builds on them and restates none of them.

What these properties provide is **execution lineage safety**, distinct from physical executor behavior:

```text
EXECUTION LINEAGE SAFETY              PHYSICAL EXECUTOR BEHAVIOR
------------------------              --------------------------
the authority states that can be      the physical actions that a buggy,
created, propagated, and              compromised, or malicious
accepted as valid                     executor performs

secured by PIC                        outside the PIC protocol guarantee
```

Execution lineage safety is more than document integrity. A conforming executor cannot create a valid successor PCA that commands the next
executor using:

- expanded authority;
- authority borrowed from another lineage;
- a union of independently valid authorities;
- authority unrelated to the current predecessor.

The valid case only narrows authority:

```text
LINEAGE A

PCA0-A { READ-ALL, BACKUP }
          |
          | PoR + non-expansion
          v
PCA1-A { BACKUP }
          |
          v
    NEXT EXECUTOR
```

The invalid case cannot be represented as a continuation of any participating lineage:

```text
PCA1-A { BACKUP }        PCA0-B { WRITE-S3 }
          \                    /
           \                  /
            v                v
        { BACKUP, WRITE-S3 }

Not a valid successor of lineage A.
Not a valid successor of lineage B.
A conforming PIC Verifier rejects it.
```

An executor may hold several capabilities or credentials and use them together at the application layer, and PIC does not prohibit an
application from holding several authorities. What it prohibits is representing their union as a valid continuation of one lineage:
possession alone does not establish which authority belongs to the execution lineage that caused the action.

Physical behavior lies outside this guarantee, for PIC as for any security protocol:

```text
Authority carried by the lineage: READ
Physical operation performed:     WRITE
```

Here the executor has failed to implement or enforce the protocol; PIC did not authorize `WRITE`. The physical write may produce real
external effects, and if the executor never attempts to represent or propagate the action as authority, PIC may not observe it at all: no
protocol can infer every local physical action from authority documents alone. The physical effects may leave the executor, but the invalid
authority state cannot propagate as a valid PIC continuation.

> A faulty executor may act locally, but it cannot use PIC to create a valid authority state that commands the next conforming executor
> beyond the authority of the current lineage.

The operational risk that remains — the physical behavior itself — is addressed by the guardrails of Section 1.2.

### 1.2 Cross-Lineage Execution Guardrails

An example introduces the concept. A homeowner gives an authorized contractor a key to renovate a house. The key allows the contractor to
enter. If the contractor enters and destroys the house, the key has not failed: asking the key to guarantee correct physical behavior is a
category error. The needed controls are external to the key — define limits, observe activity, evaluate proposed actions, block continuation
when limits are crossed.

```text
key
  -> valid authority propagation through a lineage

contractor
  -> executor operating with valid authority

contractor acting outside the intended work
  -> buggy, compromised, malicious, or non-deterministic behavior

limits, observation, and blocking
  -> cross-lineage execution guardrails
```

> A **cross-lineage execution guardrail** is an externally configured runtime control at an execution boundary that evaluates and enforces
> constraints on a proposed action or transition.

A **cross-lineage execution** is an execution in which two or more independently secured lineages participate; the lineages may belong to
the same application or to different applications. That is where a guardrail operates: within a single lineage, authority states are already
secured by execution lineage safety (Section 1.1). A guardrail may consider both executor behavior and the independently preserved semantics
of the participating lineages: the proposed action, the valid PCA or PCAs involved, the semantic labels associated with their lineages, the
relationship between the participating lineages, and configured execution constraints. It may permit, deny, block, suspend, or interrupt
the transition.

Two roles cooperate, and they are distinct:

- **Policy governance** is the human or administrative process through which policies are defined, reviewed, approved, and configured. It
  occurs before runtime execution.
- The **cross-lineage execution guardrail** is the runtime control at the execution boundary: it observes a proposed action or transition,
  evaluates it against the configured policies and the semantics of the participating lineages, and enforces the resulting decision before
  execution crosses the boundary.

```text
POLICY GOVERNANCE
defines and configures policies
          |
          v
CROSS-LINEAGE EXECUTION GUARDRAIL
evaluates the proposed transition
enforces permit, deny, block, suspend, or interrupt
```

How the guardrail evaluates a transition is an implementation choice. One possible implementation delegates the evaluation to a Policy
Decision Point (PDP); this is illustrative, neither unique nor mandatory. What matters is that the proposed transition is evaluated against
configured policies over the semantics of the participating lineages.

Runtime policy evaluation is not governance: governance configures the policies; guardrails evaluate and enforce them during execution. At
runtime, the participating lineages enter the guardrail together; the proposed cross-lineage transition is evaluated with their context and
the configured policies, and is permitted or denied as a whole:

```text
LINEAGE A            LINEAGE B
    |                    |
    +-------------+------+
                  |
                  | proposed cross-lineage transition
                  v
+-----------------------------------+
| CROSS-LINEAGE EXECUTION GUARDRAIL |
|                                   |
| collect lineage context           |
| evaluate configured policies      |
| enforce decision                  |
+-----------------------------------+
                  |
         +--------+--------+
         |                 |
       permit         deny / block
         |          suspend / interrupt
         v                 |
   NEXT EXECUTOR           X
   OR TARGET
```

How context, policies, and decisions are represented and evaluated is defined by the normative sections of this specification; this section
only introduces the concept.

PIC and the guardrail answer different questions:

> PIC determines whether the authority state is a valid lineage continuation. The guardrail determines whether the proposed transition
> satisfies the configured policies, and enforces that decision at the execution boundary.

Guardrails do not make an invalid PCA valid, do not merge authorities, do not change lineage invariants, and do not guarantee correct
internal executor behavior. They reduce the executor's ability to cause another executor or target to continue an operation that violates
the configured limits.

The canonical example. One execution may legitimately involve several lineages:

- a user authorizes an application to read a document and perform a backup; that authority propagates through lineage A;
- the executor serving the request is an AI agent: it receives PCA1-A and proves the PoR, like any other executor;
- to write the backup to S3, the agent acts as a permissioned entity of its own: it expresses its own intent and mints PCA0-B, the origin
  of lineage B;
- the agent now holds two authorities — PCA1-A { BACKUP } and PCA0-B { WRITE-S3 } — and proposes to continue with lineage B;
- the two lineages participate in one cross-lineage execution; neither authority is imported into the other lineage.

```text
LINEAGE A — USER AUTHORITY

PCA0-A { READ-ALL, BACKUP }
     |
     | PoR
     v
PCA1-A { BACKUP }
     |
     | PoR
     v
+----------------------------+          +-----------------------------------+
| AI AGENT                   |          | CROSS-LINEAGE EXECUTION GUARDRAIL |
|                            |  PCA1-A  |                                   |
| executor of lineage A      |  PCA0-B  | lineage A semantics: BACKUP       |
| holds PCA1-A { BACKUP }    |--------->| lineage B semantics: WRITE-S3     |
|                            |          | evaluate configured policies      |
| permissioned entity:       |          | decision: permit                  |
| expresses its own intent,  |          +-----------------------------------+
| mints PCA0-B { WRITE-S3 }  |                            |
| origin of LINEAGE B        |                            | continue with
+----------------------------+                            | lineage B
                                                          v
                                                          S3
```

The guardrail may evaluate whether `BACKUP` and `WRITE-S3` are semantically compatible in the proposed cross-lineage transition:

```text
PCA1-A semantics: BACKUP
             \
              \
               > GUARDRAIL policy evaluation -> permit / deny
              /
             /
PCA0-B semantics: WRITE-S3
```

The evaluation does not merge the two authorities. Lineage A still authorizes `BACKUP`; lineage B still authorizes `WRITE-S3`. The policy
determines whether their simultaneous participation is allowed, and the guardrail enforces that decision before the transition reaches S3.
Participation, not authority mixing.

```text
VALID: CROSS-LINEAGE EXECUTION

Lineage A authorizes BACKUP.
Lineage B authorizes WRITE-S3.
A policy permits both to participate in one cross-lineage execution.
The authorities remain distinct.


INVALID: CROSS-LINEAGE AUTHORITY COMPOSITION

A successor of lineage A claims:
{ BACKUP, WRITE-S3 }

WRITE-S3 did not originate in lineage A.
The successor is not a valid PIC continuation.
```

Every externally relevant action produced by a cross-lineage execution still requires authority from a specific participating lineage:
cross-lineage participation does not create a new implicit authority for the combined result. How a proposed output action is associated
with its authorizing lineage and evaluated against the other participating lineages is defined by the normative sections of this
specification.

### 1.3 Requirements Notation

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD", "SHOULD NOT", "RECOMMENDED", "NOT RECOMMENDED", "MAY", and
"OPTIONAL" are to be interpreted as described in BCP 14 [[2]](#references) [[3]](#references) when, and only when, they appear in all capitals,
and only within the normative sections of this document. Examples are illustrative and non-normative.

The normative guardrail construction and enforcement requirements will be defined in forthcoming revisions of this specification.

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
