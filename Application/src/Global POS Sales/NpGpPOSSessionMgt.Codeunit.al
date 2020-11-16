codeunit 6151165 "NPR NpGp POS Session Mgt."
{
    // NPR5.50/MHA /20190422  CASE 337539 Object created - [NpGp] NaviPartner Global POS Sales
    // NPR5.52/MHA /20191016  CASE 371388 "Global POS Sales Setup" moved from Np Retail Setup to POS Unit
    // NPR5.53/MHA /20191120  CASE 378375 Added function OnAfterDebitSalePostEvent() to include Credit Sales

    TableNo = "NPR Nc Task";

    trigger OnRun()
    var
        NcSyncMgt: Codeunit "NPR Nc Sync. Mgt.";
    begin
        NcSyncMgt.ProcessTask(Rec);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150705, 'OnAfterEndSale', '', true, true)]
    local procedure OnAfterEndSale(var Sender: Codeunit "NPR POS Sale"; SalePOS: Record "NPR Sale POS")
    var
        POSUnit: Record "NPR POS Unit";
        NcTask: Record "NPR Nc Task";
        NPRetailSetup: Record "NPR NP Retail Setup";
        NpGpPOSSalesSetup: Record "NPR NpGp POS Sales Setup";
        POSEntry: Record "NPR POS Entry";
        NpGpPOSSalesInitMgt: Codeunit "NPR NpGp POS Sales Init Mgt.";
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
        if not FindPosEntry(SalePOS, POSEntry) then
            exit;

        TaskProcessorCode := NpGpPOSSalesInitMgt.InitSyncSetup();
        if not InsertNcTask(TaskProcessorCode, POSEntry, POSEntry."Document No.", NcTask) then
            exit;

        if NpGpPOSSalesSetup."Sync POS Sales Immediately" then
            ScheduleTaskProcessing(NcTask);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014407, 'OnAfterDebitSalePostEvent', '', true, true)]
    local procedure OnAfterDebitSalePostEvent(var Sender: Codeunit "NPR Sales Doc. Exp. Mgt."; SalePOS: Record "NPR Sale POS"; SalesHeader: Record "Sales Header"; Posted: Boolean; WriteInAuditRoll: Boolean)
    var
        POSUnit: Record "NPR POS Unit";
        NcTask: Record "NPR Nc Task";
        NPRetailSetup: Record "NPR NP Retail Setup";
        NpGpPOSSalesSetup: Record "NPR NpGp POS Sales Setup";
        POSEntry: Record "NPR POS Entry";
        NpGpPOSSalesInitMgt: Codeunit "NPR NpGp POS Sales Init Mgt.";
        TaskProcessorCode: Text;
    begin
        //-NPR5.53 [378375]
        if not NPRetailSetup.Get then
            exit;
        if not NPRetailSetup."Advanced POS Entries Activated" then
            exit;

        if not POSUnit.Get(SalePOS."Register No.") then
            exit;
        if POSUnit."Global POS Sales Setup" = '' then
            exit;
        if not NpGpPOSSalesSetup.Get(POSUnit."Global POS Sales Setup") then
            exit;
        if not FindPosEntry(SalePOS, POSEntry) then
            exit;

        TaskProcessorCode := NpGpPOSSalesInitMgt.InitSyncSetup();
        if not InsertNcTask(TaskProcessorCode, POSEntry, POSEntry."Document No.", NcTask) then
            exit;

        if NpGpPOSSalesSetup."Sync POS Sales Immediately" then
            ScheduleTaskProcessing(NcTask);
        //+NPR5.53 [378375]
    end;

    local procedure FindPosEntry(SalePOS: Record "NPR Sale POS"; var POSEntry: Record "NPR POS Entry"): Boolean
    begin
        POSEntry.SetRange("POS Unit No.", SalePOS."Register No.");
        POSEntry.SetRange("Document No.", SalePOS."Sales Ticket No.");
        exit(POSEntry.FindFirst);
    end;

    procedure InsertNcTask(TaskProcessorCode: Text; RecVariant: Variant; DocNo: Code[20]; var NcTask: Record "NPR Nc Task"): Boolean
    var
        RecRef: RecordRef;
        NcSyncMgt: Codeunit "NPR Nc Sync. Mgt.";
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
        NcTask."Task Processor Code" := UpperCase(CopyStr(TaskProcessorCode, 1, MaxStrLen(NcTask."Task Processor Code")));
        exit(NcTask.Insert(true));
    end;

    local procedure ScheduleTaskProcessing(NcTask: Record "NPR Nc Task")
    var
        NewSessionId: Integer;
    begin
        SESSION.StartSession(NewSessionId, CODEUNIT::"NPR NpGp POS Session Mgt.", CompanyName, NcTask);
    end;
}

