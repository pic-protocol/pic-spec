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

A **Lineage Execution** is a single-origin PIC execution in which every PCA continues exactly one predecessor and authority remains bounded
by the origin authority context. A complete PIC implementation secures each Lineage Execution — origin binding, Proof of Relationship at
every hop, non-expansion — so invalid authority cannot be propagated as a valid continuation: authority originating in one Lineage Execution
cannot be represented as a valid continuation of another. Physical executor behavior remains outside the protocol guarantee: a buggy,
compromised, or malicious executor can still act locally, but it cannot use PIC to command the next conforming executor beyond the authority
of its Lineage Execution.

An executor may propose a transition involving one Lineage Execution, or several: a **Multi-Lineage Execution** carries two or more
independent Lineage Executions together for one proposed transition, while each retains its own origin, PCA chain, authority context, and
continuity. The participating authorities remain distinct, and no new authority or lineage is created by their joint carriage.
*Participation, not authority mixing.*

An **Execution Guardrail** is an externally configured runtime control at an execution boundary that evaluates a proposed transition
involving one or more Lineage Executions against configured policy and permits or denies it. Guardrails do not make an invalid PCA valid,
do not merge authorities, and do not alter lineage invariants.

This revision establishes the concepts and the standard requirements notation shared by the PIC specification set; the normative guardrail
construction and enforcement requirements will be defined in forthcoming revisions. Guardrails build on the PCA format of the
[PIC Prover and Verifier Specification](./pic-prover-verifier-spec.md) and are consistent with the
[PIC Revocation Specification](./pic-revocation-spec.md); they do not alter non-expansion of the signed state, Proof of Relationship, or the
rule that every PCA continues exactly one predecessor. In case of conflict, the **PIC Specification** is authoritative.

## Table of Contents

- [PIC Lineage Guardrail Specification](#pic-lineage-guardrail-specification)
  - [Abstract](#abstract)
  - [Table of Contents](#table-of-contents)
  - [1. Introduction](#1-introduction)
    - [1.1 Lineage Execution and Execution Lineage Safety](#11-lineage-execution-and-execution-lineage-safety)
    - [1.2 Execution Guardrails](#12-execution-guardrails)
    - [1.3 Multi-Lineage Execution](#13-multi-lineage-execution)
    - [1.4 Requirements Notation](#14-requirements-notation)
  - [7. Contributors](#7-contributors)
  - [8. Legal Notices](#8-legal-notices)
  - [References](#references)

## 1. Introduction

This section is non-normative. It introduces the three concepts the rest of this specification builds on: the Lineage Execution, which PIC
secures; the Execution Guardrail, which evaluates proposed transitions at execution boundaries; and the Multi-Lineage Execution, which
carries several Lineage Executions together for one proposed transition:

```text
PIC
===

LINEAGE EXECUTION
-----------------
a single-origin PIC execution

- one origin authority context
- PoR continuity
- non-expansion
- no imported authority
- no invalid PCA accepted downstream


EXECUTION GUARDRAIL
-------------------
evaluates a proposed transition
at an execution boundary

- input: one or more Lineage Executions
- evaluate configured policy
- enforce permit or deny


MULTI-LINEAGE EXECUTION
-----------------------
two or more Lineage Executions carried
together for one proposed transition

- constructed by the executor
- authorities remain separate
- no new authority or lineage is created
```

### 1.1 Lineage Execution and Execution Lineage Safety

> A **Lineage Execution** is a single-origin PIC execution in which every PCA continues exactly one predecessor and authority remains
> bounded by the origin authority context.

A Lineage Execution begins when a **permissioned entity** — a human identity, a workload, a service, an AI agent, a role, a service
account, or another authenticated entity associated with permissions — expresses an **intent** and selects an **origin authority context**
from its permissions. The result is PCA0. Every later PCA is produced by an executor and continues exactly one predecessor through PoR, and
successors need not be known in advance: each hop delegates to an N+1 executor that may not yet exist when its predecessor completes
([PIC Prover and Verifier Specification](./pic-prover-verifier-spec.md), Section 1.3).

The topology may branch under fan-out ([PIC Revocation Specification](./pic-revocation-spec.md), Section 1.1), so a Lineage Execution is
not necessarily one linear chain. Even when execution branches:

- every PCA continues exactly one predecessor, witnessed by PoR;
- every path remains bound to the same origin;
- non-expansion holds at every hop, so authority remains origin-bounded;
- unrelated authority cannot be introduced.

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
envelope or process; they remain logically distinct and are never merged. The formal definitions and proofs are in the PIC Model
[[1]](#references); the construction — Provers, Verifiers, and the PCA format — is defined by the
[PIC Prover and Verifier Specification](./pic-prover-verifier-spec.md), and revocation by the
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

Execution lineage safety is more than document integrity. A conforming executor cannot create a valid successor PCA that:

- expands authority;
- imports authority from an unrelated Lineage Execution;
- claims an operation not authorized by its own origin authority context;
- breaks predecessor continuity.

The valid case only narrows authority:

```text
LINEAGE EXECUTION A

PCA0-A { READ-ALL, BACKUP }
          |
          | PoR + non-expansion
          v
PCA1-A { BACKUP }
          |
          v
    NEXT EXECUTOR
```

The invalid case cannot be validated as a continuation:

```text
Lineage Execution A:
PCA1-A { BACKUP }

Lineage Execution B:
PCA0-B { WRITE-S3 }

Invalid successor of A:
{ BACKUP, WRITE-S3 }

WRITE-S3 did not originate in A.
The PCA is not a valid continuation of A.
```

An executor may hold several capabilities or credentials and use them together at the application layer, and PIC does not prohibit an
application from holding several authorities. What it prohibits is representing authority originating in one Lineage Execution as a valid
continuation of another: possession alone does not establish which authority belongs to the Lineage Execution that caused the action.

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
> beyond the authority of the current Lineage Execution.

The operational risk that remains — the physical behavior itself — is addressed by the guardrails of Section 1.2.

### 1.2 Execution Guardrails

An example introduces the concept. A homeowner gives an authorized contractor a key to renovate a house. The key allows the contractor to
enter. If the contractor enters and destroys the house, the key has not failed: asking the key to guarantee correct physical behavior is a
category error. The needed controls are external to the key — define limits, observe activity, evaluate proposed actions, deny continuation
when limits are crossed.

```text
key
  -> valid authority propagation through a Lineage Execution

contractor
  -> executor operating with valid authority

contractor acting outside the intended work
  -> buggy, compromised, malicious, or non-deterministic behavior

limits, observation, and denial
  -> execution guardrails
```

> An **Execution Guardrail** is an externally configured runtime control at an execution boundary that evaluates a proposed transition
> involving one or more Lineage Executions and enforces the resulting policy decision.

The guardrail may receive one Lineage Execution, or one Multi-Lineage Execution carrying two or more (Section 1.3). Within a single Lineage
Execution, authority states are already secured by execution lineage safety (Section 1.1); what the guardrail adds is the evaluation of the
proposed transition against configured policy.

```text
  ONE OR MORE LINEAGE EXECUTIONS
                |
                | proposed transition
                v
+--------------------------------+
| EXECUTION GUARDRAIL            |
|                                |
| evaluate configured policy     |
| enforce the result             |
+--------------------------------+
                |
           +----+----+
           |         |
         permit     deny
           |         |
           v         X
     NEXT EXECUTOR
     OR TARGET
```

Permit allows the proposed transition to cross the execution boundary as presented. Deny prevents that proposed transition from crossing
the boundary. Future revisions may define additional runtime controls; this section does not anticipate them.

The executor or calling system constructs the proposal: the proposed action, whether it uses one Lineage Execution or a Multi-Lineage
Execution, which Lineage Executions are presented, and how they are intended to participate. The guardrail does not construct the proposal,
does not decide which authorities to combine, does not modify the PCA inputs, and does not create an alternative transition, a new
authority, or a new Lineage Execution.

> The executor constructs the proposed transition. The guardrail does not compose the participating Lineage Executions; it only determines
> whether the proposed transition may cross the execution boundary.

If the proposal is denied, the executor may later construct a different proposal; that is a new proposed transition, outside the decision
being evaluated.

How configured policy is evaluated is an implementation choice. The guardrail may evaluate policy directly or obtain a decision from
another policy evaluation component. What matters is that the decision is enforced before the proposed transition crosses the execution
boundary.

```text
POLICY GOVERNANCE
defines, reviews, approves, and configures policy

EXECUTION GUARDRAIL
evaluates or obtains a policy decision
and enforces permit or deny at runtime
```

Runtime evaluation is not itself governance. PIC and the guardrail also answer different questions:

> PIC determines whether the authority state is a valid continuation of its Lineage Execution. The guardrail determines whether the
> proposed transition satisfies the configured policy, and enforces permit or deny at the execution boundary.

Guardrails do not make an invalid PCA valid, do not merge authorities, do not change lineage invariants, and do not guarantee correct
internal executor behavior. They reduce the executor's ability to cause another executor or target to continue an operation that violates
the configured policy. How context, policy, and decisions are represented and evaluated is defined by the normative sections of this
specification; this section only introduces the concept.

### 1.3 Multi-Lineage Execution

> A **Multi-Lineage Execution** is an execution in which two or more independent Lineage Executions are carried together for one proposed
> transition, while each retains its own origin, PCA chain, authority context, and continuity.

A Multi-Lineage Execution is a runtime envelope: it carries several distinct Lineage Executions together, and it has no authority of its
own. The executor or calling system constructs and presents it; the guardrail does not create it.

```text
one Lineage Execution
    -> one authority-propagation flow

Multi-Lineage Execution
    -> two or more distinct Lineage Executions
       carried together for one proposed transition
```

```text
LINEAGE EXECUTION A
PCA1-A { BACKUP }
        |
        | enters as A
        v
+====================================================+
|               MULTI-LINEAGE EXECUTION              |
|                                                    |
|  +----------------------------------------------+  |
|  | A: PCA1-A { BACKUP }                         |  |
|  +----------------------------------------------+  |
|                                                    |
|  +----------------------------------------------+  |
|  | B: PCA0-B { WRITE-S3 }                       |  |
|  +----------------------------------------------+  |
|                                                    |
|  authorities remain separate                       |
+====================================================+
        ^
        | enters as B
        |
LINEAGE EXECUTION B
PCA0-B { WRITE-S3 }

Distinct Lineage Executions, one proposed transition.
```

At the guardrail interface the number of participating Lineage Executions is any number greater than or equal to one:

```text
Lineage Execution A ----+
                        |
Lineage Execution B ----+---> proposed transition
                        |             |
Lineage Execution C ----+             v
                              EXECUTION GUARDRAIL

1 Lineage Execution
or
N Lineage Executions
```

With one participant, the proposal is simply a transition under one Lineage Execution; with two or more, they are carried as a
Multi-Lineage Execution. The guardrail interface does not require separate mechanisms for the two cases.

The canonical example. A user authorizes an application to read a document and perform a backup; that authority propagates through Lineage
Execution A. The executor serving the request is an AI agent: it receives PCA1-A and proves the PoR, like any other executor.

```text
LINEAGE EXECUTION A — USER AUTHORITY

PCA0-A { READ-ALL, BACKUP }
          |
          | PoR
          v
PCA1-A { BACKUP }
          |
          | PoR
          v
+------------------------+
| AI AGENT               |
| executor of A          |
+------------------------+
```

To write the backup to S3, the agent also acts as a permissioned entity of its own: it expresses its own intent and mints PCA0-B, the
origin of Lineage Execution B:

```text
LINEAGE EXECUTION B — AGENT AUTHORITY

PCA0-B { WRITE-S3 }
```

The agent now holds two authorities. It constructs a Multi-Lineage Execution carrying both and proposes the transition:

```text
+====================================================+
|               MULTI-LINEAGE EXECUTION              |
|                                                    |
| A: PCA1-A { BACKUP }                               |
| B: PCA0-B { WRITE-S3 }                             |
|                                                    |
| proposed action: write the backup to S3            |
+====================================================+
                          |
                          v
              +----------------------+
              | EXECUTION GUARDRAIL  |
              |                      |
              | evaluate policy      |
              | permit / deny        |
              +----------------------+
                          |
                          v
                          S3
```

Lineage Execution A authorizes `BACKUP`; Lineage Execution B authorizes `WRITE-S3`. The agent proposed their joint participation; the
guardrail did not create that relationship and does not merge A and B. Configured policy determines whether the proposed transition is
permitted, the guardrail enforces permit or deny, and every externally relevant action remains attributable to a specific Lineage
Execution. Participation, not authority mixing.

### 1.4 Requirements Notation

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
