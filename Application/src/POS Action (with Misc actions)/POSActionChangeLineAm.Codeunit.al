codeunit 6151175 "NPR POS Action: Change LineAm."
{
    var
        ActionDescriptionCaption: Label 'This action is used to change line amount VIA EAN Box events';
        NoSaleLineErr: Label 'A sale line must exist in order to change the amount';

    local procedure ActionCode(): Code[20]
    begin
        exit('CHANGE_AMOUNT');
    end;

    local procedure ActionVersion(): Text
    begin
        exit('1.0');
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    begin
        if Sender.DiscoverAction(
  ActionCode(),
  ActionDescriptionCaption,
  ActionVersion(),
  Sender.Type::Generic,
  Sender."Subscriber Instances Allowed"::Multiple)
then begin
            Sender.RegisterWorkflowStep('', 'respond();');
            Sender.RegisterWorkflow(false);

            Sender.RegisterDecimalParameter('NewLineAmount', 0);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        JSON: Codeunit "NPR POS JSON Management";
        LineAmount: Decimal;
    begin
        if not Action.IsThisAction(ActionCode()) then
            exit;

        JSON.InitializeJObjectParser(Context, FrontEnd);
        LineAmount := JSON.GetDecimalParameterOrFail('NewLineAmount', ActionCode());

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        if SaleLinePOS.IsEmpty then
            Error(NoSaleLineErr);

        SaleLinePOS.Validate("Amount Including VAT", LineAmount);
        SaleLinePOS.Modify();

        POSSaleLine.ResendAllOnAfterInsertPOSSaleLine();
        POSSale.RefreshCurrent();
        POSSession.RequestRefreshData();

        Handled := true;
    end;

    local procedure "-- Ean Box Event Handling"()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6060105, 'DiscoverEanBoxEvents', '', true, true)]
    local procedure DiscoverEanBoxEvents(var EanBoxEvent: Record "NPR Ean Box Event")
    var
        SaleLinePOS: Record "NPR POS Sale Line";
    begin
        if not EanBoxEvent.Get(EanEventCode()) then begin
            EanBoxEvent.Init();
            EanBoxEvent.Code := EanEventCode();
            EanBoxEvent."Module Name" := SaleLinePOS.TableCaption;
            EanBoxEvent.Description := CopyStr(SaleLinePOS.FieldCaption(Amount), 1, MaxStrLen(EanBoxEvent.Description));
            EanBoxEvent."Action Code" := ActionCode();
            EanBoxEvent."POS View" := EanBoxEvent."POS View"::Sale;
            EanBoxEvent."Event Codeunit" := CODEUNIT::"NPR POS Action: Change LineAm.";
            EanBoxEvent.Insert();
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6060105, 'OnInitEanBoxParameters', '', true, true)]
    local procedure OnInitEanBoxParameters(var Sender: Codeunit "NPR POS Input Box Setup Mgt."; EanBoxEvent: Record "NPR Ean Box Event")
    begin
        if EanBoxEvent.Code = EanEventCode() then
            Sender.SetNonEditableParameterValues(EanBoxEvent, 'NewLineAmount', true, '0');
    end;

    [EventSubscriber(ObjectType::Codeunit, 6060107, 'SetEanBoxEventInScope', '', true, true)]
    local procedure SetEanBoxEventInScope(EanBoxSetupEvent: Record "NPR Ean Box Setup Event"; EanBoxValue: Text; var InScope: Boolean)
    var
        Amount: Decimal;
    begin
        if EanBoxSetupEvent."Event Code" <> EanEventCode() then
            exit;

        if StrPos(EanBoxValue, '+') > 1 then
            exit;

        EanBoxValue := CopyStr(EanBoxValue, 2);
        if EanBoxValue = '' then
            exit;

        InScope := Evaluate(Amount, EanBoxValue);
    end;

    local procedure EanEventCode(): Code[20]
    begin
        exit('saleprice');
    end;
}
