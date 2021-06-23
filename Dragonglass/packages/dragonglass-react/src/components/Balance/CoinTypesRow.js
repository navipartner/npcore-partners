import React, { useState, useRef, useEffect } from "react";
import { motion } from "framer-motion";

const CoinTypeIcon = ({ type }) => <span className={`fal fa-${type ? "money-bill" : "coin"}`}></span>;

export default function CoinTypesRow({
  isOddRow,
  coinType,
  onQuantityChange,
  isActive,
  markAsActiveOnClick,
  quantity,
  descriptionPresent,
  index,
}) {
  const [amount, setAmount] = useState(0.0);
  const quantityInputRef = useRef();

  useEffect(() => {
    if (isActive) {
      quantityInputRef.current.focus();
    }
  }, [isActive]);

  useEffect(() => {
    const amount = coinType.value * quantity;
    setAmount(amount);
  }, [quantity]);

  const updateQuantity = (event) => {
    let quantity = parseInt(event.target.value, 10);
    if (isNaN(quantity)) {
      quantity = 0;
    }

    onQuantityChange(quantity);
  };

  const onClick = () => {
    if (isActive) {
      quantityInputRef.current.focus();
    }

    markAsActiveOnClick();
  };

  const markAsActiveAndSelectAll = (event) => {
    markAsActiveOnClick();
    event.target.select();
  };

  return (
    <motion.div
      className={`row ${isOddRow ? "row--highlight" : ""} ${isActive ? "row--active" : ""}`}
      onClick={onClick}
      initial={{ position: "relative", left: -30, opacity: 0 }}
      animate={{ left: 0, opacity: 1, transition: { ease: [0.34, 1.56, 0.64, 1], delay: index * 0.04 } }}
    >
      <div className="cell">
        {coinType.value.toFixed(2)} <CoinTypeIcon type={coinType.type} />
      </div>
      {descriptionPresent ? <div className="cell">{coinType.description}</div> : null}
      <div className="cell">
        <input
          type="number"
          min="0"
          onChange={updateQuantity}
          onFocus={markAsActiveAndSelectAll}
          value={quantity ? quantity : 0}
          ref={quantityInputRef}
        />
      </div>
      <div className="cell">{amount.toFixed(2)}</div>
    </motion.div>
  );
}
