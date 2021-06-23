import React, { useState, useEffect } from "react";
import PasswordInput from "./PasswordInput";
import Numpad from "./Numpad";
import { runWorkflow } from "dragonglass-workflows";

export default function LoginPad({ layout }) {
  const [password, setPassword] = useState("");
  let mounted;
  useEffect(() => ((mounted = true), () => (mounted = false)));

  const updatePassword = (value) => {
    setPassword(`${password}${value}`);
  };

  const deletePassword = () => {
    setPassword("");
  };

  const submitPassword = async () => {
    const content = {
      _getInitialContext: () => ({
        type: "SalespersonCode",
        password: password,
      }),
    };

    await runWorkflow("login", content);

    if (mounted) {
      setPassword("");
    }
  };

  return (
    <div className="login">
      <PasswordInput dotCount={password.length} />
      <Numpad
        updatePassword={updatePassword}
        deletePassword={deletePassword}
        submitPassword={submitPassword}
      />
    </div>
  );
}
