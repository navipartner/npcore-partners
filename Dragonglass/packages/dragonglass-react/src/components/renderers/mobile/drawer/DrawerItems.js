import React from "react";
import { DrawerItem } from "./DrawerItem";
import { NAV } from "dragonglass-nav";
import { motion } from "framer-motion";
import { useMenu } from "../../../../redux/menu/menu-selectors";

export const DrawerItems = ({ forwarderRef, menu, clickHandler }) => {
  const LOGO_IMAGE = "npretaillogo_med.png";
  const src = NAV.instance.mapPath(`Images/${LOGO_IMAGE}`);

  const itemVariants = {
    visible: {
      transition: {
        staggerChildren: 0.05,
        delayChildren: 0.15,
      },
    },
  };

  const menuItems = useMenu(menu);

  return (
    <motion.div
      className="drawer__items"
      variants={itemVariants}
      ref={forwarderRef}
    >
      <div className="logo-container">
        <img className="logo-container__image" src={src} />
      </div>
      {menuItems.map((item, index) => (
        <DrawerItem button={item} key={index} clickHandler={clickHandler} />
      ))}
    </motion.div>
  );
};
