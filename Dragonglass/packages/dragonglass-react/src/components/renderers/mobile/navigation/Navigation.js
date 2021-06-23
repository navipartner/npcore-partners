import React from "react";
import { useSelector } from "react-redux";
import { defaultPage } from "../../../../redux/mobile/mobile-selectors";
import Button from "./Button";
import Indicator from "./Indicator";

export const Navigation = ({ buttons }) => {
  const page = useSelector(defaultPage);
  const defaultIndex = buttons.indexOf(
    buttons.find((button) => button.page === page)
  );
  return (
    <nav className="nav">
      {buttons.map((button, index) => (
        <Button {...button} key={index} index={index - defaultIndex} />
      ))}
      <Indicator defaultIndex={defaultIndex} count={buttons.length} />
    </nav>
  );
};
