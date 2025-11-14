"use client";

import { motion } from "framer-motion";
import { ScanSearch, Zap, FileCheck, CheckCircle2, TrendingUp, ShoppingCart, Gauge } from "lucide-react";

const steps = [
  {
    icon: ScanSearch,
    title: "Full Journey Scan",
    description: "We simulate real customer behavior across your ecommerce platform and capture every interaction.",
  },
  {
    icon: Zap,
    title: "Automated Surfer CLI Diagnostics",
    description: "Our engine performs a full technical sweep using the Surfer CLI to detect bugs, inconsistencies, delays, and red flags.",
  },
  {
    icon: FileCheck,
    title: "Instant, Actionable Report",
    description: "Receive clear insights on what's breaking, what's slowing customers down, and what's blocking conversions — with prioritized fixes.",
  },
];

const benefits = [
  {
    icon: CheckCircle2,
    title: "Detect bugs before your shoppers do",
    color: "bg-primary",
  },
  {
    icon: TrendingUp,
    title: "Improve conversion rates with a flawless buying path",
    color: "bg-primary",
  },
  {
    icon: ShoppingCart,
    title: "Reduce cart abandonment",
    color: "bg-dark",
  },
  {
    icon: Gauge,
    title: "Speed up QA and development workflows",
    color: "bg-primary",
  },
  {
    icon: ScanSearch,
    title: "Monitor your ecommerce performance continuously",
    color: "bg-dark",
  },
];

export default function Features() {
  return (
    <>
      {/* How It Works Section */}
      <section id="how-it-works" className="py-16 px-4">
        <div className="max-w-5xl mx-auto">
          <motion.div
            className="text-center mb-12"
            initial={{ opacity: 0, y: 20 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ duration: 0.6 }}
          >
            <h2 className="text-3xl md:text-4xl font-bold text-dark mb-4">How It Works</h2>
            <p className="text-lg text-dark/60 max-w-2xl mx-auto">
              Every click, scroll, and form field matters. Even a small glitch at checkout can cause thousands in lost revenue.
            </p>
          </motion.div>

          <div className="grid md:grid-cols-3 gap-6">
            {steps.map((step, index) => {
              const Icon = step.icon;
              return (
                <motion.div
                  key={index}
                  className="bento-card"
                  initial={{ opacity: 0, y: 20 }}
                  whileInView={{ opacity: 1, y: 0 }}
                  viewport={{ once: true }}
                  transition={{ duration: 0.6, delay: index * 0.1 }}
                >
                  <div className="w-12 h-12 rounded-lg bg-primary flex items-center justify-center mb-4">
                    <Icon className="text-white" size={24} />
                  </div>
                  <h3 className="text-xl font-semibold text-dark mb-3">{step.title}</h3>
                  <p className="text-dark/60 leading-relaxed">{step.description}</p>
                </motion.div>
              );
            })}
          </div>
        </div>
      </section>

      {/* Benefits Section */}
      <section id="benefits" className="py-16 px-4 bg-white/50">
        <div className="max-w-5xl mx-auto">
          <motion.div
            className="text-center mb-12"
            initial={{ opacity: 0, y: 20 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ duration: 0.6 }}
          >
            <h2 className="text-3xl md:text-4xl font-bold text-dark mb-4">Key Benefits</h2>
            <p className="text-lg text-dark/60">
              Transform your ecommerce experience and maximize revenue
            </p>
          </motion.div>

          <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-4">
            {benefits.map((benefit, index) => {
              const Icon = benefit.icon;
              return (
                <motion.div
                  key={index}
                  className="bento-card"
                  initial={{ opacity: 0, y: 20 }}
                  whileInView={{ opacity: 1, y: 0 }}
                  viewport={{ once: true }}
                  transition={{ duration: 0.6, delay: index * 0.1 }}
                >
                  <div className={`w-10 h-10 rounded-lg ${benefit.color} flex items-center justify-center mb-3`}>
                    <Icon className="text-white" size={20} />
                  </div>
                  <h3 className="text-base font-medium text-dark">{benefit.title}</h3>
                </motion.div>
              );
            })}
          </div>
        </div>
      </section>

      {/* CTA Section */}
      <section className="py-20 px-4">
        <div className="max-w-3xl mx-auto">
          <motion.div
            className="bento-card text-center py-12 px-6"
            initial={{ opacity: 0, y: 20 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ duration: 0.6 }}
          >
            <h2 className="text-3xl md:text-4xl font-bold text-dark mb-4">
              Ready to Uncover Hidden Issues?
            </h2>
            <p className="text-lg text-dark/60 mb-6 max-w-xl mx-auto">
              Scan your site now and uncover hidden issues in minutes. Start optimizing your customer journey today.
            </p>
            <button className="px-8 py-3 rounded-lg bg-primary text-white text-base font-semibold hover:bg-primary/90 transition-all shadow-md">
              Start Your Free Scan
            </button>
          </motion.div>
        </div>
      </section>
    </>
  );
}
