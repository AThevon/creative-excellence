# ScrollTrigger

## Setup

```js
import gsap from "gsap";
import { ScrollTrigger } from "gsap/ScrollTrigger";
gsap.registerPlugin(ScrollTrigger);
```

## Syntaxe de base

### Sur un tween

```js
gsap.to(".box", {
  x: 200,
  scrollTrigger: {
    trigger: ".box",    // element declencheur
    start: "top center", // quand le TOP du trigger atteint le CENTER du viewport
    end: "bottom center",
    toggleActions: "play none none none",
  },
});
```

### Sur un timeline

```js
const tl = gsap.timeline({
  scrollTrigger: {
    trigger: ".section",
    start: "top top",
    end: "+=1000",
    pin: true,
    scrub: 1,
  },
});
tl.to(".a", { x: 200 }).to(".b", { y: -100 }, "<");
```

### Standalone (sans tween)

```js
ScrollTrigger.create({
  trigger: ".section",
  start: "top center",
  end: "bottom center",
  onEnter: () => console.log("enter"),
  onLeave: () => console.log("leave"),
  toggleClass: "active",
});
```

## Proprietes

### trigger

Element ou selecteur qui definit la zone de declenchement.

```js
trigger: ".my-section"   // selecteur CSS
trigger: elementRef       // element DOM
```

### start / end

Format : `"triggerPoint viewportPoint"`.

Valeurs possibles pour chaque point : `top`, `center`, `bottom`, pourcentage (`80%`), pixels (`200px`), ou fonction.

```js
start: "top center"        // top du trigger = center du viewport
start: "top 80%"           // top du trigger = 80% du viewport (depuis le haut)
start: "top top+=100"      // top du trigger = top du viewport + 100px
end: "bottom top"          // bottom du trigger = top du viewport
end: "+=500"               // 500px apres le start
end: () => "+=" + el.offsetHeight // dynamique
```

### scrub

Lie la progression de l'animation au scroll.

```js
scrub: true    // instantane (suit le scroll exactement)
scrub: 0.5     // smooth avec 0.5s de "rattrapage"
scrub: 1       // smooth avec 1s de rattrapage (recommande)
scrub: 3       // tres smooth, effet fluide
```

### pin

Epingle l'element pendant la duree du ScrollTrigger.

```js
pin: true               // epingle le trigger
pin: ".other-element"   // epingle un autre element
pinSpacing: true         // defaut: ajoute du padding pour compenser
pinSpacing: false        // pas de padding (pour overlay effects)
pinReparent: true        // reparente le pin (fix z-index issues, prudence)
```

### snap

Accroche la progression a des points precis apres le scroll.

```js
snap: 0.25                // accroche tous les 25%
snap: [0, 0.25, 0.5, 1]  // accroche aux points specifiques
snap: "labels"            // accroche aux labels du timeline

// Config avancee
snap: {
  snapTo: "labels",
  duration: { min: 0.2, max: 0.8 },
  delay: 0.1,
  ease: "power1.inOut",
  directional: true,     // snap dans la direction du scroll
}
```

### toggleActions

Definit le comportement aux 4 moments : `onEnter`, `onLeave`, `onEnterBack`, `onLeaveBack`.

Actions possibles : `play`, `pause`, `resume`, `reset`, `restart`, `complete`, `reverse`, `none`.

```js
toggleActions: "play none none none"     // defaut
toggleActions: "play pause resume reverse" // classique
toggleActions: "restart none none reset"   // reset a chaque entree
```

### toggleClass

```js
toggleClass: "active"                           // toggle sur le trigger
toggleClass: { targets: ".box", className: "active" } // toggle sur d'autres elements
```

### markers

Debug visuel. **A retirer en production.**

```js
markers: true
markers: { startColor: "green", endColor: "red", fontSize: "12px" }
```

## Callbacks

```js
ScrollTrigger.create({
  trigger: ".section",
  start: "top center",
  end: "bottom center",
  onEnter:     (self) => {},  // scroll down, entre dans la zone
  onLeave:     (self) => {},  // scroll down, sort de la zone
  onEnterBack: (self) => {},  // scroll up, re-entre dans la zone
  onLeaveBack: (self) => {},  // scroll up, sort par le haut
  onUpdate:    (self) => {    // chaque frame pendant scrub
    self.progress;    // 0-1
    self.direction;   // 1 (down) ou -1 (up)
    self.isActive;    // dans la zone ?
    self.getVelocity(); // vitesse du scroll
  },
  onToggle:    (self) => {},  // quand isActive change
  onRefresh:   (self) => {},  // quand les positions sont recalculees
  onScrubComplete: () => {},  // quand le scrub finit de rattraper
});
```

## containerAnimation

Permet de creer des ScrollTriggers pour des elements a l'interieur d'un scroll horizontal.

```js
// 1. Creer le scroll horizontal
const panels = gsap.utils.toArray(".panel");
const scrollTween = gsap.to(panels, {
  xPercent: -100 * (panels.length - 1),
  ease: "none", // OBLIGATOIRE: ease none sur le tween parent
  scrollTrigger: {
    trigger: ".panels-container",
    pin: true,
    scrub: 1,
    end: () => "+=" + document.querySelector(".panels-container").scrollWidth,
  },
});

// 2. Animer des elements individuels dans le scroll horizontal
panels.forEach((panel) => {
  gsap.from(panel.querySelector(".content"), {
    opacity: 0,
    y: 50,
    scrollTrigger: {
      trigger: panel,
      containerAnimation: scrollTween, // LIE au scroll horizontal
      start: "left center",            // axes horizontaux !
      end: "center center",
      scrub: true,
    },
  });
});
```

**Pieges containerAnimation** :
- Le tween parent DOIT avoir `ease: "none"`
- Les start/end utilisent des axes horizontaux (`left`, `right`, `center`)
- Ne PAS mettre de `pin` sur les ScrollTriggers enfants
- Ne PAS utiliser `snap` sur les enfants

## ScrollTrigger.batch()

Anime les elements par lots quand ils entrent dans le viewport. Ideal pour les grilles.

```js
ScrollTrigger.batch(".card", {
  onEnter: (elements, triggers) => {
    gsap.to(elements, {
      opacity: 1,
      y: 0,
      stagger: 0.1,
      overwrite: true,
    });
  },
  onLeave: (elements) => {
    gsap.set(elements, { opacity: 0, y: 30 });
  },
  onEnterBack: (elements) => {
    gsap.to(elements, { opacity: 1, y: 0, stagger: 0.1 });
  },
  start: "top 85%",
  // interval: 0.1, // temps de groupement (defaut: 0.1s)
});

// Setup initial
gsap.set(".card", { opacity: 0, y: 30 });
```

## matchMedia

Animations responsives avec cleanup automatique.

```js
ScrollTrigger.matchMedia({
  // Desktop
  "(min-width: 960px)": function () {
    gsap.to(".box", {
      x: 500,
      scrollTrigger: { trigger: ".section", scrub: true },
    });
    // Tout ce qui est cree ici est automatiquement kill quand le media ne matche plus
  },

  // Mobile
  "(max-width: 959px)": function () {
    gsap.to(".box", {
      y: 200,
      scrollTrigger: { trigger: ".section", scrub: true },
    });
  },

  // Toutes tailles
  all: function () {
    gsap.to(".always", { opacity: 1 });
  },
});
```

## Refresh

ScrollTrigger recalcule les positions sur resize. Parfois il faut forcer manuellement :

```js
// Apres chargement d'images, changement de contenu dynamique, etc.
ScrollTrigger.refresh();

// Attendre que les fonts/images soient chargees
ScrollTrigger.refresh(true); // safe mode : attend le prochain tick

// Recalculer un seul ScrollTrigger
myTrigger.refresh();

// Sort order : controle l'ordre de refresh
ScrollTrigger.sort(); // trie par position de start (recommande apres ajout dynamique)
```

## Methodes statiques utiles

```js
ScrollTrigger.getAll()                // tous les ScrollTriggers actifs
ScrollTrigger.getById("myId")         // par id
ScrollTrigger.killAll()               // detruit tout
ScrollTrigger.saveStyles(".box")      // sauvegarde les styles avant matchMedia
ScrollTrigger.scrollerProxy(el, {})   // custom scroller (Locomotive, Lenis)
ScrollTrigger.normalizeScroll(true)   // normalise le scroll touch (anti-overscroll)
ScrollTrigger.config({ limitCallbacks: true }) // optimize perf
```

## Integration smooth scroll (Lenis)

```js
import Lenis from "lenis";

const lenis = new Lenis();
lenis.on("scroll", ScrollTrigger.update);
gsap.ticker.add((time) => lenis.raf(time * 1000));
gsap.ticker.lagSmoothing(0);
```

## Cleanup (React)

```jsx
useGSAP(() => {
  ScrollTrigger.create({
    trigger: sectionRef.current,
    start: "top center",
    onEnter: () => { /* ... */ },
  });
  // useGSAP kill automatiquement tous les ScrollTriggers crees dans le scope
}, { scope: containerRef });
```
