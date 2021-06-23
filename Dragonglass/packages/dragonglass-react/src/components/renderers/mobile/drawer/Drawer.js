import React, { useRef } from "react";
import { useSelector } from "react-redux";
import { mobileActions } from "../../../../redux/mobile/mobile-actions";
import { drawerVisible } from "../../../../redux/mobile/mobile-selectors";
import { DrawerItems } from "./DrawerItems";
import { motion } from "framer-motion";
import { MenuButtonGridClickHandler } from "../../../../dragonglass-click-handlers/grid/MenuButtonGridClickHandler";

export const Drawer = ({ menu }) => {
  const isVisible = useSelector(drawerVisible);
  const drawerItemsRef = useRef();

  const drawerVariants = {
    hidden: {
      left: "-120%",
    },
    visible: {
      left: "0%",
      transition: { ease: [0.34, 1.56, 0.64, 1] },
    },
  };

  const scrollAndClose = () => {
    mobileActions.showDrawer(false);
    drawerItemsRef.current.scrollTop = 0;
  };

  return (
    <motion.nav
      className={`drawer ${isVisible ? "drawer--visible" : ""}`}
      onClick={() => scrollAndClose()}
      animate={isVisible ? "visible" : "hidden"}
      variants={drawerVariants}
    >
      <div className="drawer__background"></div>
      <DrawerItems
        menu={menu}
        forwarderRef={drawerItemsRef}
        clickHandler={new MenuButtonGridClickHandler()}
      />
    </motion.nav>
  );
};
