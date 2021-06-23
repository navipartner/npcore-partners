import React from "react";
import NumpadButton from "./CountingNumpadButton";
import { motion } from "framer-motion";

export default function Numpad({
  updateInput,
  deleteInput,
  isNumpadDisabled = false,
  hasDecimalPoint,
  hasDelete,
  isDecimalPointDisabled,
  animationDelay,
}) {
  const decimalPointButton = isDecimalPointDisabled
    ? { text: ".", className: "button--disabled" }
    : hasDecimalPoint
    ? {
        text: ".",
        onClick: () => updateInput("."),
        className: "button--secondary",
      }
    : { className: "button--transparent" };

  const deleteButton = hasDelete
    ? {
        text: <i className="fa-light fa-arrow-left-long"></i>,
        onClick: deleteInput,
        className: "button--secondary",
      }
    : { className: "button--transparent" };

  const buttons = [
    { text: "7", onClick: () => updateInput(7) },
    { text: "8", onClick: () => updateInput(8) },
    { text: "9", onClick: () => updateInput(9) },
    { text: "4", onClick: () => updateInput(4) },
    { text: "5", onClick: () => updateInput(5) },
    { text: "6", onClick: () => updateInput(6) },
    { text: "1", onClick: () => updateInput(1) },
    { text: "2", onClick: () => updateInput(2) },
    { text: "3", onClick: () => updateInput(3) },
    decimalPointButton,
    { text: "0", onClick: () => updateInput(0) },
    deleteButton,
  ];

  return (
    <motion.div
      initial={{
        position: "relative",
        top: -40,
        opacity: 0,
      }}
      animate={{
        position: "relative",
        top: 0,
        opacity: 1,
        transition: {
          ease: [0.34, 1.56, 0.64, 1],
          delay: animationDelay,
        },
      }}
      className={`counting-numpad ${isNumpadDisabled ? "counting-numpad--disabled" : ""}`}
    >
      {buttons.map((button, index) => {
        return (
          <NumpadButton key={index} text={button.text} onClick={() => button.onClick()} className={button.className} />
        );
      })}
    </motion.div>
  );
}
