You are an autonomous Senior Frontend Engineer. Your task is to initialize, architect, and completely build a production-ready, modular landing page for a cutting-edge bioinformatics company named "HelixVibe Analytics" directly in the local workspace.

Do not just output code to the terminal or chat display. Use your file manipulation tools to create the folder structure and write the files directly to the disk. Do not use external frameworks (no Tailwind, Bootstrap, React, etc.)—everything must be raw, vanilla HTML5, CSS3, and modern JavaScript.

### 1. REQUIRED WORKSPACE ARCHITECTURE
Create exactly the following file and folder structure in the root directory:
├── index.html
├── css/
│   └── styles.css
└── js/
    └── main.js

### 2. CORE COMPONENT & TECHNICAL SPECIFICATIONS

#### FILE: index.html
- Create a valid HTML5 document boilerplate with correct meta viewport tags.
- Link the external stylesheet correctly as `css/styles.css`.
- Link the external JavaScript correctly as `js/main.js` (ensure it loads after the DOM or uses defer/async appropriately).
- Write semantic HTML5 structure containing: <header>, <nav>, <main>, <section> for services, an <article> for the company bio, and a <footer>.

#### FILE: css/styles.css
- **Theme:** Design a beautiful, high-tech, clinical aesthetic using exclusively a White and Pink color palette. Use pastel pink for subtle backgrounds, vibrant magenta or deep rose for interactive states/buttons/headers, and charcoal/dark gray strictly for body text readability.
- **Layout:** Implement a fully responsive design using CSS Flexbox and Grid. Ensure sections scale beautifully from a 375px mobile screen up to a 1440px desktop monitor without overlapping elements.
- **Animations:** Create a pure CSS-animated element in the Hero section that visually simulates a rotating DNA double-helix or abstract data nodes using pink accents. 
- Include smooth transition effects (`transition: all 0.3s ease-in-out`) for all interactive elements.

#### FILE: js/main.js
- Ensure all logic executes safely after the DOM is fully interactive.
- **Component 1 (Mobile Menu):** Implement the logic for a responsive hamburger menu in the navigation bar. Clicking it must toggle CSS classes to reveal the mobile menu.
- **Component 2 (Interactive Bio-Widget):** Code the logic for an "Instant Sequence Analyzer" dashboard widget. It must look for a textarea where a user inputs a mock DNA string (e.g., "ATCGATTGCA") and an analyze button. Clicking the button must:
  1. Trigger a visible loading state/spinner for exactly 1.5 seconds.
  2. Dynamically inject simulated, pink-styled metrics below it (e.g., "GC Content: 48%", "Sequence Length: 10bp", "Target Molecules: 3") into the DOM without a page refresh.

### 3. AGENT EXECUTION RULES
- Write COMPLETE, production-ready code. Do not use code truncation, ellipses (...), or comments like "// implement logic here". Every function and style block must be fully realized.
- Once you have successfully written all files to the workspace, verify that the relative paths between the HTML, CSS, and JS are correct, and then signal that the task is complete.