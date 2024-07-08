let main = async ({ workflow, parameters, popup, captions }) => {
    debugger;
    if (parameters.DeductCommision) {
        if (parameters.CommisionAccount === "") {
            popup.error(captions.InvalidParameters);
            return;
        }
        if (parameters.CommisionPercentage == 0 && parameters.CommisionType == 0) {
            popup.error(captions.InvalidParameters);
            return;
        };
        if (parameters.CommisionAmount == 0 && parameters.CommisionType == 1) {
            popup.error(captions.InvalidParameters);
            return;
        };
    };
    let referenceNo;
    const { voucherType } = await workflow.respond("SetVoucherType");
    if (voucherType === null || voucherType === "") return;

    referenceNo = await popup.input({ title: captions.ScanRetailVoucherTitle, caption: captions.ScanRetailVoucherCaption });
    if (referenceNo === null) return;

    const { voucherSet } = await workflow.respond("ScanVoucher", { VoucherRefNo: referenceNo, voucherType: voucherType });
    if (voucherSet) {
        if (parameters.DeductCommision) {
            await workflow.respond("InsertCommision", { voucherType: voucherType });
        }
    };
}