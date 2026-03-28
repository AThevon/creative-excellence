# Framer Motion — API Reference

> `motion` v11+ — `import { motion, AnimatePresence, ... } from "motion/react"`

## motion component — Props

### Animation

| Prop | Type | Description |
|------|------|-------------|
| `initial` | `Target \| VariantLabel \| false` | Etat initial. `false` = pas d'animation au mount (part directement de `animate`) |
| `animate` | `Target \| VariantLabel` | Etat cible. Change = anime automatiquement |
| `exit` | `Target \| VariantLabel` | Animation de sortie (requiert `AnimatePresence` parent) |
| `transition` | `Transition` | Config de transition (duration, ease, type, delay...) |
| `variants` | `Variants` | Map de labels vers targets. Propagent aux enfants motion |

### Gesture props

| Prop | Type | Description |
|------|------|-------------|
| `whileHover` | `Target \| VariantLabel` | Anime pendant le hover |
| `whileTap` | `Target \| VariantLabel` | Anime pendant le press/tap |
| `whileFocus` | `Target \| VariantLabel` | Anime pendant le focus |
| `whileDrag` | `Target \| VariantLabel` | Anime pendant le drag |
| `whileInView` | `Target \| VariantLabel` | Anime quand visible dans le viewport |

### Drag

| Prop | Type | Description |
|------|------|-------------|
| `drag` | `boolean \| "x" \| "y"` | Active le drag. `true` = les deux axes |
| `dragConstraints` | `{ top, left, right, bottom } \| RefObject` | Limites du drag. Ref = un element parent |
| `dragElastic` | `number \| { top, left, right, bottom }` | Elasticite hors contraintes (0-1, default 0.35) |
| `dragMomentum` | `boolean` | Inertie apres relache (default true) |
| `dragSnapToOrigin` | `boolean` | Retourne a la position initiale apres relache |
| `dragTransition` | `InertiaTransition` | Config de la transition d'inertie |
| `dragPropagation` | `boolean` | Propage le drag aux parents draggable |
| `onDrag` | `(event, info: PanInfo) => void` | Callback pendant le drag |
| `onDragStart` | `(event, info: PanInfo) => void` | Callback au debut du drag |
| `onDragEnd` | `(event, info: PanInfo) => void` | Callback a la fin du drag |
| `onDirectionLock` | `(axis: "x" \| "y") => void` | Callback quand la direction est verrouillee |

### Layout

| Prop | Type | Description |
|------|------|-------------|
| `layout` | `boolean \| "position" \| "size" \| "preserve-aspect"` | Anime automatiquement les changements de layout |
| `layoutId` | `string` | Shared layout — anime entre composants qui partagent le meme layoutId |
| `layoutDependency` | `any` | Force un recalcul du layout quand cette valeur change |
| `layoutScroll` | `boolean` | Compense le scroll offset dans les calculs layout |
| `onLayoutAnimationStart` | `() => void` | Callback au debut de l'animation layout |
| `onLayoutAnimationComplete` | `() => void` | Callback a la fin de l'animation layout |

### Lifecycle callbacks

| Prop | Type | Description |
|------|------|-------------|
| `onAnimationStart` | `(definition) => void` | Quand une animation commence |
| `onAnimationComplete` | `(definition) => void` | Quand une animation se termine |
| `onUpdate` | `(latest: ResolvedValues) => void` | A chaque frame pendant l'animation |
| `onViewportEnter` | `(entry) => void` | Quand l'element entre dans le viewport |
| `onViewportLeave` | `(entry) => void` | Quand l'element sort du viewport |

### Style (MotionValue-compatible)

Le prop `style` accepte des `MotionValue` en plus des valeurs normales :

```tsx
const x = useMotionValue(0);
<motion.div style={{ x, opacity: 0.5 }} />
```

**Transforms independants** supportes dans `style` : `x`, `y`, `z`, `rotateX`, `rotateY`, `rotateZ`, `scale`, `scaleX`, `scaleY`, `skewX`, `skewY`.

## AnimatePresence — Props

| Prop | Type | Description |
|------|------|-------------|
| `mode` | `"sync" \| "wait" \| "popLayout"` | Comportement enter/exit. Default `"sync"` |
| `initial` | `boolean` | `false` = desactive les animations initiales des enfants au premier render |
| `onExitComplete` | `() => void` | Callback quand toutes les exit animations sont terminees |
| `custom` | `any` | Valeur passee aux variants `exit` dynamiques |
| `presenceAffectsLayout` | `boolean` | L'element sortant affecte-t-il encore le layout (default true) |

### Mode details

- **`sync`** (default) — enter et exit simultanes
- **`wait`** — attend la fin de l'exit avant de commencer l'enter (page transitions)
- **`popLayout`** — retire l'element du flow immediatement via `position: absolute`, commence l'enter pendant l'exit

## Transition — Configuration

```tsx
// Spring (default pour les valeurs physiques)
transition={{ type: "spring", stiffness: 300, damping: 30, mass: 1 }}

// Tween (default pour opacity, color)
transition={{ type: "tween", duration: 0.3, ease: "easeInOut" }}

// Inertia (pour drag momentum)
transition={{ type: "inertia", velocity: 200, power: 0.8 }}

// Per-value
transition={{
  x: { type: "spring", stiffness: 300 },
  opacity: { duration: 0.2 },
}}

// Orchestration dans variants
transition={{
  staggerChildren: 0.08,
  delayChildren: 0.2,
  staggerDirection: -1,       // reverse
  when: "beforeChildren",     // ou "afterChildren"
}}
```

### Ease presets

`"linear"`, `"easeIn"`, `"easeOut"`, `"easeInOut"`, `"circIn"`, `"circOut"`, `"circInOut"`, `"backIn"`, `"backOut"`, `"backInOut"`, `"anticipate"`

Cubic bezier : `ease: [0.25, 0.1, 0.25, 1.0]`

## Hooks

### useMotionValue

```tsx
const x = useMotionValue(0);
// Set sans re-render
x.set(100);
// Lire la valeur courante
x.get(); // 100
// Bind au style
<motion.div style={{ x }} />
```

Cree une valeur reactive qui met a jour le DOM sans re-render React. Base de tous les autres hooks.

### useTransform

```tsx
// Map une valeur vers une autre
const opacity = useTransform(x, [-200, 0, 200], [0, 1, 0]);

// Transformer avec une fonction
const rounded = useTransform(x, (latest) => Math.round(latest));

// Combiner plusieurs valeurs
const combined = useTransform([x, y], ([latestX, latestY]) => latestX + latestY);
```

Derive une `MotionValue` a partir d'une ou plusieurs autres. Recalculee a chaque changement de la source.

### useSpring

```tsx
const springX = useSpring(motionValue, {
  stiffness: 300,   // default 100
  damping: 30,      // default 10
  mass: 1,          // default 1
  restSpeed: 0.01,
  restDelta: 0.01,
});

// Avec valeur initiale (nombre)
const spring = useSpring(0);
spring.set(100); // anime vers 100 avec spring physics
```

Cree un spring qui suit une `MotionValue` ou un nombre. Ideal pour smooth scroll indicators, cursor followers.

### useScroll

```tsx
// Scroll de la page
const { scrollX, scrollY, scrollXProgress, scrollYProgress } = useScroll();

// Scroll d'un element cible
const ref = useRef(null);
const { scrollYProgress } = useScroll({
  target: ref,
  offset: ["start end", "end start"],
  // offset format: [targetEdge containerEdge]
  // "start end" = quand le haut de target atteint le bas du container
});

// Scroll d'un container specifique
const { scrollYProgress } = useScroll({ container: scrollRef });
```

Retourne 4 `MotionValue` : position absolue (scrollX/Y) et progress normalise 0-1 (scrollXProgress/YProgress).

**Offset keywords** : `"start"`, `"center"`, `"end"`, ou un nombre/pourcentage (`0.5`, `"100px"`).

### useAnimate

```tsx
const [scope, animate] = useAnimate();

// Animation imperative
await animate(scope.current, { x: 100, opacity: 1 }, { duration: 0.5 });

// Selectors dans le scope
await animate("li", { opacity: 1 }, { delay: stagger(0.1) });

// Sequence
await animate([
  [scope.current, { x: 100 }],
  ["li", { opacity: 1 }, { delay: stagger(0.1) }],
]);

<div ref={scope}>
  <li>...</li>
</div>
```

API imperative pour les animations complexes, sequences, et orchestrations dynamiques. Alternative aux variants quand la logique est trop dynamique.

### useInView

```tsx
const ref = useRef(null);
const isInView = useInView(ref, {
  once: true,          // ne declenche qu'une fois
  amount: 0.5,         // 50% visible (default "some")
  margin: "-100px",    // rootMargin (comme IntersectionObserver)
});

// Utilisation avec animate
<motion.div
  ref={ref}
  initial={{ opacity: 0, y: 50 }}
  animate={isInView ? { opacity: 1, y: 0 } : {}}
/>
```

Wrapper autour d'`IntersectionObserver`. Retourne un boolean reactif.

### useReducedMotion

```tsx
const prefersReduced = useReducedMotion();

<motion.div
  animate={prefersReduced ? { opacity: 1 } : { opacity: 1, y: 0, scale: 1 }}
  transition={prefersReduced ? { duration: 0 } : { type: "spring" }}
/>
```

Respecte `prefers-reduced-motion`. **Toujours l'utiliser** pour les animations non-essentielles. Retourne `true` si l'utilisateur a active la preference systeme.

### useMotionValueEvent

```tsx
const x = useMotionValue(0);

useMotionValueEvent(x, "change", (latest) => {
  console.log("x changed to", latest);
});

useMotionValueEvent(x, "animationStart", () => { /* ... */ });
useMotionValueEvent(x, "animationComplete", () => { /* ... */ });
useMotionValueEvent(x, "animationCancel", () => { /* ... */ });
```

Subscribe a une MotionValue sans re-render. Auto-cleanup au unmount. Preferer a `onChange` (deprecated).

## Utilities

### stagger

```tsx
import { stagger } from "motion/react";

animate("li", { opacity: 1 }, { delay: stagger(0.1) });
animate("li", { opacity: 1 }, { delay: stagger(0.1, { startDelay: 0.2 }) });
animate("li", { opacity: 1 }, { delay: stagger(0.1, { from: "center" }) });
// from: number | "first" | "center" | "last"
```

### animate (standalone)

```tsx
import { animate } from "motion/react";

// Animer une valeur
animate(0, 100, {
  duration: 1,
  onUpdate: (latest) => el.style.opacity = latest,
});

// Animer un element directement (hors React)
animate(element, { opacity: 1 }, { duration: 0.5 });
```

### scroll (standalone)

```tsx
import { scroll } from "motion";

// Callback basee sur le scroll progress
scroll((progress) => {
  el.style.opacity = progress;
});

// Lier au scroll d'un element
scroll(
  (progress) => { /* ... */ },
  { target: element, offset: ["start end", "end start"] }
);
```
