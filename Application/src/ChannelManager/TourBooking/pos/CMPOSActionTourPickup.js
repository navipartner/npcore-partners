const main = async ({ workflow, popup, captions }) => {
  const search = await popup.input({ title: captions.title, caption: captions.searchCaption });
  if (search == null) {
    return;
  }

  await workflow.respond("pickup", { search });
};
