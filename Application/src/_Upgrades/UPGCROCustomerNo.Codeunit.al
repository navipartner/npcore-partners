codeunit 6248660 "NPR UPG CRO Customer No."
{
    Access = Internal;
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgradeTagDefinitions: Codeunit "NPR Upgrade Tag Definitions";
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG CRO Customer No.', 'OnUpgradeDataPerCompany');

        if not UpgradeTag.HasUpgradeTag(UpgradeTagDefinitions.GetUpgradeTag(Codeunit::"NPR UPG CRO Customer No.", 'init-customer-no-on-cro-pos-audit-log')) then begin
            InitCustomerNoTypeOnCROPOSAuditLog();
            UpgradeTag.SetUpgradeTag(UpgradeTagDefinitions.GetUpgradeTag(Codeunit::"NPR UPG CRO Customer No.", 'init-customer-no-on-cro-pos-audit-log'));
        end;

        LogMessageStopwatch.LogFinish();
    end;

    local procedure InitCustomerNoTypeOnCROPOSAuditLog()
    var
        CROFiscalizationSetup: Record "NPR CRO Fiscalization Setup";
        CROPOSAudLogAuxInfo: Record "NPR CRO POS Aud. Log Aux. Info";
        POSEntry: Record "NPR POS Entry";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
    begin
        if not CROFiscalizationSetup.Get() then
            exit;

        if not CROFiscalizationSetup."Enable CRO Fiscal" then
            exit;

        if CROPOSAudLogAuxInfo.FindSet(true) then
            repeat
                case CROPOSAudLogAuxInfo."Audit Entry Type" of
                    CROPOSAudLogAuxInfo."Audit Entry Type"::"POS Entry":
                        begin
                            if POSEntry.Get(CROPOSAudLogAuxInfo."POS Entry No.") then begin
                                CROPOSAudLogAuxInfo."Customer No." := POSEntry."Customer No.";
                                CROPOSAudLogAuxInfo.Modify();
                            end;
                        end;
                    CROPOSAudLogAuxInfo."Audit Entry Type"::"Sales Invoice":
                        begin
                            if SalesInvoiceHeader.Get(CROPOSAudLogAuxInfo."Source Document No.") then begin
                                CROPOSAudLogAuxInfo."Customer No." := SalesInvoiceHeader."Sell-to Customer No.";
                                CROPOSAudLogAuxInfo.Modify();
                            end;
                        end;
                    CROPOSAudLogAuxInfo."Audit Entry Type"::"Sales Credit Memo":
                        begin
                            if SalesCrMemoHeader.Get(CROPOSAudLogAuxInfo."Source Document No.") then begin
                                CROPOSAudLogAuxInfo."Customer No." := SalesCrMemoHeader."Sell-to Customer No.";
                                CROPOSAudLogAuxInfo.Modify();
                            end;
                        end;
                end;
            until CROPOSAudLogAuxInfo.Next() = 0;
    end;
}
