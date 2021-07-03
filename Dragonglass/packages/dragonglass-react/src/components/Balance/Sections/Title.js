import React from "react";
import { motion } from "framer-motion";
import { localize } from "../../LocalizationManager";

export default function Title({ activeSection }) {
  return (
    <motion.h1
      className="section-title"
      initial={{ position: "relative", top: -40, opacity: 0 }}
      animate={{ top: 0, opacity: 1, transition: { ease: [0.34, 1.56, 0.64, 1], delay: 0 } }}
      key={activeSection}
    >
      {localize(activeSection)}
    </motion.h1>
  );
}
