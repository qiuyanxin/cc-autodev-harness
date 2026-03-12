# Design Principles

Core design principles governing scaffold generation. Reference this during Phase 3 and Phase 4.

1. **Templates are generation instructions, not string interpolation** — Each template contains structural skeletons, `{{placeholder}}` markers, and comments explaining what to fill and why
2. **Progressive loading** — Only read reference files when the corresponding phase/module needs them
3. **Domain knowledge first** — Phase 1 collects real knowledge before any file generation happens
4. **Proven patterns** — All templates derive from battle-tested writing-workflow plugins
5. **Skip-friendly** — Every gap category can be skipped with TODO markers, generating a valid but incomplete scaffold
6. **Progressive maturity** — Start from L0 Seed, upgrade to higher levels on demand. Avoid premature abstraction.
7. **Script deterministic operations** — Repeated file operations, data transforms, and git operations belong in scripts/, not inline text instructions
8. **Share over duplicate** — Cross-skill shared knowledge goes to shared/ directory, referenced by path. Never copy identical content into multiple skills.
9. **Anti-pattern defense** — Phase 4 checks generated output against known anti-patterns before delivery
