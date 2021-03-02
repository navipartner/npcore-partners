codeunit 6150808 "NPR POS Action: Quantity"
{
    trigger OnRun()
    begin
    end;

    var
        ActionDescription: Label 'This is a build in function to change quantity.';
        MUST_BE_POSITIVE: Label 'Quantity must be positive.';
        MUST_BE_NEGATIVE: Label 'Quantity must be negative.';
        SALE_MUST_BE_POSITIVE: Label 'Quantity must be positive on the sales line.';
        SALE_MUST_BE_NEGATIVE: Label 'Quantity must be negative on the sales line.';
        QtyCaption: Label 'Enter Quantity:';
        PriceCaption: Label 'Enter Unit Price:';
        WRONG_RETURN_QUANTITY: Label 'The maximum number of units to return for %1 is %2.';
        WRONG_QUANTITY: Label 'The minimum number of units to sell must be greater than zero.';

    local procedure ActionCode(): Text
    begin
        exit('QUANTITY');
    end;

    local procedure ActionVersion(): Text
    begin
        exit('1.7');
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    begin
        with Sender do
            if DiscoverAction(
              ActionCode(),
              ActionDescription,
              ActionVersion(),
              Sender.Type::Generic,
              Sender."Subscriber Instances Allowed"::Multiple)
            then begin
                RegisterWorkflowStep('ValidatePositiveConstraint', 'if ((param.Constraint == param.Constraint["Positive Quantity Only"]) && (parseFloat (data("12")) < 0)) { message (labels.MustBePositive);abort();};');
                RegisterWorkflowStep('ValidateNegativeConstraint', 'if ((param.Constraint == param.Constraint["Negative Quantity Only"]) && (parseFloat (data("12")) > 0)) { message (labels.MustBeNegative);abort();};');
                RegisterWorkflowStep('PromptQuantity',
                  'switch(param.InputType + "") {' +
                  '  case "0":' +
                  '    numpad({caption: labels.QtyCaption, value: Math.abs(parseFloat(data("12")))}).cancel(abort);' +
                  '    break;' +
                  '  case "1":' +
                  '    if (param.ChangeToQuantity.substring(param.ChangeToQuantity.length - 1) == "*") {' +
                  '      param.ChangeToQuantity = param.ChangeToQuantity.substring(0,param.ChangeToQuantity.length - 1);' +
                  '    }' +
                  '    context.$PromptQuantity = {"numpad": param.ChangeToQuantity};' +
                  '    break;' +
                  '  case "2":' +
                  '    var qty = parseFloat(data("12")) + param.IncrementQuantity;' +
                  '    context.$PromptQuantity = {"numpad": qty};' +
                  '    break;' +
                  '  default:' +
                  '    goto("EndOfWorkflow");' +
                  '}');
                RegisterWorkflowStep('PromptUnitPrice',
                  'if ((param.PromptUnitPriceOnNegativeInput) && (param.NegativeInput ? context.$PromptQuantity.numpad * -1 < 0 : context.$PromptQuantity.numpad < 0)) {' +
                  '  numpad({caption: labels.PriceCaption, value: data("15")})' +
                  '};');
                RegisterWorkflowStep('AskForReturnReason', 'context.PromptForReason && respond();');
                RegisterWorkflowStep('EndOfWorkflow', 'respond()');

                RegisterWorkflow(true);
                RegisterDataBinding();

                RegisterOptionParameter('Security', 'None,SalespersonPassword,CurrentSalespersonPassword,SupervisorPassword', 'None');
                RegisterOptionParameter('InputType', 'Ask,Fixed,Increment', 'Ask');
                RegisterDecimalParameter('IncrementQuantity', 0);
                RegisterOptionParameter('Constraint', 'No Constraint,Positive Quantity Only,Negative Quantity Only', 'No Constraint');
                RegisterTextParameter('ChangeToQuantity', '0');
                RegisterBooleanParameter('NegativeInput', false);
                RegisterBooleanParameter('PromptUnitPriceOnNegativeInput', true);
            end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150702, 'OnInitializeCaptions', '', false, false)]
    local procedure OnInitializeCaptions(Captions: Codeunit "NPR POS Caption Management")
    var
        UI: Codeunit "NPR POS UI Management";
    begin
        Captions.AddActionCaption(ActionCode, 'QtyCaption', QtyCaption);
        Captions.AddActionCaption(ActionCode, 'PriceCaption', PriceCaption);
        Captions.AddActionCaption(ActionCode, 'MustBePositive', MUST_BE_POSITIVE);
        Captions.AddActionCaption(ActionCode, 'MustBeNegative', MUST_BE_NEGATIVE);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS JavaScript Interface", 'OnBeforeWorkflow', '', true, false)]
    local procedure OnBeforeWorkflow(Action: Record "NPR POS Action"; Parameters: JsonObject; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        RetailItemSetup: Record "NPR Retail Item Setup";
        Context: Codeunit "NPR POS JSON Management";
        NegativeInput: Boolean;
    begin
        if not Action.IsThisAction(ActionCode) then
            exit;

        Handled := true;

        Context.InitializeJObjectParser(Parameters, FrontEnd);
        Context.SetScope('/', true);
        NegativeInput := Context.GetBoolean('NegativeInput', true);
        if not NegativeInput then
            exit;

        RetailItemSetup.Get();
        Context.SetContext('PromptForReason', RetailItemSetup."Reason for Return Mandatory");

        FrontEnd.SetActionContext(ActionCode, Context);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        SaleLinePOS: Record "NPR Sale Line POS";
        JSON: Codeunit "NPR POS JSON Management";
        SaleLine: Codeunit "NPR POS Sale Line";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        ChangeToQuantity: Decimal;
        Quantity: Decimal;
        UnitPrice: Decimal;
        ConstraintOption: Integer;
        ReturnReasonCode: Code[20];
        NegativeInput: Boolean;
        QtyCheck: Boolean;
        POSSalesLine: Record "NPR POS Sales Line";
    begin
        if not Action.IsThisAction(ActionCode) then
            exit;

        Handled := true;

        JSON.InitializeJObjectParser(Context, FrontEnd);

        if WorkflowStep = 'AskForReturnReason' then begin
            ReturnReasonCode := SelectReturnReason();
            JSON.SetContext('ReturnReasonCode', ReturnReasonCode);
            FrontEnd.SetActionContext(ActionCode, JSON);
            exit;
        end;

        ReturnReasonCode := JSON.GetString('ReturnReasonCode', false);

        ConstraintOption := JSON.GetIntegerParameter('Constraint', true);

        NegativeInput := JSON.GetBooleanParameter('NegativeInput', true);
        Quantity := GetDecimal(JSON, 'PromptQuantity');
        UnitPrice := GetDecimal(JSON, 'PromptUnitPrice');

        if NegativeInput and (Quantity > 0) then
            Quantity *= -1;

        POSSession.GetSaleLine(SaleLine);
        SaleLine.GetCurrentSaleLine(SaleLinePOS);

        if (SaleLinePOS."Return Sale Sales Ticket No." <> '') then begin
            POSSalesLine.SetRange("Document No.", SaleLinePOS."Return Sale Sales Ticket No.");
            POSSalesLine.SetRange("Line No.", SaleLinePOS."Line No.");
            if POSSalesLine.FindFirst() then
                if Abs(Quantity) > Abs(POSSalesLine.Quantity) then
                    Error(WRONG_RETURN_QUANTITY, POSSalesLine.Description, Abs(POSSalesLine.Quantity));
        end;

        case ConstraintOption of
            1: // Positive qty constraint
                begin
                    if (Quantity = 0) then
                        Error(WRONG_QUANTITY);
                    if (Quantity < 0) then
                        Error(SALE_MUST_BE_POSITIVE);
                end;

            2: // Negative qty constraint
                begin
                    if (Quantity = 0) then
                        Error(WRONG_QUANTITY);
                    if (Quantity > 0) then
                        Error(SALE_MUST_BE_NEGATIVE);
                end;
        end;

        SaleLine.SetQuantity(Quantity);

        // Manual Unit Price when returning goods
        if (UnitPrice <> 0) and (Quantity < 0) then
            SaleLine.SetUnitPrice(Abs(UnitPrice));

        if ReturnReasonCode <> '' then begin
            SaleLine.GetCurrentSaleLine(SaleLinePOS);
            SaleLinePOS.Validate("Return Reason Code", ReturnReasonCode);
            SaleLinePOS.Modify();
            SaleLine.RefreshCurrent;
        END;

        POSSession.RequestRefreshData();
    end;

    local procedure GetDecimal(JSON: Codeunit "NPR POS JSON Management"; Path: Text): Decimal
    begin
        JSON.SetScope('/', true);
        if (not JSON.SetScope('$' + Path, false)) then
            exit(0);

        exit(JSON.GetDecimal('numpad', true));
    end;

    local procedure SelectReturnReason(): Code[10]
    var
        ReturnReason: Record "Return Reason";
        ReasonRequiredErr: Label 'You must choose a return reason.';
    begin
        if Page.RunModal(Page::"NPR TouchScreen: Ret. Reasons", ReturnReason) = Action::LookupOK then
            exit(ReturnReason.Code);

        Error(ReasonRequiredErr);
    end;

    //--- Ean Box Event Handling ---

    [EventSubscriber(ObjectType::Codeunit, 6060105, 'DiscoverEanBoxEvents', '', true, true)]
    local procedure DiscoverEanBoxEvents(var EanBoxEvent: Record "NPR Ean Box Event")
    var
        SaleLinePOS: Record "NPR Sale Line POS";
    begin
        if not EanBoxEvent.Get(EventCodeQtyStar()) then begin
            EanBoxEvent.Init;
            EanBoxEvent.Code := EventCodeQtyStar();
            EanBoxEvent."Module Name" := SaleLinePOS.TableCaption;
            EanBoxEvent.Description := CopyStr(SaleLinePOS.FieldCaption(Quantity), 1, MaxStrLen(EanBoxEvent.Description));
            EanBoxEvent."Action Code" := ActionCode();
            EanBoxEvent."POS View" := EanBoxEvent."POS View"::Sale;
            EanBoxEvent."Event Codeunit" := CurrCodeunitId();
            EanBoxEvent.Insert(true);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6060105, 'OnInitEanBoxParameters', '', true, true)]
    local procedure OnInitEanBoxParameters(var Sender: Codeunit "NPR POS Input Box Setup Mgt."; EanBoxEvent: Record "NPR Ean Box Event")
    begin
        case EanBoxEvent.Code of
            EventCodeQtyStar():
                begin
                    Sender.SetNonEditableParameterValues(EanBoxEvent, 'ChangeToQuantity', true, '0');
                    Sender.SetNonEditableParameterValues(EanBoxEvent, 'InputType', false, 'Fixed');
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6060107, 'SetEanBoxEventInScope', '', true, true)]
    local procedure SetEanBoxEventInScopeQtyStar(EanBoxSetupEvent: Record "NPR Ean Box Setup Event"; EanBoxValue: Text; var InScope: Boolean)
    var
        MMMemberCard: Record "NPR MM Member Card";
        Position: Integer;
        DecBuffer: Decimal;
    begin
        if EanBoxSetupEvent."Event Code" <> EventCodeQtyStar() then
            exit;

        Position := StrPos(EanBoxValue, '*');
        if Position <> StrLen(EanBoxValue) then
            exit;

        EanBoxValue := DelStr(EanBoxValue, Position);
        if EanBoxValue = '' then
            exit;

        if Evaluate(DecBuffer, EanBoxValue) then
            InScope := true;
    end;

    local procedure EventCodeQtyStar(): Code[20]
    begin
        exit('QTYSTAR');
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(Codeunit::"NPR POS Action: Quantity");
    end;
}