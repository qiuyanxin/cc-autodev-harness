# Brand Configuration Template

The brand system enables persona/voice switching across workflow outputs. Each brand is a markdown file defining voice, style, and content boundaries.

**Source pattern:** `chinese-viral-writer/brands/_template.md`

---

## Template

Generate at: `{output_path}/{skill-name}/brands/_template.md`

````markdown
# Brand Configuration Template / 品牌配置模板

> Copy this file and rename to your brand config, e.g. `my-brand.md`

---

## Brand Basics

| Field | Value |
|-------|-------|
| **Brand Name** | [Brand/persona name] |
| **Brand Type** | [Corporate / Personal IP / Institutional] |
| **Industry** | [e.g. {{domain}}] |
| **Target Audience** | [Core audience description] |

### Brand Positioning

> One sentence describing the core brand positioning

[Example: {{positioning_example}}]

### Brand Mission

> Core values and long-term goals

[Fill in]

---

## Brand Voice

### Language Style

| Dimension | Description |
|-----------|------------|
| **Formality** | [Very formal / Formal / Semi-formal / Casual / Very casual] |
| **Expertise** | [Deep expert / Expert accessible / Educational / General] |
| **Warmth** | [Authoritative distance / Expert friend / Close friend / Neighborly] |

### Writing Characteristics

- **Sentence preference**: [Long / Short / Mixed]
- **Vocabulary**: [Academic / Conversational / Internet slang / Mixed]
- **Punctuation**: [Emoji usage / Special symbols / Standard only]
- **Person**: [First person "I" / "We" / Direct "you"]

### Emotional Tone

- **Primary tone**: [Rational / Warm / Humorous / Motivational / Direct]
- **Emotion range**: [Emotions that can be expressed]
- **Emotion boundaries**: [Emotions to avoid]

### Signature Expressions

> Brand-specific catchphrases or patterns

- [Example: greeting pattern]
- [Example: closing pattern]

---

## Content Boundaries

### Allowed Content (Do's)

- [ ] [Content type 1]
- [ ] [Content type 2]
- [ ] [Content type 3]

### Prohibited Content (Don'ts)

- [ ] [Prohibited type 1]
- [ ] [Prohibited type 2]
- [ ] [Prohibited type 3]

### Sensitive Topics

| Topic | Handling |
|-------|---------|
| Competitor comparisons | [OK / Careful / Prohibited] |
| Pricing | [OK / Careful / Prohibited] |
| Industry criticism | [OK / Careful / Prohibited] |
| Trend-chasing | [OK / Careful / Prohibited] |

---

{{#if has_social_accounts}}
## Social Media Accounts

> Used for auto-generating CTAs at article endings. Leave blank to skip.

| Platform | Field | Value |
|----------|-------|-------|
{{#each platforms}}
| **{{name}}** | Handle | [e.g. @handle] |
| **{{name}}** | Display Name | [e.g. Display Name] |
| **{{name}}** | URL | [e.g. https://...] |
{{/each}}
{{/if}}

---

## Brand Consistency Checklist

### Must Match

1. [Critical checkpoint 1]
2. [Critical checkpoint 2]
3. [Critical checkpoint 3]

### Should Match

1. [Recommended checkpoint 1]
2. [Recommended checkpoint 2]

### Red Lines

1. [Absolute boundary 1]
2. [Absolute boundary 2]

---

## Example Content

### On-Brand Example

```
[Paste 1-2 examples that match the brand voice]
```

### Off-Brand Example

```
[Paste 1-2 counter-examples with explanation]
Reason: [Why this doesn't match]
```

---

## Metadata

| Field | Value |
|-------|-------|
| Created | YYYY-MM-DD |
| Updated | YYYY-MM-DD |
| Version | v1.0 |
| Maintainer | [Name/Team] |
````

---

## Fill Instructions

| Placeholder | Source | Example |
|------------|--------|---------|
| `{{domain}}` | From workflow domain | `"customer onboarding"` |
| `{{positioning_example}}` | Example positioning for this domain | `"Friendly expert guiding new customers through setup"` |
| `{{platforms}}` | Relevant platforms for this workflow | X, LinkedIn, WeChat, etc. |
| `{{has_social_accounts}}` | Whether social accounts section is needed | `true` for publishing workflows |

---

## Key Patterns from Source

1. **Structured tables** for quick reference (not prose)
2. **Do's and Don'ts** checklist for content boundaries
3. **Sensitive topics matrix** with clear handling rules
4. **Social media accounts** section for CTA generation
5. **Consistency checklist** with must/should/red-line hierarchy
6. **Example content** with both positive and negative samples
7. **Metadata** for version tracking
