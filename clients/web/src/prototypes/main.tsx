import { StrictMode } from 'react';
import { createRoot } from 'react-dom/client';
import '../design/lifa.css';
import './prototypes.css';
import { PrototypeScreen } from './Screens';

// Prototype screens for the end-to-end demo: one per mobile journey, built only from the design-system
// components. Open /prototypes.html?screen=<id> at a 390 × 844 viewport. Not the shipped app (step 4).
const screen = new URLSearchParams(window.location.search).get('screen') ?? 'home';

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <PrototypeScreen id={screen} />
  </StrictMode>,
);
