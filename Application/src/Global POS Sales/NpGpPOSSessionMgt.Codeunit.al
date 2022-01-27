codeunit 6151165 "NPR NpGp POS Session Mgt."
{
    Access = Internal;
    TableNo = "NPR Nc Task";

    trigger OnRun()
    var
        NcSyncMgt: Codeunit "NPR Nc Sync. Mgt.";
    begin
        NcSyncMgt.ProcessTask(Rec);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Sale", 'OnAfterEndSale', '', true, true)]
    local procedure OnAfterEndSale(var Sender: Codeunit "NPR POS Sale"; SalePOS: Record "NPR POS Sale")
    var
        POSUnit: Record "NPR POS Unit";
        NcTask: Record "NPR Nc Task";
        NpGpPOSSalesSetup: Record "NPR NpGp POS Sales Setup";
        POSEntry: Record "NPR POS Entry";
        NpGpPOSSalesInitMgt: Codeunit "NPR NpGp POS Sales Init Mgt.";
        TaskProcessorCode: Text;
    begin
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

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Sales Doc. Exp. Mgt.", 'OnAfterDebitSalePostEvent', '', true, true)]
    local procedure OnAfterDebitSalePostEvent(var Sender: Codeunit "NPR Sales Doc. Exp. Mgt."; SalePOS: Record "NPR POS Sale"; SalesHeader: Record "Sales Header"; Posted: Boolean)
    var
        POSUnit: Record "NPR POS Unit";
        NcTask: Record "NPR Nc Task";
        NpGpPOSSalesSetup: Record "NPR NpGp POS Sales Setup";
        POSEntry: Record "NPR POS Entry";
        NpGpPOSSalesInitMgt: Codeunit "NPR NpGp POS Sales Init Mgt.";
        TaskProcessorCode: Text;
    begin
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


    end;

    local procedure FindPosEntry(SalePOS: Record "NPR POS Sale"; var POSEntry: Record "NPR POS Entry"): Boolean
    begin
        POSEntry.SetRange("POS Unit No.", SalePOS."Register No.");
        POSEntry.SetRange("Document No.", SalePOS."Sales Ticket No.");
        exit(POSEntry.FindFirst());
    end;

    procedure InsertNcTask(TaskProcessorCode: Text; RecVariant: Variant; DocNo: Code[20]; var NcTask: Record "NPR Nc Task"): Boolean
    var
        RecRef: RecordRef;
    begin
        if not RecVariant.IsRecord then
            exit(false);

        RecRef.GetTable(RecVariant);

        NcTask.Init();
        NcTask."Entry No." := 0;
        NcTask.Type := NcTask.Type::Insert;
        NcTask."Table No." := RecRef.Number;
        NcTask."Record Position" := CopyStr(RecRef.GetPosition(false), 1, MaxStrLen(NcTask."Record Position"));
        NcTask."Log Date" := CurrentDateTime;
        NcTask."Company Name" := '';
        NcTask.Processed := false;
        NcTask."Process Error" := false;
        NcTask."Record Value" := DocNo;
        NcTask."Task Processor Code" := CopyStr(TaskProcessorCode, 1, MaxStrLen(NcTask."Task Processor Code"));
        exit(NcTask.Insert(true));
    end;

}

