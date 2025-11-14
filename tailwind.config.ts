import type { Config } from "tailwindcss";

const config: Config = {
  content: [
    "./pages/**/*.{js,ts,jsx,tsx,mdx}",
    "./components/**/*.{js,ts,jsx,tsx,mdx}",
    "./app/**/*.{js,ts,jsx,tsx,mdx}",
  ],
  theme: {
    extend: {
      colors: {
        primary: "#D72638",
        secondary: "#EEDED2",
        dark: "#3F3B40",
      },
      borderRadius: {
        DEFAULT: "1rem",
      },
      boxShadow: {
        "bento": "0 8px 32px rgba(100, 200, 200, 0.15)",
        "float": "0 4px 24px rgba(100, 200, 200, 0.12)",
      },
    },
  },
  plugins: [],
};
export default config;
