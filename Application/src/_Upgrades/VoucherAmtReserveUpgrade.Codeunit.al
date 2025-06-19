codeunit 6248385 "NPR VoucherAmtReserve Upgrade"
{
    Access = Internal;
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    begin
        Upgrade();
    end;

    local procedure Upgrade()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgTagDef: Codeunit "NPR Upgrade Tag Definitions";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR VoucherAmtReserve Upgrade', 'Upgrade');

        if UpgradeTag.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR VoucherAmtReserve Upgrade")) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        UpgradeReservationAmount();

        UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR VoucherAmtReserve Upgrade"));

        LogMessageStopwatch.LogFinish();
    end;


    local procedure UpgradeReservationAmount()
    var
        MagentoPaymentLine: Record "NPR Magento Payment Line";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        PosSavedSaleLine: Record "NPR POS Saved Sale Line";
    begin
        NpRvSalesLine.SetRange(Type, NpRvSalesLine.Type::Payment);
        NpRvSalesLine.SetRange(Posted, false);
        if NpRvSalesLine.FindSet() then
            repeat
                case NpRvSalesLine."Document Source" of
                    NpRvSalesLine."Document Source"::"Payment Line":
                        begin
                            if MagentoPaymentLine.Get(Database::"Sales Header", NpRvSalesLine."Document Type", NpRvSalesLine."Document No.", NpRvSalesLine."Document Line No.") then begin
                                NpRvSalesLine."Reservation Line Id" := MagentoPaymentLine.SystemId;
                                NpRvSalesLine.Amount := MagentoPaymentLine."Amount";
                                NpRvSalesLine.Modify();

                            end;
                        end;

                    NpRvSalesLine."Document Source"::"POS Quote":
                        begin
                            if PosSavedSaleLine.GetBySystemId(NpRvSalesLine."Retail ID") then begin
                                NpRvSalesLine.Amount := PosSavedSaleLine."Amount Including VAT";
                                NpRvSalesLine.Modify();
                            end;
                        end;
                end;
            until NpRvSalesLine.Next() = 0;
    end;
}
