"use client";

import { useState } from "react";
import { motion } from "framer-motion";
import { Search, ArrowRight, Loader2 } from "lucide-react";
import { toast } from "sonner";

export default function Hero() {
  const [url, setUrl] = useState("");
  const [isScanning, setIsScanning] = useState(false);

  const handleScan = async () => {
    if (!url) {
      toast.error("Please enter a URL");
      return;
    }

    // Basic URL validation
    try {
      new URL(url);
    } catch {
      toast.error("Please enter a valid URL");
      return;
    }

    setIsScanning(true);
    toast.info("Starting scan...");

    try {
      const response = await fetch("/api/scan", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({ url }),
      });

      const data = await response.json();

      if (response.ok) {
        toast.success("Scan completed successfully!");
        console.log("Scan results:", data);
        // Handle successful scan - redirect to results page or display results
      } else {
        toast.error(data.error || "Scan failed");
      }
    } catch (error) {
      toast.error("An error occurred during the scan");
      console.error("Scan error:", error);
    } finally {
      setIsScanning(false);
    }
  };

  return (
    <section className="min-h-screen flex items-center justify-center px-4 pt-24 pb-20">
      <div className="max-w-4xl w-full">
        <motion.div
          className="text-center space-y-8"
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6 }}
        >
          {/* Headline */}
          <motion.h1
            className="text-4xl md:text-6xl font-bold text-dark leading-tight"
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.6, delay: 0.1 }}
          >
            End-to-End
            <br />
            <span className="text-primary">
              Bug Checker 
            </span>
            <br />
            
          </motion.h1>

          {/* Sub-headline */}
          <motion.p
            className="text-lg md:text-xl text-dark/70 max-w-2xl mx-auto"
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.6, delay: 0.2 }}
          >
            Detect bugs and friction in just one scan.
          </motion.p>

          {/* URL Input */}
          <motion.div
            className="max-w-2xl mx-auto mt-12"
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.6, delay: 0.3 }}
          >
            <div className="bento-card p-2 flex flex-col sm:flex-row gap-2 items-stretch">
              <div className="flex-1 flex items-center gap-3 px-4 py-2">
                <Search className="text-dark/40 flex-shrink-0" size={20} />
                <input
                  type="url"
                  placeholder="Enter URL"
                  value={url}
                  onChange={(e) => setUrl(e.target.value)}
                  onKeyDown={(e) => e.key === "Enter" && handleScan()}
                  className="flex-1 bg-transparent outline-none text-dark placeholder:text-dark/40"
                  disabled={isScanning}
                />
              </div>
              <button
                onClick={handleScan}
                disabled={isScanning}
                className="px-6 py-3 rounded-lg bg-primary text-white font-medium hover:bg-primary/90 transition-all flex items-center justify-center gap-2 disabled:opacity-50 disabled:cursor-not-allowed whitespace-nowrap"
              >
                {isScanning ? (
                  <>
                    <Loader2 className="animate-spin" size={20} />
                    Scanning...
                  </>
                ) : (
                  <>
                    Scan
                    <ArrowRight size={20} />
                  </>
                )}
              </button>
            </div>
          </motion.div>

          {/* Value Proposition */}
          <motion.p
            className="text-base text-dark/60 max-w-2xl mx-auto pt-6"
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            transition={{ duration: 0.6, delay: 0.4 }}
          >
            Surfer CLI journey identifies errors, broken steps, and red flags blocking conversion.
          </motion.p>
        </motion.div>
      </div>
    </section>
  );
}
