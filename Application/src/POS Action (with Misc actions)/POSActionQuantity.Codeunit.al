codeunit 6150808 "NPR POS Action: Quantity"
{
    var
        MustBePositiveErr: Label 'Quantity must be positive.';
        MustBeNegativeErr: Label 'Quantity must be negative.';
        ReadingErr: Label 'reading in %1 of %2';

    local procedure ActionCode(): Text
    begin
        exit('QUANTITY');
    end;

    local procedure ActionVersion(): Text
    begin
        exit('2.0');
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Action", 'OnDiscoverActions', '', true, true)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    var
        ActionDescriptionLbl: Label 'This is a build in function to change quantity.';
    begin
        if Sender.DiscoverAction20(ActionCode(), ActionDescriptionLbl, ActionVersion()) then begin
            Sender.RegisterWorkflow20(GetActionJavascript());

            Sender.RegisterOptionParameter('InputType', 'Ask,Fixed,Increment', 'Ask');
            Sender.RegisterDecimalParameter('IncrementQuantity', 0);
            Sender.RegisterOptionParameter('Constraint', 'No Constraint,Positive Quantity Only,Negative Quantity Only', 'No Constraint');
            Sender.RegisterTextParameter('ChangeToQuantity', '0');
            Sender.RegisterBooleanParameter('NegativeInput', false);
            Sender.RegisterBooleanParameter('PromptUnitPriceOnNegativeInput', true);
            Sender.RegisterDecimalParameter('MaxQuantityAllowed', 0);
        end;
    end;

    local procedure GetActionJavascript(): Text
    begin
        exit(
            //###NP_FILE_REPLACE:POSActionQuantity.Codeunit.js###
            'await workflow.respond("AddPresetValuesToContext"); let saleLines = runtime.getData("BUILTIN_SALELINE"); let currentQty = parseFloat(saleLines._current[12]); if (($parameters.Constraint == $parameters.Constraint["Positive Quantity Only"]) && (currentQty < 0)) { popup.error($labels.MustBePositive); return; }; if (($parameters.Constraint == $parameters.Constraint["Negative Quantity Only"]) && (currentQty > 0)) { popup.error($labels.MustBeNegative); return; }; $context.PromptQuantity = ($parameters.InputType == $parameters.InputType["Ask"]) ? await popup.numpad({ caption: $labels.QtyCaption, value: currentQty }) : ($parameters.InputType == $parameters.InputType["Fixed"]) ? $parameters.ChangeToQuantity : ($parameters.InputType == $parameters.InputType["Increment"]) ? currentQty + $parameters.IncrementQuantity : null; if (!$context.PromptQuantity) { return; }; if ($parameters.MaxQuantityAllowed) { if (($parameters.MaxQuantityAllowed != 0) && (Math.abs($context.PromptQuantity) > $parameters.MaxQuantityAllowed)) { popup.error($labels.CannotExceedMaxQty + " " + $parameters.MaxQuantityAllowed); return; }; }; if (($parameters.PromptUnitPriceOnNegativeInput) && ($parameters.NegativeInput ? $context.PromptQuantity > 0 : $context.PromptQuantity < 0)) { $context.PromptUnitPrice = await popup.numpad({ caption: $labels.PriceCaption, value: saleLines._current[15] }); }; if ($context.PromptForReason) { await workflow.respond("AskForReturnReason"); }; workflow.respond();'
          );
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS UI Management", 'OnInitializeCaptions', '', false, false)]
    local procedure OnInitializeCaptions(Captions: Codeunit "NPR POS Caption Management")
    var
        CannotExceedMaxQtyErr: Label 'Quantity cannot exceed the limit value.';
        PriceCaptionLbl: Label 'Enter Unit Price';
        QtyCaptionLbl: Label 'Enter Quantity';
    begin
        Captions.AddActionCaption(ActionCode(), 'QtyCaption', QtyCaptionLbl);
        Captions.AddActionCaption(ActionCode(), 'PriceCaption', PriceCaptionLbl);
        Captions.AddActionCaption(ActionCode(), 'MustBePositive', MustBePositiveErr);
        Captions.AddActionCaption(ActionCode(), 'MustBeNegative', MustBeNegativeErr);
        Captions.AddActionCaption(ActionCode(), 'CannotExceedMaxQty', CannotExceedMaxQtyErr);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Workflows 2.0", 'OnAction', '', true, true)]
    local procedure OnAction20("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session"; State: Codeunit "NPR POS WF 2.0: State"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        POSSalesLine: Record "NPR POS Entry Sales Line";
        SaleLinePOS: Record "NPR POS Sale Line";
        SaleLine: Codeunit "NPR POS Sale Line";
        Quantity: Decimal;
        UnitPrice: Decimal;
        ConstraintOption: Option "No Constraint","Positive Quantity Only","Negative Quantity Only";
        ReturnReasonCode: Code[20];
        NegativeInput: Boolean;
        SaleMustBePositiveErr: Label 'Quantity must be positive on the sales line.';
        SaleMustBeNegativeErr: Label 'Quantity must be negative on the sales line.';
        WrongQuantityErr: Label 'The minimum number of units to sell must be greater than zero.';
        WrongReturnQuantityErr: Label 'The maximum number of units to return for %1 is %2.', Comment = '%1 = item description, %2 = maximal allowed quantity for return';
    begin
        if not Action.IsThisAction(ActionCode()) then
            exit;
        Handled := true;

        CASE WorkflowStep OF
            'AddPresetValuesToContext':
                begin
                    AddPresetValuesToContext(Context, POSSession);
                    exit;
                end;
            'AskForReturnReason':
                begin
                    ReturnReasonCode := SelectReturnReason();
                    Context.SetContext('ReturnReasonCode', ReturnReasonCode);
                    exit;
                end;
        end;

        ReturnReasonCode := Context.GetString('ReturnReasonCode');
        Quantity := Context.GetDecimalOrFail('PromptQuantity', StrSubstNo(ReadingErr, 'OnAction', ActionCode()));
        UnitPrice := Context.GetDecimal('PromptUnitPrice');
        ConstraintOption := Context.GetIntegerParameter('Constraint');
        NegativeInput := Context.GetBooleanParameter('NegativeInput');

        if NegativeInput and (Quantity > 0) then
            Quantity := -Quantity;

        POSSession.GetSaleLine(SaleLine);
        SaleLine.GetCurrentSaleLine(SaleLinePOS);

        if (SaleLinePOS."Return Sale Sales Ticket No." <> '') then begin
            POSSalesLine.SetRange("Document No.", SaleLinePOS."Return Sale Sales Ticket No.");
            POSSalesLine.SetRange("Line No.", SaleLinePOS."Line No.");
            if POSSalesLine.FindFirst() then
                if Abs(Quantity) > Abs(POSSalesLine.Quantity) then
                    Error(WrongReturnQuantityErr, POSSalesLine.Description, Abs(POSSalesLine.Quantity));
        end;

        case ConstraintOption of
            ConstraintOption::"Positive Quantity Only":
                begin
                    if (Quantity = 0) then
                        Error(WrongQuantityErr);
                    if (Quantity < 0) then
                        Error(SaleMustBePositiveErr);
                end;
            ConstraintOption::"Negative Quantity Only":
                begin
                    if (Quantity = 0) then
                        Error(WrongQuantityErr);
                    if (Quantity > 0) then
                        Error(SaleMustBeNegativeErr);
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
            SaleLine.RefreshCurrent();
        END;

        POSSession.RequestRefreshData();
    end;

    local procedure AddPresetValuesToContext(Context: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session")
    var
        POSAuditProfile: Record "NPR POS Audit Profile";
        POSUnit: Record "NPR POS Unit";
        POSSetup: Codeunit "NPR POS Setup";
    begin
        if not Context.GetBooleanParameter('NegativeInput') then
            exit;

        POSSession.GetSetup(POSSetup);
        POSSetup.GetPOSUnit(POSUnit);
        if POSUnit.GetProfile(POSAuditProfile) then
            Context.SetContext('PromptForReason', POSAuditProfile."Require Item Return Reason");
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnValidateValue', '', true, false)]
    local procedure OnParameterValidateValue(var POSParameterValue: Record "NPR POS Parameter Value")
    var
        ValueAsDecimal: Decimal;
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;

        case POSParameterValue.Name of
            'MaxQuantityAllowed':
                begin
                    if POSParameterValue.Value = '' then
                        exit;
                    Evaluate(ValueAsDecimal, POSParameterValue.Value);
                    if ValueAsDecimal < 0 then
                        Error(MustBePositiveErr);
                end;
        end;
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

    #region Ean Box Event Handling
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Input Box Setup Mgt.", 'DiscoverEanBoxEvents', '', true, true)]
    local procedure DiscoverEanBoxEvents(var EanBoxEvent: Record "NPR Ean Box Event")
    var
        SaleLinePOS: Record "NPR POS Sale Line";
    begin
        if not EanBoxEvent.Get(EventCodeQtyStar()) then begin
            EanBoxEvent.Init();
            EanBoxEvent.Code := EventCodeQtyStar();
            EanBoxEvent."Module Name" := SaleLinePOS.TableCaption;
            EanBoxEvent.Description := CopyStr(SaleLinePOS.FieldCaption(Quantity), 1, MaxStrLen(EanBoxEvent.Description));
            EanBoxEvent."Action Code" := ActionCode();
            EanBoxEvent."POS View" := EanBoxEvent."POS View"::Sale;
            EanBoxEvent."Event Codeunit" := CurrCodeunitId();
            EanBoxEvent.Insert(true);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Input Box Setup Mgt.", 'OnInitEanBoxParameters', '', true, true)]
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

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Input Box Evt Handler", 'SetEanBoxEventInScope', '', true, true)]
    local procedure SetEanBoxEventInScopeQtyStar(EanBoxSetupEvent: Record "NPR Ean Box Setup Event"; EanBoxValue: Text; var InScope: Boolean)
    var
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
    #endregion
}
