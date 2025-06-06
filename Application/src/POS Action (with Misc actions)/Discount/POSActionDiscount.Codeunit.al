codeunit 6150792 "NPR POS Action - Discount" implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config");
    var
        ActionDescription: Label 'This is a built-in action for handling discount';
        TotalAmountLabel: Label 'Type in the total amount that you want for the whole sales';
        LineAmountLabel: Label 'Type in the total amount for the sales line';
        LineDiscountAmountLabel: Label 'Type in the discount amount that you want to give on the current sales line';
        LineDiscountPercentABSLabel: Label 'Type in the discount % that you want to give on the current sales line';
        LineDiscountPercentRELLabel: Label 'Type in the extra discount % that you want to give on the current sales line';
        LineDiscountPercentExtraLabel: Label 'Type in flat extra discount % that you want to give on the current sales line';
        TotalDiscountAmountLabel: Label 'Type in the discount amount that you want to give on the whole sales';
        DiscountPercentABSLabel: Label 'Type in the discount % that you want to give on the whole sales';
        DiscountPercentRELLabel: Label 'Type in the extra discount % that you want to give on the whole sales';
        DiscountPercentExtraLabel: Label 'Type in flat extra discount % that you want to give on the whole sales';
        LineUnitPriceLabel: Label 'Type in the unit price for the current sales line';
        DiscountAuthLbl: Label 'Discount Authorisation';
        DiscountTypeOptionLbl: Label 'TotalAmount,TotalDiscountAmount,DiscountPercentABS,DiscountPercentREL,LineAmount,LineDiscountAmount,LineDiscountPercentABS,LineDiscountPercentREL,LineUnitPrice,ClearLineDiscount,ClearTotalDiscount,DiscountPercentExtra,LineDiscountPercentExtra', Locked = true;
        TotalDiscTargetLinesCptOptLbl: Label 'Auto,Positive quantity lines only,Negative quantity lines only,All non-zero quantity lines,Ask';
        DiscountTypeCaptionLbl: Label 'Discount Type';
        FixedDiscountNumberCaptionLbl: Label 'Fixed Discount Number';
        FixedDiscountNumberDescLbl: Label 'Specifies Fixed Discount Number';
        AmtIncludesTaxCaptionLbl: Label 'Amount Incl. VAT/Tax';
        FixedReasonCodeCaptionLbl: Label 'Reason: Fixed Code';
        LookupReasonCodeCaptionLbl: Label 'Reason: Lookup';
        ReasonCodeMandatoryCaptionLbl: Label 'Reason: Mandatory';
        TotalDiscTargetLinesCaptionLbl: Label 'Total Discount Target';
        AmtIncludesTaxDescLbl: Label 'Specifies whether amount entered is VAT/tax inclusive. The parameter is ignored if DiscountType is set to "LineUnitPrice"';
        FixedReasonCodeDescLbl: Label 'Select a reason code, which will be assigned automatically to sale lines';
        LookupReasonCodeDescLbl: Label 'Ask user to select a reason code, when the action is run';
        ReasonCodeMandatoryDescLbl: Label 'Defines whether a reason code must be selected in order for the discount to be successfully applied to sale lines';
        TotalDiscTargetLinesDescLbl: Label 'Select target lines multi-line discounts to be applied to';
        DimensionCodeCaptionLbl: Label 'Dimension Code';
        DimensionCodeDescLbl: Label 'Specifies Dimension Code';
        DimensionValueCaptionLbl: Label 'Dimension Value';
        DimensionValueDescLbl: Label 'Specifies Dimension Value';
        DiscountGroupFilterCaptionLbl: Label 'Discount Group Filter';
        DiscountGroupFilterDescLbl: Label 'Specifies Discount Group Filter';
        AmtIncludesTaxOptionLbl: Label 'Always,IfPricesInclTax,Never', Locked = true;
        TotalDiscTargetLinesOptionLbl: Label 'Auto,Positive,Negative,All,Ask', Locked = true;
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddOptionParameter(
                       'DiscountType',
                       DiscountTypeOptionLbl,
#pragma warning disable AA0139
                       SelectStr(2, DiscountTypeOptionLbl),
#pragma warning restore
                       DiscountTypeCaptionLbl,
                       DiscountTypeCaptionLbl,
                       DiscountTypeOptionLbl);
        WorkflowConfig.AddDecimalParameter('FixedDiscountNumber', 0, FixedDiscountNumberCaptionLbl, FixedDiscountNumberDescLbl);
        WorkflowConfig.AddTextParameter('FixedReasonCode', '', FixedReasonCodeCaptionLbl, FixedReasonCodeDescLbl);
        WorkflowConfig.AddBooleanParameter('LookupReasonCode', false, LookupReasonCodeCaptionLbl, LookupReasonCodeDescLbl);
        WorkflowConfig.AddBooleanParameter('ReasonCodeMandatory', false, ReasonCodeMandatoryCaptionLbl, ReasonCodeMandatoryDescLbl);
        WorkflowConfig.AddTextParameter('DimensionCode', '', DimensionCodeCaptionLbl, DimensionCodeDescLbl);
        WorkflowConfig.AddTextParameter('DimensionValue', '', DimensionValueCaptionLbl, DimensionValueDescLbl);
        WorkflowConfig.AddTextParameter('DiscountGroupFilter', '', DiscountGroupFilterCaptionLbl, DiscountGroupFilterDescLbl);
        WorkflowConfig.AddOptionParameter(
                    'TotalDiscTargetLines',
                    TotalDiscTargetLinesOptionLbl,
#pragma warning disable AA0139
                    SelectStr(2, TotalDiscTargetLinesOptionLbl),
#pragma warning restore
                  TotalDiscTargetLinesCaptionLbl,
                  TotalDiscTargetLinesDescLbl,
#pragma warning disable AA0139
                  TotalDiscTargetLinesCptOptLbl);
#pragma warning restore
        WorkflowConfig.AddOptionParameter(
            'AmtIncludesTax',
            AmtIncludesTaxOptionLbl,
#pragma warning disable AA0139
            SelectStr(1, AmtIncludesTaxOptionLbl),
#pragma warning restore
            AmtIncludesTaxCaptionLbl,
            AmtIncludesTaxDescLbl,
            AmtIncludesTaxOptionLbl);
        WorkflowConfig.SetDataBinding();

        //labels
        WorkflowConfig.AddLabel('DiscountLabel0', TotalAmountLabel);
        WorkflowConfig.AddLabel('DiscountLabel1', TotalDiscountAmountLabel);
        WorkflowConfig.AddLabel('DiscountLabel2', DiscountPercentABSLabel);
        WorkflowConfig.AddLabel('DiscountLabel3', DiscountPercentRELLabel);
        WorkflowConfig.AddLabel('DiscountLabel4', LineAmountLabel);
        WorkflowConfig.AddLabel('DiscountLabel5', LineDiscountAmountLabel);
        WorkflowConfig.AddLabel('DiscountLabel6', LineDiscountPercentABSLabel);
        WorkflowConfig.AddLabel('DiscountLabel7', LineDiscountPercentRELLabel);
        WorkflowConfig.AddLabel('DiscountLabel8', LineUnitPriceLabel);
        WorkflowConfig.AddLabel('DiscountLabel11', DiscountPercentExtraLabel);
        WorkflowConfig.AddLabel('DiscountLabel12', LineDiscountPercentExtraLabel);
        WorkflowConfig.AddLabel('DiscountAuthorisationTitle', DiscountAuthLbl);
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup");
    begin
        case Step of
            'LookupReasonCode':
                FrontEnd.WorkflowResponse(OnActionLookupReasonCode(Context));
            'AddDimensionValue':
                FrontEnd.WorkflowResponse(OnActionAddDimensionValue(Context));
            'ProcessRequest':
                FrontEnd.WorkflowResponse(ProcessRequest(Context, Sale, SaleLine));
            'PreparePostWorkflows':
                FrontEnd.WorkflowResponse(PreparePostWorkflows(Context, Sale, SaleLine));
        end;
    end;

    local procedure PreparePostWorkflows(Context: Codeunit "NPR POS JSON Helper"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line") Response: JsonObject
    var
        POSActionPublishers: Codeunit "NPR POS Action Publishers";
        PostWorkflows: JsonObject;
    begin
        PostWorkflows.ReadFrom('{}');
        POSActionPublishers.OnAddPostWorkflowsToRunOnDiscount(Context, Sale, SaleLine, PostWorkflows);
        Response.Add('postWorkflows', PostWorkflows);
    end;

    local procedure ProcessRequest(Context: Codeunit "NPR POS JSON Helper"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"): JsonObject
    var
        DiscountInput: Decimal;
        DiscountType: Option TotalAmount,TotalDiscountAmount,DiscountPercentABS,DiscountPercentREL,LineAmount,LineDiscountAmount,LineDiscountPercentABS,LineDiscountPercentREL,LineUnitPrice,ClearLineDiscount,ClearTotalDiscount,DiscountPercentExtra,LineDiscountPercentExtra;
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        View: Codeunit "NPR POS View";
        ApprovedBySalesperson: Code[20];
        PresetMultiLineDiscTarget: Integer;
        DiscountReasonCode: Code[10];
        DimensionCode: Text;
        DimensionValue: Text;
        DiscountGroupFilter: Text;
        InputIncludesTax: Option Always,IfPricesInclTax,Never;
        POSSession: Codeunit "NPR POS Session";
        POSActionDiscountB: Codeunit "NPR POS Action - Discount B";
        SecureContextId: Text;
        SecureMethodHelper: Codeunit "NPR POS Secure Method Helper";
    begin
        if Context.GetString('secureMethodContextId', SecureContextId) then
            ApprovedBySalesperson := SecureMethodHelper.GetSalespersonCode(SecureContextId);

        DiscountInput := Context.GetDecimal('discountNumber');
        DiscountType := Context.GetIntegerParameter('DiscountType');
        POSActionDiscountB.CheckNegativeAmount(DiscountType, DiscountInput);

        PresetMultiLineDiscTarget := Context.GetIntegerParameter('TotalDiscTargetLines');
        DiscountGroupFilter := Context.GetStringParameter('DiscountGroupFilter');
        InputIncludesTax := Context.GetIntegerParameter('AmtIncludesTax');
        DimensionCode := Context.GetStringParameter('DimensionCode');

        ReadReasonCode(Context, DiscountReasonCode);
        ReadDimensionValue(Context, DimensionValue);

        Sale.GetCurrentSale(SalePOS);
        SaleLine.GetCurrentSaleLine(SaleLinePOS);
        SaleLine.RefreshxRec();
        POSSession.GetCurrentView(View);
#pragma warning disable AA0139
        POSActionDiscountB.StoreAdditionalParams(ApprovedBySalesperson, DiscountReasonCode, DimensionCode, DimensionValue, DiscountGroupFilter, InputIncludesTax);
#pragma warning restore
        POSActionDiscountB.ProcessRequest(DiscountType, DiscountInput, SalePOS, SaleLinePOS, PresetMultiLineDiscTarget);

        SaleLine.RefreshCurrent();
        SaleLine.GetCurrentSaleLine(SaleLinePOS);
        SaleLine.OnAfterSetQuantity(SaleLinePOS);
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionDiscount.js###
'let main=async({workflow:a,captions:e,parameters:s,popup:o})=>{let n,t,i,r={discountReason:s.FixedReasonCode};""==r.discountReason&&(s.LookupReasonCode||s.ReasonCodeMandatory)&&(r=await a.respond("LookupReasonCode")),i=s.DimensionCode;let u={dimensionValue:s.DimensionValue};switch(""!=i&&""==u.dimensionValue&&(u=await a.respond("AddDimensionValue")),n=s.FixedDiscountNumber,s._parameters.DiscountType){case 0:t=e.DiscountLabel0,0==n&&(n=await o.numpad(t));break;case 1:t=e.DiscountLabel1,0==n&&(n=await o.numpad(t));break;case 2:t=e.DiscountLabel2,0==n&&(n=await o.numpad(t));break;case 3:t=e.DiscountLabel3,0==n&&(n=await o.numpad(t));break;case 4:t=e.DiscountLabel4,0==n&&(n=await o.numpad(t));break;case 5:t=e.DiscountLabel5,0==n&&(n=await o.numpad(t));break;case 6:t=e.DiscountLabel6,0==n&&(n=await o.numpad(t));break;case 7:t=e.DiscountLabel7,0==n&&(n=await o.numpad(t));break;case 8:t=e.DiscountLabel8,0==n&&(n=await o.numpad(t));break;case 9:case 10:break;case 11:t=e.DiscountLabel11,0==n&&(n=await o.numpad(t));break;case 12:t=e.DiscountLabel12,0==n&&(n=await o.numpad(t))}if(null===n)return;await a.respond("ProcessRequest",{discountNumber:n,discountReason:r,dimensionValue:u});let{postWorkflows:c}=await a.respond("PreparePostWorkflows");await processWorkflows(c)};async function processWorkflows(a){if(a)for(const[e,{mainParameters:s,customParameters:o}]of Object.entries(a))await workflow.run(e,{context:{customParameters:o},parameters:s})}'
        )
    end;

    local procedure ReadReasonCode(Context: Codeunit "NPR POS JSON Helper"; var DiscountReasonCode: Code[10])
    var
        JSObj: JsonObject;
        ContextObj: JsonObject;
        JToken: JsonToken;
    begin
        Context.GetJObject(ContextObj);
        ContextObj.Get('discountReason', JToken);
        JSObj := JToken.AsObject();
        if JSObj.Get('discountReason', JToken) then
#pragma warning disable AA0139
            DiscountReasonCode := JToken.AsValue().AsCode();
#pragma warning restore
    end;

    local procedure OnActionLookupReasonCode(Context: Codeunit "NPR POS JSON Helper") Response: JsonObject
    var
        POSActionDiscountB: Codeunit "NPR POS Action - Discount B";
        LookupReasonCode: Boolean;
        ReasonCodeMandatory: Boolean;
        DiscountReasonCode: Code[10];
    begin
        LookupReasonCode := Context.GetBooleanParameter('LookupReasonCode');
        ReasonCodeMandatory := Context.GetBooleanParameter('ReasonCodeMandatory');
        POSActionDiscountB.GetReasonCode(LookupReasonCode, ReasonCodeMandatory, DiscountReasonCode);

        Response.Add('discountReason', DiscountReasonCode);
        exit(Response);
    end;

    local procedure ReadDimensionValue(Context: Codeunit "NPR POS JSON Helper"; var DimensionValueParameter: Text)
    var
        JSObj: JsonObject;
        ContextObj: JsonObject;
        JToken: JsonToken;
    begin
        Context.GetJObject(ContextObj);
        ContextObj.Get('dimensionValue', JToken);
        JSObj := JToken.AsObject();
        if JSObj.Get('dimensionValue', JToken) then
            DimensionValueParameter := JToken.AsValue().AsCode();
    end;

    local procedure OnActionAddDimensionValue(Context: Codeunit "NPR POS JSON Helper") Response: JsonObject
    var
        POSActionDiscountB: Codeunit "NPR POS Action - Discount B";
        DimensionCodeParameter: Text;
        DimensionValueParameter: Text;
    begin
        DimensionCodeParameter := Context.GetStringParameter('DimensionCode');
        DimensionValueParameter := Context.GetStringParameter('DimensionValue');

        if DimensionValueParameter = '' then
            POSActionDiscountB.GetDimensionValue(DimensionCodeParameter, DimensionValueParameter);

        Response.Add('dimensionValue', DimensionValueParameter);
        exit(Response);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnLookupValue', '', false, false)]
    local procedure OnLookupValue(var POSParameterValue: Record "NPR POS Parameter Value"; Handled: Boolean)
    var
        Reason: Record "Reason Code";
    begin
        if POSParameterValue."Action Code" <> 'DISCOUNT' then
            exit;

        case POSParameterValue.Name of
            'FixedReasonCode':
                if Page.RunModal(0, Reason) = Action::LookupOK then
                    POSParameterValue.Value := Reason.Code;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnValidateValue', '', false, false)]
    local procedure OnValidateValue(var POSParameterValue: Record "NPR POS Parameter Value")
    var
        Reason: Record "Reason Code";
    begin
        if POSParameterValue."Action Code" <> 'DISCOUNT' then
            exit;

        case POSParameterValue.Name of
            'FixedReasonCode':
                begin
                    if POSParameterValue.Value = '' then
                        exit;
                    POSParameterValue.Value := CopyStr(UpperCase(POSParameterValue.Value), 1, 10);
                    if not Reason.Get(POSParameterValue.Value) then begin
                        Reason.SetFilter(Code, '%1', POSParameterValue.Value + '*');
                        if Reason.FindFirst() then
                            POSParameterValue.Value := Reason.Code;
                    end;
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnLookupValue', '', false, false)]
    local procedure OnLookupValueDimension(var POSParameterValue: Record "NPR POS Parameter Value"; Handled: Boolean)
    var
        Dimension: Record Dimension;
        DimCode: Code[20];
        DimValueCode: Text;
        POSActionDiscountB: Codeunit "NPR POS Action - Discount B";
    begin
        if POSParameterValue."Action Code" <> 'DISCOUNT' then
            exit;

        case POSParameterValue.Name of
            'DimensionCode':
                if Page.RunModal(0, Dimension) = Action::LookupOK then
                    POSParameterValue.Value := Dimension.Code;

            'DimensionValue':
                begin
                    GetDimensionCodeParameter(POSParameterValue, DimCode);
                    if DimCode = '' then begin
                        POSParameterValue.Value := '';
                        exit;
                    end;
                    POSActionDiscountB.GetDimensionValue(DimCode, DimValueCode);
                    POSParameterValue.Value := CopyStr(UpperCase(DimValueCode), 1, 20);
                end;
        end;
    end;


    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnValidateValue', '', false, false)]
    local procedure OnValidateValueDimension(var POSParameterValue: Record "NPR POS Parameter Value")
    var
        Dimension: Record Dimension;
        DimensionValue: Record "Dimension Value";
        DimCode: Code[20];
        DimMgt: Codeunit DimensionManagement;
    begin
        if POSParameterValue."Action Code" <> 'DISCOUNT' then
            exit;

        case POSParameterValue.Name of
            'DimensionCode':
                begin
                    if POSParameterValue.Value = '' then
                        exit;
                    POSParameterValue.Value := CopyStr(UpperCase(POSParameterValue.Value), 1, 20);
                    if not Dimension.Get(POSParameterValue.Value) then begin
                        Dimension.SetFilter(Code, '%1', POSParameterValue.Value + '*');
                        if Dimension.FindFirst() then
                            POSParameterValue.Value := Dimension.Code;
                    end;
                end;

            'DimensionValue':
                begin
                    if POSParameterValue.Value = '' then
                        exit;

                    GetDimensionCodeParameter(POSParameterValue, DimCode);
                    DimensionValue."Dimension Code" := DimCode;
                    DimensionValue.Code := CopyStr(POSParameterValue.Value, 1, MaxStrLen(DimensionValue.Code));
                    DimensionValue.SetRange(Code, DimensionValue.Code);
                    if not DimensionValue.FindFirst() then begin
                        DimensionValue.SetRange("Dimension Code", Dimension.Code);
                        DimensionValue.SetFilter(Code, '%1', POSParameterValue.Value + '*');
                        DimensionValue.FindFirst();
                    end;
                    if not DimMgt.CheckDimValue(DimensionValue."Dimension Code", DimensionValue.Code) then
                        Error(DimMgt.GetDimErr());
                    POSParameterValue.Value := DimensionValue.Code;
                end;
        end;
    end;

    local procedure GetDimensionCodeParameter(POSParameterValue: Record "NPR POS Parameter Value"; var DimCode: Code[20])
    begin
        POSParameterValue.SetRecFilter();
        POSParameterValue.SetRange(Name, 'DimensionCode');
        if not (POSParameterValue.FindFirst() or (POSParameterValue.Value = '')) then
            exit;
        DimCode := CopyStr(POSParameterValue.Value, 1, MaxStrLen(DimCode));
    end;
}
