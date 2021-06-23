import React from "react";
import Dot from "./Dot";
import { motion } from "framer-motion";

export default function PasswordInput({ dotCount }) {
  let numberOfItemsAboveThreshold = 0;
  const dotThreshold = 8;

  if (dotCount > dotThreshold) {
    numberOfItemsAboveThreshold = dotCount - dotThreshold;
  }

  const variants = {
    initial: {
      top: "2em",
      scale: 1,
    },
    hasInput: {
      top: "0em",
      scale: 0.8,
      transition: { ease: [0.34, 1.56, 0.64, 1] },
    },
  };

  return (
    <div className="password-input">
      <motion.div
        variants={variants}
        animate={dotCount === 0 ? "initial" : "hasInput"}
        className="password-input__caption"
      >
        Salesperson Code
      </motion.div>
      <div className="password-input__password">
        {Array(dotCount)
          .fill({})
          .map((item, index) => {
            return (
              <Dot
                index={index}
                key={index}
                needsToShift={index < numberOfItemsAboveThreshold}
              />
            );
          })}
      </div>
    </div>
  );
}
