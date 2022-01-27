codeunit 6151100 "NPR NpRi Setup Mgt."
{
    Access = Internal;
    [IntegrationEvent(false, false)]
    procedure DiscoverModules(var NpRiModule: Record "NPR NpRi Reimbursement Module")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure SetupPartyTypeTableNoLookup(var TempTableMetadata: Record "Table Metadata" temporary)
    begin
    end;

    procedure ShowEntrySource(var NpRiReimbursementEntry: Record "NPR NpRi Reimbursement Entry")
    var
        PageMgt: Codeunit "Page Management";
        RecRef: RecordRef;
        RecID: RecordID;
        RecordPosition: Text;
    begin
        RecID := NpRiReimbursementEntry."Source Record ID";
        RecRef := RecID.GetRecord();
        if (NpRiReimbursementEntry."Source Company Name" <> '') and (NpRiReimbursementEntry."Source Company Name" <> CompanyName) then begin
            RecordPosition := RecRef.GetPosition(false);
            RecRef.Close();

            RecRef.Open(NpRiReimbursementEntry."Source Table No.", false, NpRiReimbursementEntry."Source Company Name");
            RecRef.SetPosition(RecordPosition);
        end;
        RecRef.Find();

        PageMgt.PageRun(RecRef);
    end;
}

