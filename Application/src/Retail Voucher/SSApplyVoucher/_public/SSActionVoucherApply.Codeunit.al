codeunit 6150625 "NPR SS Action: Voucher Apply" implements "NPR IPOS Workflow"
{
    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config");
    var
        ActionDescription: Label 'This action handles Scan Retail Vouchers (Payment).';
        VoucherTypeCode_CptLbl: Label 'Voucher Type';
        EndSale_CptLbl: Label 'End Sale';
        ApplyVoucherCaptionLbl: Label 'Apply Retail Voucher';
        EnterRefNoCaptionLbl: Label 'Enter Vourcher Reference No.';
        EndSale_DescLbl: Label 'Specifies whether the system should attempt to end the sale immediately after a voucher has been applied';
        VoucherTypeCode_DescLbl: Label 'Defines retail voucher type';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddTextParameter('VoucherTypeCode', '', VoucherTypeCode_CptLbl, VoucherTypeCode_DescLbl);
        WorkflowConfig.AddBooleanParameter('EndSale', true, EndSale_CptLbl, EndSale_DescLbl);
        WorkflowConfig.AddLabel('ApplyVoucherCaption', ApplyVoucherCaptionLbl);
        WorkflowConfig.AddLabel('EnterRefNoCaption', EnterRefNoCaptionLbl);
        WorkflowConfig.SetWorkflowTypeUnattended();
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    begin
        case Step of
            'prepareRequest':
                FrontEnd.WorkflowResponse(ApplyVoucher(Context, Sale, PaymentLine, SaleLine));
            'doLegacyWorkflow':
                FrontEnd.WorkflowResponse(DoLegacyAction(FrontEnd, Context));
            'endSale':
                FrontEnd.WorkflowResponse(EndSale(Context, Sale, PaymentLine, SaleLine, Setup));
        end;
    end;

    local procedure ApplyVoucher(Context: Codeunit "NPR POS JSON Helper"; Sale: Codeunit "NPR POS Sale"; PaymentLine: Codeunit "NPR POS Payment Line"; SaleLine: Codeunit "NPR POS Sale Line") Response: JsonObject
    var
        SSActionVoucherApplyB: Codeunit "NPR POSAct. SS Voucher Apply B";
        ReferenceNo: Text;
        VoucherType: Text;
        VoucherTypeCode: Code[20];
        EndSalePar: Boolean;
        ActionContext: JsonObject;
    begin
        ReferenceNo := Context.GetString('VoucherRefNo');
        VoucherType := Context.GetStringParameter('VoucherTypeCode');
        EndSalePar := Context.GetBooleanParameter('EndSale');
        Evaluate(VoucherTypeCode, VoucherType);

        SSActionVoucherApplyB.ProcessPayment(VoucherTypeCode, ReferenceNo, Sale, PaymentLine, SaleLine, EndSalePar, ActionContext);

        Response.Add('tryEndSale', HandleWorkflowResponse(Response, ActionContext));
        exit(Response);
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
        VoucherType := Context.GetString('VoucherTypeCode');
        Evaluate(VoucherTypeCode, VoucherType);
        ParamEndSale := Context.GetBooleanParameter('EndSale');
    end;

    local procedure EndSale(Context: Codeunit "NPR POS JSON Helper"; Sale: Codeunit "NPR POS Sale"; PaymentLine: Codeunit "NPR POS Payment Line"; SaleLine: Codeunit "NPR POS Sale Line"; Setup: Codeunit "NPR POS Setup") Response: JsonObject
    var
        SSActionVoucherApplyB: Codeunit "NPR POSAct. SS Voucher Apply B";
        VoucherType: Text;
        VoucherTypeCode: Code[20];
    begin
        VoucherType := Context.GetStringParameter('VoucherTypeCode');
        Evaluate(VoucherTypeCode, VoucherType);

        SSActionVoucherApplyB.EndSale(VoucherTypeCode, Sale, PaymentLine, SaleLine, Setup);

        Response.ReadFrom('{}');
        exit(Response);

    end;

    internal procedure HandleWorkflowResponse(var Response: JsonObject; ActionContextIn: JsonObject): Boolean
    var
        Jtoken: JsonToken;
        Jobj: JsonObject;
    begin
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

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnLookupValue', '', true, false)]
    local procedure OnLookupVoucherTypeCode(var POSParameterValue: Record "NPR POS Parameter Value"; Handled: Boolean)
    var
        NpRvVoucherType: Record "NPR NpRv Voucher Type";
    begin
        if POSParameterValue."Action Code" <> 'SS-VOUCHER-APPLY-2' then
            exit;
        if POSParameterValue.Name <> 'VoucherTypeCode' then
            exit;

        Handled := true;

        if Page.RunModal(0, NpRvVoucherType) = Action::LookupOK then
            POSParameterValue.Value := NpRvVoucherType.Code;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnValidateValue', '', true, false)]
    local procedure OnValidateVoucherTypeCode(var POSParameterValue: Record "NPR POS Parameter Value")
    var
        NpRvVoucherType: Record "NPR NpRv Voucher Type";
        TypeErr: Label 'Voucher Type can be only 20 characters.';
    begin
        if POSParameterValue."Action Code" <> 'SS-VOUCHER-APPLY-2' then
            exit;
        if POSParameterValue.Name <> 'VoucherTypeCode' then
            exit;
        if POSParameterValue.Value = '' then
            exit;
        if StrLen(POSParameterValue.Value) > 20 then
            Error(TypeErr);

        POSParameterValue.Value := UpperCase(POSParameterValue.Value);
        if not NpRvVoucherType.Get(POSParameterValue.Value) then begin
            NpRvVoucherType.SetFilter(Code, '%1*', POSParameterValue.Value);
            if NpRvVoucherType.FindFirst() then
                POSParameterValue.Value := NpRvVoucherType.Code;
        end;

        NpRvVoucherType.Get(POSParameterValue.Value);
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionSSVoucherApply.js###
'let main=async({workflow:a,popup:n,parameters:i,captions:t})=>{let r=await n.stringpad({title:t.ApplyVoucherCaption,caption:t.EnterRefNoCaption});if(r===null||r==="")return;let e=await a.respond("prepareRequest",{VoucherRefNo:r});if(e.tryEndSale){i.EndSale&&await a.respond("endSale");return}e.workflowVersion==1?await a.respond("doLegacyWorkflow",{workflowName:e.workflowName}):await a.run(e.workflowName,{parameters:e.parameters})};'
        );
    end;

    [IntegrationEvent(false, false)]
    local procedure OnRunLegacyWorkflow(FrontEnd: Codeunit "NPR POS Front End Management"; var POSAction: Record "NPR POS Action"; VoucherType: Code[20]; EndSale: Boolean; var Handled: Boolean)
    begin
    end;

}
