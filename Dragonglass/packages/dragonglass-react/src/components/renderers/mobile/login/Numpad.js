import React from "react";
import NumpadButton from "./NumpadButton";

export default function Numpad({
  updatePassword,
  deletePassword,
  submitPassword,
}) {
  const buttons = [
    { text: "7", onClick: () => updatePassword(7) },
    { text: "8", onClick: () => updatePassword(8) },
    { text: "9", onClick: () => updatePassword(9) },
    { text: "4", onClick: () => updatePassword(4) },
    { text: "5", onClick: () => updatePassword(5) },
    { text: "6", onClick: () => updatePassword(6) },
    { text: "1", onClick: () => updatePassword(1) },
    { text: "2", onClick: () => updatePassword(2) },
    { text: "3", onClick: () => updatePassword(3) },
    { text: "delete", onClick: () => deletePassword(), transparent: true },
    { text: "0", onClick: () => updatePassword(0) },
    { text: "ok", onClick: () => submitPassword(), transparent: true },
  ];

  return (
    <div className="numpad">
      {buttons.map((button) => {
        return (
          <NumpadButton
            key={button.text}
            text={button.text}
            transparent={button.transparent}
            onClick={() => button.onClick()}
          />
        );
      })}
    </div>
  );
}
