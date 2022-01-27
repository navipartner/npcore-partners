codeunit 6014648 "NPR Get External POS Sale" implements "NPR Nc Import List IUpdate"
{
    Access = Internal;
    procedure Update(TaskLine: Record "NPR Task Line"; ImportType: Record "NPR Nc Import Type")

    begin
        GetNewEntries(ImportType);
    end;

    procedure Update(JobQueueEntry: Record "Job Queue Entry"; ImportType: Record "NPR Nc Import Type")
    begin
        GetNewEntries(ImportType);
    end;

    procedure ShowSetup(ImportType: Record "NPR Nc Import Type")
    begin
        Message('No Setup');
    end;

    procedure ShowErrorLog(ImportType: Record "NPR Nc Import Type")
    var
        ExtPOSSale: Record "NPR External POS Sale";
        ExtPOSSaleList: Page "NPR External POS Sales";
    begin
        ExtPOSSale.SetRange("Converted To POS Entry", false);
        ExtPOSSale.SetRange("Has Conversion Error", true);
        ExtPOSSaleList.SetTableView(ExtPOSSale);
        ExtPOSSaleList.RunModal();
    end;

    procedure GetNewEntries(ImportType: Record "NPR Nc Import Type")
    var
        ExtPOSSale: Record "NPR External POS Sale";
        POSStore: Record "NPR POS Store";
        POSPostingProfile: Record "NPR POS Posting Profile";
    begin
        ExtPOSSale.SetCurrentKey("Converted To POS Entry", "Has Conversion Error", "POS Store Code");
        ExtPOSSale.SetRange("Converted To POS Entry", false);
        ExtPOSSale.SetRange("Has Conversion Error", false);
        IF ExtPOSSale.FindSet() then
            repeat
                ExtPOSSale.SetRange("POS Store Code", ExtPOSSale."POS Store Code");
                IF ExtPOSSale."POS Store Code" <> POSStore.Code then begin
                    IF POSStore.Get(ExtPOSSale."POS Store Code") then;
                    POSStore.GetProfile(POSPostingProfile);
                end;

                IF POSPostingProfile."Auto Process Ext. POS Sales" then
                    InsertImportEntry(ImportType.Code, ExtPOSSale)
                else
                    ExtPOSSale.FindLast(); // to skip records with the same Store No.

                ExtPOSSale.SetRange("POS Store Code");
            until ExtPOSSale.Next() = 0;
    end;

    procedure InsertImportEntry(ImportTypeCode: Code[20]; ExtPOSSale: Record "NPR External POS Sale")
    var
        ImportEntry: Record "NPR Nc Import Entry";
    begin
        clear(ImportEntry);
        ImportEntry."Entry No." := 0;
        ImportEntry."Import Type" := ImportTypeCode;
        ImportEntry."Document Name" := 'External POS Sale';
        ImportEntry."Document ID" := Format(ExtPOSSale.RecordId());
        ImportEntry.Insert(true);
    end;
}
