report 6014463 "NPR Sync RS VAT Entry"
{
    Caption = 'Sync RS VAT Entries';
#IF NOT BC17
    Extensible = false;
#ENDIF
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = NPRRSLocal;
    ProcessingOnly = true;
    UseRequestPage = false;

    dataset
    {
        dataitem("VAT Entry"; "VAT Entry")
        {
            trigger OnAfterGetRecord()
            var
                RSVATEntry: Record "NPR RS VAT Entry";
            begin
                if not RSVATEntry.Get("VAT Entry"."Entry No.") then begin
                    RSVATEntry.TransferFields("VAT Entry");
                    RSVATEntry.Insert(true);
                end;
            end;
        }
    }
    trigger OnPreReport()
    var
        RSVATEntry: Record "NPR RS VAT Entry";
        ConfirmManagement: Codeunit "Confirm Management";
        DeleteExistingEntriesQst: Label 'Do you want to delete all existing entries in %1', Comment = 'RS VAT Entry';
    begin
        if ConfirmManagement.GetResponseOrDefault(StrSubstNo(DeleteExistingEntriesQst, RSVATEntry.TableCaption), true) then
            RSVATEntry.DeleteAll();
    end;
}