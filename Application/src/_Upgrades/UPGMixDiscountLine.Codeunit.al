codeunit 6150839 "NPR UPG MixDiscountLine"
{
    Access = Internal;
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgTagDef: Codeunit "NPR Upgrade Tag Definitions";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG MixDiscountLine', 'OnUpgradePerCompany');
        if not UpgradeTag.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG MixDiscountLine", 'MixDiscCustAndMinQty')) then begin
            UpgMixDiscount();
            UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG MixDiscountLine", 'MixDiscCustAndMinQty'));
        end;
        LogMessageStopwatch.LogFinish();
    end;

    local procedure UpgMixDiscount()
    var
        MixedDiscount: Record "NPR Mixed Discount";
        CustomerDiscountGroupCode: Code[20];
    begin
        MixedDiscount.SetLoadFields("Customer Disc. Group Filter", "Min. Quantity");
        if MixedDiscount.FindSet() then
            repeat
                CustomerDiscountGroupCode := MixedDiscount.GetSingleCustomerDiscountGroupCode(MixedDiscount."Customer Disc. Group Filter");
                if (CustomerDiscountGroupCode <> '') or (MixedDiscount."Min. Quantity" <> 0) then
                    UpdateMixDiscountLines(MixedDiscount.Code, MixedDiscount."Min. Quantity", CustomerDiscountGroupCode);
            until MixedDiscount.Next() = 0;
    end;

    local procedure UpdateMixDiscountLines(MixedDiscountCode: Code[20]; MinQuantity: Decimal; CustomerDiscountGroupCode: Code[20])
    var
        MixedDiscountLine: Record "NPR Mixed Discount Line";
    begin
        MixedDiscountLine.SetRange(Code, MixedDiscountCode);
        if CustomerDiscountGroupCode <> '' then
            MixedDiscountLine.ModifyAll("Customer Disc. Group Code", CustomerDiscountGroupCode, false);
        if MinQuantity <> 0 then
            MixedDiscountLine.ModifyAll("Min. Quantity", MinQuantity, false);
    end;

}
