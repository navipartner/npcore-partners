codeunit 6060160 "POS Action - Get Event"
{
    // NPR5.49/TJ  /20181207 CASE 331208 New object


    trigger OnRun()
    begin
    end;

    var
        ActionDescription: Label 'Get event from Event Management module';
        EnterEventTxt: Label 'Enter Event No.';
        JobIsNotEventErr: Label 'Job is not Event. Please specify another.';
        NothingToInvoiceErr: Label 'There''s nothing to invoice on that event.';

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "POS Action")
    begin
        with Sender do
            if DiscoverAction(
              ActionCode,
              ActionDescription,
              ActionVersion,
              Sender.Type::Generic,
              Sender."Subscriber Instances Allowed"::Multiple)
            then begin
                RegisterWorkflowStep('textfield', 'if (param.DialogType == param.DialogType["TextField"]) {input(labels.prompt).respond();}');
                RegisterWorkflowStep('list', 'if (param.DialogType == param.DialogType["List"]) {respond();}');
                RegisterOptionParameter('DialogType', 'TextField,List', 'TextField');
                RegisterWorkflow(false);
            end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150702, 'OnInitializeCaptions', '', false, false)]
    local procedure OnInitializeCaptions(Captions: Codeunit "POS Caption Management")
    begin
        Captions.AddActionCaption(ActionCode, 'prompt', EnterEventTxt);
    end;

    local procedure ActionCode(): Text
    begin
        exit('GET_EVENT');
    end;

    local procedure ActionVersion(): Text
    begin
        exit('1.0');
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "POS Session"; FrontEnd: Codeunit "POS Front End Management"; var Handled: Boolean)
    var
        JSON: Codeunit "POS JSON Management";
        EventNo: Code[20];
    begin
        if not Action.IsThisAction(ActionCode) then
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
                    EventNo := CopyStr(JSON.GetString('value', true), 1, MaxStrLen(EventNo));
                end;
        end;

        ImportEvent(Context, POSSession, FrontEnd, EventNo);
    end;

    local procedure SelectEvent(var EventNo: Code[20]): Boolean
    var
        Job: Record Job;
        EventList: Page "Event List";
    begin
        Job.SetRange("Event", true);
        Job.SetRange("Event Status", Job."Event Status"::Order);
        Job.SetRange(Blocked, Job.Blocked::" ");
        EventList.SetTableView(Job);
        EventList.LookupMode := true;
        if EventList.RunModal = ACTION::LookupOK then begin
            EventList.GetRecord(Job);
            EventNo := Job."No.";
        end;
        exit(EventNo <> '');
    end;

    local procedure ImportEvent(Context: JsonObject; POSSession: Codeunit "POS Session"; FrontEnd: Codeunit "POS Front End Management"; EventNo: Code[20])
    var
        Job: Record Job;
        Customer: Record Customer;
        JobPlanningLine: Record "Job Planning Line";
        JobTask: Record "Job Task";
        JobPlanningLineInvoice: Record "Job Planning Line Invoice";
        SaleLinePOS: Record "Sale Line POS";
        SalePOS: Record "Sale POS";
        POSSaleLine: Codeunit "POS Sale Line";
        POSSale: Codeunit "POS Sale";
    begin
        Job.Get(EventNo);
        Job.TestField("Event");
        Job.TestField("Event Status", Job."Event Status"::Order);
        Job.TestBlocked();
        Job.TestField("Event Customer No.");
        Customer.Get(Job."Event Customer No.");
        Customer.TestField(Blocked, Customer.Blocked::" ");
        JobPlanningLine.SetRange("Job No.", Job."No.");
        JobPlanningLine.SetFilter("Line Type", '>%1', JobPlanningLine."Line Type"::Budget);
        JobPlanningLine.SetRange(Type, JobPlanningLine.Type::Item);
        JobPlanningLine.SetFilter("Qty. to Transfer to Invoice", '>0');
        if not JobPlanningLine.FindSet then
            Error(NothingToInvoiceErr);

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        POSSession.GetSaleLine(POSSaleLine);
        //POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        SalePOS.Validate("Customer No.", Customer."No.");
        SalePOS.Validate("Prices Including VAT",Customer."Prices Including VAT");
        SalePOS.Modify;
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

            JobPlanningLineInvoice.Init;
            JobPlanningLineInvoice."POS Unit No." := SaleLinePOS."Register No.";
            JobPlanningLineInvoice."POS Store Code" := SalePOS."POS Store Code";
            JobPlanningLineInvoice."Document Type" := JobPlanningLineInvoice."Document Type"::Invoice;
            JobPlanningLineInvoice."Document No." := SaleLinePOS."Sales Ticket No.";
            JobPlanningLineInvoice."Line No." := SaleLinePOS."Line No.";
            JobPlanningLineInvoice."Job No." := JobPlanningLine."Job No.";
            JobPlanningLineInvoice."Job Task No." := JobPlanningLine."Job Task No.";
            JobPlanningLineInvoice."Job Planning Line No." := JobPlanningLine."Line No.";
            JobPlanningLineInvoice."Quantity Transferred" := JobPlanningLine."Qty. to Transfer to Invoice";
            JobPlanningLineInvoice."Transferred Date" := SaleLinePOS.Date;
            JobPlanningLineInvoice.Insert;

            JobPlanningLine.UpdateQtyToTransfer();
            JobPlanningLine.Modify;
        until JobPlanningLine.Next = 0;

        POSSession.RequestRefreshData();
    end;
}

