codeunit 6151012 "NPR NpRv Issue POSAction Mgt." implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config");
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        ActionDescription: Label 'This action Issues Retail Vouchers.';
        ParameterAmount_CaptionLbl: Label 'Amount';
        ParameterContactInfo_CaptLbl: Label 'Contact Info';
        ParameterDiscAmount_CaptionLbl: Label 'Discount Amount';
        ParameterDiscType_CaptionLbl: Label 'Discount Type';
        ParameterDiscType_OptionCaptionLbl: Label 'Amount,Percent,None';
        ParameterDiscType_OptionsLbl: Label 'Amount,Percent,None', Locked = true;
        ParameterQuantity_CptLbl: Label 'Quantity';
        ParameterScanReference_CaptLbl: Label 'Scan Reference Nos';
        ParameterIssueVoucherPerQuantity_CaptLbl: Label 'Issue Voucher per Quantity';
        ParameterVoucherTypeCode_CaptLbl: Label 'Voucher Type Code';
        Text001: Label 'Select Voucher Type';
        Text002: Label 'Issue Retail Vouchers';
        Text003: Label 'Enter Quantity';
        Text004: Label 'Enter Amount';
        Text005: Label 'Enter Discount Amount';
        Text006: Label 'Enter Discount Percent';
        CustomReferenceNoCaptionLbl: Label 'Reference No.';
        CustomReferenceNoTitleLbl: Label 'Please scan a reference no.';
        ScanReferenceNoErrorLbl: Label 'Please scan a reference no. Do you want to continue?';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);

        WorkflowConfig.AddLabel('IssueVoucherPrompt', Text001);
        WorkflowConfig.AddLabel('IssueVoucherTitle', Text002);
        WorkflowConfig.AddLabel('Quantity', Text003);
        WorkflowConfig.AddLabel('Amount', Text004);
        WorkflowConfig.AddLabel('DiscountAmount', Text005);
        WorkflowConfig.AddLabel('DiscountPercent', Text006);
        WorkflowConfig.AddLabel('SendViaEmail', NpRvVoucher.FieldCaption("Send via E-mail"));
        WorkflowConfig.AddLabel('Email', NpRvVoucher.FieldCaption("E-mail"));
        WorkflowConfig.AddLabel('SendViaSMS', NpRvVoucher.FieldCaption("Send via SMS"));
        WorkflowConfig.AddLabel('Phone', NpRvVoucher.FieldCaption("Phone No."));
        WorkflowConfig.AddLabel('CustomReferenceNoCaption', CustomReferenceNoCaptionLbl);
        WorkflowConfig.AddLabel('CustomReferenceNoTitle', CustomReferenceNoTitleLbl);
        WorkflowConfig.AddLabel('ScanReferenceNoError', ScanReferenceNoErrorLbl);

        WorkflowConfig.AddDecimalParameter('Amount', 0, ParameterAmount_CaptionLbl, ParameterAmount_CaptionLbl);
        WorkflowConfig.AddBooleanParameter('ContactInfo', true, ParameterContactInfo_CaptLbl, ParameterContactInfo_CaptLbl);
        WorkflowConfig.AddDecimalParameter('DiscountAmount', 0, ParameterDiscAmount_CaptionLbl, ParameterDiscAmount_CaptionLbl);
        WorkflowConfig.AddOptionParameter(
            'DiscountType',
            ParameterDiscType_OptionsLbl,
#pragma warning disable AA0139
            SelectStr(3, ParameterDiscType_OptionsLbl),
#pragma warning restore
            ParameterDiscType_CaptionLbl,
            ParameterDiscType_CaptionLbl,
            ParameterDiscType_OptionCaptionLbl);
        WorkflowConfig.AddIntegerParameter('Quantity', 0, ParameterQuantity_CptLbl, ParameterQuantity_CptLbl);
        WorkflowConfig.AddBooleanParameter('ScanReferenceNos', false, ParameterScanReference_CaptLbl, ParameterScanReference_CaptLbl);
        WorkflowConfig.AddBooleanParameter('IssueVoucherPerQuantity', false, ParameterIssueVoucherPerQuantity_CaptLbl, ParameterIssueVoucherPerQuantity_CaptLbl);
        WorkflowConfig.AddTextParameter('VoucherTypeCode', '', ParameterVoucherTypeCode_CaptLbl, ParameterVoucherTypeCode_CaptLbl);
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
        //###NPR_INJECT_FROM_FILE:POSActionIssueVoucher.js###
'let main=async({workflow:l,parameters:e,popup:t,captions:n})=>{debugger;let c,i,a,u;if(e.VoucherTypeCode?c={VoucherTypeCode:e.VoucherTypeCode}:c=await l.respond("voucher_type_input"),c==null||c=="")return;for(;i<=0||i==null;){if(e.Quantity<=0?i=await t.numpad({title:n.IssueVoucherTitle,caption:n.Quantity,value:1,notBlank:!0}):i=e.Quantity,i==null)return;await l.respond("check_qty",{qty_input:i})}if(e.Amount<=0){if(a=await t.numpad({title:n.IssueVoucherTitle,caption:n.Amount,value:0,notBlank:!0}),a==null)return}else a=e.Amount;switch(e.DiscountType.toInt()){case e.DiscountType.Amount:if(e.DiscountAmount<=0){if(u=await t.numpad({title:n.IssueVoucherTitle,caption:n.DiscountAmount,value:0}),u==null)return}else u=e.DiscountAmount;break;case e.DiscountType.Percent:if(e.DiscountAmount<=0){if(u=await t.numpad({title:n.IssueVoucherTitle,caption:n.DiscountPercent,value:0}),u==null)return}else u=e.DiscountAmount;break;default:break}let{SendToEmail:f,SendToPhoneNo:r,SendMethodPrint:y,SendMethodEmail:h,SendMethodSMS:s}=await l.respond("select_send_method",{VoucherTypeCode:c});if(h&&(f=await t.input({title:n.SendViaEmail,caption:n.Email,value:f,notBlank:!0}),f==null)||s&&(r=await t.input({title:n.SendViaSMS,caption:n.Phone,value:r,notBlank:!0}),r==null))return;let o,S=!1,T=0;if(e.ScanReferenceNos){let _=!0;for(;_;){let d=!0;for(;d;){o=await t.input({title:n.CustomReferenceNoTitle,caption:n.CustomReferenceNoCaption}),d=o=="",o!==null&&(d&&(d=await t.confirm({title:n.CustomReferenceNoTitle,caption:n.ScanReferenceNoError})),S=!d||S);const{ReferenceNoAlreadyUsed:m,ReferenceNoAlreadyUsedMessage:C}=await l.respond("check_reference_no_already_used",{CustomReferenceNo:o});m&&(o="",d=await t.confirm({title:n.CustomReferenceNoCaption,caption:C}))}o&&await l.respond("issue_voucher",{VoucherTypeCode:c,qty_input:1,amt_input:a,DiscountType:e.DiscountType,discount_input:u,SendMethodPrint:y,SendToEmail:f,SendToPhoneNo:r,SendMethodEmail:h,SendMethodSMS:s,CustomReferenceNo:o}),T+=1,_=o!==null&&T<i}}else await l.respond("issue_voucher",{VoucherTypeCode:c,qty_input:i,amt_input:a,DiscountType:e.DiscountType,discount_input:u,SendMethodPrint:y,SendToEmail:f,SendToPhoneNo:r,SendMethodEmail:h,SendMethodSMS:s});(S||!e.ScanReferenceNos)&&e.ContactInfo&&await l.respond("contact_info")};'
        );
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup");
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        IssueVoucherMgtB: Codeunit "NPR NpRv Issue POSAction Mgt-B";
    begin
        SaleLine.GetCurrentSaleLine(SaleLinePOS);
        case Step of
            'check_qty':
                CheckQty(Context);
            'voucher_type_input':
                FrontEnd.WorkflowResponse(VoucherTypeInput(Context));
            'select_send_method':
                FrontEnd.WorkflowResponse(SelectSendMethod(Context, Sale));
            'issue_voucher':
                IssueVoucher(Context, Sale, SaleLine);
            'contact_info':
                IssueVoucherMgtB.ContactInfo(SaleLinePOS);
            'scan_reference_nos':
                IssueVoucherMgtB.ScanReferenceNos(SaleLinePOS, SaleLinePOS.Quantity);
            'check_reference_no_already_used':
                FrontEnd.WorkflowResponse(CheckReferenceNoAlreadyUsed(Context));
        end;
    end;

    local procedure IssueVoucher(Context: Codeunit "NPR POS JSON Helper"; POSSale: Codeunit "NPR POS Sale"; POSSaleLine: Codeunit "NPR POS Sale Line")
    var
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        TempVoucher: Record "NPR NpRv Voucher" temporary;
        VoucherType: Record "NPR NpRv Voucher Type";
        IssueVoucherMgtB: Codeunit "NPR NpRv Issue POSAction Mgt-B";
        NpRvModuleMgt: Codeunit "NPR NpRv Module Mgt.";
        Amount: Decimal;
        Discount: Decimal;
        Quantity: Integer;
        Idx: Integer;
        StartIdx: Integer;
        QuantityPerLine: Integer;
        DiscountType: Text;
        CustomReferenceNo: Text;
        SendToEmail: Text;
        SendToPhoneNo: Text;
        IssueVoucherPerQuantity: Boolean;
        ScanReferenceNos: Boolean;
        SendMethodPrint: Boolean;
        SendMethodEmail: Boolean;
        SendMethodSMS: Boolean;
        ShouldIssueVoucherPerQuantity: Boolean;
    begin
        Context.SetScopePath('VoucherTypeCode');
        VoucherType.Get(UpperCase(Context.GetString('VoucherTypeCode')));

        Context.SetScopeRoot();
        Quantity := Context.GetInteger('qty_input');
        Amount := Context.GetDecimal('amt_input');

        if not Context.GetString('CustomReferenceNo', CustomReferenceNo) then
            CustomReferenceNo := '';
        NpRvModuleMgt.OnBeforeIssueVoucherCheckCustomReferenceNo(CustomReferenceNo);

        if not Context.GetBooleanParameter('ScanReferenceNos', ScanReferenceNos) then
            ScanReferenceNos := false;

        if not Context.GetBooleanParameter('IssueVoucherPerQuantity', IssueVoucherPerQuantity) then
            IssueVoucherPerQuantity := false;

        ShouldIssueVoucherPerQuantity := not ScanReferenceNos and IssueVoucherPerQuantity;

        Context.SetScopeParameters();
        DiscountType := Context.GetString('DiscountType');
        if DiscountType <> '2' then begin
            Context.SetScopeRoot();
            Discount := Context.GetDecimal('discount_input');
        end;

        if not IssueVoucherPerQuantity then begin
            StartIdx := Quantity;
            QuantityPerLine := Quantity;
        end else begin
            StartIdx := 1;
            QuantityPerLine := 1;
        end;

        Context.SetScopeRoot();
        SendMethodPrint := Context.GetBoolean('SendMethodPrint');
        SendMethodEmail := Context.GetBoolean('SendMethodEmail');
        SendMethodSMS := Context.GetBoolean('SendMethodSMS');
        SendToEmail := Context.GetString('SendToEmail');
        SendToPhoneNo := Context.GetString('SendToPhoneNo');


        for Idx := StartIdx to Quantity do begin
            TempVoucher.Reset();
            if not TempVoucher.IsEmpty then
                TempVoucher.DeleteAll();

            NpRvModuleMgt.OnBeforeIssueVoucher(VoucherType, QuantityPerLine, Quantity, Amount, DiscountType, Discount, ScanReferenceNos, IssueVoucherPerQuantity, ShouldIssueVoucherPerQuantity);

#pragma warning disable AA0139
            IssueVoucherMgtB.IssueVoucherCreate(POSSaleLine, TempVoucher, VoucherType, DiscountType, QuantityPerLine, Amount, Discount, CustomReferenceNo);
#pragma warning restore AA0139
            IssueVoucherMgtB.CreateNpRvSalesLine(POSSale, NpRvSalesLine, TempVoucher, VoucherType, POSSaleLine);

            OnIssueVoucherBeforeNpRvSalesLineModify(POSSale, NpRvSalesLine, TempVoucher, VoucherType, POSSaleLine);

            NpRvSalesLine."Send via Print" := SendMethodPrint;
            NpRvSalesLine."Send via E-mail" := SendMethodEmail;
            NpRvSalesLine."Send via SMS" := SendMethodSMS;
            NpRvSalesLine."E-mail" := CopyStr(SendToEmail, 1, MaxStrLen(NpRvSalesLine."E-mail"));
            NpRvSalesLine."Phone No." := CopyStr(SendToPhoneNo, 1, MaxStrLen(NpRvSalesLine."Phone No."));
            NpRvSalesLine.Modify();

            IssueVoucherMgtB.CreateNpRvSalesLineRef(NpRvSalesLine, TempVoucher);
        end;
    end;

    local procedure SelectSendMethod(Context: Codeunit "NPR POS JSON Helper"; POSSale: Codeunit "NPR POS Sale") Response: JsonObject
    var
        VoucherType: Record "NPR NpRv Voucher Type";
        NpRvModuleSendDefault: Codeunit "NPR NpRv Module Send: Def.";
        IssueVoucherMgtB: Codeunit "NPR NpRv Issue POSAction Mgt-B";
        Selection: Integer;
        Email: Text;
        PhoneNo: Text;
    begin
        Context.SetScopePath('VoucherTypeCode');
        VoucherType.Get(UpperCase(Context.GetString('VoucherTypeCode')));

        IssueVoucherMgtB.FindSendMethod(POSSale, Email, PhoneNo);
        Response.Add('SendToEmail', Email);
        Response.Add('SendToPhoneNo', PhoneNo);

        Selection := NpRvModuleSendDefault.SelectSendMethod(VoucherType);
        Response.Add('SendMethodPrint', Selection = VoucherType."Send Method via POS"::Print);
        Response.Add('SendMethodEmail', Selection = VoucherType."Send Method via POS"::"E-mail");
        Response.Add('SendMethodSMS', Selection = VoucherType."Send Method via POS"::SMS);
        exit(Response);
    end;

    local procedure VoucherTypeInput(Context: Codeunit "NPR POS JSON Helper") Response: JsonObject;
    var
        VoucherTypeCode: Text;
        IssueVoucherMgtB: Codeunit "NPR NpRv Issue POSAction Mgt-B";
    begin
        if not IssueVoucherMgtB.SelectVoucherType(VoucherTypeCode) then
            Error('');
        Context.SetScopeParameters();
        Context.SetContext('VoucherTypeCode', VoucherTypeCode);
        Response.Add('VoucherTypeCode', VoucherTypeCode);
    end;

    local procedure CheckQty(Context: Codeunit "NPR POS JSON Helper")
    var
        Qty: Decimal;
        ConfirmReenterQtyMsg: Label '\Do you want to re-enter the quantity?';
        QtyNotPositiveErr: Label 'You must specify a positive quantity.';
    begin
        Context.SetScopeRoot();
        Qty := Context.GetDecimal('qty_input');
        if Qty <= 0 then
            if not Confirm(QtyNotPositiveErr + ConfirmReenterQtyMsg, true) then
                Error('');
    end;

    local procedure CheckReferenceNoAlreadyUsed(Context: Codeunit "NPR POS JSON Helper") Response: JsonObject;
    var
        IssuePOSActionMgtB: Codeunit "NPR NpRv Issue POSAction Mgt-B";
        NpRvModuleMgt: Codeunit "NPR NpRv Module Mgt.";
        CustomReferenceNo: Text;
        ReferenceNoAlreadyUsed: Boolean;
        ReferenceNoAlreadyUsedLbl: Label 'Reference No. %1 already used.Do you want to scan the reference no. again?';
        ReferenceNoResponseText: Text;
    begin
        if not Context.GetString('CustomReferenceNo', CustomReferenceNo) then
            CustomReferenceNo := '';
        NpRvModuleMgt.OnBeforeCheckCustomReferenceNoAlreadyUsed(CustomReferenceNo);
#pragma warning disable AA0139
        ReferenceNoAlreadyUsed := IssuePOSActionMgtB.CheckReferenceNoAlreadyUsed('', CustomReferenceNo);
        if ReferenceNoAlreadyUsed then
            ReferenceNoResponseText := StrSubstNo(ReferenceNoAlreadyUsedLbl, CustomReferenceNo);

        Response.Add('ReferenceNoAlreadyUsed', ReferenceNoAlreadyUsed);
        Response.Add('ReferenceNoAlreadyUsedMessage', ReferenceNoResponseText);
#pragma warning restore AA0139
    end;

    local procedure IssueVoucherActionCode(): Code[20]
    begin
        exit(Format(Enum::"NPR POS Workflow"::ISSUE_VOUCHER));
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnLookupValue', '', true, true)]
    local procedure OnLookupVoucherTypeCode(var POSParameterValue: Record "NPR POS Parameter Value"; Handled: Boolean)
    var
        NpRvVoucherType: Record "NPR NpRv Voucher Type";
    begin
        if POSParameterValue."Action Code" <> IssueVoucherActionCode() then
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
    begin
        if POSParameterValue."Action Code" <> IssueVoucherActionCode() then
            exit;
        if POSParameterValue.Name <> 'VoucherTypeCode' then
            exit;
        if POSParameterValue."Data Type" <> POSParameterValue."Data Type"::Text then
            exit;

        if POSParameterValue.Value = '' then
            exit;

        POSParameterValue.Value := UpperCase(POSParameterValue.Value);
        if not NpRvVoucherType.Get(POSParameterValue.Value) then begin
            NpRvVoucherType.SetFilter(Code, '%1', POSParameterValue.Value + '*');
            if NpRvVoucherType.FindFirst() then
                POSParameterValue.Value := NpRvVoucherType.Code;
        end;

        NpRvVoucherType.Get(POSParameterValue.Value);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnIssueVoucherBeforeNpRvSalesLineModify(var POSSale: Codeunit "NPR POS Sale"; var NpRvSalesLine: Record "NPR NpRv Sales Line"; var TempVoucher: Record "NPR NpRv Voucher" temporary; var VoucherType: Record "NPR NpRv Voucher Type"; var POSSaleLine: Codeunit "NPR POS Sale Line")
    begin
    end;

}

