codeunit 6151100 "NpRi Setup Mgt."
{
    // NPR5.44/MHA /20180723  CASE 320133 Object Created - NaviPartner Reimbursement


    trigger OnRun()
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure DiscoverModules(var NpRiModule: Record "NpRi Reimbursement Module")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure SetupPartyTypeTableNoLookup(var TempTableMetadata: Record "Table Metadata" temporary)
    begin
    end;

    procedure ShowEntrySource(var NpRiReimbursementEntry: Record "NpRi Reimbursement Entry")
    var
        PageMgt: Codeunit "Page Management";
        RecRef: RecordRef;
        RecID: RecordID;
        RecordPosition: Text;
    begin
        RecID := NpRiReimbursementEntry."Source Record ID";
        RecRef := RecID.GetRecord;
        if (NpRiReimbursementEntry."Source Company Name" <> '') and (NpRiReimbursementEntry."Source Company Name" <> CompanyName) then begin
          RecordPosition := RecRef.GetPosition(false);
          RecRef.Close;

          RecRef.Open(NpRiReimbursementEntry."Source Table No.",false,NpRiReimbursementEntry."Source Company Name");
          RecRef.SetPosition(RecordPosition);
        end;
        RecRef.Find;

        PageMgt.PageRun(RecRef);
    end;
}

