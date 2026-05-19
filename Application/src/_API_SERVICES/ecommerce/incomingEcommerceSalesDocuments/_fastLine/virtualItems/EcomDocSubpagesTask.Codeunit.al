#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
codeunit 6150899 "NPR Ecom Doc Subpages Task"
{
    // Page background task that builds the data for all virtual-item subpages on the Ecom Sales
    // Document page in a single child session. Today: vouchers. Future: tickets, memberships, etc. —
    // add one Build<Subpage>Payload procedure and one corresponding call in OnRun, plus a
    // ResultKeyTok() for the parent to fan out on completion.
    Access = Internal;

    trigger OnRun()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        Params: Dictionary of [Text, Text];
        Result: Dictionary of [Text, Text];
        HeaderSystemId: Guid;
    begin
        Params := Page.GetBackgroundParameters();
        if not Evaluate(HeaderSystemId, Params.Get(HeaderSystemIdParamTok())) then
            exit;
        if not EcomSalesHeader.GetBySystemId(HeaderSystemId) then
            exit;

        BuildVouchersPayload(EcomSalesHeader, Result);

        Page.SetBackgroundTaskResult(Result);
    end;

    local procedure BuildVouchersPayload(EcomSalesHeader: Record "NPR Ecom Sales Header"; var Result: Dictionary of [Text, Text])
    var
        TempVoucher: Record "NPR NpRv Voucher" temporary;
        VchrImpl: Codeunit "NPR EcomCreateVchrImpl";
        VouchersJson: JsonArray;
        VoucherJson: JsonObject;
        VouchersJsonText: Text;
    begin
        VchrImpl.BuildVoucherTempBufferForDoc(EcomSalesHeader, TempVoucher);
        if TempVoucher.FindSet() then
            repeat
                Clear(VoucherJson);
                VoucherJson.Add('No', TempVoucher."No.");
                VoucherJson.Add('Ref', TempVoucher."Reference No.");
                VoucherJson.Add('Type', TempVoucher."Voucher Type");
                VoucherJson.Add('Desc', TempVoucher.Description);
                VoucherJson.Add('Start', Format(TempVoucher."Starting Date", 0, 9));
                VoucherJson.Add('End', Format(TempVoucher."Ending Date", 0, 9));
                VoucherJson.Add('Sid', Format(TempVoucher.SystemId, 0, 4));
                VouchersJson.Add(VoucherJson);
            until TempVoucher.Next() = 0;
        VouchersJson.WriteTo(VouchersJsonText);
        Result.Add(VouchersResultKeyTok(), VouchersJsonText);
    end;

    internal procedure HeaderSystemIdParamTok(): Text
    var
        ParamTok: Label 'HeaderSystemId', Locked = true;
    begin
        exit(ParamTok);
    end;

    internal procedure VouchersResultKeyTok(): Text
    var
        ResultKeyTok: Label 'Vouchers', Locked = true;
    begin
        exit(ResultKeyTok);
    end;
}
#endif
