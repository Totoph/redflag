"use client";

import { useState } from "react";
import { motion } from "framer-motion";
import { 
  AlertCircle, 
  AlertTriangle, 
  Info, 
  CheckCircle2, 
  Clock,
  TrendingDown,
  ShoppingCart,
  Zap
} from "lucide-react";
import Header from "@/components/Header";

// Mock data - this would come from the API in production
const mockScanData = {
  url: "https://example-store.com",
  timestamp: "2025-11-14T10:30:00Z",
  status: "completed",
  summary: {
    totalIssues: 12,
    critical: 3,
    warnings: 6,
    info: 3,
  },
  issues: [
    {
      id: 1,
      severity: "critical",
      type: "Payment Error",
      message: "Page doesn't memorize content in case of network crash, causing payment failures and lost customer data",
      location: "/checkout",
      impact: "High - Blocks purchase completion",
      affectedUsers: "~45% of checkout attempts",
    },
    {
      id: 2,
      severity: "critical",
      type: "JavaScript Error",
      message: "Uncaught TypeError in product image gallery",
      location: "/product/*",
      impact: "High - Prevents product view",
      affectedUsers: "~30% of product page visits",
    },
    {
      id: 3,
      severity: "critical",
      type: "Form Validation",
      message: "Email validation fails with plus sign addresses",
      location: "/checkout",
      impact: "High - Blocks valid customers",
      affectedUsers: "~5% of users",
    },
    {
      id: 4,
      severity: "warning",
      type: "Performance",
      message: "Checkout page load time exceeds 3 seconds",
      location: "/checkout",
      impact: "Medium - Increases cart abandonment",
      affectedUsers: "All users",
    },
    {
      id: 5,
      severity: "warning",
      type: "Mobile Responsiveness",
      message: "Add to cart button partially hidden on mobile",
      location: "/product/*",
      impact: "Medium - Reduces mobile conversions",
      affectedUsers: "Mobile users (~60%)",
    },
    {
      id: 6,
      severity: "warning",
      type: "Broken Link",
      message: "Product category link returns 404",
      location: "/categories/electronics",
      impact: "Medium - Poor user experience",
      affectedUsers: "Category browsers",
    },
    {
      id: 7,
      severity: "info",
      type: "Best Practice",
      message: "Missing ARIA labels on checkout form",
      location: "/checkout",
      impact: "Low - Affects accessibility",
      affectedUsers: "Screen reader users",
    },
    {
      id: 8,
      severity: "info",
      type: "SEO",
      message: "Missing meta description on product pages",
      location: "/product/*",
      impact: "Low - Reduces search visibility",
      affectedUsers: "N/A",
    },
    {
      id: 9,
      severity: "info",
      type: "Performance",
      message: "Unoptimized images increase page load time",
      location: "Site-wide",
      impact: "Low - Minor performance impact",
      affectedUsers: "All users",
    },
  ],
};

const getSeverityColor = (severity: string) => {
  switch (severity) {
    case "critical":
      return "text-red-600 bg-red-50 border-red-200";
    case "warning":
      return "text-yellow-600 bg-yellow-50 border-yellow-200";
    case "info":
      return "text-blue-600 bg-blue-50 border-blue-200";
    default:
      return "text-gray-600 bg-gray-50 border-gray-200";
  }
};

const getSeverityIcon = (severity: string) => {
  switch (severity) {
    case "critical":
      return <AlertCircle className="text-red-600" size={20} />;
    case "warning":
      return <AlertTriangle className="text-yellow-600" size={20} />;
    case "info":
      return <Info className="text-blue-600" size={20} />;
    default:
      return <Info className="text-gray-600" size={20} />;
  }
};

export default function DashboardPage() {
  const [selectedSeverity, setSelectedSeverity] = useState<string | null>(null);

  const filteredIssues = selectedSeverity
    ? mockScanData.issues.filter((issue) => issue.severity === selectedSeverity)
    : mockScanData.issues;

  return (
    <div className="min-h-screen">
      <Header />
      
      <main className="pt-32 pb-16 px-4">
        <div className="max-w-7xl mx-auto">
          {/* Header Section */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.6 }}
            className="mb-8"
          >
            <h1 className="text-4xl font-bold text-dark mb-2">Bug Report Dashboard</h1>
            <p className="text-dark/60">
              Scan completed for <span className="font-semibold">{mockScanData.url}</span>
            </p>
            <p className="text-dark/50 text-sm">
              {new Date(mockScanData.timestamp).toLocaleString()}
            </p>
          </motion.div>

          {/* Summary Cards */}
          <div className="grid grid-cols-1 md:grid-cols-4 gap-4 mb-8">
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.6, delay: 0.1 }}
              className="bento-card cursor-pointer"
              onClick={() => setSelectedSeverity(null)}
            >
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-dark/60 text-sm mb-1">Total Issues</p>
                  <p className="text-3xl font-bold text-dark">{mockScanData.summary.totalIssues}</p>
                </div>
                <div className="w-12 h-12 rounded-lg bg-gray-100 flex items-center justify-center">
                  <Zap className="text-dark" size={24} />
                </div>
              </div>
            </motion.div>

            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.6, delay: 0.2 }}
              className="bento-card cursor-pointer"
              onClick={() => setSelectedSeverity("critical")}
            >
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-dark/60 text-sm mb-1">Critical</p>
                  <p className="text-3xl font-bold text-red-600">{mockScanData.summary.critical}</p>
                </div>
                <div className="w-12 h-12 rounded-lg bg-red-100 flex items-center justify-center">
                  <AlertCircle className="text-red-600" size={24} />
                </div>
              </div>
            </motion.div>

            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.6, delay: 0.3 }}
              className="bento-card cursor-pointer"
              onClick={() => setSelectedSeverity("warning")}
            >
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-dark/60 text-sm mb-1">Warnings</p>
                  <p className="text-3xl font-bold text-yellow-600">{mockScanData.summary.warnings}</p>
                </div>
                <div className="w-12 h-12 rounded-lg bg-yellow-100 flex items-center justify-center">
                  <AlertTriangle className="text-yellow-600" size={24} />
                </div>
              </div>
            </motion.div>

            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.6, delay: 0.4 }}
              className="bento-card cursor-pointer"
              onClick={() => setSelectedSeverity("info")}
            >
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-dark/60 text-sm mb-1">Info</p>
                  <p className="text-3xl font-bold text-blue-600">{mockScanData.summary.info}</p>
                </div>
                <div className="w-12 h-12 rounded-lg bg-blue-100 flex items-center justify-center">
                  <Info className="text-blue-600" size={24} />
                </div>
              </div>
            </motion.div>
          </div>

          {/* Filter Badge */}
          {selectedSeverity && (
            <div className="mb-4 flex items-center gap-2">
              <span className="text-sm text-dark/60">Filtered by:</span>
              <button
                onClick={() => setSelectedSeverity(null)}
                className="px-3 py-1 rounded-lg bg-primary/10 text-primary text-sm font-medium hover:bg-primary/20 transition-colors"
              >
                {selectedSeverity} ✕
              </button>
            </div>
          )}

          {/* Issues List */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.6, delay: 0.5 }}
            className="space-y-4"
          >
            <h2 className="text-2xl font-bold text-dark mb-4">
              Detected Issues ({filteredIssues.length})
            </h2>
            
            {filteredIssues.map((issue, index) => (
              <motion.div
                key={issue.id}
                initial={{ opacity: 0, x: -20 }}
                animate={{ opacity: 1, x: 0 }}
                transition={{ duration: 0.4, delay: index * 0.05 }}
                className={`bento-card border-l-4 ${getSeverityColor(issue.severity)} overflow-hidden`}
              >
                <div className="flex items-start gap-4">
                  <div className="flex-shrink-0 mt-1">
                    {getSeverityIcon(issue.severity)}
                  </div>
                  
                  <div className="flex-1">
                    <div className="flex items-start justify-between mb-2">
                      <div>
                        <span className={`text-xs font-semibold uppercase tracking-wide ${
                          issue.severity === "critical" ? "text-red-600" :
                          issue.severity === "warning" ? "text-yellow-600" :
                          "text-blue-600"
                        }`}>
                          {issue.severity}
                        </span>
                        <h3 className="text-lg font-semibold text-dark mt-1">{issue.type}</h3>
                      </div>
                    </div>
                    
                    <p className="text-dark/80 mb-3">{issue.message}</p>
                    
                    <div className="grid grid-cols-1 md:grid-cols-3 gap-3 text-sm">
                      <div>
                        <span className="text-dark/50">Location:</span>
                        <p className="text-dark font-mono text-xs bg-gray-100 px-2 py-1 rounded mt-1">
                          {issue.location}
                        </p>
                      </div>
                      <div>
                        <span className="text-dark/50">Impact:</span>
                        <p className="text-dark mt-1">{issue.impact}</p>
                      </div>
                      <div>
                        <span className="text-dark/50">Affected Users:</span>
                        <p className="text-dark mt-1">{issue.affectedUsers}</p>
                      </div>
                    </div>
                  </div>
                </div>
              </motion.div>
            ))}
          </motion.div>

          {/* Action Buttons */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.6, delay: 0.6 }}
            className="mt-8 flex flex-col sm:flex-row gap-4 justify-center"
          >
            <button className="px-8 py-3 rounded-lg bg-primary text-white font-medium hover:bg-primary/90 transition-all">
              Export Report
            </button>
            <button className="px-8 py-3 rounded-lg bg-white text-dark font-medium border border-gray-200 hover:border-primary hover:text-primary transition-all">
              Schedule Another Scan
            </button>
          </motion.div>
        </div>
      </main>
    </div>
  );
}
