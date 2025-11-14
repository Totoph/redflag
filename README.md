# RedFlag - Ecommerce Bug Scanner

Discover every bug blocking your customers from buying. Automated bug checker using Surfer CLI to scan your entire ecommerce buying journey.

## Features

- 🔍 Full journey scanning from product page to checkout
- ⚡ Automated Surfer CLI diagnostics
- 📊 Instant, actionable reports
- 🎨 Modern, responsive design with bento-style UI
- 🚀 Built with Next.js 15 and React 19

## Tech Stack

- **Framework:** Next.js 15 (App Router) + TypeScript
- **Styling:** Tailwind CSS v4 + PostCSS
- **Animations:** Framer Motion + tw-animate-css
- **Icons:** Lucide React
- **Auth/Backend:** Supabase
- **Charts:** Recharts
- **Notifications:** Sonner
- **AI:** OpenAI

## Getting Started

1. **Install dependencies:**

```bash
npm install
```

2. **Set up environment variables:**

Copy `.env.local.example` to `.env.local` and fill in your credentials:

```bash
cp .env.local.example .env.local
```

Required environment variables:
- `NEXT_PUBLIC_SUPABASE_URL`
- `NEXT_PUBLIC_SUPABASE_ANON_KEY`
- `SUPABASE_SERVICE_ROLE_KEY`
- `OPENAI_API_KEY`

3. **Run the development server:**

```bash
npm run dev
```

Open [http://localhost:3000](http://localhost:3000) to see the application.

## Project Structure

```
├── app/
│   ├── api/scan/        # Scan API endpoint
│   ├── globals.css      # Global styles
│   ├── layout.tsx       # Root layout
│   └── page.tsx         # Home page
├── components/
│   ├── Header.tsx       # Floating navbar
│   ├── Hero.tsx         # Hero section with URL input
│   └── Features.tsx     # Features and benefits
├── lib/
│   ├── utils.ts         # Utility functions
│   └── supabase.ts      # Supabase client
└── styles/              # Additional styles
```

## Design System

**Color Palette:**
- Primary: `#D7638F`
- Secondary: `#EEDED2`
- Dark: `#3F3B40`

**Key Styles:**
- Border radius: `1rem`
- Finance gradient: `#D7638F` to `#EEDED2`
- Bento cards: Rounded 2xl with frosted glass effect
- Floating navbar: Fixed with scroll state

## Features to Implement

- [ ] Integrate actual Surfer CLI
- [ ] Results dashboard with charts
- [ ] User authentication
- [ ] Scan history
- [ ] Automated scheduling
- [ ] Email notifications
- [ ] Export reports

## License

MIT
