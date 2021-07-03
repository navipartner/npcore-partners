import React from "react";

export default function NumpadButton({ text, onClick, className }) {
  return (
    <div className={`button ${className ? className : ""}`} onClick={() => onClick(text)}>
      {text}
    </div>
  );
}
