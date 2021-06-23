import React, { useState, useEffect } from "react";
import { createRipple } from "../createRipple";
import { Workflow } from "dragonglass-workflows";
import {
  motion,
  useMotionValue,
  useAnimation,
  useTransform,
  useMotionTemplate,
  AnimatePresence,
} from "framer-motion";
import { StateStore } from "../../../../redux/StateStore";
import { setSetCurrentPositionAction } from "../../../../redux/actions/dataActions";
import ExpandedDataGridItem from "./ExpandedDataGridItem";

export const DataGridItem = ({
  provider,
  item,
  dataSource,
  clickHandler,
  setCurrentlySwipedItemIndex,
  currentlySwipedItemIndex,
  itemIndex,
}) => {
  const swipeThreshold = window.innerWidth * 0.4;
  let x = useMotionValue(0);
  let sliderOpacity = useTransform(
    x,
    [-swipeThreshold, 0, swipeThreshold],
    [0.75, 1, 0.75]
  );

  let rightMenuOpacity = useTransform(x, [-swipeThreshold, 0], [1, 0]);
  let leftMenuOpacity = useTransform(x, [0, swipeThreshold], [0, 1]);

  let rightScaleAmount = useTransform(x, [-swipeThreshold, 0], [1, 0.75]);
  const rightScale = useMotionTemplate`scale(${rightScaleAmount})`;

  let leftScaleAmount = useTransform(x, [0, swipeThreshold], [0.75, 1]);
  const leftScale = useMotionTemplate`scale(${leftScaleAmount})`;

  let rightOffset = useTransform(x, [-swipeThreshold, 0], [0, 20]);
  let leftOffset = useTransform(x, [0, swipeThreshold], [-20, 0]);

  let leftZIndex = useTransform(x, [0, swipeThreshold], [1, 2]);

  const controls = useAnimation();

  const resetOnDragEnd = () => {
    if (x.current > -swipeThreshold && x.current < swipeThreshold) {
      controls.start("reset");
      setCurrentlySwipedItemIndex(null);
    }
  };

  const hiddenMenuButtonclick = async (event, button) => {
    createRipple(event, true);

    if (button && button.action) {
      StateStore.dispatch(
        setSetCurrentPositionAction(dataSource, item.position)
      );

      await Workflow.run(button.action);

      resetSwipedItem();
    }
  };

  const setSwipedItem = () => {
    if (currentlySwipedItemIndex !== itemIndex) {
      setCurrentlySwipedItemIndex(itemIndex);
    }
  };

  const itemClick = () => {
    if (currentlySwipedItemIndex !== null) {
      setCurrentlySwipedItemIndex(null);
    } else {
      setIsExpanded(!isExpanded);
    }
  };

  const resetSwipedItem = () => {
    // reset other item if it's locked
    if (currentlySwipedItemIndex !== itemIndex) {
      setCurrentlySwipedItemIndex(null);
    } else {
      resetPosition();
    }
  };

  const [isExpanded, setIsExpanded] = useState(false);

  const resetPosition = () => {
    controls.stop();
    controls.start("reset");
    setIsExpanded(false);
  };

  useEffect(() => {
    if (currentlySwipedItemIndex !== itemIndex) {
      resetPosition();
    }
  }, [currentlySwipedItemIndex]);

  const itemName = item.fields[provider.layout[0].controls[0].fieldNo];
  const quantity = item.fields[provider.layout[0].controls[1].fieldNo];
  const price = item.fields[provider.layout[1].controls[0].fieldNo];
  const priceCaption = provider.layout[1].controls[0].caption;
  const total = item.fields[provider.layout[1].controls[1].fieldNo];
  const totalCaption = provider.layout[1].controls[1].caption;

  return (
    <motion.div
      className="data-grid__item"
      onClick={itemClick}
      exit={{
        scale: 0.75,
        opacity: 0,
        margin: "-37.5px",
        transition: {
          margin: {
            delay: 0.25,
          },
        },
      }}
      key={itemIndex}
    >
      <motion.div
        className="data-grid__slider"
        drag="x"
        dragConstraints={{ left: -swipeThreshold, right: swipeThreshold }}
        dragElastic={0.1}
        dragTransition={{ bounceStiffness: 400 }}
        style={{ x, opacity: sliderOpacity }}
        onDragEnd={resetOnDragEnd}
        onDragStart={setSwipedItem}
        animate={controls}
        variants={{
          reset: { x: 0 },
        }}
        transition={{ duration: 0.3, ease: [0.34, 1.25, 0.64, 1] }}
      >
        <div className="item-data">
          <div className="item-data__name-container">
            <div className="item-data__name">{itemName}</div>
            <span>{` (${quantity})`}</span>
          </div>
          <div className="item-data__price-per-unit">
            <div>{price}</div>
            <div className="item-data__caption">{priceCaption}</div>
          </div>
          <div className="item-data__price-total">
            <div className="item-data__price-total-value">{total}</div>
            <div className="item-data__caption">{totalCaption}</div>
          </div>
          <motion.div
            className="expanded-item-container"
            layoutId={`daga-grid-item-${itemIndex}`}
          ></motion.div>
        </div>
      </motion.div>

      <motion.div
        className="data-grid__hidden-menu data-grid__hidden-menu--left"
        style={{ opacity: leftMenuOpacity, zIndex: leftZIndex }}
      >
        {provider.buttons.left.map((button, index) => {
          return (
            <motion.i
              key={index}
              className={`fa-light ${button.icon} hidden-menu-button`}
              onClick={(event) =>
                hiddenMenuButtonclick(event, button, clickHandler)
              }
              style={{ transform: leftScale, x: leftOffset }}
            ></motion.i>
          );
        })}
      </motion.div>

      <motion.div
        className="data-grid__hidden-menu data-grid__hidden-menu--right"
        style={{ opacity: rightMenuOpacity }}
      >
        {provider.buttons.right.map((button, index) => {
          return (
            <motion.i
              key={index}
              className={`fa-light ${button.icon} hidden-menu-button`}
              onClick={(event) =>
                hiddenMenuButtonclick(event, button, clickHandler)
              }
              style={{ transform: rightScale, x: rightOffset }}
            ></motion.i>
          );
        })}
      </motion.div>

      <AnimatePresence>
        {isExpanded && (
          <ExpandedDataGridItem
            onClick={() => setIsExpanded(false)}
            key="expanded"
            id={itemIndex}
            item={{
              itemName,
              quantity,
              price,
              priceCaption,
              total,
              totalCaption,
            }}
          />
        )}
      </AnimatePresence>
    </motion.div>
  );
};
