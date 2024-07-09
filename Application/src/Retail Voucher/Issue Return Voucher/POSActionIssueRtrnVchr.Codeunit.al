codeunit 6150623 "NPR POSAction: Issue Rtrn Vchr" implements "NPR IPOS Workflow"
{
    Access = Internal;
    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config");
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        ParameterContactInfo_CaptLbl: Label 'Contact Info';
        ParameterScanReference_CaptLbl: Label 'Scan Reference Nos';
        ParameterVoucherTypeCode_CaptLbl: Label 'Voucher Type Code';
        ActionDescription: Label 'This action Issues Return Retail Vouchers.';
        Text001: Label 'Select Voucher Type';
        Text002: Label 'Issue Return Retail Voucher';
        Text003: Label 'Enter Amount';
        EndSaleDescLbl: Label 'End Sale';
        EndSaleNameLbl: Label 'End Sale';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddTextParameter('VoucherTypeCode', '', ParameterVoucherTypeCode_CaptLbl, ParameterVoucherTypeCode_CaptLbl);
        WorkflowConfig.AddBooleanParameter('ContactInfo', false, ParameterContactInfo_CaptLbl, ParameterContactInfo_CaptLbl);
        WorkflowConfig.AddBooleanParameter('ScanReferenceNos', false, ParameterScanReference_CaptLbl, ParameterScanReference_CaptLbl);
        WorkflowConfig.AddBooleanParameter('EndSale', true, EndSaleNameLbl, EndSaleDescLbl);
        WorkflowConfig.AddLabel('IssueVoucherPrompt', Text001);
        WorkflowConfig.AddLabel('IssueReturnVoucherTitle', Text002);
        WorkflowConfig.AddLabel('Amount', Text003);
        WorkflowConfig.AddLabel('SendViaEmail', NpRvVoucher.FieldCaption("Send via E-mail"));
        WorkflowConfig.AddLabel('Email', NpRvVoucher.FieldCaption("E-mail"));
        WorkflowConfig.AddLabel('SendViaSMS', NpRvVoucher.FieldCaption("Send via SMS"));
        WorkflowConfig.AddLabel('Phone', NpRvVoucher.FieldCaption("Phone No."));
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionIssueRetVoucher.js###
'let main=async({workflow:e,parameters:a,popup:i,captions:n})=>{debugger;let u;if(await e.respond("validateRequest"),a.VoucherTypeCode?e.context.voucherType=a.VoucherTypeCode:e.context.voucherType=await e.respond("setVoucherType"),e.context.voucherType==null||e.context.voucherType=="")return;if(e.context.IsUnattendedPOS)u=e.context.voucher_amount;else if(u=await i.numpad({title:n.IssueReturnVoucherTitle,caption:n.Amount,value:e.context.voucher_amount,notBlank:!0}),u===0||u===null)return;let c=await e.respond("validateAmount",{amountInput:u});if(c==0)return;let t=await e.respond("select_send_method");t.SendMethodEmail&&(t.SendToEmail=await i.input({title:n.SendViaEmail,caption:n.Email,value:t.SendToEmail,notBlank:!0})),t.SendMethodSMS&&(t.SendToPhoneNo=await i.input({title:n.SendViaSMS,caption:n.Phone,value:t.SendToPhoneNo,notBlank:!0})),e.context=Object.assign(e.context,t);const{paymentNo:d}=await e.respond("issueReturnVoucher",{ReturnVoucherAmount:c});a.ContactInfo&&await e.respond("contactInfo"),a.ScanReferenceNos&&await e.respond("scanReference"),a.EndSale&&await e.run("END_SALE",{parameters:{calledFromWorkflow:"ISSUE_RETURN_VCHR_2",paymentNo:d}})};'
        );
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup");
    begin
        case Step of
            'validateRequest':
                ValidateRequest(Context, PaymentLine, Setup);
            'setVoucherType':
                FrontEnd.WorkflowResponse(VoucherTypeInput());
            'validateAmount':
                FrontEnd.WorkflowResponse(ValidateAmount(Context));
            'select_send_method':
                FrontEnd.WorkflowResponse(SelectSendMethod(Context, Sale));
            'issueReturnVoucher':
                FrontEnd.WorkflowResponse(IssueReturnVoucher(Context));
            'contactInfo':
                ShowContactInfo(PaymentLine);
            'scanReference':
                ScanReference(PaymentLine);
            'endSale':
                FrontEnd.WorkflowResponse(TryEndSale(Context, Sale, PaymentLine, SaleLine, Setup));
        end;

    end;

    local procedure ShowContactInfo(POSPaymentLine: Codeunit "NPR POS Payment Line")
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        POSActIssueReturnVchrB: Codeunit "NPR POS Act.Issue Return VchrB";
    begin
        POSPaymentLine.GetCurrentPaymentLine(SaleLinePOS);
        POSActIssueReturnVchrB.ContactInfo(SaleLinePOS);
    end;

    local procedure ScanReference(POSPaymentLine: Codeunit "NPR POS Payment Line")
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        POSActIssueReturnVchrB: Codeunit "NPR POS Act.Issue Return VchrB";
    begin
        POSPaymentLine.GetCurrentPaymentLine(SaleLinePOS);
        POSActIssueReturnVchrB.ScanReferenceNos(SaleLinePOS, SaleLinePOS.Quantity);
    end;

    local procedure IssueReturnVoucher(Context: Codeunit "NPR POS JSON Helper") Response: JsonObject
    var
        VoucherType: Record "NPR NpRv Voucher Type";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        NpRvVoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
        Amount: Decimal;
        Email: Text[80];
        PhoneNo: Text[30];
        SendMethodPrint: Boolean;
        SendMethodEmail: Boolean;
        SendMethodSMS: Boolean;
        POSSession: Codeunit "NPR POS Session";
        VoucherTypeCode: Code[20];
        EndSalePar: Boolean;
    begin
        GetParameterValues(Context, VoucherTypeCode, EndSalePar);
        VoucherType.Get(VoucherTypeCode);
        Amount := Context.GetDecimal('ReturnVoucherAmount');

        SendMethodPrint := Context.GetBoolean('SendMethodPrint');
        SendMethodEmail := Context.GetBoolean('SendMethodEmail');
        SendMethodSMS := Context.GetBoolean('SendMethodSMS');
        if SendMethodEmail then
            Email := CopyStr(Context.GetString('SendToEmail'), 1, MaxStrLen(NpRvSalesLine."E-mail"));
        if SendMethodSMS then
            PhoneNo := CopyStr(Context.GetString('SendToPhoneNo'), 1, MaxStrLen(NpRvSalesLine."Phone No."));

        NpRvVoucherMgt.IssueReturnVoucher(POSSession, VoucherTypeCode, Amount, Email, PhoneNo, SendMethodPrint, SendMethodEmail, SendMethodSMS);

        Response.Add('paymentNo', VoucherType."Payment Type");
        exit(Response);
    end;

    local procedure ValidateRequest(Context: Codeunit "NPR POS JSON Helper"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    var
        POSUnit: Record "NPR POS Unit";
        VoucherType: Text;
        VoucherTypeCode: Code[20];
        ReturnAmountToCapture: Decimal;
        POSActIssueReturnVchrB: Codeunit "NPR POS Act.Issue Return VchrB";
    begin
        Context.SetScopeParameters();
        if Context.GetString('VoucherTypeCode', VoucherType) then begin
            Evaluate(VoucherTypeCode, VoucherType);

            POSActIssueReturnVchrB.ValidateAmount(VoucherTypeCode, ReturnAmountToCapture, PaymentLine);

            Context.SetContext('voucher_amount', -ReturnAmountToCapture);
        end;
        Setup.GetPOSUnit(POSUnit);
        Context.SetContext('IsUnattendedPOS', POSUnit."POS Type" = POSUnit."POS Type"::UNATTENDED);
    end;

    local procedure ValidateAmount(Context: Codeunit "NPR POS JSON Helper"): Decimal
    var
        EndSalePar: Boolean;
        VoucherTypeCode: Code[20];
        POSActIssueReturnVchrB: Codeunit "NPR POS Act.Issue Return VchrB";
        CapturedAmount: Decimal;
        IsUnattendedPOS: Boolean;
    begin
        GetParameterValues(Context, VoucherTypeCode, EndSalePar);

        CapturedAmount := Context.GetDecimal('amountInput');
        IsUnattendedPOS := Context.GetBoolean('IsUnattendedPOS');
        if not IsUnattendedPOS then
            POSActIssueReturnVchrB.ValidateCapturedAmount(VoucherTypeCode, CapturedAmount);
        exit(CapturedAmount);
    end;

    internal procedure GetParameterValues(Context: Codeunit "NPR POS JSON Helper"; var VoucherTypeCode: Code[20]; var EndSale: Boolean)
    var
        VoucherType: Text;
    begin
        VoucherType := Context.GetStringParameter('VoucherTypeCode');
        EndSale := Context.GetBooleanParameter('EndSale');
        Evaluate(VoucherTypeCode, VoucherType);
    end;

    local procedure SelectSendMethod(Context: Codeunit "NPR POS JSON Helper"; POSSale: Codeunit "NPR POS Sale") Response: JsonObject
    var
        VoucherType: Record "NPR NpRv Voucher Type";
        NpRvModuleSendDefault: Codeunit "NPR NpRv Module Send: Def.";
        POSActIssueReturnVchrB: Codeunit "NPR POS Act.Issue Return VchrB";
        Selection: Integer;
        Email: Text;
        PhoneNo: Text;
        VoucherTypeCode: Code[20];
        EndSalePar: Boolean;
    begin
        GetParameterValues(Context, VoucherTypeCode, EndSalePar);
        VoucherType.Get(VoucherTypeCode);

        POSActIssueReturnVchrB.FindSendMethod(POSSale, Email, PhoneNo);
        Response.Add('SendToEmail', Email);
        Response.Add('SendToPhoneNo', PhoneNo);

        Selection := NpRvModuleSendDefault.SelectSendMethod(VoucherType);
        Response.Add('SendMethodPrint', Selection = VoucherType."Send Method via POS"::Print);
        Response.Add('SendMethodEmail', Selection = VoucherType."Send Method via POS"::"E-mail");
        Response.Add('SendMethodSMS', Selection = VoucherType."Send Method via POS"::SMS);
        exit(Response);
    end;

    [Obsolete('Use the new END_SALE workflow instead', '2023-11-28')]
    local procedure TryEndSale(Context: Codeunit "NPR POS JSON Helper"; Sale: Codeunit "NPR POS Sale"; PaymentLine: Codeunit "NPR POS Payment Line"; SaleLine: Codeunit "NPR POS Sale Line"; Setup: Codeunit "NPR POS Setup") Response: JsonObject
    var
        POSActIssueReturnVchrB: Codeunit "NPR POS Act.Issue Return VchrB";
        VoucherTypeCode: Code[20];
        EndSalePar: Boolean;
    begin
        GetParameterValues(Context, VoucherTypeCode, EndSalePar);

        POSActIssueReturnVchrB.EndSale(VoucherTypeCode, Sale, PaymentLine, SaleLine, Setup);

        Response.ReadFrom('{}');
        exit(Response);

    end;

    local procedure VoucherTypeInput() Response: JsonObject;
    var
        VoucherTypeCode: Text;
        IssueVoucherMgtB: Codeunit "NPR NpRv Issue POSAction Mgt-B";
    begin
        if not IssueVoucherMgtB.SelectVoucherType(VoucherTypeCode) then
            Error('');
        Response.Add('VoucherTypeCode', VoucherTypeCode);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnLookupValue', '', true, true)]
    local procedure OnLookupVoucherTypeCode(var POSParameterValue: Record "NPR POS Parameter Value"; Handled: Boolean)
    var
        NpRvVoucherType: Record "NPR NpRv Voucher Type";
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
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
        if POSParameterValue."Action Code" <> ActionCode() then
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

    procedure ActionCode(): Code[20]
    begin
        exit('ISSUE_RETURN_VCHR_2');
    end;
}
