"use client";

import { useEffect, useState, useRef } from "react";
import { useSearchParams, useRouter } from "next/navigation";
import { motion } from "framer-motion";
import Header from "@/components/Header";

export default function ScanningPage() {
  const searchParams = useSearchParams();
  const router = useRouter();
  const url = searchParams.get("url");
  const [videoEnded, setVideoEnded] = useState(false);
  const [videoError, setVideoError] = useState<string | null>(null);
  const videoRef = useRef<HTMLVideoElement>(null);

  useEffect(() => {
    if (!url) {
      router.push("/");
    }
  }, [url, router]);

  const handleVideoEnd = () => {
    setVideoEnded(true);
    // Redirect to dashboard after video ends
    setTimeout(() => {
      router.push("/dashboard");
    }, 2000);
  };

  const handleVideoError = (e: React.SyntheticEvent<HTMLVideoElement, Event>) => {
    console.error("Video error:", e);
    setVideoError("Unable to load video. Please check the file format.");
  };

  return (
    <div className="min-h-screen">
      <Header />
      
      <main className="pt-32 pb-16 px-4">
        <div className="max-w-6xl mx-auto">
          {/* Header Section */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.6 }}
            className="text-center mb-8"
          >
            <h1 className="text-4xl font-bold text-dark mb-4">
              {videoEnded ? "Scan Complete!" : "Scanning Your Website..."}
            </h1>
            <p className="text-dark/60 text-lg">
              {videoEnded 
                ? "Redirecting to your results..." 
                : `Analyzing ${url}`
              }
            </p>
          </motion.div>

          {/* Video Player */}
          <motion.div
            initial={{ opacity: 0, scale: 0.95 }}
            animate={{ opacity: 1, scale: 1 }}
            transition={{ duration: 0.6, delay: 0.2 }}
            className="bento-card p-0 overflow-hidden max-w-md mx-auto"
          >
            {videoError && (
              <div className="bg-yellow-100 text-yellow-800 p-4 mb-4 rounded">
                {videoError}
              </div>
            )}
            <video
              ref={videoRef}
              className="w-full h-auto"
              muted
              playsInline
              onEnded={handleVideoEnd}
              onError={handleVideoError}
              onLoadedMetadata={() => {
                // Attempt to play once metadata is loaded
                if (videoRef.current) {
                  videoRef.current.play().catch(err => {
                    console.error("Play failed:", err);
                  });
                }
              }}
            >
              <source src="/Red%20Flag%20-%20Demo%20Video.mp4" type="video/mp4" />
              Your browser does not support the video tag.
            </video>
          </motion.div>

          {/* Loading indicator while video plays */}
          {!videoEnded && (
            <motion.div
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              transition={{ duration: 0.6, delay: 0.4 }}
              className="text-center mt-8"
            >
              <div className="flex items-center justify-center gap-3">
                <div className="w-2 h-2 bg-primary rounded-full animate-bounce" style={{ animationDelay: "0ms" }}></div>
                <div className="w-2 h-2 bg-primary rounded-full animate-bounce" style={{ animationDelay: "150ms" }}></div>
                <div className="w-2 h-2 bg-primary rounded-full animate-bounce" style={{ animationDelay: "300ms" }}></div>
              </div>
              <p className="text-dark/60 mt-4">Detecting bugs and issues...</p>
            </motion.div>
          )}

          {/* Redirect message */}
          {videoEnded && (
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.6 }}
              className="text-center mt-8"
            >
              <div className="inline-flex items-center gap-2 px-6 py-3 rounded-lg bg-green-100 text-green-700">
                <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
                </svg>
                <span>Scan completed successfully</span>
              </div>
            </motion.div>
          )}
        </div>
      </main>
    </div>
  );
}
