# PIC Execution Guardrail Specification

**Version:** 0.2 (Draft)  
**Status**: Draft – Not a Standard  
**Date:** 2026-07-19  
**Source:** [github.com/pic-protocol/pic-spec/draft/0.2/pic-lineage-guardrail-spec.md](https://github.com/pic-protocol/pic-spec/blob/main/draft/0.2/pic-lineage-guardrail-spec.md)  
**Editors:**

- **Nicola Gallo** (Nitro Agility S.r.l.) Lead Editor
- *Add your name via pull request (individual or organization) — listing is subject to editor approval (see [Section 6](#6-contributors)).*

**Contributors:**

- *Add your name via pull request (individual or organization) — listing is subject to editor approval (see [Section 6](#6-contributors)).*

## Abstract

This document is the **PIC Execution Guardrail Specification**, a subordinate specification of the [PIC Specification](./pic-spec.md).
It retains its historical repository filename (`pic-lineage-guardrail-spec.md`); the runtime construct it defines is the Execution
Guardrail.

A **Lineage Execution** is a single-origin PIC execution in which every PCA continues exactly one predecessor and authority remains bounded
by the origin authority context. A complete PIC implementation secures each Lineage Execution — origin binding, Proof of Relationship at
every hop, non-expansion — so invalid authority cannot be propagated as a valid continuation: authority originating in one Lineage Execution
cannot be represented as a valid continuation of another. Physical executor behavior remains outside the protocol guarantee: a buggy,
compromised, or malicious executor can still act locally, but it cannot use PIC to command the next conforming executor beyond the authority
of its Lineage Execution.

An executor proposes a transition through a **Multi-Lineage Execution**: one or more independent Lineage Executions carried together for
one proposed transition, each retaining its own origin, PCA chain, authority context, and continuity. The participating authorities remain
distinct, and no new authority or lineage is created by their joint carriage. *Participation, not authority mixing.*

An **Execution Guardrail** is an externally configured runtime control at an execution boundary that evaluates the proposed transition of a
Multi-Lineage Execution against configured policy and permits or denies it. Guardrails do not make an invalid PCA valid, do not merge
authorities, and do not alter lineage invariants.

This revision establishes the concepts and the standard requirements notation shared by the PIC specification set. It also defines the
execution model — untrusted executors inside trusted sandboxes that invoke the guardrail — the guardrail envelope in which permitted
crossings travel, and the enforcement order over semantic scopes and configured policies (Sections 2–5); the normative guardrail
construction and enforcement requirements will be defined in forthcoming revisions. Guardrails build on the PCA format of the
[PIC Prover and Verifier Specification](./pic-prover-verifier-spec.md) and are consistent with the
[PIC Revocation Specification](./pic-revocation-spec.md); they do not alter non-expansion of the signed state, Proof of Relationship, or the
rule that every PCA continues exactly one predecessor. In case of conflict, the **PIC Specification** is authoritative.

## Table of Contents

- [PIC Execution Guardrail Specification](#pic-execution-guardrail-specification)
  - [Abstract](#abstract)
  - [Table of Contents](#table-of-contents)
  - [1. Introduction](#1-introduction)
    - [1.1 Lineage Execution and Execution Lineage Safety](#11-lineage-execution-and-execution-lineage-safety)
    - [1.2 Multi-Lineage Execution](#12-multi-lineage-execution)
    - [1.3 Execution Guardrails](#13-execution-guardrails)
    - [1.4 Requirements Notation](#14-requirements-notation)
  - [2. Execution Model](#2-execution-model)
    - [2.1 Executors: Deterministic and Non-Deterministic](#21-executors-deterministic-and-non-deterministic)
    - [2.2 The Invocation Problem](#22-the-invocation-problem)
    - [2.3 The Sandbox](#23-the-sandbox)
    - [2.4 Discrete Multi-Hop Execution](#24-discrete-multi-hop-execution)
    - [2.5 The Abstraction Step](#25-the-abstraction-step)
    - [2.6 Lineage Executions Through the Sandbox](#26-lineage-executions-through-the-sandbox)
    - [2.7 Model Summary](#27-model-summary)
  - [3. Guarded Crossings](#3-guarded-crossings)
    - [3.1 Input and Output](#31-input-and-output)
    - [3.2 Selection](#32-selection)
    - [3.3 The Guardrail Envelope](#33-the-guardrail-envelope)
    - [3.4 Sandbox Mode and Non-Sandbox Mode](#34-sandbox-mode-and-non-sandbox-mode)
    - [3.5 Architecture and Deployment Profiles](#35-architecture-and-deployment-profiles)
  - [4. Guardrail Enforcement](#4-guardrail-enforcement)
    - [4.1 Enforcement Order](#41-enforcement-order)
    - [4.2 Semantic Scopes](#42-semantic-scopes)
    - [4.3 Policies](#43-policies)
  - [5. Lineage Executions in Transit](#5-lineage-executions-in-transit)
  - [6. Contributors](#6-contributors)
  - [7. Legal Notices](#7-legal-notices)
  - [References](#references)

## 1. Introduction

This section is non-normative. It introduces the three concepts the rest of this specification builds on: the Lineage Execution, which PIC
secures; the Multi-Lineage Execution, which carries one or more Lineage Executions together for one proposed transition; and the Execution
Guardrail, which evaluates that proposed transition at an execution boundary:

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


MULTI-LINEAGE EXECUTION
-----------------------
n >= 1 Lineage Executions carried
together for one proposed transition

- constructed by the executor
- authorities remain separate
- no new authority or lineage is created


EXECUTION GUARDRAIL
-------------------
evaluates the proposed transition
at an execution boundary

- input: one Multi-Lineage Execution
- evaluate configured policy
- enforce permit or deny
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

These properties structurally eliminate the confused deputy from the PIC state model: authority from one Lineage Execution cannot appear
as a valid continuation of another. The claim is limited to valid PIC state and authority propagation; the physical boundary is stated
below. Distinct authorities may travel together in the same message or process; they remain logically distinct and are never merged. The formal definitions and proofs are in the PIC Model
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

The operational risk that remains — the physical behavior itself — is addressed by the guardrails of Section 1.3, enforced through the
execution model of Section 2.

### 1.2 Multi-Lineage Execution

> A **Multi-Lineage Execution** is an execution in which one or more independent Lineage Executions are carried together for one proposed
> transition, while each retains its own origin, PCA chain, authority context, and continuity.

A Multi-Lineage Execution is a runtime carrier: it carries n >= 1 distinct Lineage Executions, and it has no authority of its own. With
n = 1 it is simply a proposed transition under one Lineage Execution; with n >= 2 several authorities travel together. The name is
intentional: Multi-Lineage Execution names the uniform runtime carrier used at a guarded crossing, whether it carries one Lineage
Execution or several. The executor or calling system constructs it by selecting the participating Lineage Executions. The proposed
transition consists exclusively of the concrete signed requests carried by the participating Lineage Executions, together with their
declared participation context: a Multi-Lineage Execution introduces no additional request, executable authority, or unsigned action.

```text
one Lineage Execution
    -> one authority-propagation flow

Multi-Lineage Execution
    -> n >= 1 distinct Lineage Executions
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

### 1.3 Execution Guardrails

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

The guardrail evaluates a proposed transition represented as one Multi-Lineage Execution (Section 1.2), the single-lineage case included.
Within a single Lineage Execution,
authority states are already secured by execution lineage safety (Section 1.1); what the guardrail adds is the evaluation of the proposed
transition against configured policy.

```text
MULTI-LINEAGE EXECUTION (n >= 1)
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
Execution, which Lineage Executions are selected, and how they are intended to participate. The guardrail does not construct the proposal,
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
the configured policy. How crossings are carried and enforced is described in Sections 3 and 4; the formal requirements are deferred to
the normative sections of this specification.

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
| proposed action: WRITE-S3, the signed request of B |
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

Lineage Execution A authorizes `BACKUP`; Lineage Execution B authorizes `WRITE-S3`. B authorizes the external S3 write; A provides the
independently preserved `BACKUP` authority context that motivates the proposed transition. The agent proposed their joint participation; the
guardrail did not create that relationship and does not merge A and B. Configured policy determines whether the proposed transition is
permitted, the guardrail enforces permit or deny, and every externally relevant action remains attributable to a specific Lineage
Execution. Participation, not authority mixing.

### 1.4 Requirements Notation

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD", "SHOULD NOT", "RECOMMENDED", "NOT RECOMMENDED", "MAY", and
"OPTIONAL" are to be interpreted as described in BCP 14 [[2]](#references) [[3]](#references) when, and only when, they appear in all capitals,
and only within the normative sections of this document. Examples are illustrative and non-normative.

The normative guardrail construction and enforcement requirements will be defined in forthcoming revisions of this specification.

## 2. Execution Model

This section is non-normative. It defines the execution model — executor, sandbox, guardrail — and one point must be clear by its end:
the executor, deterministic or not, is never trusted to invoke its own control; the sandbox is.

### 2.1 Executors: Deterministic and Non-Deterministic

An executor belongs to one of two classes:

- a **deterministic executor** has behavior fixed by human-written code: given the same inputs and state, it performs the same operations;
- a **non-deterministic executor** has behavior not fixed by its implementation — an LLM, an AI agent, or any component whose next
  operation is a runtime decision.

When an operation is judged incorrect, the two classes name it differently, but it is the same phenomenon. In a deterministic executor it
is called a **bug**: the author acknowledges a design or implementation error. In a non-deterministic executor it is a **decision we did
not want**: there is no error to point to; the component chose. Both belong to the physics of execution — physical executor behavior in
the sense of Section 1.1, outside execution lineage safety, for PIC as for any security protocol. From the protocol's point of view the
two failure modes are operationally equivalent.

### 2.2 The Invocation Problem

Section 1 defined the Execution Guardrail but left one question open: who invokes it?

- If the executor's own code is responsible for calling the guardrail, a deterministic executor with a bug may simply never make the
  call: the control silently does not run.
- A non-deterministic executor may decide not to make the call — precisely because it does not want to be limited.

The flaw is the same in both cases: trusting the executor to invoke its own control is circular — the component whose behavior is in
question would be the enforcement point of its own limits. The invocation of the guardrail cannot live inside the executor.

### 2.3 The Sandbox

> A **sandbox** is a fixed, trusted execution boundary that encloses an executor. The executor has no path to governed external effect
> except through the boundary, and it is the sandbox — not the executor — that invokes the Execution Guardrail on every governed boundary
> crossing.

The sandbox is a trusted component: an explicit trust assumption of this specification, exactly as Verifier correctness is an explicit
trust assumption of the [PIC Prover and Verifier Specification](./pic-prover-verifier-spec.md). The gain is where the trust sits: it moves
from the behavior of the executor, unverifiable per Section 2.1, to the structure of the boundary — fixed, implementable, attestable. In
the execution model assumed by this specification, the sandbox is the only permitted path from the enclosed executor to a governed
external effect; an implementation that permits an unmediated governed external path from the executor does not satisfy this
execution-model assumption.

```text
+ - - - - - - - - - - - - - - - +
|  SANDBOX                      |
|                               |
|   +-----------------------+   |
|   |       EXECUTOR        |   |
|   | (deterministic /      |   |
|   |  non-deterministic)   |   |
|   +-----------------------+   |
|                               |
+ - - - - - - - - - - - - - - - +
```

This closes a gap Section 1.1 left open: a purely local physical action may be invisible to the protocol. Within the external-effect
channels governed by this execution model, an action that does not cross the sandbox boundary cannot produce an external effect through
those channels, and an action with such an effect necessarily crosses the boundary — and is therefore mediated. The claim stops there:
the sandbox does not make the executor behave correctly; it makes governed external effect impossible without mediation.

### 2.4 Discrete Multi-Hop Execution

Execution is discrete and multi-hop: a chain of sandboxed executors, each hop continuing the Lineage Execution under PoR and non-expansion
as defined by the [PIC Prover and Verifier Specification](./pic-prover-verifier-spec.md).

```text
+ - - - - - - - - +      + - - - - - - - - +      + - - - - - - - - +
|  SANDBOX        |      |  SANDBOX        |      |  SANDBOX        |
|  +-----------+  |      |  +-----------+  |      |  +-----------+  |
|  | EXECUTOR  |  |----->|  | EXECUTOR  |  |----->|  | EXECUTOR  |  |
|  +-----------+  | PoR  |  +-----------+  | PoR  |  +-----------+  |
+ - - - - - - - - +      + - - - - - - - - +      + - - - - - - - - +
```

### 2.5 The Abstraction Step

Whether the executor inside a sandbox is deterministic or non-deterministic does not matter. Bug or decision, the failure mode is the same
(Section 2.1); the invocation problem is the same (Section 2.2); the answer is the same (Section 2.3). The model therefore discards the
executor's nature and keeps only the invariant element: the sandbox is fixed, and the sandbox invokes the guardrail.

```text
+ - - - - - - - - - - - - - - - +
|  SANDBOX                      |
|                               |
|   +-----------------------+   |
|   |     ANY EXECUTOR      |   |
|   +-----------------------+   |
|                               |
+ - - - - - - - - - - - - - - - +

The sandbox is the fixed, trusted element.
The executor inside it is untrusted, whatever its nature.
The sandbox invokes the guardrail; the executor cannot skip it.
```

### 2.6 Lineage Executions Through the Sandbox

At each hop, a Multi-Lineage Execution (Section 1.2) enters, traverses, and leaves the sandbox. Every governed crossing passes through
the Execution Guardrail, which evaluates the proposed transition against configured policy (Section 1.3); the decision gates continuation.

```text
L1 ----+                                                      +----> L1'
       |    + - - - - - - - - +                               |
L2 ----+--->|     SANDBOX     |     +-------------+  permit   +----> L2'
       |    |  [ EXECUTOR ]   |---->|  GUARDRAIL  |-----------+
LN ----+    |                 |     +-------------+           +----> LN'
            + - - - - - - - - +            |
                                           | deny
                                           v
                                           X

Every governed external effect crosses the sandbox boundary.
Every governed crossing passes through the guardrail.
```

The decision verbs are those of Section 1.3: permit and deny. Richer runtime-control taxonomies are deferred to the normative sections of
this specification.

### 2.7 Model Summary

- **executor** — untrusted, deterministic or non-deterministic; the source of bugs and unwanted decisions;
- **sandbox** — fixed, trusted execution boundary; the only path to governed external effect; invokes the guardrail on every governed
  crossing;
- **Execution Guardrail** — evaluates every proposed crossing against configured policy (Section 1.3); permits or denies;
- **Lineage Executions** — the secured authority inputs and outputs of each hop (Sections 1.1, 1.2); never merged, and every externally
  relevant action keeps an authorizing Lineage Execution.

With the model in place, Section 3 describes how crossings are carried and Section 4 how the guardrail enforces them; the formal
requirements remain deferred to the normative sections.

## 3. Guarded Crossings

This section is non-normative. It describes how Lineage Executions reach a hop, how the executor selects the ones that continue, and how
the next hop knows that a crossing was guarded.

### 3.1 Input and Output

At each hop the sandbox receives a Multi-Lineage Execution as input and emits a Multi-Lineage Execution as output — n >= 1 on both sides.
No new machinery is required for PCA validity: each PCA remains subject to the
[PIC Prover and Verifier Specification](./pic-prover-verifier-spec.md), and an invalid PCA is rejected by a conforming PIC Verifier
function. What sandbox mode adds is a guarded-crossing acceptance requirement through the guardrail envelope (Sections 3.3 and 3.4),
without changing PCA validity, PoR, or non-expansion. What this specification governs is the proposed output crossing presented to the
successor hop: it may carry several independently attributable Lineage Executions, and it does not become a combined authority state.
That is what must pass through the guardrail.

### 3.2 Selection

The Lineage Executions of the output come from two sources:

- the **input**: Lineage Executions that entered the hop;
- the **environment**: authorities available at the hop, including origins the executor mints as a permissioned entity of its own
  (Section 1.3, canonical example).

Which ones the executor selects cannot be dictated from outside. A deterministic executor with a bug departs from any instruction; a
non-deterministic executor may simply choose otherwise (Section 2.1) — and either way the result would still need verification. The model
therefore does not force the selection: the executor selects freely, the sandbox guarantees that the selection reaches the guardrail
(Section 2.3), and the guardrail decides whether it may cross. The division of responsibility is exact: the executor constructs the
proposed transition and selects its participating Lineage Executions; the sandbox captures the resulting crossing and presents the
Multi-Lineage Execution to the Execution Guardrail.

```text
INPUT (n >= 1)              ENVIRONMENT
Multi-Lineage Execution     authorities at the hop
        |                        |
        v                        v
+ - - - - - - - - - - - - - - - - - - - +
|  SANDBOX                              |
|                                       |
|   the executor freely selects the     |
|   Lineage Executions of the output    |
|                                       |
+ - - - - - - - - - - - - - - - - - - - +
                    |
                    | proposed output:
                    | Multi-Lineage Execution (n >= 1)
                    v
             +-------------+
             |  GUARDRAIL  |
             +-------------+
```

### 3.3 The Guardrail Envelope

One question remains: the successor receives Lineage Executions — how does it know they passed through a guardrail? Because a permitted
crossing is delivered in a **guardrail envelope**: an envelope, signed by the guardrail, carrying the validated Lineage Executions of the
crossing. It follows the forwarding-envelope pattern of the
[PIC Prover and Verifier Specification](./pic-prover-verifier-spec.md) (Section 2.5), but it is issued by the guardrail and binds the
guardrail decision to the crossing context defined by the applicable profile; the normative profile defines which crossing elements are
bound, including any required destination, action, participant, freshness, or replay-protection information.

The guardrail signing capability lies outside the executor's reach and within the trust domain of the sandbox and guardrail enforcement
components; an executor that can access or invoke it independently of the enforced guardrail decision violates this trust assumption.

The envelope is what defeats bypass. An attacker that escapes a sandbox, or skips it entirely, can still call the next hop directly; the
call arrives without an envelope, with an envelope that does not validate, or with one not signed by a guardrail authority the receiver
recognizes — and the receiving hop rejects it. As with invalid authority in Section 1.1, the failure is not prevented at the faulty hop;
it is blocked at the next conforming one.

```text
GUARDED PATH

+-------------+   permit + sign   +------------------------------+
|  GUARDRAIL  |------------------>|  GUARDRAIL ENVELOPE          |
+-------------+                   |  [ L1' ... LN' ] validated   |
                                  +------------------------------+
                                                 |
                                                 v
                                           EXECUTOR N+1
                                accepts: the envelope is signed by
                                a recognized guardrail authority


BYPASS ATTEMPT

ATTACKER ---- direct call, no envelope ---->  EXECUTOR N+1
                                              rejects the crossing
```

For a target that does not validate guardrail envelopes — a conventional storage or network service — the sandbox is responsible for
materializing or forwarding exactly the crossing permitted by the guardrail, without returning control of that crossing to the executor:
the action, destination, participants, and other context bound to the permit decision are not replaceable by the executor after the
decision. For a PIC-aware successor, the envelope itself provides this binding.

```text
guardrail permits action X          not:   guardrail permits action X
        |                                          |
        v                                          v
sandbox performs or                        executor substitutes action Y
forwards action X
```

How guardrail authorities are established and recognized — key generation, storage, attestation, rotation, revocation, and algorithm
selection — is defined in the normative sections of this specification.

### 3.4 Sandbox Mode and Non-Sandbox Mode

A PIC-compliant hop may operate in **sandbox mode** or in **non-sandbox mode**. In sandbox mode the hop accepts only guarded crossings: a
valid guardrail envelope is required, plain PCA delivery is insufficient, and bypass attempts are rejected (Section 3.3). In non-sandbox
mode the hop may accept a plain PCA, as defined by the [PIC Prover and Verifier Specification](./pic-prover-verifier-spec.md): PCA
validity, PoR, origin binding, and non-expansion remain enforced, but guardrail enforcement is not required for that crossing and the
envelope bypass guarantee does not apply.

```text
SANDBOX MODE                          NON-SANDBOX MODE
------------                          ----------------
guardrail envelope required           plain PCA accepted, per the
plain PCA insufficient                Prover and Verifier Specification
bypass rejected                       baseline PIC enforcement only
guarded-crossing enforcement          no guarded-crossing claim
```

The bypass resistance provided by guardrail envelopes applies only across topology segments in which receiving hops require sandbox mode.
A non-sandbox hop intentionally preserves baseline PIC interoperability without claiming guarded-crossing enforcement: a deployment choice
with a weaker enforcement profile, not a defect.

### 3.5 Architecture and Deployment Profiles

Deployments select the mode per topology segment, following its trust and risk characteristics:

```text
TRUSTED OR CONTROLLED SEGMENT          UNTRUSTED OR HIGH-RISK SEGMENT
-----------------------------          ------------------------------
baseline PIC validation                sandbox mediation and guardrail
may be sufficient                      envelopes provide runtime
                                       transition enforcement
non-sandbox mode may be
selected when guarded                  sandbox mode is used
execution is not required
```

Higher-risk executors include AI agents, third-party workloads, plugin or tool execution, user-supplied code, partially trusted services,
and components outside the operator's administrative domain; deterministic internal software is not automatically trusted. The selection
is an architecture and deployment decision: trust boundary, threat model, required assurance, executor control, external-effect risk, and
interoperability requirements.

> PIC defines authority validity independently of deployment mode. Architecture and deployment determine where Execution Guardrails are
> required in addition to baseline PIC validation.

Guidance for selecting sandbox mode, non-sandbox mode, and mixed deployment profiles is defined by the
[PIC Architecture and Deployment Specification](./pic-architecture-deployment-spec.md).

## 4. Guardrail Enforcement

This section is non-normative. It describes the enforcement logic of the guardrail: validation first, then policy, then the enforced
decision.

### 4.1 Enforcement Order

The guardrail enforces a proposed crossing in a fixed order:

1. **validate** — before policy evaluation, each participating PCA is validated by a conforming PIC Verifier function
   ([PIC Prover and Verifier Specification](./pic-prover-verifier-spec.md)); if any is invalid, deny is enforced without evaluating policy;
2. **evaluate** — the configured policy is evaluated over the participating Lineage Executions;
3. **enforce** — the decision, permit or deny, is enforced at the boundary (Section 1.3).

```text
proposed crossing
        |
        v
validate every PCA ---- any invalid ----> enforce deny
        |
    all valid
        |
        v
evaluate configured policy
        |
        v
enforce permit / deny
```

The Verifier function may be integrated into the guardrail implementation or invoked as a separate component; the architectural packaging
is an implementation choice, and policy evaluation cannot override PIC invalidity.

```text
PIC VERIFIER FUNCTION
determines whether each PCA and continuation is valid

POLICY EVALUATION
determines whether the proposed crossing is permitted

EXECUTION GUARDRAIL
enforces the resulting permit or deny decision
```

The executed-vs-signed rule of the [PIC Prover and Verifier Specification](./pic-prover-verifier-spec.md) (Section 3.3) applies per
participating Lineage Execution: each executed operation must match the signed request of its own Lineage Execution and remains attributed
to it. Policy authorizes joint participation only; it does not compose the authority sets into a common one.

### 4.2 Semantic Scopes

Each Lineage Execution is tagged with **semantic scopes**: labels that describe the semantics of the authority it carries. A scope adds no
authority — the operations a Lineage Execution can authorize remain those of its PCAs, and non-expansion is untouched; scopes exist only
to inform the guardrail decision. The scope vocabulary is defined by policy governance (Section 1.3).

A semantic scope used in a guardrail decision must be bound to its Lineage Execution by a mechanism that is not under the unilateral
control of the executor whose crossing is being evaluated: an executor may propose a semantic claim, but an untrusted executor's claim
alone is not sufficient for policy enforcement. Accepted binding sources — origin-bound metadata, signed declarations, trusted derivation,
policy-controlled mapping, or attested execution context — are defined in the normative sections of this specification.

```text
LINEAGE EXECUTION A        LINEAGE EXECUTION B        LINEAGE EXECUTION C
PCA1-A { BACKUP }          PCA0-B { WRITE-S3 }        PCA0-C { SHARE-PUBLIC }
scope: data-protection     scope: data-protection     scope: external-sharing
```

### 4.3 Policies

A policy is a rule over the scopes of the participating Lineage Executions: it expresses which semantic combinations may cross together.
Whoever defines the policies defines how the semantics may combine; the guardrail enforces it (Section 1.3). A policy carries an
effect and a condition — the condition is an expression over the participants and their scopes — and the decision defaults to deny: a
crossing is permitted only if the condition of an applicable permit policy holds. An illustrative policy, with a CEL-like condition:

```json
{
  "id": "policy-backup-pipeline-01",
  "effect": "permit",
  "appliesTo": { "crossing": "*" },
  "when": "participants.all(l, 'data-protection' in l.scopes || 'ai-compliance' in l.scopes)"
}
```

Against the scopes of Section 4.2:

```text
PROPOSED CROSSING 1: A + B

A.scopes = [ data-protection ]     condition: true
B.scopes = [ data-protection ]     condition: true

every participant satisfies the condition   -> enforce permit


PROPOSED CROSSING 2: A + C

A.scopes = [ data-protection ]     condition: true
C.scopes = [ external-sharing ]    condition: false

C does not satisfy the condition            -> enforce deny
```

The policy language, the scope vocabulary, and how scopes are bound to a Lineage Execution are defined in the normative sections of this
specification; the example — including its CEL-like condition language — is illustrative only.

## 5. Lineage Executions in Transit

This section is non-normative. It closes the conceptual model.

A crossing is an execution in transit: it may happen in process, across a network, or over any other medium. The transport does not
matter — the [PIC Prover and Verifier Specification](./pic-prover-verifier-spec.md) already separates the security model from transport,
and this specification inherits that separation. In a guarded crossing, what travels is the guardrail envelope, and inside it travel the
Lineage Executions of the crossing: bound together, never merged.

```text
HOP N                                                            HOP N+1

GUARDRAIL                                                        VERIFIER
    |                                                               ^
    |     +----------------------------------------------+          |
    +---->| GUARDRAIL ENVELOPE                           |----------+
          | [ L1 | L2 | ... | LN ]  bound, never merged  |
          +----------------------------------------------+

          ------ in process | network | any medium ------
```

The originating guardrail validates the proposed crossing before issuing the envelope; the receiving hop validates the envelope and
performs the PIC validation required by its acceptance profile (Section 3.4).

PIC does not represent authority from several Lineage Executions as one lineage authority state: a successor PCA cannot import or merge
authority, and that prohibition is what eliminates the confused deputy by construction (Section 1.1). The execution model may carry
several independent Lineage Executions together for one crossing without changing any of them: each remains separately attributable, the
guardrail evaluates the proposed crossing, and no combined authority state is created. Multi-Lineage Execution belongs to the
execution-control model, not to the PIC authority-state model: if several authorities were represented as one valid PCA state, PIC's
origin-bounded lineage guarantee would be lost; carrying them separately preserves that guarantee.

```text
INSIDE EACH LINEAGE EXECUTION          AT A GUARDED CROSSING
-----------------------------          ---------------------
one origin authority context           one or more independent
PoR continuity                         Lineage Executions carried together
authority only narrows                 each remains separately attributable
no authority imported from             the guardrail evaluates the crossing
another Lineage Execution              no combined authority state is created
```

This closes the conceptual model of this revision; the normative sections define the representations and the enforcement requirements.

## 6. Contributors

The editors and contributors of this document are listed in the **document header** above. Listing is governed by Appendix B.7 of the
[PIC Legal Appendices](./pic-legal.md).

## 7. Legal Notices

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
