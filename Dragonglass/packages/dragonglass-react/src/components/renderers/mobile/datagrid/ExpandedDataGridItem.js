import React from "react";
import { motion } from "framer-motion";

export default function ExpandedDataGridItem({ onClick, id, item }) {
  const { itemName, quantity, price, priceCaption, total, totalCaption } = item;

  //TODO: Return regular data with styling and non-hardcoded animations/transitions
  return (
    <motion.div
      className="expanded-item"
      onClick={onClick}
      layoutId={`daga-grid-item-${id}`}
      transition={{ duration: 0.3, ease: [0.34, 1.25, 0.64, 1] }}
      exit={{ opacity: 0 }}
    >
      <motion.p
        initial={{ opacity: 0, x: -20 }}
        animate={{
          opacity: 1,
          x: 0,
          transition: {
            delay: 0.2,
          },
        }}
        exit={{ opacity: 0, x: -20 }}
      >
        Click anywhere to return to normal view.
      </motion.p>
      <motion.div
        initial={{ opacity: 0, x: -20 }}
        animate={{
          opacity: 1,
          x: 0,
          transition: {
            delay: 0.3,
          },
        }}
        exit={{ opacity: 0, x: -20 }}
      >
        <span>{`${itemName}: ${quantity}`}</span>
      </motion.div>
      <motion.div
        initial={{ opacity: 0, x: -20 }}
        animate={{
          opacity: 1,
          x: 0,
          transition: {
            delay: 0.4,
          },
        }}
        exit={{ opacity: 0, x: -20 }}
      >
        <span>{`${priceCaption}: ${price}`}</span>
      </motion.div>
      <motion.div
        initial={{ opacity: 0, x: -20 }}
        animate={{
          opacity: 1,
          x: 0,
          transition: {
            delay: 0.5,
          },
        }}
        exit={{ opacity: 0, x: -20 }}
      >
        <span>{`${totalCaption}: ${total}`}</span>
      </motion.div>
    </motion.div>
  );
}
