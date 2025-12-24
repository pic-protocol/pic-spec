# **PIC AI AGENTS SPEC**

**Version:** 0.1 (Draft)  
**Status**: Draft – Not a Standard  
**Date:** 2025-12-06  
**Source:** https://github.com/pic-protocol/pic-spec/draft/0.1/pic-ai-agents-spec.md

---

## Abstract

This specification extends the **Provenance Identity Continuity (PIC) Model** to distributed execution environments involving **human users and AI agents operating as peer-level participants within a shared execution space**.

Contemporary digital identity systems primarily address authentication and initial authorization through wallets, credentials, and token-based mechanisms. While effective for establishing identity and enabling execution entry, these systems do not define how **authority is composed, constrained, and preserved throughout a distributed, multi-hop execution**, particularly when AI agents autonomously act on behalf of humans across devices, execution contexts, and administrative domains.

This document formalizes a separation between **identity**, **authentication**, and **authority**. Authority is modeled not as a function of identity possession, role, or credential transfer, but as a **causally derived property of execution**, enforced through Provenance Identity Continuity invariants. Within this model, humans and AI agents may authenticate using different mechanisms, but they participate under identical authority semantics governed by causal continuity.

By treating authority as an explicit, execution-bound relation rather than a transferable artifact, this specification addresses structural authority diversion risks, including confused deputy scenarios, that arise in agent-mediated execution flows. Wallets and existing identity systems remain valid mechanisms for identity and execution entry, but are insufficient on their own to ensure safe authority propagation in long-running or delegated executions involving AI agents.

---

## Table of Contents

1. [Introduction](#1-introduction)  
A. [Use of Automated Language Assistance](#appendix-a--use-of-automated-language-assistance)  
B. [Authorship, Stewardship, Attribution, and Derivative Works](#appendix-b--authorship-stewardship-attribution-and-derivative-works)
C. [Disclaimer and Limitation of Liability](#appendix-c--disclaimer-and-limitation-of-liability)  

---

## 1 Introduction

The adoption of AI agents as autonomous or semi-autonomous executors introduces new execution patterns in which actions are initiated by humans, delegated to agents, and completed across multiple devices, execution contexts, and third-party systems.

In these environments, humans and AI agents operate within a single distributed execution, yet are often authenticated through different identity technologies (e.g., OIDC, OAuth, Verifiable Credentials, SAML, SPIFFE). Authentication alone, however, does not define how authority is safely exercised once execution has begun.

A common architectural assumption is that wallets, credentials, or delegated tokens are sufficient to safely transfer authority across execution boundaries. This assumption leads to execution models in which authority is implicitly inferred from identity or possession and is passed across hops as artifacts. Such models permit authority detachment and reinterpretation during execution and are therefore vulnerable to confused deputy scenarios by construction.

```text
+------------------------------------------------------+
|                  HUMAN AND AI AGENTS                 |
|  (humans, services, AI copilots, background agents)  |
+------------------------------------------------------+
|              ONTOLOGY / RELATIONSHIPS                |
|  (links between human and non-human identities)      |
+------------------------------------------------------+
|                      AUTHORITY                       |
|   (how authority is composed before execution)       |
+------------------------------------------------------+
|                         PIC                          |
|   Provenance Identity Continuity across all hops     |
+------------------------------------------------------+
|             TRANSPORT / MESSAGING LAYER              |
|   HTTP / gRPC / messaging buses      TCP / UDP       |
+------------------------------------------------------+
```

This specification adopts the PIC Model’s foundational principle that **authority is not inferred from identity, role, or possession**, but is instead **derived exclusively through verified causal continuity across execution hops**. Under this model:

- Humans and AI agents are treated as **execution-level peers**, not as separate authority classes.
- Wallets and identity systems establish **entry conditions** for execution, but do not propagate authority.
- Authority must be **explicitly composed prior to execution** and is preserved only through valid causal transitions.
- No execution hop may introduce, expand, or reinterpret authority not present at the origin of the distributed transaction.

By modeling authority as a causal relation over execution rather than as an attribute of identities or tokens, the PIC AI Agents model eliminates confused deputy scenarios by construction. Authority cannot be diverted, replayed, or substituted during execution, regardless of how many intermediaries, agents, or devices participate.

This specification does not replace existing identity frameworks, wallets, or regulatory regimes. Instead, it provides an execution-level foundation in which legal, regulatory, and policy constraints can be enforced as part of the execution protocol itself. Identity systems remain responsible for authentication and entry, while PIC governs authority continuity once execution begins.

---

## Appendix A. Use of Automated Language Assistance

The PIC Specification has used automated language assistance tools solely to improve grammar, clarity, and phrasing. All substantive technical content and editorial decisions remain the responsibility of the PIC Spec Contributors under the stewardship of Nitro Agility S.r.l.

---

## Appendix B. Authorship, Stewardship, Attribution, and Derivative Works

### B.1 Scope and Roles

This appendix defines the separation between:

- the **PIC Model** (theoretical framework and foundational results), and
- the **PIC Specification** (this document: terminology, normative requirements, structure, examples, and maintenance process).

This separation is intentional and MUST be preserved in references, derivative works, and claims of conformance.

---

### B.2 PIC Model — Authorship (Theoretical Framework)

The **Provenance Identity Continuity (PIC) Model**, including its formal definitions, invariants, execution semantics, and foundational proofs (including the structural resolution of the confused deputy class under the PIC assumptions), originates from the original theoretical work of **Nicola Gallo**.

Authorship of the PIC Model is independent of repository ownership, maintainer status, stewardship of the specification, or any publishing entity.

Primary references for the PIC Model include:

- Gallo, N. (2025). *Authority Propagation Models: PoP vs PoC and the Confused Deputy Problem*. Zenodo. DOI: 10.5281/zenodo.17833000  
- Gallo, N. (2025). *Authority is a Continuous System*. Zenodo. DOI: 10.5281/zenodo.17860199  
- Gallo, N. (2025). *PIC Model — Provenance Identity Continuity for Distributed Execution Systems*. Zenodo. DOI: 10.5281/zenodo.17777421  

---

### B.3 PIC Specification — Stewardship, Publication, and Canonical Status

This document (the **PIC Specification**) is authored, developed, published, maintained, and stewarded by:

**Nitro Agility S.r.l.** (the “Specification Steward”)

All normative text of this PIC Specification — including structure, terminology, requirements, examples, editorial content, and all subsequent edits incorporated into the canonical version — is produced and maintained under the stewardship of Nitro Agility S.r.l.

The Specification Steward is responsible for:

- publication and maintenance of the PIC Specification,
- editorial decisions and normative text,
- contribution review and acceptance,
- release management and designation of canonical versions,
- specification governance and process.

The canonical PIC Specification is the version designated by the Specification Steward in the official PIC Spec repositories.

---

### B.4 License

The PIC Model references and this PIC Specification are published under the **Creative Commons Attribution 4.0 International (CC BY 4.0)** license.

CC BY 4.0 governs copyright and redistribution only.  
It does not imply any warranty, support obligation, operational responsibility, or professional services.

---

### B.5 Mandatory Attribution and Correct Referencing

Any academic, technical, or commercial work that references, implements, or claims conformance with PIC MUST clearly distinguish between:

1. **The PIC Model (theoretical framework)**  
   **Author:** Nicola Gallo

2. **The PIC Specification (this document)**  
   **Publisher and Steward:** Nitro Agility S.r.l.

A compliant reference MUST acknowledge both roles.

**Example attribution (acceptable):**

> “Based on the Provenance Identity Continuity (PIC) Model created by Nicola Gallo.  
> Conforms to the PIC Specification published and maintained by Nitro Agility S.r.l.”

Attribution MUST NOT:

- omit the PIC Model author when referencing the PIC Model, or
- attribute the PIC Model’s foundational concepts and proofs to parties other than its author, or
- represent a fork or derivative as the canonical PIC Specification without Steward designation.

---

### B.6 Derivative Works, Forks, and Implementations

Derivative works (modified specifications, extensions, profiles, or adaptations):

- MUST clearly state they are **derivative works** of the PIC Specification,
- MUST preserve the attribution requirements in B.5,
- SHOULD document any substantive semantic or security-relevant changes,
- MUST NOT claim to be the canonical PIC Specification unless explicitly designated by the Specification Steward.

Implementations (software libraries, SDKs, middleware, gateways, services):

- MAY claim authorship of the implementation code,
- MUST NOT claim authorship of the PIC Model’s foundational concepts, invariants, or proofs.

---

### B.7 Contributors and Responsibility Boundaries

#### B.7.1 PIC Spec Contributors

“PIC Spec Contributors” are individuals or organizations that contribute text, reviews, examples, or discussion to the PIC Specification repositories.

Contributions by **Nicola Gallo**, **Antonio Radesca**, and **any other employee, associate, contractor, or co-founder of Nitro Agility S.r.l.** to the PIC Specification are made **on behalf of Nitro Agility S.r.l.**, and **not in a personal capacity**. All such contributions are incorporated as part of the Nitro Agility–stewarded specification.

For avoidance of doubt: where Nicola Gallo contributes to the PIC Specification repositories, he does so as a representative of Nitro Agility S.r.l. for purposes of the specification text and its maintenance. This does not alter or diminish his independent authorship of the underlying **PIC Model**.

**Contribution does not imply:**

- authorship of the PIC Model, or
- acceptance of operational responsibility, warranty, or liability for the PIC Specification.

The Specification Steward (Nitro Agility S.r.l.) retains full editorial and governance control over what becomes normative in the PIC Specification.

#### B.7.2 External Contributors

External contributors (i.e., contributors not acting on behalf of Nitro Agility S.r.l.) contribute on an “as-is” basis.

External contributors:

- do not become stewards, publishers, or operators by contributing,
- do not provide warranties or professional advice,
- are not responsible for maintenance, release management, or governance of the PIC Specification.

Operational and editorial responsibility for the PIC Specification remains with the Specification Steward.

---

### B.8 Credits

**PIC Model Author (Theoretical Framework):**

- **Nicola Gallo** (in personal capacity)

**PIC Specification Steward / Publisher:**

- **Nitro Agility S.r.l.**

**PIC Spec Contributors (non-exhaustive, in order of appearance):**

1. **Nicola Gallo (on behalf of Nitro Agility S.r.l.)** — contributor to specification text and examples  
2. **Nitro Agility S.r.l.** — specification stewardship, editorial maintenance, governance  
3. *Add your name here via pull request (individual or organization)*

---

### B.9 Stewardship Transfer

Stewardship of the PIC Specification MAY be transferred by Nitro Agility S.r.l. to another organization.

Such a transfer does not affect:

- authorship of the PIC Model (Nicola Gallo),
- the CC BY 4.0 license terms,
- the attribution requirements defined in this appendix.

The new steward (if any) becomes the Specification Steward for canonical designation and maintenance of the PIC Specification.

---

## Appendix C. Disclaimer and Limitation of Liability

THIS SPECIFICATION IS PROVIDED **"AS IS" AND "AS AVAILABLE"**, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, TITLE, AND NON-INFRINGEMENT.

THIS SPECIFICATION **DOES NOT GUARANTEE SECURITY, CORRECTNESS, OR FITNESS FOR ANY PARTICULAR IMPLEMENTATION OR DEPLOYMENT CONTEXT**.  
SECURITY, SAFETY, AND CORRECT BEHAVIOR DEPEND ENTIRELY ON PROPER IMPLEMENTATION, CONFIGURATION, AND OPERATION.

IN NO EVENT SHALL THE AUTHORS, CONTRIBUTORS, ACKNOWLEDGED INDIVIDUALS, OR COPYRIGHT HOLDERS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, CONSEQUENTIAL, OR PUNITIVE DAMAGES (INCLUDING BUT NOT LIMITED TO PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES, LOSS OF USE, DATA, PROFITS, OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SPECIFICATION, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

USE OF THIS SPECIFICATION, INCLUDING ANY CLAIMS OF CONFORMANCE OR COMPATIBILITY, **DOES NOT IMPLY ENDORSEMENT** BY THE AUTHORS OR PIC SPEC CONTRIBUTORS UNLESS EXPLICITLY STATED IN WRITING.

IMPLEMENTERS AND USERS ASSUME **ALL RISKS** ASSOCIATED WITH THE USE OF THIS SPECIFICATION AND ANY IMPLEMENTATIONS OR DERIVATIVE WORKS BASED UPON IT.

THIS DISCLAIMER SHALL BE GOVERNED BY AND CONSTRUED IN ACCORDANCE WITH APPLICABLE LAW, WITHOUT REGARD TO CONFLICT OF LAW PRINCIPLES.

IF ANY PROVISION OF THIS DISCLAIMER IS HELD TO BE UNENFORCEABLE, THE REMAINING PROVISIONS SHALL CONTINUE IN FULL FORCE AND EFFECT.

THE AUTHORS AND CONTRIBUTORS HAVE NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, PATCHES, OR CORRECTIONS.

THIS SPECIFICATION DOES NOT CONSTITUTE LEGAL, SECURITY, OR PROFESSIONAL ADVICE.

### Responsibility and Legal Context

This specification is published and maintained by **Nitro Agility S.r.l.** as the **Specification Steward**.

Nothing in this document creates a contractual relationship between any **individual contributor** and any user of this specification.  
No duty of care is assumed or created by publication of this document.

To the **maximum extent permitted by applicable law**, any claims, disputes, or legal actions arising from:

- the use of this specification,
- any claim of conformance, compatibility, or derivation from PIC,
- any implementation, deployment, product, or service that references or relies on this specification,

should be directed to the **Specification Steward (Nitro Agility S.r.l.)** and/or the relevant **implementer**, as applicable.

For avoidance of doubt, implementers and operators remain solely responsible for their own implementations, deployments, products, services, security, and compliance claims.

### Exclusion of Personal Liability (PIC Model Author)

**Nicola Gallo**, as the author of the underlying **PIC Model** (theoretical framework), is recognized solely for **academic authorship** of that theoretical work.

This recognition does **not**:

- create any personal liability for this specification or its use,
- create any warranty, support, maintenance, or professional services obligation,
- create any contractual, fiduciary, advisory, or professional relationship with users,
- constitute endorsement of this specification or of any implementation or deployment.

To the maximum extent permitted by applicable law, **Nicola Gallo** disclaims all liability for any loss or damages arising from the use of this specification or from any implementation, deployment, product, or service based on it.

The PIC Model author’s role is strictly limited to authorship of academic publications referenced by this specification.  
All operational, legal, and commercial responsibility for this specification rests with the **Specification Steward (Nitro Agility S.r.l.)**, and for implementations with their respective **implementers/operators**.

---

## References

- [1] Gallo, N. (2025). *Authority Propagation Models: PoP vs PoC and the Confused Deputy Problem*. Zenodo. [doi.org/10.5281/zenodo.17833000](https://doi.org/10.5281/zenodo.17833000)
- [2] Gallo, N. (2025). *PIC Model — Provenance Identity Continuity for Distributed Execution Systems (0.1-draft)*. Zenodo. [doi.org/10.5281/zenodo.17777421](https://doi.org/10.5281/zenodo.17777421)
- [3] Gallo, N. (2025). *Authority is a Continuous System. (0.1-draft)*. Zenodo. [doi.org/10.5281/zenodo.17860199](https://doi.org/10.5281/zenodo.17860199)
