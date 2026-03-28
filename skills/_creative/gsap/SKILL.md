# GSAP — Animation Engine

## Quand utiliser GSAP

| Critere               | CSS Transitions | Framer Motion | GSAP              |
| --------------------- | --------------- | ------------- | ----------------- |
| Hover / simple toggle | Oui             | Oui           | Overkill          |
| Timeline sequencee    | Non             | Limite        | **Oui**           |
| Scroll-driven         | scroll-timeline | Limite        | **ScrollTrigger** |
| Stagger complexe      | Non             | Basique       | **Distribution**  |
| Perf mobile (60fps)   | Bon             | Moyen         | **Excellent**     |
| Text splitting        | Non             | Non           | **SplitText**     |
| SVG morph / draw      | Non             | Non           | **MorphSVG**      |
| Bundle size concern   | 0kb             | ~30kb         | ~25kb + plugins   |

**Regle** : si l'animation a besoin de timeline, scroll-link, ou stagger distribue, GSAP. Sinon CSS d'abord.

## Setup

```js
// Toujours enregistrer les plugins au top level
import gsap from "gsap";
import { ScrollTrigger } from "gsap/ScrollTrigger";
import { SplitText } from "gsap/SplitText";

gsap.registerPlugin(ScrollTrigger, SplitText);
```

React : utiliser `useGSAP()` du package `@gsap/react` au lieu de `useEffect` + cleanup manuel.

```jsx
import { useGSAP } from "@gsap/react";

useGSAP(() => {
  gsap.to(".box", { x: 200 });
}, { scope: containerRef }); // auto-cleanup, auto-revert
```

## Core Patterns

### defaults{} pour eviter la repetition

```js
const tl = gsap.timeline({
  defaults: { duration: 0.8, ease: "power2.out" },
});
tl.to(".a", { y: -20 })
  .to(".b", { y: -20 }, "<0.1")
  .to(".c", { y: -20 }, "<0.1");
```

### fromTo pour controle total

```js
gsap.fromTo(".card", { y: 40, opacity: 0 }, { y: 0, opacity: 1, stagger: 0.15 });
```

### Stagger avec distribution

```js
gsap.to(".grid-item", {
  scale: 0,
  stagger: {
    each: 0.05,
    from: "center",   // "start" | "end" | "center" | "edges" | "random" | index
    grid: "auto",      // detecte la grille automatiquement
    axis: "x",         // "x" | "y" | null (les deux)
  },
});
```

## ScrollTrigger Patterns

### Pin + Scrub basique

```js
gsap.to(".panel", {
  x: "-300%",
  ease: "none",
  scrollTrigger: {
    trigger: ".container",
    pin: true,
    scrub: 1,
    end: () => "+=" + document.querySelector(".container").scrollWidth,
  },
});
```

### Batch pour reveal en masse

```js
ScrollTrigger.batch(".card", {
  onEnter: (elements) => gsap.to(elements, { opacity: 1, y: 0, stagger: 0.1 }),
  start: "top 85%",
});
```

### Scroll horizontal avec containerAnimation

```js
const scrollTween = gsap.to(".panels", {
  x: () => -(document.querySelector(".panels").scrollWidth - window.innerWidth),
  ease: "none",
  scrollTrigger: { trigger: ".wrapper", pin: true, scrub: 1 },
});

// Animer des elements A L'INTERIEUR du scroll horizontal
gsap.to(".panel-content", {
  scale: 1.2,
  scrollTrigger: {
    trigger: ".panel-content",
    containerAnimation: scrollTween, // relie au scroll horizontal
    start: "left center",
    end: "right center",
    scrub: true,
  },
});
```

## DO NOT — Erreurs critiques

### 1. Ease sur containerAnimation

```js
// BAD — le ease casse le mapping scroll
scrollTrigger: { containerAnimation: scrollTween, scrub: 1, ease: "power2.out" }

// GOOD — toujours ease: "none" sur le tween parent
const scrollTween = gsap.to(".panels", { x: ..., ease: "none", scrollTrigger: { scrub: 1 } });
```

### 2. ScrollTrigger sur un child tween dans un timeline

```js
// BAD — ScrollTrigger ignore les tweens enfants d'un timeline avec son propre ScrollTrigger
const tl = gsap.timeline({ scrollTrigger: { trigger: ".section" } });
tl.to(".box", { x: 100, scrollTrigger: { trigger: ".box" } }); // IGNORE

// GOOD — un seul ScrollTrigger par timeline OU des tweens independants
gsap.to(".box", { x: 100, scrollTrigger: { trigger: ".box" } }); // tween standalone
```

### 3. setState dans onUpdate

```js
// BAD — setState 60x/sec = re-render hell
scrollTrigger: { onUpdate: (self) => setProgress(self.progress) }

// GOOD — muter une ref ou un DOM element directement
const progressRef = useRef(0);
scrollTrigger: { onUpdate: (self) => { progressRef.current = self.progress; } }
// Ou mieux : gsap.quickSetter pour muter le DOM sans React
```

### 4. immediateRender sur from() dans un timeline

```js
// BAD — from() a immediateRender: true par defaut, casse le sequencing
tl.to(".box", { x: 100 });
tl.from(".box", { y: 50 }); // saute visuellement au debut

// GOOD — desactiver immediateRender quand from() suit un autre tween
tl.to(".box", { x: 100 });
tl.from(".box", { y: 50, immediateRender: false });
```

### 5. Animer des proprietes non-transform

```js
// BAD — width/height/top/left declenchent layout reflow
gsap.to(".box", { width: 200, height: 200 });

// GOOD — utiliser transforms (GPU-accelerated, composited)
gsap.to(".box", { scaleX: 1.5, scaleY: 1.5 });
// Si taille reelle requise : utiliser Flip plugin pour transition layout
```

## Refs

- `references/core.md` — API complete gsap.to/from/fromTo/set, options
- `references/timeline.md` — Timeline, position parameter, nesting
- `references/scrolltrigger.md` — ScrollTrigger complet
- `references/plugins.md` — SplitText, Flip, MorphSVG, DrawSVG, MotionPath, Observer
