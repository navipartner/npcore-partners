import React from "react";
import { motion } from "framer-motion";
import Lottie from "lottie-react";
import emptyCartAnimation from "../../../../lottie/empty_cart.json";
import { createRipple } from "../createRipple";
import { mobileActions } from "../../../../redux/mobile/mobile-actions";
import { MOBILE_SEARCH_TYPES } from "../mobileConstants";

export default function EmptyCart() {
  const stagger = {
    slide: {
      transition: {
        staggerChildren: 0.15,
        delayChildren: 0.15,
      },
    },
  };

  const variants = {
    initial: {
      left: "-120%",
    },
    slide: {
      left: "0%",
      transition: { ease: [0.34, 1.56, 0.64, 1] },
    },
  };

  const variantsRight = {
    initial: {
      right: "-120%",
    },
    slide: {
      right: "0%",
      transition: { ease: [0.34, 1.56, 0.64, 1] },
    },
  };

  const addItem = (event) => {
    createRipple(event, true);
    mobileActions.openSearch(MOBILE_SEARCH_TYPES.ITEM);
  };

  return (
    <motion.div className="empty-cart" variants={stagger} animate="slide">
      <motion.div
        variants={variants}
        initial="initial"
        key={1}
        className="empty-cart__image"
      >
        <Lottie animationData={emptyCartAnimation} />
      </motion.div>

      <motion.div
        className="empty-cart__caption"
        variants={variantsRight}
        initial="initial"
        key={2}
      >
        The cart is empty, why don't you add an item?
      </motion.div>
      <motion.div
        className="empty-cart__call-to-action"
        variants={variants}
        initial="initial"
        key={3}
        onClick={(event) => addItem(event)}
      >
        <i className="fa-regular fa-plus empty-cart__icon"></i> Add item
      </motion.div>
    </motion.div>
  );
}
