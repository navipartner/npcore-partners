codeunit 6184907 "NPR POS Action: AT Audit Lkp B"
{
    Access = Internal;

    internal procedure ShowATAuditLog(Show: Option All,AllSigned,AllNonSigned,LastTransaction)
    var
        ATPOSAuditLogAuxInfo, ATPOSAuditLogAuxInfo2 : Record "NPR AT POS Audit Log Aux. Info";
        ATPOSAuditLogAuxInfoPage: Page "NPR AT POS Audit Log Aux. Info";
    begin
        ATPOSAuditLogAuxInfo.FilterGroup(10);

        case Show of
            Show::AllSigned:
                ATPOSAuditLogAuxInfo.SetRange(Signed, true);
            Show::AllNonSigned:
                ATPOSAuditLogAuxInfo.SetRange(Signed, false);
            Show::LastTransaction:
                begin
                    ATPOSAuditLogAuxInfo2.SetLoadFields("Audit Entry Type", "Audit Entry No.");
                    ATPOSAuditLogAuxInfo2.SetRange(Signed, true);
                    ATPOSAuditLogAuxInfo2.FindLast();

                    ATPOSAuditLogAuxInfo.SetRange("Audit Entry Type", ATPOSAuditLogAuxInfo2."Audit Entry Type");
                    ATPOSAuditLogAuxInfo.SetRange("Audit Entry No.", ATPOSAuditLogAuxInfo2."Audit Entry No.");
                end;
        end;

        ATPOSAuditLogAuxInfo.FilterGroup(0);
        ATPOSAuditLogAuxInfoPage.SetTableView(ATPOSAuditLogAuxInfo);
        ATPOSAuditLogAuxInfoPage.RunModal();
    end;
}
