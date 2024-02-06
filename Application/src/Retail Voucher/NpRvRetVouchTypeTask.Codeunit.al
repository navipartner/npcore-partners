codeunit 6184744 "NPR NpRv Ret. Vouch. Type Task"
{
    Access = Internal;
    trigger OnRun()
    begin
        CalculateFlowfields();
    end;

    local procedure CalculateFlowfields()
    var
        VoucherType: Record "NPR NpRv Voucher Type";
        Params: Dictionary of [Text, Text];
        Result: Dictionary of [Text, Text];
    begin
        Params := Page.GetBackgroundParameters();
        VoucherType.Get(Params.Get('VoucherTypeCode'));
        if Params.ContainsKey(Format(VoucherType.FieldNo("Voucher Qty. (Open)"))) then begin
            VoucherType.CalcFields("Voucher Qty. (Open)");
            Result.Add(Format(VoucherType.FieldNo("Voucher Qty. (Open)")), Format(VoucherType."Voucher Qty. (Open)"));
        end;
        if Params.ContainsKey(Format(VoucherType.FieldNo("Voucher Qty. (Closed)"))) then begin
            VoucherType.CalcFields("Voucher Qty. (Closed)");
            Result.Add(Format(VoucherType.FieldNo("Voucher Qty. (Closed)")), Format(VoucherType."Voucher Qty. (Closed)"));
        end;
        if Params.ContainsKey(Format(VoucherType.FieldNo("Arch. Voucher Qty."))) then begin
            VoucherType.CalcFields("Arch. Voucher Qty.");
            Result.Add(Format(VoucherType.FieldNo("Arch. Voucher Qty.")), Format(VoucherType."Arch. Voucher Qty."));
        end;

        Page.SetBackgroundTaskResult(Result);
    end;
}
