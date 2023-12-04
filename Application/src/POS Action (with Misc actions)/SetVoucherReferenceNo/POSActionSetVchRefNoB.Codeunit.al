codeunit 6184646 "NPR POS Action Set Vch Ref NoB"
{
    Access = Internal;

    internal procedure AssignReferenceNo(SaleLinePOS: Record "NPR POS Sale Line"; VocuherNo: Code[20]; ReferenceNo: Text[50])
    var
        ReferenceNoAlreadyUsedLbl: Label 'Reference No. %1 already used.';
        EmptyReferenceNoErrorLbl: Label 'Reference No. cannot be empty.';
    begin
        if ReferenceNo = '' then
            Error(EmptyReferenceNoErrorLbl);
        if CheckReferenceNoAlreadyUsed(VocuherNo, ReferenceNo) then
            Error(ReferenceNoAlreadyUsedLbl, ReferenceNo);
        SetReferenceNo(SaleLinePOS, ReferenceNo);
    end;

    local procedure SetReferenceNo(SaleLinePOS: Record "NPR POS Sale Line"; NewReferenceNo: Text[50])
    var
        VoucherType: Record "NPR NpRv Voucher Type";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        NpRvSalesLineRef: Record "NPR NpRv Sales Line Ref.";
        LineTypeErrorLbl: Label 'The line is not a voucher. Please select a voucher.';
    begin
        if SaleLinePOS."Line Type" <> SaleLinePOS."Line Type"::"Issue Voucher" then
            Error(LineTypeErrorLbl);

        NpRvSalesLine.Reset();
        NpRvSalesLine.SetRange("Retail ID", SaleLinePOS.SystemId);
        NpRvSalesLine.SetRange(Type, NpRvSalesLine.Type::"New Voucher");
        if not NpRvSalesLine.FindFirst() then
            exit;

        if NewReferenceNo = NpRvSalesLine."Reference No." then
            exit;

        NpRvSalesLineRef.Reset();
        NpRvSalesLineRef.SetCurrentKey("Sales Line Id");
        NpRvSalesLineRef.SetRange("Sales Line Id", NpRvSalesLine.Id);
        NpRvSalesLineRef.FindFirst();

        NpRvSalesLineRef.Validate("Reference No.", NewReferenceNo);
        NpRvSalesLineRef.Modify(true);

        VoucherType.Get(NpRvSalesLine."Voucher Type");
        SaleLinePOS.Description := CopyStr(NewReferenceNo + ' ' + VoucherType.Description, 1, MaxStrLen(SaleLinePOS.Description));
        SaleLinePOS.Modify(true);
    end;

    local procedure CheckReferenceNoAlreadyUsed(VocuherNo: Code[20]; RefereceNo: Text) ReferenceNoAlreadyUsed: Boolean
    var
        VoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
    begin
        ReferenceNoAlreadyUsed := VoucherMgt.CheckReferenceNoAlreadyUsed(VocuherNo, RefereceNo);
    end;


}