import React from "react";
import { motion } from "framer-motion";

export default function Filter({ text, isActive, onClick }) {
  return (
    <motion.div className={`filter ${isActive ? "filter--active" : ""}`} onClick={onClick}>
      {text}
      {isActive && (
        <motion.div
          className="filter__active-background"
          layoutId="active-filter-background"
          transition={{
            duration: 0.2,
          }}
        />
      )}
    </motion.div>
  );
}
