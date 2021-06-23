import React from "react";
import { motion } from "framer-motion";

export default function Dot({ index, needsToShift }) {
  const variants = {
    hidden: {
      opacity: 0.7,
      scale: 0.4,
      marginLeft: 0,
      marginRight: 0,
    },
    visible: {
      opacity: needsToShift ? 0 : 1,
      scale: needsToShift ? 0.7 : 1,
      marginLeft: needsToShift ? -14 : 6,
      marginRight: needsToShift ? 0 : 6,
      transition: { ease: [0.34, 1.56, 0.64, 1] },
      transitionEnd: {
        display: needsToShift ? "none" : "block",
      },
    },
  };

  return (
    <motion.i
      initial="hidden"
      animate="visible"
      variants={variants}
      className="dot fa-solid fa-circle"
    ></motion.i>
  );
}
