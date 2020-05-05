codeunit 6151282 "SS Action - Delete POS Line"
{
    // 
    // NPR5.54/TSA /20200205 CASE 387912 Initial Version


    trigger OnRun()
    begin
    end;

    var
        ActionDescription: Label 'This built in function deletes sales or payment line from the POS';
        Title: Label 'Delete Line';
        Prompt: Label 'Are you sure you want to delete the line %1?';
        NotAllowed: Label 'This line can''t be deleted.';

    local procedure ActionCode(): Text
    begin

        exit ('SS-DELETE-LINE');
    end;

    local procedure ActionVersion(): Text
    begin

        exit ('1.0');
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "POS Action")
    begin
        with Sender do
          if DiscoverAction20(
            ActionCode(),
            ActionDescription,
            ActionVersion())
          then begin
            RegisterWorkflow20('workflow.respond();');
            RegisterDataBinding();
            SetWorkflowTypeUnattended ();
          end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150733, 'OnAction', '', false, false)]
    local procedure OnAction20("Action": Record "POS Action";WorkflowStep: Text;Context: Codeunit "POS JSON Management";POSSession: Codeunit "POS Session";State: Codeunit "POS Workflows 2.0 - State";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    var
        SaleLine: Codeunit "POS Sale Line";
        SaleLinePOS: Record "Sale Line POS";
        POSSaleLine: Codeunit "POS Sale Line";
        Qty: Integer;
    begin

        if not Action.IsThisAction(ActionCode) then
          exit;

        DeletePosLine(POSSession);

        Handled := true;
    end;

    procedure DeletePosLine(POSSession: Codeunit "POS Session")
    var
        POSSaleLine: Codeunit "POS Sale Line";
        POSPaymentLine: Codeunit "POS Payment Line";
        LinePOS: Record "Sale Line POS";
        POSSale: Codeunit "POS Sale";
        POSActionDeletePOSLine: Codeunit "POS Action - Delete POS Line";
        CurrentView: DotNet npNetView0;
        CurrentViewType: DotNet npNetViewType0;
        ViewType: DotNet npNetViewType0;
    begin

        // This function should be "not local" for testability

        POSSession.GetSaleLine(POSSaleLine);
        POSActionDeletePOSLine.OnBeforeDeleteSaleLinePOS(POSSaleLine);
        DeleteAccessories(POSSaleLine);
        POSSaleLine.DeleteLine();

        POSSession.GetSale(POSSale);
        POSSale.SetModified();

        POSSession.RequestRefreshData();
    end;

    procedure DeleteAccessories(POSSaleLine: Codeunit "POS Sale Line")
    var
        SaleLinePOS: Record "Sale Line POS";
        SaleLinePOS2: Record "Sale Line POS";
    begin

        // This function should be "not local" for testability
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
        if SaleLinePOS.Type <> SaleLinePOS.Type::Item then
          exit;
        if SaleLinePOS."No." in ['','*'] then
          exit;

        SaleLinePOS2.SetRange("Register No.",SaleLinePOS."Register No.");
        SaleLinePOS2.SetRange("Sales Ticket No.",SaleLinePOS."Sales Ticket No.");
        SaleLinePOS2.SetRange("Sale Type",SaleLinePOS."Sale Type");
        SaleLinePOS2.SetFilter("Line No.",'<>%1',SaleLinePOS."Line No.");
        SaleLinePOS2.SetRange("Main Line No.",SaleLinePOS."Line No.");
        SaleLinePOS2.SetRange(Accessory,true);
        SaleLinePOS2.SetRange("Main Item No.",SaleLinePOS."No.");
        if SaleLinePOS2.IsEmpty then
          exit;

        SaleLinePOS2.SetSkipCalcDiscount(true);
        SaleLinePOS2.DeleteAll(false);
    end;
}

