codeunit 6150808 "NPR POS Action: Quantity" implements "NPR IPOS Workflow"
{
    var
        MustBePositiveErr: Label 'Quantity must be positive.';
        QuantityGlobal: Decimal;
        InitializedQty: Boolean;

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        ActionDescription: Label 'Post Inventory Adjustment directly from POS';
        ParamInputType_CptLbl: Label 'Input Type';
        ParamInputType_OptLbl: Label 'Ask,Fixed,Increment', Locked = true;
        ParamInputType_OptCptLbl: Label 'Ask,Fixed,Increment';
        ParamInputType_DescLbl: Label 'Defines Input Type';
        ParamIncQty_CptLbl: Label 'Increment Quantity';
        ParamIncQty_DescLbl: Label 'Defines the quantity increment number';
        ParamConstraint_CptLbl: Label 'Constraint';
        ParamConstraint_OptLbl: Label 'No Constraint,Positive Quantity Only,Negative Quantity Only', Locked = true;
        ParamConstraint_OptCptLbl: Label 'No Constraint,Positive Quantity Only,Negative Quantity Only';
        ParamConstraint_DescLbl: Label 'Defines the Constraint';
        ParamChangeQty_CptLbl: Label 'Change To Quantity';
        ParamChangeQty_DescLbl: Label 'Defines change to quantity';
        ParamNegInput_CptLbl: Label 'Negative Input';
        ParamNegInput_DescLbl: Label 'Defines negative input of quantity';
        ParamPrompUnitPriceNegInput_CptLbl: Label 'Prompt Unit Price On Negative Input';
        ParamPrompUnitPriceNegInput_DescLbl: Label 'Defines if Prompt Unit Price will show On Negative Input';
        ParamMaxQtyAllowed_CptLbl: Label 'Max Quantity Allowed';
        ParamMaxQtyAllowed_DescLbl: Label 'Defines Maximum Quantity Allowed';
        ParamSkipItemAvCheck_CptLbl: Label 'Skip Item Availability Check';
        ParamSkipItemAvCheck_DescLbl: Label 'Enable/Disable skip Item Availability Check';
        CannotExceedMaxQtyErr: Label 'Quantity cannot exceed the limit value.';
        PriceCaptionLbl: Label 'Enter Unit Price';
        QtyCaptionLbl: Label 'Enter Quantity';
        MustBeNegativeErr: Label 'Quantity must be negative.';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddOptionParameter(
            'InputType',
            ParamInputType_OptLbl,
#pragma warning disable AA0139
            SelectStr(1, ParamInputType_OptLbl),
#pragma warning restore 
            ParamInputType_DescLbl,
            ParamInputType_CptLbl,
            ParamInputType_OptCptLbl);
        WorkflowConfig.AddDecimalParameter('IncrementQuantity', 0, ParamIncQty_CptLbl, ParamIncQty_DescLbl);
        WorkflowConfig.AddOptionParameter(
            'Constraint',
            ParamConstraint_OptLbl,
#pragma warning disable AA0139
            SelectStr(1, ParamConstraint_OptLbl),
#pragma warning restore 
            ParamConstraint_DescLbl,
            ParamConstraint_CptLbl,
            ParamConstraint_OptCptLbl);
        WorkflowConfig.AddTextParameter('ChangeToQuantity', '0', ParamChangeQty_CptLbl, ParamChangeQty_DescLbl);
        WorkflowConfig.AddBooleanParameter('NegativeInput', false, ParamNegInput_CptLbl, ParamNegInput_DescLbl);
        WorkflowConfig.AddBooleanParameter('PromptUnitPriceOnNegativeInput', true, ParamPrompUnitPriceNegInput_CptLbl, ParamPrompUnitPriceNegInput_DescLbl);
        WorkflowConfig.AddDecimalParameter('MaxQuantityAllowed', 0, ParamMaxQtyAllowed_CptLbl, ParamMaxQtyAllowed_DescLbl);
        WorkflowConfig.AddBooleanParameter('SkipItemAvailabilityCheck', false, ParamSkipItemAvCheck_CptLbl, ParamSkipItemAvCheck_DescLbl);
        WorkflowConfig.AddLabel('QtyCaption', QtyCaptionLbl);
        WorkflowConfig.AddLabel('PriceCaption', PriceCaptionLbl);
        WorkflowConfig.AddLabel('MustBePositive', MustBePositiveErr);
        WorkflowConfig.AddLabel('MustBeNegative', MustBeNegativeErr);
        WorkflowConfig.AddLabel('CannotExceedMaxQty', CannotExceedMaxQtyErr);
    end;


    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    var
    begin
        case Step of
            'AddPresetValuesToContext':
                FrontEnd.WorkflowResponse(AddPresetValuesToContext(Context));
            'AskForReturnReason':
                FrontEnd.WorkflowResponse(SelectReturnReason());
            'ChangeQty':
                ChangeQty(Context, SaleLine);
        end;
    end;

    local procedure ChangeQty(Context: Codeunit "NPR POS JSON Helper"; SaleLine: Codeunit "NPR POS Sale Line")
    var
        Quantity: Decimal;
        UnitPrice: Decimal;
        ConstraintOption: Option "No Constraint","Positive Quantity Only","Negative Quantity Only";
        ReturnReasonCode: Code[20];
        NegativeInput: Boolean;
        SkipItemAvailabilityCheck: Boolean;
        POSActQuantityB: Codeunit "NPR POS Action: Quantity B";
        PromptUnitPriceOnNegativeInput: Boolean;
    begin
        if (Context.GetBoolean('PromptForReason') = true) then
            ReturnReasonCode := CopyStr(Context.GetString('ReturnReasonCode'), 1, MaxStrLen(ReturnReasonCode));

        PromptUnitPriceOnNegativeInput := Context.GetBooleanParameter('PromptUnitPriceOnNegativeInput');

        Quantity := GetQty(Context);

        NegativeInput := Context.GetBooleanParameter('NegativeInput');

        if (PromptUnitPriceOnNegativeInput) and (Quantity > 0) and (NegativeInput) then
            UnitPrice := Context.GetDecimal('PromptUnitPrice');

        ConstraintOption := Context.GetIntegerParameter('Constraint');
        SkipItemAvailabilityCheck := Context.GetBooleanParameter('SkipItemAvailabilityCheck');

        POSActQuantityB.ChangeQuantity(ReturnReasonCode, Quantity, UnitPrice, ConstraintOption, NegativeInput, SkipItemAvailabilityCheck, SaleLine);

    end;

    local procedure GetQty(Context: Codeunit "NPR POS JSON Helper"): Decimal
    var
        QuantityText: Text;
        POSActQuantityB: Codeunit "NPR POS Action: Quantity B";
    begin
        if not InitializedQty then begin
            QuantityText := Context.GetString('PromptQuantity');

            if not Evaluate(QuantityGlobal, QuantityText) then begin
                POSActQuantityB.RemoveStarFromQuantity(QuantityText);
                Evaluate(QuantityGlobal, QuantityText);
            end;
            InitializedQty := true;
        end;

        exit(QuantityGlobal);
    end;

    local procedure AddPresetValuesToContext(Context: Codeunit "NPR POS JSON Helper") Response: JsonObject;
    var
        POSAuditProfile: Record "NPR POS Audit Profile";
        POSUnit: Record "NPR POS Unit";
        POSSetup: Codeunit "NPR POS Setup";
        POSSession: Codeunit "NPR POS Session";
        Quantity: Decimal;
    begin
        Quantity := GetQty(Context);

        if (Context.GetBooleanParameter('NegativeInput') = false) and (Quantity > 0) then begin
            Response.Add('PromptForReason', false);
            exit;
        end;

        POSSession.GetSetup(POSSetup);
        POSSetup.GetPOSUnit(POSUnit);
        if POSUnit.GetProfile(POSAuditProfile) then
            Response.Add('PromptForReason', POSAuditProfile."Require Item Return Reason");
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

    local procedure SelectReturnReason() Response: JsonObject;
    var
        ReturnReason: Record "Return Reason";
        ReasonRequiredErr: Label 'You must choose a return reason.';
    begin
        if Page.RunModal(Page::"NPR TouchScreen: Ret. Reasons", ReturnReason) = Action::LookupOK then
            Response.Add('ReturnReasonCode', ReturnReason.Code)
        else
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
            EanBoxEvent."Module Name" := CopyStr(SaleLinePOS.TableCaption, 1, MaxStrLen(EanBoxEvent."Module Name"));
            EanBoxEvent.Description := CopyStr(SaleLinePOS.FieldCaption(Quantity), 1, MaxStrLen(EanBoxEvent.Description));
            EanBoxEvent."Action Code" := CopyStr(ActionCode(), 1, MaxStrLen(EanBoxEvent."Action Code"));
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

    local procedure ActionCode(): Code[20]
    begin
        exit(Format(Enum::"NPR POS Workflow"::QUANTITY));
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionQuantity.Codeunit.js###
'let main=async({workflow:a,context:n,popup:i,parameters:t,captions:e})=>{let o,r=runtime.getData("BUILTIN_SALELINE"),u=parseFloat(r._current[12]);if(t.Constraint==t.Constraint["Positive Quantity Only"]&&u<0){i.error(e.MustBePositive);return}if(t.Constraint==t.Constraint["Negative Quantity Only"]&&u>0){i.error(e.MustBeNegative);return}if(n.PromptQuantity=t.InputType==0?await i.numpad({caption:e.QtyCaption,value:u}):t.InputType==1?t.ChangeToQuantity:t.InputType==2?u+t.IncrementQuantity:null,!n.PromptQuantity)return;if(t.MaxQuantityAllowed&&t.MaxQuantityAllowed!=0&&Math.abs(n.PromptQuantity)>t.MaxQuantityAllowed){i.error(e.CannotExceedMaxQty+" "+t.MaxQuantityAllowed);return}let y=await a.respond("AddPresetValuesToContext");t.PromptUnitPriceOnNegativeInput&&(t.NegativeInput?n.PromptQuantity>0:n.PromptQuantity<0)&&(n.PromptUnitPrice=await i.numpad({caption:e.PriceCaption,value:r._current[15]})),y.PromptForReason?(o=await a.respond("AskForReturnReason"),n.PromptForReason=!0):(n.PromptForReason=!1,o=""),await a.respond("ChangeQty",o)};'
          );
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(Codeunit::"NPR POS Action: Quantity");
    end;
    #endregion
}
