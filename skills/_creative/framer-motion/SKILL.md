# Framer Motion — Sub-skill

> Package: `motion` (v11+, anciennement `framer-motion`). Import: `import { motion, AnimatePresence } from "motion/react"`

## Quand utiliser Framer Motion vs alternatives

| Critere | Framer Motion | GSAP | CSS natif |
|---------|--------------|------|-----------|
| Layout animations | Excellent (layoutId) | Manuel | Impossible |
| Exit animations | AnimatePresence | Timeline reverse | Limité (display) |
| Gestures (drag, hover) | Natif, déclaratif | Draggable plugin | Basique |
| Scroll-driven | useScroll + useTransform | ScrollTrigger (plus puissant) | scroll-timeline |
| Orchestration complexe | Variants + propagation | Timeline (plus flexible) | @keyframes |
| Bundle size | ~50kb tree-shaken | ~30kb core | 0kb |
| React integration | Natif, composant-first | Refs + useGSAP | className toggle |

**Regle** : Framer Motion pour les interactions UI React (modals, toasts, reorder, shared layout). GSAP pour les timelines complexes, scroll-driven cinematiques, morphing SVG.

## AnimatePresence — Exit animations

```tsx
<AnimatePresence mode="wait">
  {isVisible && (
    <motion.div
      key="unique-key"        // OBLIGATOIRE — identifie le composant
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      exit={{ opacity: 0 }}
    />
  )}
</AnimatePresence>
```

- `mode="wait"` — attend la fin de l'exit avant le enter (page transitions)
- `mode="sync"` — exit et enter simultanés
- `mode="popLayout"` — retire du flow immédiatement (bon pour les listes)
- `onExitComplete` — callback quand toutes les exit animations sont terminées

## Layout animations

```tsx
// Shared layout — l'element "glisse" entre deux positions
<motion.div layoutId="highlight" className={activeTab === id ? "active" : ""} />

// Layout auto — anime position/taille quand le layout change
<motion.div layout>
  {isExpanded && <motion.p layout>Contenu additionnel</motion.p>}
</motion.div>

// layout="position" — anime seulement la position (pas la taille)
// layout="size" — anime seulement la taille
// layout="preserve-aspect" — preserve le ratio pendant la transition
```

## Variants — Propagation et orchestration

```tsx
const container = {
  hidden: { opacity: 0 },
  show: {
    opacity: 1,
    transition: {
      staggerChildren: 0.08,
      delayChildren: 0.2,
      staggerDirection: 1,    // 1 = normal, -1 = reverse
    },
  },
};

const item = {
  hidden: { opacity: 0, y: 20 },
  show: { opacity: 1, y: 0 },
};

<motion.ul variants={container} initial="hidden" animate="show">
  {items.map((i) => (
    <motion.li key={i.id} variants={item} />
  ))}
</motion.ul>
```

Les variants **propagent automatiquement** aux enfants motion — pas besoin de `initial`/`animate` sur les enfants.

## Gestures

```tsx
<motion.div
  whileHover={{ scale: 1.05 }}
  whileTap={{ scale: 0.95 }}
  whileFocus={{ borderColor: "#3b82f6" }}
  // Drag
  drag               // true = x+y, "x" = horizontal only, "y" = vertical only
  dragConstraints={{ left: -100, right: 100, top: -50, bottom: 50 }}
  dragElastic={0.2}  // 0 = rigid, 1 = libre (default 0.35)
  dragSnapToOrigin   // retourne a la position initiale
  onDragEnd={(e, info) => {
    if (info.offset.x > 100) handleSwipe("right");
  }}
/>
```

## Motion values — Reactive sans re-render

```tsx
const x = useMotionValue(0);
const opacity = useTransform(x, [-200, 0, 200], [0, 1, 0]);
const background = useTransform(x, [-200, 200], ["#ff0000", "#00ff00"]);

// Spring-based smoothing
const smoothX = useSpring(x, { stiffness: 300, damping: 30 });

// Scroll tracking
const { scrollY, scrollYProgress } = useScroll();
const parallaxY = useTransform(scrollYProgress, [0, 1], [0, -300]);

// Element-scoped scroll
const ref = useRef(null);
const { scrollYProgress } = useScroll({
  target: ref,
  offset: ["start end", "end start"],
});
```

**Motion values ne declenchent PAS de re-render React** — ils mettent a jour le DOM directement via `style`.

## Do Not

### Ne pas setState dans les callbacks sans guard

```tsx
// BAD — re-render infini si animate depend de state
onUpdate={(latest) => setPosition(latest.x)}

// GOOD — guard ou useMotionValueEvent
const x = useMotionValue(0);
useMotionValueEvent(x, "change", (latest) => {
  if (latest > threshold) onThresholdReached();
});
```

### Ne pas faire de layout animation sans key stable

```tsx
// BAD — key change a chaque render, casse le layout tracking
<motion.div layout key={Math.random()} />

// GOOD — key stable derivee des donnees
<motion.div layout key={item.id} />
```

### Ne pas oublier le key unique sur AnimatePresence

```tsx
// BAD — pas de key, exit animation ne se declenche pas
<AnimatePresence>
  {isOpen && <motion.div exit={{ opacity: 0 }} />}
</AnimatePresence>

// GOOD — key unique pour chaque enfant conditionnel
<AnimatePresence>
  {isOpen && <motion.div key="modal" exit={{ opacity: 0 }} />}
</AnimatePresence>
```

### Ne pas wrapper un composant deja anime avec motion.div

```tsx
// BAD — double animation, conflits de transform
<motion.div animate={{ x: 100 }}>
  <motion.div animate={{ x: -50 }}>Content</motion.div>
</motion.div>

// GOOD — un seul niveau d'animation par axe de transform
<motion.div animate={{ x: 100 }}>
  <motion.div animate={{ opacity: 0.5 }}>Content</motion.div>
</motion.div>

// GOOD — utiliser variants pour coordonner parent/enfant
<motion.div variants={parent} animate="active">
  <motion.div variants={child} />
</motion.div>
```
