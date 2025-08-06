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
        CustomReferenceNoCaptionLbl: Label 'Reference No.';
        CustomReferenceNoTitleLbl: Label 'Please scan a reference no.';
        ScanReferenceNoErrorLbl: Label 'Please scan a reference no. Do you want to continue?';
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
        WorkflowConfig.AddLabel('CustomReferenceNoCaption', CustomReferenceNoCaptionLbl);
        WorkflowConfig.AddLabel('CustomReferenceNoTitle', CustomReferenceNoTitleLbl);
        WorkflowConfig.AddLabel('ScanReferenceNoError', ScanReferenceNoErrorLbl);
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionIssueRtrnVchr.js###
'const main=async({context:n,workflow:t,parameters:i,popup:o,captions:e})=>{let a;await t.respond("validateRequest");const c={returnVoucherAmt:0};if(i.VoucherTypeCode?n.voucherType=i.VoucherTypeCode:n.voucherType=await t.respond("setVoucherType"),n.voucherType==null||n.voucherType=="")return c;if(!n.IsUnattendedPOS&&!n.issueReturnVoucherSilent){if(a=await o.numpad({title:e.IssueReturnVoucherTitle,caption:e.Amount,value:n.voucher_amount}),a===0||a===null)return c}else a=n.voucher_amount;const s=await t.respond("validateAmount",{amountInput:a});if(s==0)return c;const l=await t.respond("select_send_method");l.SendMethodEmail&&(l.SendToEmail=await o.input({title:e.SendViaEmail,caption:e.Email})),l.SendMethodSMS&&(l.SendToPhoneNo=await o.input({title:e.SendViaSMS,caption:e.Phone})),n=Object.assign(n,l);debugger;let r;if(i.ScanReferenceNos){let d=!0;for(;d;){let u=!0;for(;u;){if(r=await o.input({title:e.CustomReferenceNoTitle,caption:e.CustomReferenceNoCaption}),r===null)return{};if(u=r==="",r!==null&&u&&(u=await o.confirm({title:e.CustomReferenceNoTitle,caption:e.ScanReferenceNoError}),!u))return{};const{ReferenceNoAlreadyUsed:R,ReferenceNoAlreadyUsedMessage:h}=await t.respond("check_reference_no_already_used",{CustomReferenceNo:r});if(R&&(r="",u=await o.confirm({title:e.CustomReferenceNoCaption,caption:h}),!u))return{}}d=r===null}}const{paymentNo:f,collectReturnInformation:m}=await t.respond("issueReturnVoucher",{ReturnVoucherAmount:s,CustomReferenceNo:r});return c.returnVoucherAmt=s,i.ContactInfo&&await t.respond("contactInfo"),i.EndSale&&m&&!(await t.run("DATA_COLLECTION",{parameters:{requestCollectInformation:"ReturnInformation"}})).success?{}:(i.EndSale&&await t.run("END_SALE",{parameters:{calledFromWorkflow:"ISSUE_RETURN_VCHR_2",paymentNo:f}}),c)};'
        );
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup");
    var
        NpRvIssuePOSActionMgt: Codeunit "NPR NpRv Issue POSAction Mgt.";
    begin
        case Step of
            'validateRequest':
                ValidateRequest(Context, PaymentLine, Setup, Sale);
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
            'check_reference_no_already_used':
                FrontEnd.WorkflowResponse(CheckReferenceNoAlreadyUsed(Context));
            'issue_voucher':
                NpRvIssuePOSActionMgt.IssueVoucher(Context, Sale, SaleLine);
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

    local procedure IssueReturnVoucher(Context: Codeunit "NPR POS JSON Helper") Response: JsonObject
    var
        VoucherType: Record "NPR NpRv Voucher Type";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        SalePOS: Record "NPR POS Sale";
        NpRvVoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
        POSActionDataCollectionB: Codeunit "NPR POS Action DataCollectionB";
        Sale: Codeunit "NPR POS Sale";
        Amount: Decimal;
        Email: Text[80];
        PhoneNo: Text[30];
        CustomReferenceNo: Text[50];
        VoucherSalesLineParentIdText: Text;
        VoucherSalesLineParentId: Guid;
        SendMethodPrint: Boolean;
        SendMethodEmail: Boolean;
        SendMethodSMS: Boolean;
        POSSession: Codeunit "NPR POS Session";
        VoucherTypeCode: Code[20];
        EndSalePar: Boolean;
        CollectReturnInformation: Boolean;
    begin
        GetParameterValues(Context, VoucherTypeCode, EndSalePar);
        VoucherType.Get(VoucherTypeCode);
        Amount := Context.GetDecimal('ReturnVoucherAmount');
        CustomReferenceNo := CopyStr(Context.GetString('CustomReferenceNo'), 1, MaxStrLen(CustomReferenceNo));

        SendMethodPrint := Context.GetBoolean('SendMethodPrint');
        SendMethodEmail := Context.GetBoolean('SendMethodEmail');
        SendMethodSMS := Context.GetBoolean('SendMethodSMS');
        if SendMethodEmail then
            Email := CopyStr(Context.GetString('SendToEmail'), 1, MaxStrLen(NpRvSalesLine."E-mail"));
        if SendMethodSMS then
            PhoneNo := CopyStr(Context.GetString('SendToPhoneNo'), 1, MaxStrLen(NpRvSalesLine."Phone No."));

#pragma warning disable AA0139

        if not Context.GetString('voucherSalesLineParentId', VoucherSalesLineParentIdText) then
            Clear(VoucherSalesLineParentIdText);

        if not Evaluate(VoucherSalesLineParentId, VoucherSalesLineParentIdText) then
            Clear(VoucherSalesLineParentId);

        NpRvVoucherMgt.IssueReturnVoucher(POSSession, VoucherTypeCode, Amount, Email, PhoneNo, SendMethodPrint, SendMethodEmail, SendMethodSMS, VoucherSalesLineParentId, CustomReferenceNo);
#pragma warning restore AA0139

        POSSession.GetSale(Sale);
        Sale.GetCurrentSale(SalePOS);
        POSActionDataCollectionB.CheckIfCollectReturnInformation(SalePOS."Sales Ticket No.", CollectReturnInformation);

        Response.Add('paymentNo', VoucherType."Payment Type");
        Response.Add('collectReturnInformation', CollectReturnInformation);
        exit(Response);
    end;

    local procedure ValidateRequest(Context: Codeunit "NPR POS JSON Helper"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup"; Sale: Codeunit "NPR POS Sale")
    var
        POSUnit: Record "NPR POS Unit";
        POSSale: Record "NPR POS Sale";
        VoucherType: Text;
        VoucherSalesLineParentIdText: Text;
        VoucherTypeCode: Code[20];
        ReturnAmountToCapture: Decimal;
        POSActIssueReturnVchrB: Codeunit "NPR POS Act.Issue Return VchrB";
        VoucherSalesLineParentId: Guid;
    begin
        if not Context.GetString('voucherSalesLineParentId', VoucherSalesLineParentIdText) then
            Clear(VoucherSalesLineParentIdText);

        if not Evaluate(VoucherSalesLineParentId, VoucherSalesLineParentIdText) then
            Clear(VoucherSalesLineParentId);

        Context.SetScopeParameters();
        Setup.GetPOSUnit(POSUnit);
        if Context.GetString('VoucherTypeCode', VoucherType) then begin
            Evaluate(VoucherTypeCode, VoucherType);

            Sale.GetCurrentSale(POSSale);
            POSActIssueReturnVchrB.ValidateAmount(VoucherTypeCode, ReturnAmountToCapture, PaymentLine, POSUnit."No.", POSSale."Sales Ticket No.", VoucherSalesLineParentId);

            Context.SetContext('voucher_amount', -ReturnAmountToCapture);
        end;
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

    local procedure CheckReferenceNoAlreadyUsed(Context: Codeunit "NPR POS JSON Helper") Response: JsonObject;
    var
        IssuePOSActionMgtB: Codeunit "NPR NpRv Issue POSAction Mgt-B";
        CustomReferenceNo: Text;
        ReferenceNoAlreadyUsed: Boolean;
        ReferenceNoAlreadyUsedLbl: Label 'Reference No. %1 already used.Do you want to scan the reference no. again?';
        ReferenceNoResponseText: Text;
    begin
        if not Context.GetString('CustomReferenceNo', CustomReferenceNo) then
            CustomReferenceNo := '';
#pragma warning disable AA0139
        ReferenceNoAlreadyUsed := IssuePOSActionMgtB.CheckReferenceNoAlreadyUsed('', CustomReferenceNo);
        if ReferenceNoAlreadyUsed then
            ReferenceNoResponseText := StrSubstNo(ReferenceNoAlreadyUsedLbl, CustomReferenceNo);

        Response.Add('ReferenceNoAlreadyUsed', ReferenceNoAlreadyUsed);
        Response.Add('ReferenceNoAlreadyUsedMessage', ReferenceNoResponseText);
#pragma warning restore AA0139
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
