import React from "react";

export default function Alert({
  messageType,
  originFile,
  originProperties,
  additionalMessage,
}) {
  return (
    <div className="alert">
      {messageType && (
        <div
          className={`alert__title ${
            messageType && `alert__title--${messageType.text}`
          }`}
        >
          <i className={`alert__title-icon ${messageType.icon}`}></i>{" "}
          <div className="alert__title-text">{messageType.text}</div>
        </div>
      )}
      <div className="alert__message">
        {originFile && <section>Error originated in {originFile}.</section>}
        {originProperties && (
          <section>
            Your data needs additional setup. Following properties need to be
            configured:
            <ul>
              {originProperties.map((property) => (
                <li key={property}>{property}</li>
              ))}
            </ul>
          </section>
        )}
        {additionalMessage && <section>{additionalMessage}</section>}
      </div>
    </div>
  );
}
