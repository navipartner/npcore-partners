const main = async ({ workflow }) => {
  await workflow.respond("CreateMember");
  await workflow.respond("TermsAndConditions");
};
