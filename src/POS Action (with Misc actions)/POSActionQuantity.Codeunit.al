codeunit 6150808 "NPR POS Action: Quantity"
{
    // NPR5.32.10/TSA/20170615  CASE 280993 Changes to workflow regarding unitprice dialog and default quantity
    // NPR5.36/ANEN/20170901  CASE 288703 Adding parameter ChangeToQuantity
    // NPR5.38/MMV /20171208  CASE 296804 Added parameter NegativeInput. 5.38 upgrade codeunit will set this to default false silently and Refactored js steps.
    // NPR5.40/MHA /20180315  CASE 307228 Added Parameter PromptUnitPriceOnNegativeInput
    // NPR5.42/BHR /20180214  CASE 312830 Added Security functionality
    // NPR5.44/MHA /20180720  CASE 320844 Added Parameter InputType
    // NPR5.45/MHA /20180817  CASE 319706 Added Ean Box Event Handler functions
    // NPR5.46/TSA /20180914 CASE 314603 Refactored the security functionality to use secure methods
    // NPR5.46/TSA /20180914 CASE 314603 Removed green code
    // NPR5.49/MHA /20190328  CASE 350374 Added MaxStrLen to EanBox.Description in DiscoverEanBoxEvents()
    // NPR5.51/ALPO/20190802 CASE 362928 Fix: POS Action 'QUANTITY', parameter Constraint was applied to incorrect quantity variable


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

        exit('1.7'); //-+NPR5.46 [314603]
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

                //-NPR5.44 [320844]
                //RegisterWorkflowStep ('PromptQuantity', 'if (param.ChangeToQuantity == -9999) { numpad({caption: labels.QtyCaption, value: Math.abs(parseFloat(data("12")))}).cancel(abort); }');
                RegisterWorkflowStep('PromptQuantity',
                  'switch(param.InputType + "") {' +
                  '  case "0":' +
                  '    numpad({caption: labels.QtyCaption, value: Math.abs(parseFloat(data("12")))}).cancel(abort);' +
                  '    break;' +
                  '  case "1":' +
                  //-NPR5.45 [319706]
                  '    if (param.ChangeToQuantity.substring(param.ChangeToQuantity.length - 1) == "*") {' +
                  '      param.ChangeToQuantity = param.ChangeToQuantity.substring(0,param.ChangeToQuantity.length - 1);' +
                  '    }' +
                  //+NPR5.45 [319706]
                  '    context.$PromptQuantity = {"numpad": param.ChangeToQuantity};' +
                  '    break;' +
                  '  case "2":' +
                  '    var qty = parseFloat(data("12")) + param.IncrementQuantity;' +
                  '    context.$PromptQuantity = {"numpad": qty};' +
                  '    break;' +
                  '  default:' +
                  '    goto("EndOfWorkflow");' +
                  '}');
                //+NPR5.44 [320844]

                //-NPR5.44 [320844]
                //RegisterWorkflowStep('PromptUnitPrice', 'if ((param.PromptUnitPriceOnNegativeInput) ' +
                //                                         '&& (((param.ChangeToQuantity == -9999) && (param.NegativeInput ? context.$PromptQuantity.numpad * -1 < 0 : context.$PromptQuantity.numpad < 0)) ' +
                //                                         '|| ((param.ChangeToQuantity != -9999) && (param.NegativeInput)))) ' +
                //                                           '{ numpad({caption: labels.PriceCaption, value: data("15")}) };');
                RegisterWorkflowStep('PromptUnitPrice',
                  'if ((param.PromptUnitPriceOnNegativeInput) && (param.NegativeInput ? context.$PromptQuantity.numpad * -1 < 0 : context.$PromptQuantity.numpad < 0)) {' +
                  '  numpad({caption: labels.PriceCaption, value: data("15")})' +
                  '};');
                //+NPR5.44 [320844]

                RegisterWorkflowStep('EndOfWorkflow', 'respond()');

                RegisterWorkflow(false);
                RegisterDataBinding();
                //-NPR5.42 [312830]
                RegisterOptionParameter('Security', 'None,SalespersonPassword,CurrentSalespersonPassword,SupervisorPassword', 'None');
                //+NPR5.42 [312830]

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

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        JSON: Codeunit "NPR POS JSON Management";
        SaleLine: Codeunit "NPR POS Sale Line";
        SaleLinePOS: Record "NPR Sale Line POS";
        AuditRoll: Record "NPR Audit Roll";
        Quantity: Decimal;
        UnitPrice: Decimal;
        ConstraintOption: Integer;
        QtyCheck: Boolean;
        ChangeToQuantity: Decimal;
        POSSaleLine: Codeunit "NPR POS Sale Line";
        NegativeInput: Boolean;
    begin
        if not Action.IsThisAction(ActionCode) then
            exit;

        JSON.InitializeJObjectParser(Context, FrontEnd);

        ConstraintOption := JSON.GetIntegerParameter('Constraint', true);

        NegativeInput := JSON.GetBooleanParameter('NegativeInput', true);
        Quantity := GetDecimal(JSON, 'PromptQuantity');
        UnitPrice := GetDecimal(JSON, 'PromptUnitPrice');

        if NegativeInput and (Quantity > 0) then
            Quantity *= -1;

        POSSession.GetSaleLine(SaleLine);
        SaleLine.GetCurrentSaleLine(SaleLinePOS);

        if (SaleLinePOS."Return Sale Sales Ticket No." <> '') then begin
            AuditRoll.SetFilter("Sales Ticket No.", '=%1', SaleLinePOS."Return Sale Sales Ticket No.");
            AuditRoll.SetFilter("Line No.", '=%1', SaleLinePOS."Line No.");
            if (AuditRoll.FindFirst()) then
                if (Abs(Quantity) > Abs(AuditRoll.Quantity)) then
                    Error(WRONG_RETURN_QUANTITY, AuditRoll.Description, Abs(AuditRoll.Quantity));
        end;

        case ConstraintOption of
            1: // Positive qty constraint
                begin
                    if (Quantity = 0) then
                        Error(WRONG_QUANTITY);
                    //-NPR5.51 [362928]
                    //IF (SaleLinePOS.Quantity < 0) THEN
                    if (Quantity < 0) then
                        //+NPR5.51 [362928]
                        Error(SALE_MUST_BE_POSITIVE);
                end;

            2: // Negative qty constraint
                begin
                    if (Quantity = 0) then
                        Error(WRONG_QUANTITY);
                    //-NPR5.51 [362928]
                    //IF (SaleLinePOS.Quantity > 0) THEN
                    if (Quantity > 0) then
                        //+NPR5.51 [362928]
                        Error(SALE_MUST_BE_NEGATIVE);
                end;
        end;

        SaleLine.SetQuantity(Quantity);

        // Manual Unit Price when returning goods
        if (UnitPrice <> 0) and (Quantity < 0) then
            SaleLine.SetUnitPrice(Abs(UnitPrice));

        POSSession.RequestRefreshData();

        Handled := true;
    end;

    local procedure "--"()
    begin
    end;

    local procedure GetDecimal(JSON: Codeunit "NPR POS JSON Management"; Path: Text): Decimal
    begin
        JSON.SetScope('/', true);
        if (not JSON.SetScope('$' + Path, false)) then
            exit(0);

        exit(JSON.GetDecimal('numpad', true));
    end;

    local procedure "--- Ean Box Event Handling"()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6060105, 'DiscoverEanBoxEvents', '', true, true)]
    local procedure DiscoverEanBoxEvents(var EanBoxEvent: Record "NPR Ean Box Event")
    var
        SaleLinePOS: Record "NPR Sale Line POS";
    begin
        //-NPR5.45 [319706]
        if not EanBoxEvent.Get(EventCodeQtyStar()) then begin
            EanBoxEvent.Init;
            EanBoxEvent.Code := EventCodeQtyStar();
            EanBoxEvent."Module Name" := SaleLinePOS.TableCaption;
            //-NPR5.49 [350374]
            //EanBoxEvent.Description := SaleLinePOS.FIELDCAPTION(Quantity);
            EanBoxEvent.Description := CopyStr(SaleLinePOS.FieldCaption(Quantity), 1, MaxStrLen(EanBoxEvent.Description));
            //+NPR5.49 [350374]
            EanBoxEvent."Action Code" := ActionCode();
            EanBoxEvent."POS View" := EanBoxEvent."POS View"::Sale;
            EanBoxEvent."Event Codeunit" := CurrCodeunitId();
            EanBoxEvent.Insert(true);
        end;
        //+NPR5.45 [319706]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6060105, 'OnInitEanBoxParameters', '', true, true)]
    local procedure OnInitEanBoxParameters(var Sender: Codeunit "NPR Ean Box Setup Mgt."; EanBoxEvent: Record "NPR Ean Box Event")
    begin
        //-NPR5.45 [319706]
        case EanBoxEvent.Code of
            EventCodeQtyStar():
                begin
                    Sender.SetNonEditableParameterValues(EanBoxEvent, 'ChangeToQuantity', true, '0');
                    Sender.SetNonEditableParameterValues(EanBoxEvent, 'InputType', false, 'Fixed');
                end;
        end;
        //+NPR5.45 [319706]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6060107, 'SetEanBoxEventInScope', '', true, true)]
    local procedure SetEanBoxEventInScopeQtyStar(EanBoxSetupEvent: Record "NPR Ean Box Setup Event"; EanBoxValue: Text; var InScope: Boolean)
    var
        MMMemberCard: Record "NPR MM Member Card";
        Position: Integer;
        DecBuffer: Decimal;
    begin
        //-NPR5.45 [319706]
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
        //+NPR5.45 [319706]
    end;

    local procedure EventCodeQtyStar(): Code[20]
    begin
        //-NPR5.45 [319706]
        exit('QTYSTAR');
        //+NPR5.45 [319706]
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        //-NPR5.45 [319706]
        exit(CODEUNIT::"NPR POS Action: Quantity");
        //+NPR5.45 [319706]
    end;
}

