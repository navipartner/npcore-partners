const main = async ({ workflow }) => {
  const { listOfWallets, frontEndUx } = await workflow.respond(
    "GetAssignedWalletList",
    {}
  );

  if (!frontEndUx) {
    return;
  }
};
