import React from "react";
import { useSelector } from "react-redux";
import { motion, AnimatePresence } from "framer-motion";

export const Badge = ({ dataSource }) => {
  const set = useSelector((state) => state.data.sets[dataSource]);

  const isVisible = set && set.rows && set.rows.length;

  return (
    <AnimatePresence>
      {isVisible && (
        <motion.div
          animate={{ scale: [0.85, 1.15, 1], transition: { duration: 0.3 } }}
          exit={{
            scale: 0,
            opacity: 0,
            transition: { duration: 0.3 },
          }}
          className="nav__badge"
        >
          {set.rows.length}
        </motion.div>
      )}
    </AnimatePresence>
  );
};
