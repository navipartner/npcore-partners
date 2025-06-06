codeunit 6150808 "NPR POS Action: Quantity" implements "NPR IPOS Workflow"
{
    var
        MustBePositiveErr: Label 'Quantity must be positive.';
        QuantityGlobal: Decimal;
        InitializedQty: Boolean;

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        ActionDescriptionLbl: Label 'Post Inventory Adjustment directly from POS';
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
        TakePhotoLbl: Label 'Take photo';
        TakePhotoDesc: Label 'Specifies if the user has to insert photo.';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescriptionLbl);
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
        WorkflowConfig.AddBooleanParameter(TakePhotoParLbl, false, TakePhotoLbl, TakePhotoDesc);
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    begin
        case Step of
            'AddPresetValuesToContext':
                FrontEnd.WorkflowResponse(AddPresetValuesToContext(Context, Sale));
            'AskForReturnReason':
                FrontEnd.WorkflowResponse(SelectReturnReason());
            'ChangeQty':
                ChangeQty(Context, SaleLine, Sale);
            'PreparePostWorkflows':
                FrontEnd.WorkflowResponse(PreparePostWorkflows(Context, SaleLine));
        end;
    end;

    local procedure ChangeQty(Context: Codeunit "NPR POS JSON Helper"; SaleLine: Codeunit "NPR POS Sale Line"; Sale: codeunit "NPR POS Sale")
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        POSActQuantityB: Codeunit "NPR POS Action: Quantity B";
        POSActionTakePhotoB: Codeunit "NPR POS Action Take Photo B";
        Quantity: Decimal;
        UnitPrice: Decimal;
        ConstraintOption: Option "No Constraint","Positive Quantity Only","Negative Quantity Only";
        ReturnReasonCode: Code[20];
        NegativeInput: Boolean;
        SkipItemAvailabilityCheck: Boolean;
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

        TakePhotoEnabled := Context.GetBooleanParameter(TakePhotoParLbl);
        if TakePhotoEnabled then
            POSActionTakePhotoB.CheckIfPhotoIsTaken(Sale);
        POSActQuantityB.ChangeQuantity(ReturnReasonCode, Quantity, UnitPrice, ConstraintOption, NegativeInput, SkipItemAvailabilityCheck, SaleLine);

        SaleLine.GetCurrentSaleLine(SaleLinePOS);
    end;

    local procedure GetQty(Context: Codeunit "NPR POS JSON Helper"): Decimal
    var
        POSActQuantityB: Codeunit "NPR POS Action: Quantity B";
        QuantityText: Text;
    begin
        if not InitializedQty then begin
            QuantityText := Context.GetString('PromptQuantity');

            if not Evaluate(QuantityGlobal, QuantityText, 9) then begin
                POSActQuantityB.RemoveStarFromQuantity(QuantityText);
                Evaluate(QuantityGlobal, QuantityText);
            end;
            InitializedQty := true;
        end;

        exit(QuantityGlobal);
    end;

    local procedure AddPresetValuesToContext(Context: Codeunit "NPR POS JSON Helper"; Sale: codeunit "NPR POS Sale") Response: JsonObject;
    var
        POSAuditProfile: Record "NPR POS Audit Profile";
        POSUnit: Record "NPR POS Unit";
        POSSetup: Codeunit "NPR POS Setup";
        POSSession: Codeunit "NPR POS Session";
        POSActionTakePhotoB: Codeunit "NPR POS Action Take Photo B";
        Quantity: Decimal;
    begin
        Quantity := GetQty(Context);

        TakePhotoEnabled := Context.GetBooleanParameter(TakePhotoParLbl);
        if TakePhotoEnabled then
            POSActionTakePhotoB.TakePhoto(Sale);
        if (Context.GetBooleanParameter('NegativeInput') = false) and (Quantity > 0) then begin
            Response.Add('PromptForReason', false);
            exit;
        end;

        POSSession.GetSetup(POSSetup);
        POSSetup.GetPOSUnit(POSUnit);
        if POSUnit.GetProfile(POSAuditProfile) then
            Response.Add('PromptForReason', POSAuditProfile."Require Item Return Reason");
    end;

    local procedure PreparePostWorkflows(Context: Codeunit "NPR POS JSON Helper"; SaleLine: Codeunit "NPR POS Sale Line") Response: JsonObject
    var
        POSActionPublishers: Codeunit "NPR POS Action Publishers";
        PostWorkflows: JsonObject;
    begin
        PostWorkflows.ReadFrom('{}');
        POSActionPublishers.OnAddPostWorkflowsToRunOnQuantity(Context, SaleLine, PostWorkflows);
        Response.Add('postWorkflows', PostWorkflows);
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
'let main=async({workflow:t,context:a,popup:e,parameters:r,captions:n})=>{let o,i=runtime.getData("BUILTIN_SALELINE"),s=parseFloat(i._current[12]);if(r.Constraint==r.Constraint["Positive Quantity Only"]&&s<0)return void e.error(n.MustBePositive);if(r.Constraint==r.Constraint["Negative Quantity Only"]&&s>0)return void e.error(n.MustBeNegative);if(a.PromptQuantity=0==r.InputType?await e.numpad({caption:n.QtyCaption,value:s}):1==r.InputType?r.ChangeToQuantity:2==r.InputType?s+r.IncrementQuantity:null,!a.PromptQuantity)return;if(r.MaxQuantityAllowed&&0!=r.MaxQuantityAllowed&&Math.abs(a.PromptQuantity)>r.MaxQuantityAllowed)return void e.error(n.CannotExceedMaxQty+" "+r.MaxQuantityAllowed);let p=await t.respond("AddPresetValuesToContext");if(r.PromptUnitPriceOnNegativeInput&&(r.NegativeInput?a.PromptQuantity>0:a.PromptQuantity<0)&&(a.PromptUnitPrice=await e.numpad({caption:n.PriceCaption,value:i._current[15]}),!a.PromptUnitPrice))return;p.PromptForReason?(o=await t.respond("AskForReturnReason"),a.PromptForReason=!0):(a.PromptForReason=!1,o=""),await t.respond("ChangeQty",o);let{postWorkflows:u}=await t.respond("PreparePostWorkflows");await processWorkflows(u)};async function processWorkflows(t){if(t)for(const[a,{mainParameters:e,customParameters:r}]of Object.entries(t))await workflow.run(a,{context:{customParameters:r},parameters:e})}'
          );
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(Codeunit::"NPR POS Action: Quantity");
    end;
    #endregion

    var
        TakePhotoEnabled: Boolean;
        TakePhotoParLbl: Label 'TakePhoto', Locked = true;
}
