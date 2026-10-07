import { StrictMode } from 'react';
import { createRoot } from 'react-dom/client';
import './design/lifa.css';
import './gallery/gallery.css';
import { Gallery } from './gallery/Gallery';

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <Gallery />
  </StrictMode>,
);
