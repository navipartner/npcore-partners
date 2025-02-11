codeunit 6184980 "NPR POS Action: ES Audit Lkp B"
{
    Access = Internal;

    internal procedure ShowESAuditLog(Show: Option All,AllRegistered,AllNonRegistered,LastTransaction)
    var
        ESPOSAuditLogAuxInfo, ESPOSAuditLogAuxInfo2 : Record "NPR ES POS Audit Log Aux. Info";
        ESPOSAuditLogAuxInfoPage: Page "NPR ES POS Audit Log Aux. Info";
    begin
        ESPOSAuditLogAuxInfo.FilterGroup(10);
        ESPOSAuditLogAuxInfo.SetRange("Audit Entry Type", ESPOSAuditLogAuxInfo."Audit Entry Type"::"POS Entry");

        case Show of
            Show::AllRegistered:
                ESPOSAuditLogAuxInfo.SetRange("Invoice Registration State", ESPOSAuditLogAuxInfo."Invoice Registration State"::REGISTERED);
            Show::AllNonRegistered:
                ESPOSAuditLogAuxInfo.SetFilter("Invoice Registration State", '<>%1', ESPOSAuditLogAuxInfo."Invoice Registration State"::REGISTERED);
            Show::LastTransaction:
                begin
                    ESPOSAuditLogAuxInfo2.SetLoadFields("Audit Entry Type", "Audit Entry No.");
                    ESPOSAuditLogAuxInfo.SetRange("Invoice Registration State", ESPOSAuditLogAuxInfo."Invoice Registration State"::REGISTERED);
                    ESPOSAuditLogAuxInfo2.FindLast();

                    ESPOSAuditLogAuxInfo.SetRange("Audit Entry Type", ESPOSAuditLogAuxInfo2."Audit Entry Type");
                    ESPOSAuditLogAuxInfo.SetRange("Audit Entry No.", ESPOSAuditLogAuxInfo2."Audit Entry No.");
                end;
        end;

        ESPOSAuditLogAuxInfo.FilterGroup(0);
        ESPOSAuditLogAuxInfoPage.SetTableView(ESPOSAuditLogAuxInfo);
        ESPOSAuditLogAuxInfoPage.RunModal();
    end;
}
