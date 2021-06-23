import React from "react";
import { createRipple } from "../createRipple";

export default function NumpadButton({ text, transparent, onClick }) {
  const caption =
    text === "delete" ? (
      <i className="fa-light fa-xmark"></i>
    ) : text === "ok" ? (
      <i className="fa-light fa-check"></i>
    ) : (
      text
    );

  return (
    <div
      className={`numpad-button ${
        transparent ? "numpad-button--transparent" : ""
      }`}
      onClick={(event) => {
        onClick(text);
        createRipple(event);
      }}
    >
      {caption}
    </div>
  );
}
