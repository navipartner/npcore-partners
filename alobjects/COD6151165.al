codeunit 6151165 "NpGp POS Session Mgt."
{
    // NPR5.50/MHA /20190422  CASE 337539 Object created - [NpGp] NaviPartner Global POS Sales
    // NPR5.52/MHA /20191016 CASE 371388 "Global POS Sales Setup" moved from Np Retail Setup to POS Unit

    TableNo = "Nc Task";

    trigger OnRun()
    var
        NcSyncMgt: Codeunit "Nc Sync. Mgt.";
    begin
        NcSyncMgt.ProcessTask(Rec);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150705, 'OnAfterEndSale', '', true, true)]
    local procedure OnAfterEndSale(var Sender: Codeunit "POS Sale";SalePOS: Record "Sale POS")
    var
        POSUnit: Record "POS Unit";
        NcTask: Record "Nc Task";
        NPRetailSetup: Record "NP Retail Setup";
        NpGpPOSSalesSetup: Record "NpGp POS Sales Setup";
        POSEntry: Record "POS Entry";
        NpGpPOSSalesInitMgt: Codeunit "NpGp POS Sales Init Mgt.";
        TaskProcessorCode: Text;
    begin
        if not NPRetailSetup.Get then
          exit;
        if not NPRetailSetup."Advanced POS Entries Activated" then
          exit;

        //-NPR5.52 [371388]
        if not POSUnit.Get(SalePOS."Register No.") then
          exit;
        if POSUnit."Global POS Sales Setup" = '' then
          exit;
        if not NpGpPOSSalesSetup.Get(POSUnit."Global POS Sales Setup") then
          exit;
        //+NPR5.52 [371388]
        if not FindPosEntry(SalePOS,POSEntry) then
          exit;

        TaskProcessorCode := NpGpPOSSalesInitMgt.InitSyncSetup();
        if not InsertNcTask(TaskProcessorCode,POSEntry,POSEntry."Document No.",NcTask) then
          exit;

        if NpGpPOSSalesSetup."Sync POS Sales Immediately" then
          ScheduleTaskProcessing(NcTask);
    end;

    local procedure FindPosEntry(SalePOS: Record "Sale POS";var POSEntry: Record "POS Entry"): Boolean
    begin
        POSEntry.SetRange("POS Unit No.",SalePOS."Register No.");
        POSEntry.SetRange("Document No.",SalePOS."Sales Ticket No.");
        exit(POSEntry.FindFirst);
    end;

    procedure InsertNcTask(TaskProcessorCode: Text;RecVariant: Variant;DocNo: Code[20];var NcTask: Record "Nc Task"): Boolean
    var
        RecRef: RecordRef;
        NcSyncMgt: Codeunit "Nc Sync. Mgt.";
    begin
        if not RecVariant.IsRecord then
          exit(false);

        RecRef.GetTable(RecVariant);

        NcTask.Init;
        NcTask."Entry No." := 0;
        NcTask.Type := NcTask.Type::Insert;
        NcTask."Table No." := RecRef.Number;
        NcTask."Record Position" := RecRef.GetPosition(false);
        NcTask."Log Date" := CurrentDateTime;
        NcTask."Company Name" := '';
        NcTask.Processed := false;
        NcTask."Process Error" := false;
        NcTask."Record Value" := DocNo;
        NcTask."Task Processor Code" := UpperCase(CopyStr(TaskProcessorCode,1,MaxStrLen(NcTask."Task Processor Code")));
        exit(NcTask.Insert(true));
    end;

    local procedure ScheduleTaskProcessing(NcTask: Record "Nc Task")
    var
        NewSessionId: Integer;
    begin
        SESSION.StartSession(NewSessionId,CODEUNIT::"NpGp POS Session Mgt.",CompanyName,NcTask);
    end;
}

