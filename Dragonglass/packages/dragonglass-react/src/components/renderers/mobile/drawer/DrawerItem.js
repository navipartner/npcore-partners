import React from "react";
import { motion } from "framer-motion";

const variants = {
  hidden: { x: -100, opacity: 0 },
  visible: { x: 0, opacity: 1 },
};

const click = (button, clickHandler) => {
  if (clickHandler && button) {
    clickHandler.onClick(button);
  }
};

export const DrawerItem = ({ button, clickHandler }) => {
  return (
    <motion.div
      className="drawer__item"
      variants={variants}
      onClick={() => click(button, clickHandler)}
    >
      <i className={`${button.iconClass} drawer__icon`}></i>
      <div className="drawer__caption">{button.caption}</div>
    </motion.div>
  );
};
