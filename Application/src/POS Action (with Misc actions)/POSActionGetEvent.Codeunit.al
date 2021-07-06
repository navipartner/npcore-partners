codeunit 6060160 "NPR POS Action: Get Event"
{
    var
        ActionDescription: Label 'Get event from Event Management module';
        EnterEventTxt: Label 'Enter Event No.';
        NothingToInvoiceErr: Label 'There''s nothing to invoice on that event.';

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Action", 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    begin
        if Sender.DiscoverAction(
            ActionCode(),
            ActionDescription,
            ActionVersion(),
            Sender.Type::Generic,
            Sender."Subscriber Instances Allowed"::Multiple)
        then begin
            Sender.RegisterWorkflowStep('textfield', 'if (param.DialogType == param.DialogType["TextField"]) {input(labels.prompt).respond();}');
            Sender.RegisterWorkflowStep('list', 'if (param.DialogType == param.DialogType["List"]) {respond();}');
            Sender.RegisterOptionParameter('DialogType', 'TextField,List', 'TextField');
            Sender.RegisterWorkflow(false);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS UI Management", 'OnInitializeCaptions', '', false, false)]
    local procedure OnInitializeCaptions(Captions: Codeunit "NPR POS Caption Management")
    begin
        Captions.AddActionCaption(ActionCode(), 'prompt', EnterEventTxt);
    end;

    local procedure ActionCode(): Text
    begin
        exit('GET_EVENT');
    end;

    local procedure ActionVersion(): Text
    begin
        exit('1.0');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS JavaScript Interface", 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        JSON: Codeunit "NPR POS JSON Management";
        EventNo: Code[20];
        ExecutingErr: Label 'executing %1';
    begin
        if not Action.IsThisAction(ActionCode()) then
            exit;

        case WorkflowStep of
            'list':
                begin
                    Handled := true;
                    if not SelectEvent(EventNo) then
                        exit;
                end;
            'textfield':
                begin
                    Handled := true;
                    JSON.InitializeJObjectParser(Context, FrontEnd);
                    EventNo := CopyStr(JSON.GetStringOrFail('value', StrSubstNo(ExecutingErr, ActionCode())), 1, MaxStrLen(EventNo));
                end;
        end;

        ImportEvent(POSSession, EventNo);
    end;

    local procedure SelectEvent(var EventNo: Code[20]): Boolean
    var
        Job: Record Job;
        EventList: Page "NPR Event List";
    begin
        Job.SetRange("NPR Event", true);
        Job.SetRange("NPR Event Status", Job."NPR Event Status"::Order);
        Job.SetRange(Blocked, Job.Blocked::" ");
        EventList.SetTableView(Job);
        EventList.LookupMode := true;
        if EventList.RunModal() = ACTION::LookupOK then begin
            EventList.GetRecord(Job);
            EventNo := Job."No.";
        end;
        exit(EventNo <> '');
    end;

    local procedure ImportEvent(POSSession: Codeunit "NPR POS Session"; EventNo: Code[20])
    var
        Job: Record Job;
        Customer: Record Customer;
        JobPlanningLine: Record "Job Planning Line";
        JobTask: Record "Job Task";
        JobPlanningLineInvoice: Record "Job Planning Line Invoice";
        SaleLinePOS: Record "NPR POS Sale Line";
        SalePOS: Record "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSSale: Codeunit "NPR POS Sale";
    begin
        Job.Get(EventNo);
        Job.TestField("NPR Event");
        Job.TestField("NPR Event Status", Job."NPR Event Status"::Order);
        Job.TestBlocked();
        Job.TestField("NPR Event Customer No.");
        Customer.Get(Job."NPR Event Customer No.");
        Customer.TestField(Blocked, Customer.Blocked::" ");
        JobPlanningLine.SetRange("Job No.", Job."No.");
        JobPlanningLine.SetFilter("Line Type", '>%1', JobPlanningLine."Line Type"::Budget);
        JobPlanningLine.SetRange(Type, JobPlanningLine.Type::Item);
        JobPlanningLine.SetFilter("Qty. to Transfer to Invoice", '>0');
        if not JobPlanningLine.FindSet() then
            Error(NothingToInvoiceErr);

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        POSSession.GetSaleLine(POSSaleLine);

        SalePOS.Validate("Customer No.", Customer."No.");
        SalePOS.Validate("Prices Including VAT", Customer."Prices Including VAT");
        SalePOS.Modify();
        repeat
            JobTask.Get(JobPlanningLine."Job No.", JobPlanningLine."Job Task No.");
            SaleLinePOS."Sale Type" := SaleLinePOS."Sale Type"::Sale;
            SaleLinePOS."No." := JobPlanningLine."No.";
            SaleLinePOS.Description := JobPlanningLine.Description;
            SaleLinePOS."Description 2" := JobPlanningLine."Description 2";
            SaleLinePOS."Variant Code" := JobPlanningLine."Variant Code";
            SaleLinePOS."Unit of Measure Code" := JobPlanningLine."Unit of Measure Code";
            SaleLinePOS.Quantity := JobPlanningLine."Qty. to Transfer to Invoice";
            SaleLinePOS."Unit Price" := JobPlanningLine."Unit Price";
            SaleLinePOS."Bin Code" := JobPlanningLine."Bin Code";
            SaleLinePOS."Location Code" := JobPlanningLine."Location Code";
            SaleLinePOS."Shortcut Dimension 1 Code" := JobTask."Global Dimension 1 Code";
            SaleLinePOS."Shortcut Dimension 2 Code" := JobTask."Global Dimension 2 Code";
            SaleLinePOS."Discount %" := JobPlanningLine."Line Discount %";
            SaleLinePOS."Discount Amount" := JobPlanningLine."Line Discount Amount";
            POSSaleLine.InsertLine(SaleLinePOS);

            JobPlanningLineInvoice.Init();
            JobPlanningLineInvoice."NPR POS Unit No." := SaleLinePOS."Register No.";
            JobPlanningLineInvoice."NPR POS Store Code" := SalePOS."POS Store Code";
            JobPlanningLineInvoice."Document Type" := JobPlanningLineInvoice."Document Type"::Invoice;
            JobPlanningLineInvoice."Document No." := SaleLinePOS."Sales Ticket No.";
            JobPlanningLineInvoice."Line No." := SaleLinePOS."Line No.";
            JobPlanningLineInvoice."Job No." := JobPlanningLine."Job No.";
            JobPlanningLineInvoice."Job Task No." := JobPlanningLine."Job Task No.";
            JobPlanningLineInvoice."Job Planning Line No." := JobPlanningLine."Line No.";
            JobPlanningLineInvoice."Quantity Transferred" := JobPlanningLine."Qty. to Transfer to Invoice";
            JobPlanningLineInvoice."Transferred Date" := SaleLinePOS.Date;
            JobPlanningLineInvoice.Insert();

            JobPlanningLine.UpdateQtyToTransfer();
            JobPlanningLine.Modify();
        until JobPlanningLine.Next() = 0;

        POSSession.RequestRefreshData();
    end;
}

