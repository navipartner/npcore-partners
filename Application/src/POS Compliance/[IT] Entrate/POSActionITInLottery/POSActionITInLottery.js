let main = async ({ workflow, context, captions, parameters }) => {
    let CustomerLotteryCode;
    await workflow.respond("SetupWorkflow");

    if(context.ReceiptAmount < 1)
        return await popup.error(captions.recAmountError);

    CustomerLotteryCode = await popup.input({ title: captions.title, caption: captions.lotteryCodePrompt });

    if (CustomerLotteryCode === null || CustomerLotteryCode === "") return;
    if (!CheckCodeFormat(CustomerLotteryCode)) return await popup.error(captions.codeFormatError);
    if (!CheckCodeLength(CustomerLotteryCode)) return await popup.error(captions.codeLengthError);

    return await workflow.respond("InsertCustomerLotteryCode", { CustomerLotteryCode: CustomerLotteryCode });
};

function CheckCodeFormat(lotteryCode) {
    var pattern = /^[A-Za-z0-9]+$/;
    return pattern.test(lotteryCode);
}
function CheckCodeLength(lotteryCode) {
    return lotteryCode.length >= 2 && lotteryCode.length <= 15;
}