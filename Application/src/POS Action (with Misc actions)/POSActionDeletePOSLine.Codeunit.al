codeunit 6150796 "NPR POSAction: Delete POS Line"
{
    var
        ActionDescription: Label 'This built in function deletes sales or payment line from the POS';
        Title: Label 'Delete Line';
        Prompt: Label 'Are you sure you want to delete the line %1?';
        NotAllowed: Label 'This line can''t be deleted.';

    local procedure ActionCode(): Text
    begin
        exit('DELETE_POS_LINE');
    end;

    local procedure ActionVersion(): Text
    begin

        exit('1.2');
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    begin
        if Sender.DiscoverAction(
  ActionCode(),
  ActionDescription,
  ActionVersion(),
  Sender.Type::Generic,
  Sender."Subscriber Instances Allowed"::Multiple)
then begin

            Sender.RegisterWorkflowStep('decl0', 'confirmtext = labels.notallowed;');
            Sender.RegisterWorkflowStep('decl1', 'if (!data.isEmpty())    {confirmtext = labels.Prompt.substitute(data("10"));};');
            Sender.RegisterWorkflowStep('confirm', '(param.ConfirmDialog == param.ConfirmDialog["Yes"]) ? confirm({title: labels.title, caption: confirmtext}).respond() : respond();');
            Sender.RegisterWorkflow(false);
            Sender.RegisterDataBinding();
            Sender.RegisterOptionParameter('Security', 'None,SalespersonPassword,CurrentSalespersonPassword,SupervisorPassword', 'None');
            Sender.RegisterOptionParameter('ConfirmDialog', 'No,Yes', 'No');
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    begin
        if not Action.IsThisAction(ActionCode()) then
            exit;

        DeletePosLine(Context, POSSession, FrontEnd);
        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150702, 'OnInitializeCaptions', '', false, false)]
    local procedure OnInitializeCaptions(Captions: Codeunit "NPR POS Caption Management")
    begin
        Captions.AddActionCaption(ActionCode(), 'title', Title);
        Captions.AddActionCaption(ActionCode(), 'notallowed', NotAllowed);
        Captions.AddActionCaption(ActionCode(), 'Prompt', Prompt);
    end;

    local procedure DeletePosLine(Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        JSON: Codeunit "NPR POS JSON Management";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSPaymentLine: Codeunit "NPR POS Payment Line";
        LinePOS: Record "NPR POS Sale Line";
        POSSale: Codeunit "NPR POS Sale";
        CurrentView: Codeunit "NPR POS View";
    begin
        JSON.InitializeJObjectParser(Context, FrontEnd);
        POSSession.GetCurrentView(CurrentView);

        if (CurrentView.Type() = CurrentView.Type()::Sale) then begin
            POSSession.GetSaleLine(POSSaleLine);
            OnBeforeDeleteSaleLinePOS(POSSaleLine);
            DeleteAccessories(POSSaleLine);
            POSSaleLine.DeleteLine();
        end;

        if (CurrentView.Type() = CurrentView.Type()::Payment) then begin
            POSSession.GetPaymentLine(POSPaymentLine);
            POSPaymentLine.RefreshCurrent();
            POSPaymentLine.DeleteLine();
        end;

        POSSession.GetSale(POSSale);
        POSSale.SetModified();
        POSSession.RequestRefreshData();
    end;

    local procedure DeleteAccessories(POSSaleLine: Codeunit "NPR POS Sale Line")
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

    [IntegrationEvent(false, false)]
    procedure OnBeforeDeleteSaleLinePOS(POSSaleLine: Codeunit "NPR POS Sale Line")
    begin
    end;
}
