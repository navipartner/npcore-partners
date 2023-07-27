codeunit 6151444 "NPR POS Action Scan Voucher2" implements "NPR IPOS Workflow", "NPR POS IPaymentWFHandler"
{
    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config");
    var
        ActionDescription: Label 'This action handles Scan Retail Vouchers (Payment).';
        VoucherTypeCode_CptLbl: Label 'Voucher Type';
        ReferenceNo_CptLbl: Label 'Reference No.';
        ReferenceNo_DescLbl: Label 'Specifies Reference No.';
        VoucherTypeCode_DescLbl: Label 'Specifies Voucher Type';
        EndSale_CptLbl: Label 'End Sale';
        EndSale_DescLbl: Label 'Specifies if Sale should be ended';
        EnableVoucherList_CptLbl: Label 'Open Voucher List';
        EnableVoucherList_DescLbl: Label 'Open Voucher List if Reference No. is blank';
        RetailVoucherLbl: Label 'Retail Voucher Payment';
        ReferenceNoLbl: Label 'Enter Reference No.';
        BlankVoucherTypeErr: Label 'Voucher Type doesn''t exist';
        AskForVoucherType_CptLbl: Label 'Ask for voucher type';
        AskForVoucherType_DescLbl: Label 'The system is going to ask for the voucher type before scanning';
        ProposedAmountDifferenceConfirmationLbl: Label 'The selected amount {0} is higher than the proposed amount {1}.';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddTextParameter('VoucherTypeCode', '', VoucherTypeCode_CptLbl, VoucherTypeCode_DescLbl);
        WorkflowConfig.AddTextParameter('ReferenceNo', '', ReferenceNo_CptLbl, ReferenceNo_DescLbl);
        WorkflowConfig.AddBooleanParameter('EndSale', true, EndSale_CptLbl, EndSale_DescLbl);
        WorkflowConfig.AddBooleanParameter('EnableVoucherList', false, EnableVoucherList_CptLbl, EnableVoucherList_DescLbl);
        WorkflowConfig.AddLabel('VoucherPaymentTitle', RetailVoucherLbl);
        WorkflowConfig.AddLabel('ReferenceNo', ReferenceNoLbl);
        WorkflowConfig.AddLabel('InvalidVoucherType', BlankVoucherTypeErr);
        WorkflowConfig.AddLabel('ProposedAmountDifferenceConfirmation', ProposedAmountDifferenceConfirmationLbl);
        WorkflowConfig.AddBooleanParameter('AskForVoucherType', false, AskForVoucherType_CptLbl, AskForVoucherType_DescLbl);
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    begin
        case Step of
            'setVoucherType':
                FrontEnd.WorkflowResponse(SetVoucherType());
            'calculateVoucherInformation':
                FrontEnd.WorkflowResponse(CalculateVoucherInformation(PaymentLine, Context));
            'prepareRequest':
                FrontEnd.WorkflowResponse(VoucherPayment(Context, Sale, PaymentLine, SaleLine));
            'doLegacyWorkflow':
                FrontEnd.WorkflowResponse(DoLegacyAction(FrontEnd, Context));
            'endSale':
                FrontEnd.WorkflowResponse(EndSale(Context, Sale, PaymentLine, SaleLine, Setup));
        end;
    end;

    internal procedure SetVoucherType(): Text
    var
        VoucherType: Code[20];
    begin
        VoucherType := GetVoucherType();
        exit(VoucherType);
    end;

    local procedure CalculateVoucherInformation(PaymentLine: Codeunit "NPR POS Payment Line";
                                                Context: Codeunit "NPR POS JSON Helper") Response: JsonObject;
    var
        NPRNpRvVoucherModule: Record "NPR NpRv Voucher Module";
        NPRNpRvVoucherType: Record "NPR NpRv Voucher Type";
        NPRPOSPaymentMethod: Record "NPR POS Payment Method";
        NPRNpRvVoucher: Record "NPR NpRv Voucher";
        NPRNpRvVoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
        NPRPOSActionScanVoucher2B: Codeunit "NPR POS Action Scan Voucher2B";
        ReferenceNo: Text;
        VoucherType: Text;
        SuggestedAmount: Decimal;
    begin
        if Context.GetString('VoucherRefNo', ReferenceNo) then;
        if Context.GetString('voucherType', VoucherType) then;

        if VoucherType = '' then
            VoucherType := NPRNpRvVoucherMgt.GetVoucherTypeFromReferenceNumber(ReferenceNo);

        if VoucherType = '' then begin
            Response.Add('voucherType', '');
            Response.Add('askForAmount', false);
            Response.Add('suggestedAmount', 0);
            Response.Add('paymentDescription', '');
            exit;
        end;

        if not NPRNpRvVoucherType.Get(VoucherType) then
            Clear(NPRNpRvVoucherType);

        if not NPRNpRvVoucherModule.Get(NPRNpRvVoucherModule.Type::"Apply Payment", NPRNpRvVoucherType."Apply Payment Module") then
            Clear(NPRNpRvVoucherModule);

        NPRNpRvVoucher.Reset();
        NPRNpRvVoucher.SetCurrentKey("Reference No.");
        NPRNpRvVoucher.SetRange("Reference No.", ReferenceNo);
        if not NPRNpRvVoucher.FindFirst() then
            Clear(NPRNpRvVoucher);

        NPRNpRvVoucher.CalcFields(Amount);

        NPRPOSActionScanVoucher2B.CalculateRemainingAmount(PaymentLine,
                                                           NPRNpRvVoucherType."Payment Type",
                                                           NPRPOSPaymentMethod,
                                                           SuggestedAmount);
        if SuggestedAmount > NPRNpRvVoucher.Amount then
            SuggestedAmount := NPRNpRvVoucher.Amount;

        Response.Add('voucherType', VoucherType);
        Response.Add('askForAmount', NPRNpRvVoucherModule."Ask For Amount");
        Response.Add('suggestedAmount', SuggestedAmount);
        Response.Add('paymentDescription', NPRPOSPaymentMethod.Description);
    end;

    local procedure GetVoucherType(): Code[20]
    var
        NpRvVoucherType: Record "NPR NpRv Voucher Type";
        VoucherType: Code[20];
    begin
        if Page.RunModal(0, NpRvVoucherType) <> Action::LookupOK then
            exit;
        VoucherType := NpRvVoucherType.Code;

        exit(VoucherType);
    end;

    local procedure VoucherPayment(Context: Codeunit "NPR POS JSON Helper"; Sale: Codeunit "NPR POS Sale"; PaymentLine: Codeunit "NPR POS Payment Line"; SaleLine: Codeunit "NPR POS Sale Line") Response: JsonObject
    var
        ReferenceNo: Text;
        POSActionScanActionB: Codeunit "NPR POS Action Scan Voucher2B";
        ActionContext: JsonObject;
        VoucherTypeCode: Code[20];
        SelectedAmount: Decimal;
        EndSalePar: Boolean;
    begin
        HandleParameters(Context, VoucherTypeCode, EndSalePar, ReferenceNo, SelectedAmount);
        POSActionScanActionB.ProcessPayment(VoucherTypeCode, ReferenceNo, SelectedAmount, Sale, PaymentLine, SaleLine, EndSalePar, ActionContext);

        Response.Add('tryEndSale', HandleWorkflowResponse(Response, ActionContext));
        exit(Response);

    end;

    internal procedure HandleParameters(Context: Codeunit "NPR POS JSON Helper"; var VoucherTypeCode: Code[20]; var ParamEndSale: Boolean; var ReferenceNo: Text; var SelectedAmount: Decimal)
    var
        VoucherListEnabled: Boolean;
        POSActionScanActionB: Codeunit "NPR POS Action Scan Voucher2B";
    begin
        GetParameterValues(Context, VoucherTypeCode, ParamEndSale, ReferenceNo, VoucherListEnabled, SelectedAmount);
        if ReferenceNo = '' then
            POSActionScanActionB.CheckReferenceNo(ReferenceNo, VoucherListEnabled, VoucherTypeCode);
    end;

    internal procedure GetParameterValues(Context: Codeunit "NPR POS JSON Helper"; var VoucherTypeCode: Code[20]; var ParamEndSale: Boolean; var ReferenceNo: Text; var VoucherListEnabled: Boolean; var SelectedAmount: Decimal)
    var
        VoucherType: Text;
    begin
        ReferenceNo := Context.GetString('VoucherRefNo');
        ParamEndSale := Context.GetBooleanParameter('EndSale');
        VoucherListEnabled := Context.GetBooleanParameter('EnableVoucherList');
        VoucherType := Context.GetString('voucherType');
        if not Context.GetDecimal('selectedAmount', SelectedAmount) then;
        Evaluate(VoucherTypeCode, VoucherType);
    end;

    local procedure DoLegacyAction(FrontEnd: Codeunit "NPR POS Front End Management"; Context: Codeunit "NPR POS JSON Helper"): JsonObject
    var
        POSAction: Record "NPR POS Action";
        POSSession: Codeunit "NPR POS Session";
        VoucherTypeCode: Code[20];
        EndSalePar: Boolean;
        Handled: Boolean;
        WorkflowName: Text;
        ActionCode: Code[20];
    begin
        WorkflowName := Context.GetString('workflowName');
        if WorkflowName = '' then
            exit;
        Evaluate(ActionCode, WorkflowName);
        GetParameterValues(Context, VoucherTypeCode, EndSalePar);

        if not POSSession.RetrieveSessionAction(ActionCode, POSAction) then
            POSAction.Get(ActionCode);

        OnRunLegacyWorkflow(FrontEnd, POSAction, VoucherTypeCode, EndSalePar, Handled);
    end;

    internal procedure GetParameterValues(Context: Codeunit "NPR POS JSON Helper"; var VoucherTypeCode: Code[20]; var ParamEndSale: Boolean)
    var
        VoucherType: Text;
    begin
        Context.SetScope('voucherType');
        VoucherType := Context.GetString('voucherType');
        Evaluate(VoucherTypeCode, VoucherType);
        ParamEndSale := Context.GetBooleanParameter('EndSale');
    end;

    local procedure EndSale(Context: Codeunit "NPR POS JSON Helper"; Sale: Codeunit "NPR POS Sale"; PaymentLine: Codeunit "NPR POS Payment Line"; SaleLine: Codeunit "NPR POS Sale Line"; Setup: Codeunit "NPR POS Setup") Response: JsonObject
    var
        POSActionScanActionB: Codeunit "NPR POS Action Scan Voucher2B";
        VoucherType: Text;
        VoucherTypeCode: Code[20];
    begin
        VoucherType := Context.GetString('voucherType');
        Evaluate(VoucherTypeCode, VoucherType);

        POSActionScanActionB.EndSale(VoucherTypeCode, Sale, PaymentLine, SaleLine, Setup);

        Response.ReadFrom('{}');
        exit(Response);

    end;

    internal procedure HandleWorkflowResponse(var Response: JsonObject; ActionContextIn: JsonObject): Boolean
    var
        Jtoken: JsonToken;
        Jobj: JsonObject;
    begin
        Response.Add('endSaleWithoutPosting', false);
        if ActionContextIn.Get('endSaleWithoutPosting', Jtoken) then
            response.Replace('endSaleWithoutPosting', Jtoken.AsValue().AsBoolean());

        if not ActionContextIn.Get('name', Jtoken) then
            exit(true);

        if Jtoken.AsValue().AsText() = '' then
            exit(true);

        Response.Add('workflowName', Jtoken.AsValue().AsText());

        ActionContextIn.Get('version', Jtoken);
        Response.Add('workflowVersion', Jtoken.AsValue().AsText());

        ActionContextIn.Get('parameters', Jtoken);
        Jobj := Jtoken.AsObject();
        Response.Add('parameters', Jobj);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnLookupValue', '', true, true)]
    local procedure OnLookupVoucherTypeCode(var POSParameterValue: Record "NPR POS Parameter Value"; Handled: Boolean)
    var
        NpRvVoucherType: Record "NPR NpRv Voucher Type";
    begin
        if POSParameterValue."Action Code" <> 'SCAN_VOUCHER_2' then
            exit;
        if POSParameterValue.Name <> 'VoucherTypeCode' then
            exit;
        if POSParameterValue."Data Type" <> POSParameterValue."Data Type"::Text then
            exit;

        Handled := true;

        if Page.RunModal(0, NpRvVoucherType) = Action::LookupOK then
            POSParameterValue.Value := NpRvVoucherType.Code;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnValidateValue', '', true, true)]
    local procedure OnValidateVoucherTypeCode(var POSParameterValue: Record "NPR POS Parameter Value")
    var
        NpRvVoucherType: Record "NPR NpRv Voucher Type";
        TypeErr: Label 'Voucher Type can be only 20 characters.';
    begin
        if POSParameterValue."Action Code" <> 'SCAN_VOUCHER_2' then
            exit;
        if POSParameterValue.Name <> 'VoucherTypeCode' then
            exit;
        if POSParameterValue."Data Type" <> POSParameterValue."Data Type"::Text then
            exit;

        if POSParameterValue.Value = '' then
            exit;
        if StrLen(POSParameterValue.Value) > 20 then
            Error(TypeErr);

        POSParameterValue.Value := UpperCase(POSParameterValue.Value);
        if not NpRvVoucherType.Get(POSParameterValue.Value) then begin
            NpRvVoucherType.SetFilter(Code, '%1', POSParameterValue.Value + '*');
            if NpRvVoucherType.FindFirst() then
                POSParameterValue.Value := NpRvVoucherType.Code;
        end;

        NpRvVoucherType.Get(POSParameterValue.Value);
    end;

    procedure GetPaymentHandler(): Code[20];
    begin
        exit(Format(Enum::"NPR POS Workflow"::VOUCHER_PAYMENT));
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionScanVoucher2.js###
'let main=async({workflow:e,parameters:r,popup:i,context:s,captions:o})=>{debugger;let t,n={tryEndSale:!1,legacy:!1};if(r.VoucherTypeCode)e.context.voucherType=r.VoucherTypeCode;else if(r.AskForVoucherType&&(e.context.voucherType=await e.respond("setVoucherType"),!e.context.voucherType))return n;if(r.ReferenceNo?t=r.ReferenceNo:t=await i.input({title:o.VoucherPaymentTitle,caption:o.ReferenceNo}),!t||(setVoucherTypeFromReferenceNoResponse=await e.respond("calculateVoucherInformation",{VoucherRefNo:t}),e.context.voucherType=setVoucherTypeFromReferenceNoResponse.voucherType,!e.context.voucherType))return n;var f=setVoucherTypeFromReferenceNoResponse.askForAmount,u=setVoucherTypeFromReferenceNoResponse.suggestedAmount,h=setVoucherTypeFromReferenceNoResponse.paymentDescription,m=setVoucherTypeFromReferenceNoResponse.amountPrompt;let c=u;if(f)for(var p=!0;p;){if(c=u,u>0&&(c=await i.numpad({title:h,caption:m,value:u}),c===null))return n;p=c>u,p&&await i.message(strSubstNo(o.ProposedAmountDifferenceConfirmation,c,u))}let a=await e.respond("prepareRequest",{VoucherRefNo:t,selectedAmount:c});return a.tryEndSale?(r.EndSale&&!a.endSaleWithoutPosting&&await e.respond("endSale"),n):(a.workflowVersion==1?await e.respond("doLegacyWorkflow",{workflowName:a.workflowName}):await e.run(a.workflowName,{parameters:a.parameters}),n)};function strSubstNo(e,...r){if(!e.match(/^(?:(?:(?:[^{}]|(?:\{\{)|(?:\}\}))+)|(?:\{[0-9]+\}))+$/))throw new Error("invalid format string.");return e.replace(/((?:[^{}]|(?:\{\{)|(?:\}\}))+)|(?:\{([0-9]+)\})/g,(i,s,o)=>{if(s)return s.replace(/(?:{{)|(?:}})/g,t=>t[0]);if(o>=r.length)throw new Error("argument index is out of range in format");return r[o]})}'
        );
    end;

    [IntegrationEvent(false, false)]
    local procedure OnRunLegacyWorkflow(FrontEnd: Codeunit "NPR POS Front End Management"; var POSAction: Record "NPR POS Action"; VoucherType: Code[20]; EndSale: Boolean; var Handled: Boolean)
    begin
    end;


}
