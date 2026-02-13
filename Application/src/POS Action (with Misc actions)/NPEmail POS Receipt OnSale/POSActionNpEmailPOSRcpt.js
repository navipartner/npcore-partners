const main = async ({ workflow }) => {
  try {
    const result = await workflow.respond("SendReceiptEmail");
    if (result.success) {
      console.log("Receipt email sent successfully");
    } else {
      console.warn("Receipt email not sent - no valid email address or configuration");
    }
  } catch (e) {
    console.error("Email send failed:", e);
  }
};
