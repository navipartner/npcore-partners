const main = async ({ workflow, popup, captions }) => {
  const result = await popup.input({ title: captions.title, caption: captions.referenceNoPrompt });

  if (result !== null) {
    await workflow.respond("ReprintWallet", { ReferenceNo: result});
  }
};
