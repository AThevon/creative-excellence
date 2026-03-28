# GSAP Plugins

## SplitText (Free depuis v3.12)

Decoupe le texte en `chars`, `words`, `lines` pour animations granulaires.

### Usage

```js
import { SplitText } from "gsap/SplitText";
gsap.registerPlugin(SplitText);

const split = SplitText.create(".headline", {
  type: "chars, words, lines",
  mask: "lines",       // masque les lignes (clip overflow pour reveal)
  linesClass: "line",
  charsClass: "char",
  wordsClass: "word",
});

// Animer les chars
gsap.from(split.chars, {
  y: 50,
  opacity: 0,
  stagger: 0.03,
  duration: 0.6,
  ease: "power3.out",
});
```

### autoSplit + onSplit (v3.13+)

Re-split automatique au resize (lignes qui changent).

```js
SplitText.create(".text", {
  type: "lines, words",
  mask: "lines",
  autoSplit: true, // re-split au resize
  onSplit(self) {
    return gsap.from(self.words, {
      y: "100%",
      opacity: 0,
      stagger: 0.04,
      duration: 0.7,
    });
    // Retourner le tween permet a autoSplit de le kill/recreer
  },
});
```

### Revert

Toujours revert apres animation pour nettoyer le DOM.

```js
// BAD — les spans restent dans le DOM indefiniment
const split = SplitText.create(".text", { type: "chars" });
gsap.from(split.chars, { opacity: 0 });

// GOOD — revert quand l'animation est finie
const split = SplitText.create(".text", { type: "chars" });
gsap.from(split.chars, {
  opacity: 0,
  stagger: 0.02,
  onComplete: () => split.revert(),
});
// OU utiliser autoSplit + onSplit qui gere le cycle automatiquement
```

## Flip

Anime des changements de layout (position, taille) avec une transition fluide. Technique FLIP : First, Last, Invert, Play.

### Usage

```js
import { Flip } from "gsap/Flip";
gsap.registerPlugin(Flip);

// 1. Capturer l'etat actuel
const state = Flip.getState(".items");

// 2. Modifier le DOM / layout
container.appendChild(movedElement);
// ou toggle une classe, reorder, etc.

// 3. Animer depuis l'ancien etat vers le nouveau
Flip.from(state, {
  duration: 0.8,
  ease: "power2.inOut",
  stagger: 0.05,
  absolute: true,      // utilise position absolute pendant l'animation
  onEnter: (elements) => gsap.fromTo(elements, { opacity: 0, scale: 0 }, { opacity: 1, scale: 1 }),
  onLeave: (elements) => gsap.to(elements, { opacity: 0, scale: 0 }),
});
```

### Flip.fit()

Fait correspondre la taille/position d'un element a un autre.

```js
// Fait matcher .box a la position/taille de .target
Flip.fit(".box", ".target", {
  scale: true,     // utilise scale au lieu de width/height
  duration: 0.5,
});
```

### Piege Flip

```js
// BAD — getState APRES le changement de DOM = pas de reference
container.appendChild(element);
const state = Flip.getState(".items"); // TROP TARD

// GOOD — getState AVANT le changement
const state = Flip.getState(".items");
container.appendChild(element);
Flip.from(state, { duration: 0.6 });
```

## MorphSVG (Club)

Morphe un path SVG vers un autre.

### Usage

```js
import { MorphSVGPlugin } from "gsap/MorphSVGPlugin";
gsap.registerPlugin(MorphSVGPlugin);

gsap.to("#circle", {
  morphSVG: "#star",     // target shape (selecteur ou path data)
  duration: 1.5,
  ease: "power2.inOut",
});

// Avec path data string
gsap.to("#shape", {
  morphSVG: "M10,10 C20,20 40,20 50,10",
  duration: 1,
});
```

### findShapeIndex

Outil interactif pour trouver le meilleur point de depart du morph.

```js
// En dev uniquement — ouvre un outil interactif
MorphSVGPlugin.findShapeIndex("#circle", "#star");
```

### Convertir des primitives en path

```js
// Convertit rect, circle, ellipse, polygon, polyline, line en <path>
MorphSVGPlugin.convertToPath("circle, rect, ellipse");
```

### Piege MorphSVG

```js
// BAD — morph entre shapes avec nombre tres different de points = resultat chaotique
gsap.to("#simple-circle", { morphSVG: "#complex-illustration" });

// GOOD — utiliser des shapes avec complexite similaire, ou shapeIndex pour optimiser
gsap.to("#simple-circle", {
  morphSVG: { shape: "#complex-shape", shapeIndex: 2 }, // tester avec findShapeIndex
});
```

## DrawSVG (Club)

Anime le stroke d'un SVG (effet "dessin").

### Usage

```js
import { DrawSVGPlugin } from "gsap/DrawSVGPlugin";
gsap.registerPlugin(DrawSVGPlugin);

// Dessine le stroke de 0% a 100%
gsap.from(".path", { drawSVG: 0, duration: 2, ease: "power2.inOut" });

// Anime une portion du stroke
gsap.fromTo(".path",
  { drawSVG: "0% 0%" },
  { drawSVG: "0% 100%", duration: 2 }
);

// Portion qui se deplace
gsap.to(".path", { drawSVG: "50% 60%", duration: 1 });

// Timeline pour effet "snake"
const tl = gsap.timeline({ repeat: -1 });
tl.fromTo(".path",
  { drawSVG: "0% 0%" },
  { drawSVG: "0% 30%", duration: 1 }
).to(".path",
  { drawSVG: "100% 100%", duration: 1 }
);
```

### Piege DrawSVG

```js
// BAD — l'element n'a pas de stroke defini en CSS/SVG
gsap.from(".path", { drawSVG: 0 }); // rien ne se passe

// GOOD — toujours definir un stroke visible
// CSS: .path { stroke: #fff; stroke-width: 2; fill: none; }
gsap.from(".path", { drawSVG: 0, duration: 2 });
```

## MotionPath (Free)

Anime un element le long d'un path SVG.

### Usage

```js
import { MotionPathPlugin } from "gsap/MotionPathPlugin";
gsap.registerPlugin(MotionPathPlugin);

gsap.to(".rocket", {
  motionPath: {
    path: "#flight-path",    // path SVG a suivre
    align: "#flight-path",   // aligne l'element sur le path
    alignOrigin: [0.5, 0.5], // centre de l'element
    autoRotate: true,         // tourne dans la direction du mouvement
    autoRotate: 90,           // offset de rotation en degres
    start: 0,                 // position de depart (0-1)
    end: 1,                   // position de fin (0-1)
  },
  duration: 3,
  ease: "power1.inOut",
});
```

### Path avec coordonnees

```js
gsap.to(".ball", {
  motionPath: {
    path: [
      { x: 100, y: 0 },
      { x: 200, y: -100 },
      { x: 300, y: 0 },
    ],
    curviness: 1.5,   // 0 = lineaire, 2 = tres courbe
    autoRotate: true,
  },
  duration: 2,
});
```

### Piege MotionPath

```js
// BAD — autoRotate sans alignOrigin = l'element pivote autour de son coin
gsap.to(".el", {
  motionPath: { path: "#path", autoRotate: true },
});

// GOOD — toujours definir align + alignOrigin avec autoRotate
gsap.to(".el", {
  motionPath: {
    path: "#path",
    align: "#path",
    alignOrigin: [0.5, 0.5],
    autoRotate: true,
  },
});
```

## Observer (Free)

Detecte les gestes utilisateur (scroll, touch, pointer) sans ScrollTrigger. Ideal pour des interactions custom (swipe, drag-to-reveal).

### Usage

```js
import { Observer } from "gsap/Observer";
gsap.registerPlugin(Observer);

Observer.create({
  type: "wheel, touch, pointer",  // types d'events a ecouter
  target: window,                  // element cible
  onUp: () => goToSection(-1),     // scroll/swipe vers le haut
  onDown: () => goToSection(1),    // scroll/swipe vers le bas
  tolerance: 50,                   // pixels minimum avant declenchement
  preventDefault: true,            // empeche le scroll natif
  wheelSpeed: -1,                  // inverse la direction de la wheel
  onPress: (self) => {},           // pointer down
  onRelease: (self) => {},         // pointer up
  onDrag: (self) => {},            // pendant le drag
  onChange: (self) => {
    self.deltaX;    // deplacement X
    self.deltaY;    // deplacement Y
    self.velocityX; // vitesse X
    self.velocityY; // vitesse Y
  },
});
```

### Full-page section transitions

```js
let currentIndex = 0;
const sections = gsap.utils.toArray(".section");
let animating = false;

function goToSection(direction) {
  if (animating) return;
  const nextIndex = gsap.utils.clamp(0, sections.length - 1, currentIndex + direction);
  if (nextIndex === currentIndex) return;

  animating = true;
  gsap.to(sections[currentIndex], { yPercent: -100 * direction, duration: 0.8 });
  gsap.fromTo(sections[nextIndex],
    { yPercent: 100 * direction },
    { yPercent: 0, duration: 0.8, onComplete: () => (animating = false) }
  );
  currentIndex = nextIndex;
}

Observer.create({
  type: "wheel, touch",
  onUp: () => goToSection(-1),
  onDown: () => goToSection(1),
  tolerance: 80,
  preventDefault: true,
});
```

### Piege Observer

```js
// BAD — pas de debounce/lock = animations qui s'empilent
Observer.create({
  onDown: () => gsap.to(".box", { y: "+=100" }), // chaque scroll ajoute 100px

// GOOD — verrouiller pendant l'animation
let animating = false;
Observer.create({
  onDown: () => {
    if (animating) return;
    animating = true;
    gsap.to(".box", { y: "+=100", onComplete: () => (animating = false) });
  },
});
```

## Recap : Free vs Club

| Plugin         | Licence | Usage principal                    |
| -------------- | ------- | ---------------------------------- |
| ScrollTrigger  | Free    | Scroll-driven animations           |
| Observer       | Free    | Gesture detection                  |
| MotionPath     | Free    | Path following                     |
| Flip           | Free    | Layout transitions                 |
| SplitText      | Free    | Text splitting (free depuis v3.12) |
| MorphSVG       | Club    | SVG shape morphing                 |
| DrawSVG        | Club    | SVG stroke animation               |
| CustomEase     | Free    | Custom easing curves               |
| ScrollSmoother | Club    | Smooth scrolling wrapper           |
