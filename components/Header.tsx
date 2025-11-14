"use client";

import { useState, useEffect } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { Menu, X, Flag } from "lucide-react";
import { cn } from "@/lib/utils";

export default function Header() {
  const [scrolled, setScrolled] = useState(false);
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);

  useEffect(() => {
    const handleScroll = () => {
      setScrolled(window.scrollY > 50);
    };
    window.addEventListener("scroll", handleScroll);
    return () => window.removeEventListener("scroll", handleScroll);
  }, []);

  return (
    <motion.header
      className="fixed top-0 left-0 right-0 z-50 transition-all duration-300"
      initial={{ y: -100, opacity: 0 }}
      animate={{ y: 0, opacity: 1 }}
      transition={{ duration: 0.5 }}
    >
      <div className="max-w-6xl mx-auto px-4 py-4">
        <nav
          className={cn(
            "float-card px-6 py-4 flex items-center justify-between",
            scrolled && "shadow-lg"
          )}
        >
          {/* Logo - Left */}
          <a href="#home" className="flex items-center gap-2">
            <div className="w-8 h-8 rounded-lg bg-primary flex items-center justify-center">
              <Flag className="text-white" size={18} />
            </div>
            <span className="font-bold text-lg text-dark">RedFlag</span>
          </a>

          {/* Desktop Navigation - Right */}
          <div className="hidden md:flex items-center gap-6">
            <a href="#how-it-works" className="text-dark/70 hover:text-primary transition-colors">
              How It Works
            </a>
            <a href="#benefits" className="text-dark/70 hover:text-primary transition-colors">
              Benefits
            </a>
            <a href="/dashboard" className="text-dark/70 hover:text-primary transition-colors">
              Dashboard
            </a>
            <button className="px-6 py-2 rounded-lg bg-primary text-white font-medium hover:bg-primary/90 transition-all">
              Get Started
            </button>
          </div>

          {/* Mobile Menu Button */}
          <button
            className="md:hidden p-2 text-dark"
            onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
          >
            {mobileMenuOpen ? <X size={24} /> : <Menu size={24} />}
          </button>
        </nav>

        {/* Mobile Menu */}
        <AnimatePresence>
          {mobileMenuOpen && (
            <motion.div
              className="md:hidden mt-2 float-card px-6 py-4"
              initial={{ opacity: 0, y: -20 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: -20 }}
              transition={{ duration: 0.2 }}
            >
              <div className="flex flex-col gap-4">
                <a
                  href="#how-it-works"
                  className="text-dark/70 hover:text-primary transition-colors"
                  onClick={() => setMobileMenuOpen(false)}
                >
                  How It Works
                </a>
                <a
                  href="#benefits"
                  className="text-dark/70 hover:text-primary transition-colors"
                  onClick={() => setMobileMenuOpen(false)}
                >
                  Benefits
                </a>
                <a
                  href="/dashboard"
                  className="text-dark/70 hover:text-primary transition-colors"
                  onClick={() => setMobileMenuOpen(false)}
                >
                  Dashboard
                </a>
                <button className="px-6 py-2 rounded-lg bg-primary text-white font-medium">
                  Get Started
                </button>
              </div>
            </motion.div>
          )}
        </AnimatePresence>
      </div>
    </motion.header>
  );
}
