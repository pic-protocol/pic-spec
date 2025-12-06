# **PIC SPEC**

**Version:** 0.1 (Draft)  
**Date:** 2025-12-06  
**Author:** PIC Protocol Contributors  
**Source:** [github.com/pic-protocol/pic-spec](https://github.com/pic-protocol/pic-spec)  
**License:** CC BY 4.0

---

## 1. Introduction

This specification originates from the formalization presented in **"Authority Propagation Models: PoP vs PoC and the Confused Deputy Problem"** [1],
which demonstrates that the confused deputy problem is formally impossible in any execution model satisfying **Provenance Identity Continuity (PIC)**.

As described in **“PIC Model — Provenance Identity Continuity for Distributed Execution Systems”** [2], the PIC Model is grounded in the **Executor-First
Paradigm**, which holds that identity is not a property embedded in static credentials or artifacts, but an emergent invariant of the execution state
and its verifiable causal origin.

The **Provenance Identity Continuity (PIC) Model** specifies the invariants that identity **MUST** satisfy across a complete multi-hop causal execution.
Accordingly, artifact possession is replaced by **execution provenance** as the sole continuity anchor.

Each execution hop **MUST** be treated as part of a verifiable distributed transaction that binds the executor to its causal predecessor. This binding
prevents detachment, impersonation, replay, and unintended authority inheritance commonly observed in token-based and credential-centric systems.

Because continuity is derived from provenance rather than possession, the model supports both identity-centric execution flows and anonymous
capability-based flows. These flows reduce identity leakage, prevent impersonation via transferable credentials, and limit cross-domain replay
vectors while preserving full causal verifiability.

Anonymous capability-based flows are inherently privacy-preserving in multi-hop environments, as they preserve continuity through **Proof of
Continuity** rather than **Proof of Possession**, without exposing identity.

The PIC Model therefore establishes the following **Structural Impossibility Claim (NO-GO Result)**: within any PIC-compliant execution model, the confused
deputy problem cannot arise as a valid execution state.

## 1.1 Normative Language

The key words **MUST**, **MUST NOT**, **REQUIRED**, **SHALL**, **SHALL NOT**, **SHOULD**, **SHOULD NOT**, **RECOMMENDED**, **MAY**, and **OPTIONAL**
in this document are to be interpreted as described in RFC 2119 and RFC 8174 when, and only when, they appear in all capitals.

The following definitions are normative for this specification.

**Identity**  
An invariant attribution of an execution to a specific origin.
In this specification, identity is not an input to authorization decisions
nor a policy parameter; it serves to anchor authority and provenance across
execution boundaries.

**Authority**  
The set of permissible actions associated with an execution context.
Authority may be derived or constrained, but it **MUST** be explicitly
propagated and **MUST NOT** be assumed implicitly from identity alone.

**Provenance**  
The ordered and non-forgeable history of execution contexts and authority
propagations that led to a given execution state.

**Provenance Identity Continuity (PIC)**  
An execution-model invariant in which identity, authority, and provenance
remain continuously bound across all execution boundaries.
In a PIC-compliant model, authority **MUST NOT** be introduced, substituted,
or amplified without preserving identity and provenance continuity.

**PIC-Compliant Execution Model**  
An execution model that satisfies Provenance Identity Continuity.
In such models, the confused deputy problem is structurally impossible and
cannot arise as a valid execution state.

## Architecture

xxxx

---

## Appendix A. Use of Automated Language Assistance

The authors have used automated language assistance tools solely to improve grammar, clarity, and phrasing.
All substantive technical content, including the conceptual model, formal results, and proofs, is the exclusive work of the authors.

## References

- [1] Gallo, N. (2025). Authority Propagation Models: PoP vs PoC and the Confused Deputy Problem. Zenodo. [doi.org/10.5281/zenodo.17833000](https://doi.org/10.5281/zenodo.17833000)
- [1] Gallo, N. (2025). PIC Model — Provenance Identity Continuity for Distributed Execution Systems (0.1-draft). Zenodo. [doi.org/10.5281/zenodo.17777421](https://doi.org/10.5281/zenodo.17777421)
