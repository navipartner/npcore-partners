codeunit 6151282 "NPR SS Action: Delete POS Line"
{
    Access = Internal;
    var
        ActionDescription: Label 'This built in function deletes sales or payment line from the POS';

    local procedure ActionCode(): Text[20]
    begin
        exit('SS-DELETE-LINE');
    end;

    local procedure ActionVersion(): Text[30]
    begin
        exit('1.0');
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Action", 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    begin

        if Sender.DiscoverAction20(
          ActionCode(),
          ActionDescription,
          ActionVersion())
        then begin
            Sender.RegisterWorkflow20('workflow.respond();');
            Sender.RegisterDataBinding();
            Sender.SetWorkflowTypeUnattended();
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Workflows 2.0", 'OnAction', '', false, false)]
    local procedure OnAction20("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session"; State: Codeunit "NPR POS WF 2.0: State"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    begin
        if not Action.IsThisAction(ActionCode()) then
            exit;

        DeletePosLine(POSSession);

        Handled := true;
    end;

    procedure DeletePosLine(POSSession: Codeunit "NPR POS Session")
    var
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSSale: Codeunit "NPR POS Sale";
        POSActionDeletePOSLine: Codeunit "NPR POSAction: Delete POS Line";
    begin
        POSSession.GetSaleLine(POSSaleLine);
        POSActionDeletePOSLine.OnBeforeDeleteSaleLinePOS(POSSaleLine);
        DeleteAccessories(POSSaleLine);
        POSSaleLine.DeleteLine();

        POSSession.GetSale(POSSale);
        POSSale.SetModified();

        POSSession.RequestRefreshData();
    end;

    procedure DeleteAccessories(POSSaleLine: Codeunit "NPR POS Sale Line")
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        SaleLinePOS2: Record "NPR POS Sale Line";
    begin
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
        if SaleLinePOS.Type <> SaleLinePOS.Type::Item then
            exit;
        if SaleLinePOS."No." in ['', '*'] then
            exit;

        SaleLinePOS2.SetRange("Register No.", SaleLinePOS."Register No.");
        SaleLinePOS2.SetRange("Sales Ticket No.", SaleLinePOS."Sales Ticket No.");
        SaleLinePOS2.SetRange("Sale Type", SaleLinePOS."Sale Type");
        SaleLinePOS2.SetFilter("Line No.", '<>%1', SaleLinePOS."Line No.");
        SaleLinePOS2.SetRange("Main Line No.", SaleLinePOS."Line No.");
        SaleLinePOS2.SetRange(Accessory, true);
        SaleLinePOS2.SetRange("Main Item No.", SaleLinePOS."No.");
        if SaleLinePOS2.IsEmpty then
            exit;

        SaleLinePOS2.SetSkipCalcDiscount(true);
        SaleLinePOS2.DeleteAll(false);
    end;
}
