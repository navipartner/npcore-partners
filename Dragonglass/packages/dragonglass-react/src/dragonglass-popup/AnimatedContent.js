import React, { useEffect, forwardRef, useImperativeHandle } from "react";
import { motion, useAnimation, useMotionValue } from "framer-motion";

const AnimatedContent = forwardRef(
  (
    {
      children,
      dismissOnSwipeDown,
      offset,
      canDismissByClickingOutside,
      isTopMost,
    },
    ref
  ) => {
    useEffect(() => {
      controls.start("visible");
    }, [offset]);

    useImperativeHandle(ref, () => ({
      triggerShake() {
        controls.start("shake");
      },
    }));

    const controls = useAnimation();
    let y = useMotionValue(0);

    const isMobileView = window.innerWidth < 600;

    const startingOffset = isMobileView ? -240 : 0;

    const offsetAmount = startingOffset + offset * 50;

    const variants = {
      visible: {
        bottom: offsetAmount,
        opacity: 1,
      },
      hidden: {
        bottom: isMobileView ? -400 : -50,
        opacity: 0,
      },
      shake: {
        x: [-3, 3, -3, 3, 0],
      },
    };

    const resetIfOverThreshold = () => {
      if (y.current > 0) {
        dismissOnSwipeDown();
      } else {
        controls.start("visible");
      }
    };

    const shakeIfNotDraggable = () => {
      if (canDismissByClickingOutside && !isTopMost) {
        controls.start("shake");
      }
    };

    const isDraggable =
      isMobileView && canDismissByClickingOutside && isTopMost;

    return (
      <motion.div
        className="animated-content"
        animate={controls}
        initial="hidden"
        exit="hidden"
        drag={isDraggable && "y"}
        onTouchStart={shakeIfNotDraggable}
        style={{ y }}
        variants={variants}
        dragConstraints={{ top: 0, bottom: 200 }}
        dragElastic={0.05}
        onDragEnd={resetIfOverThreshold}
        transition={{ duration: 0.3, ease: [0.34, 1.25, 0.64, 1] }}
      >
        {children}
      </motion.div>
    );
  }
);

export default AnimatedContent;
