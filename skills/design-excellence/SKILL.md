---
name: design-excellence
description: "Exceptional design pipeline — art direction brainstorm, design system, implementation, audit. Build a complete visual universe."
allowed-tools: Bash, Read, Edit, Write, Grep, Glob, WebSearch, Agent
---

# Design Excellence — The Architect

> Build a complete visual universe. Brainstorm first, design system second, implement third, audit last.
> This is NOT a quick beautifier — it's a full design pipeline.

---

## /design-excellence vs /creative-excellence

| | `/creative-excellence` | `/design-excellence` |
|---|---|---|
| **Philosophy** | "Make this thing beautiful/wow" | "Build a visual universe from scratch" |
| **Entry point** | Adapts to existing code | Mandatory brainstorm, wipes design if existing |
| **Discovery** | Lightweight, only when vague | Full brainstorm, never skipped |
| **Design system** | Optional, implicit | Required, generates MASTER.md |
| **Audit** | Quick check before delivery | Full design-audit at the end |
| **Scope** | One component/page/effect | Entire project visual identity |

`/design-excellence` calls the same sub-skills as `/creative-excellence` for implementation.

---

## Iron Rules

1. **Never skip the brainstorm.** Not even if the user says "just make it look good." Especially then.
2. **One question at a time during brainstorm.** Never bundle. The second question depends on the first answer.
3. **Never proceed without both theses validated.** Visual + interaction, both explicitly approved.
4. **Every design token comes from MASTER.md.** No magic numbers, no rogue hex values.
5. **Every animation respects the interaction thesis.** Timing, easing, forbidden patterns — no exceptions.
6. **Never install a dependency without asking.**
7. **Work page by page, validate page by page.** Never try to do everything at once.
8. **The audit is not optional.** Phase 5 always runs, even if the user seems happy.

---

## Sub-skills Path Detection

```bash
# Environment detection:
# - claude.ai: skills are uploaded individually to /mnt/skills/user/<name>/
# - Claude Code: skills live under the plugin directory
if [ -d "/mnt/skills/user/motion-principles" ]; then
  # claude.ai - each sub-skill is its own uploaded skill
  SKILL_BASE="/mnt/skills/user"
else
  # Claude Code plugin
  PLUGIN_ROOT=$(find ~/.claude/plugins -path "*/creative-excellence/skills" -type d | head -1 | sed 's|/skills$||')
  SKILL_BASE="$PLUGIN_ROOT/skills/_creative"
fi
```

All sub-skills are loaded via `$SKILL_BASE/<name>/SKILL.md`.

---

## Pipeline

### Phase 1 — BRAINSTORM (mandatory, never skip)

This is the foundation. Rush it and everything downstream is wrong. The goal: understand the user's vision well enough to write two theses they'd agree with without hesitation.

**The five domains to cover:**

1. **Product** — What is it? (app, landing page, portfolio, SaaS, e-commerce, blog, dashboard...)
2. **Audience** — Who uses it? (devs, designers, general public, enterprise, kids, luxury...)
3. **Mood** — 3 to 5 adjectives that define the visual feel
4. **References** — Sites, screenshots, mood boards, anything visual
5. **Tech stack** — What's already in place? Or starting from scratch?

**How to ask:** One question at a time, starting with the least obvious domain. If you already know the tech stack from scanning `package.json`, don't ask — start with mood or audience instead. Each answer reshapes how you ask the next question.

**How to handle vague answers:**

When the user says "modern" or "clean" or "I don't know, just make it nice":

1. **Validate** — "That's a starting point. Let's make it precise."
2. **Offer concrete options** — "Clean like Stripe's editorial whitespace, clean like Linear's dense-but-organized, or clean like Apple's dramatic minimalism?"
3. **Reframe** — "What would feel *wrong*? What sites make you cringe? That's just as useful."
4. **Name the consequence** — "This choice drives the entire color palette and typography. Worth spending a minute on."

**Never** interpret a vague answer as confirmation. "Yeah something like that" means dig deeper — ask which part of "that" resonates.

**When the user pushes to skip or rush brainstorm:**

Do NOT capitulate. Instead:

> "On a couvert [domaines couverts]. Il me manque [domaines manquants] — ça va directement impacter [conséquence concrète]. Je pose encore une question ou tu préfères que je fasse des hypothèses et tu corriges après ?"

This gives them an informed choice. If they choose assumptions, name each assumption explicitly in the thesis.

**Never** negotiate the number of remaining questions ("just two more, I promise"). You don't know how many you need until you hear the answers.

**When to stop:** When you can write both theses (visual + interaction) and you'd bet money the user will say "oui parfait." If you'd be guessing on even one aspect, keep asking.

---

### Phase 2 — THESIS (define direction, get validation)

From the brainstorm, produce two theses:

#### Visual Thesis

A single sentence that captures the entire visual identity. **Must explicitly address all four:**

- **Color direction** — dark/light, palette family, accent color
- **Typography spirit** — serif/sans/mono, weight usage, size contrast
- **Spacing philosophy** — dense/airy, base unit feel
- **Component style** — rounded/sharp, bordered/filled, elevated/flat

> Example: "Dark neo-brutalist interface with bold monospace type, fluorescent chartreuse accents, generous whitespace, raw-edged components with offset shadows."

**Self-check:** read your thesis back. If any of the four areas is missing or vague ("nice typography"), rewrite it before presenting.

#### Interaction Thesis

A single sentence that captures the motion and interaction language. **Must explicitly address all four:**

- **Timing range** — fast (100-200ms), medium (200-400ms), or slow (400ms+)
- **Hover behavior** — what happens on hover
- **Scroll behavior** — reveals, parallax, or nothing
- **Forbidden patterns** — what this project will NOT do

> Example: "Fast and dry transitions (100-200ms), hover with subtle scale (1.02), scroll-triggered reveals with stagger, no bounce or elastic — all sharp ease-out."

**Self-check:** read your thesis back. If you can't immediately derive the CSS/JS properties from it, it's too vague. Rewrite.

**Wait for explicit user validation of BOTH theses before moving on.** If the user pushes back, don't start over — ask what feels wrong and adjust.

---

### Phase 3 — DESIGN SYSTEM

Load `_creative/ui-ux-pro-max` sub-skill:

```bash
cat "$SKILL_BASE/ui-ux-pro-max/SKILL.md"
```

Generate the complete design system based on both theses:

- **Color palette** — Primary, secondary, accent, neutrals, semantic (success/warning/error/info). Light + dark if needed.
- **Typography** — Font stack, size scale (fluid or fixed), weight usage, line-height rules.
- **Spacing** — Base unit, scale (4px, 8px, 12px, 16px, 24px, 32px, 48px, 64px...).
- **Radii** — Border radius scale (none, sm, md, lg, full).
- **Shadows** — Elevation levels (0-4), consistent with visual thesis.
- **Base components** — Button, input, card, badge, link — styled per the theses.
- **Motion tokens** — Duration scale (fast/normal/slow), easing names, stagger delay.

#### MASTER.md

Create a `MASTER.md` at project root with the full design system. This file is the single source of truth. Every implementation decision references it.

#### MCP Tools (if available)

Check if these MCPs are connected and use them when available:
- **Stitch** — Generate mockups/wireframes
- **Nano Banana** — Generate visual assets (illustrations, icons, backgrounds)
- **21st.dev Magic** — Generate UI components from descriptions

If MCPs are not available, skip gracefully — the design system + code implementation is the core path.

---

### Phase 4 — IMPLEMENT

Load sub-skills based on tech stack and interaction thesis. Always load `motion-principles` first, then stack-specific skills:

```bash
# Always first
cat "$SKILL_BASE/motion-principles/SKILL.md"
# Then per stack: framer-motion, gsap, css-native, threejs-r3f, canvas-generative
cat "$SKILL_BASE/<skill>/SKILL.md"
```

Implementation rules:
- Work **page by page** or **component by component** — never try to do everything at once.
- Every color, font, spacing, shadow, radius MUST come from MASTER.md tokens. No magic numbers.
- Every animation MUST respect the interaction thesis (timing, easing, forbidden patterns).
- Apply the 5-state rule for interactive elements: **default, hover, focus, active, disabled**.
- Ask the user for validation after each major page/section before moving to the next.

---

### Phase 5 — AUDIT (never skip)

Load `_creative/design-audit` sub-skill:

```bash
cat "$SKILL_BASE/design-audit/SKILL.md"
```

Run the full audit checklist:

#### Motion Gap Analysis
- Conditional renders without AnimatePresence
- Hover states without transition
- Dynamic lists without stagger
- Style changes without transition
- Entries without corresponding exits

#### Color & Contrast Consistency
- All interactive elements have 5 states: default, hover, focus, active, disabled
- Contrast ratio >= 4.5:1 for all text
- Color palette matches MASTER.md — no rogue hex values

#### Accessibility
- `prefers-reduced-motion` handler exists (critical)
- Focus visible on all interactives
- Semantic HTML — no clickable divs without role
- `aria-hidden` on decorative animations

#### Responsive (4 breakpoints)
375px (mobile) / 768px (tablet) / 1024px (small desktop) / 1440px (large desktop)

#### Performance
No layout property animations, `will-change` sparingly, `requestAnimationFrame` for custom loops.

Present findings grouped by severity: **Critical > Important > Nice-to-have**.

---

## Existing Project Protocol

When invoked on a project that already has design/styling:

1. Still run the full BRAINSTORM (Phase 1)
2. Acknowledge existing design, but the thesis overrides it
3. In Phase 4, **replace** existing design tokens/styles with the new design system
4. Preserve functionality and layout structure — only replace the visual layer

This is intentional: `/design-excellence` rebuilds the visual universe. To enhance what exists, use `/creative-excellence` instead.

---

## Red Flags — You're About to Violate This Skill

| Thought | Reality |
|---------|---------|
| "The user already said 'minimal dark' — I have enough for a thesis" | Two words aren't five domains. Keep asking. |
| "I'll ask all five brainstorm questions at once" | One at a time. The answer to 'audience' changes how you ask about 'mood'. |
| "The user seems impatient, let's skip to coding" | Use the pressure protocol. A bad thesis costs days, not minutes. |
| "I'll pick colors that feel right" | Every token comes from MASTER.md. No freelancing. |
| "I'll do the whole site in one pass" | Page by page. Validate page by page. |
| "This animation would be cool even though the thesis says no bounce" | The thesis is law. Change it? Re-validate with the user first. |
| "The audit can wait, the user seems happy" | The audit is not optional. Phase 5 always runs. |
| "I'll interpret 'yeah something like that' as a yes" | That's not confirmation. Ask which part resonates. |
