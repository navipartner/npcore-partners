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
        WorkflowConfig.AddTextParameter('VoucherTypeCode', '', ParameterVoucherTypeCode_CaptLbl, ParameterVoucherTypeCode_CaptLbl);
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
        //###NPR_INJECT_FROM_FILE:POSActionIssueVoucher.js###
'let main=async({workflow:t,parameters:e,popup:i,captions:n})=>{debugger;let c,u,l,o;if(e.VoucherTypeCode?c={VoucherTypeCode:e.VoucherTypeCode}:c=await t.respond("voucher_type_input"),c==null||c=="")return;for(;u<=0||u==null;){if(e.Quantity<=0?u=await i.numpad({title:n.IssueVoucherTitle,caption:n.Quantity,value:1,notBlank:!0}):u=e.Quantity,u==null)return;await t.respond("check_qty",{qty_input:u})}if(e.Amount<=0){if(l=await i.numpad({title:n.IssueVoucherTitle,caption:n.Amount,value:0,notBlank:!0}),l==null)return}else l=e.Amount;switch(e.DiscountType.toInt()){case e.DiscountType.Amount:if(e.DiscountAmount<=0){if(o=await i.numpad({title:n.IssueVoucherTitle,caption:n.DiscountAmount,value:0}),o==null)return}else o=e.DiscountAmount;break;case e.DiscountType.Percent:if(e.DiscountAmount<=0){if(o=await i.numpad({title:n.IssueVoucherTitle,caption:n.DiscountPercent,value:0}),o==null)return}else o=e.DiscountAmount;break;default:break}let{SendToEmail:a,SendToPhoneNo:s,SendMethodPrint:S,SendMethodEmail:h,SendMethodSMS:r,NewVoucherCustomReferenceNoExperienceEnabled:C}=await t.respond("select_send_method",{VoucherTypeCode:c});if(!(h&&(a=await i.input({title:n.SendViaEmail,caption:n.Email,value:a,notBlank:!0}),a==null))&&!(r&&(s=await i.input({title:n.SendViaSMS,caption:n.Phone,value:s,notBlank:!0}),s==null)))if(C){let d,y=!1,T=0;if(e.ScanReferenceNos){let _=!0;for(;_;){let f=!0;for(;f;){d=await i.input({title:n.CustomReferenceNoTitle,caption:n.CustomReferenceNoCaption}),f=d=="",d!==null&&(f&&(f=await i.confirm({title:n.CustomReferenceNoTitle,caption:n.ScanReferenceNoError})),y=!f||y);const{ReferenceNoAlreadyUsed:m,ReferenceNoAlreadyUsedMessage:N}=await t.respond("check_reference_no_already_used",{CustomReferenceNo:d});m&&(d="",f=await i.confirm({title:n.CustomReferenceNoCaption,caption:N}))}d&&await t.respond("issue_voucher",{VoucherTypeCode:c,qty_input:1,amt_input:l,DiscountType:e.DiscountType,discount_input:o,SendMethodPrint:S,SendToEmail:a,SendToPhoneNo:s,SendMethodEmail:h,SendMethodSMS:r,CustomReferenceNo:d}),T+=1,_=d!==null&&T<u}}else await t.respond("issue_voucher",{VoucherTypeCode:c,qty_input:u,amt_input:l,DiscountType:e.DiscountType,discount_input:o,SendMethodPrint:S,SendToEmail:a,SendToPhoneNo:s,SendMethodEmail:h,SendMethodSMS:r});(y||!e.ScanReferenceNos)&&e.ContactInfo&&await t.respond("contact_info")}else await t.respond("issue_voucher",{VoucherTypeCode:c,qty_input:u,amt_input:l,DiscountType:e.DiscountType,discount_input:o,SendMethodPrint:S,SendToEmail:a,SendToPhoneNo:s,SendMethodEmail:h,SendMethodSMS:r}),e.ContactInfo&&await t.respond("contact_info"),e.ScanReferenceNos&&await t.respond("scan_reference_nos")};'
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
        Amount: Decimal;
        Discount: Decimal;
        Quantity: Integer;
        DiscountType: Text;
        CustomReferenceNo: Text;
    begin
        Context.SetScopePath('VoucherTypeCode');
        VoucherType.Get(UpperCase(Context.GetString('VoucherTypeCode')));

        Context.SetScopeRoot();
        Quantity := Context.GetInteger('qty_input');
        Amount := Context.GetDecimal('amt_input');

        if not Context.GetString('CustomReferenceNo', CustomReferenceNo) then
            CustomReferenceNo := '';

        Context.SetScopeParameters();
        DiscountType := Context.GetString('DiscountType');
        if DiscountType <> '2' then begin
            Context.SetScopeRoot();
            Discount := Context.GetDecimal('discount_input');
        end;
#pragma warning disable AA0139
        IssueVoucherMgtB.IssueVoucherCreate(POSSaleLine, TempVoucher, VoucherType, DiscountType, Quantity, Amount, Discount, CustomReferenceNo);
#pragma warning restore AA0139
        IssueVoucherMgtB.CreateNpRvSalesLine(POSSale, NpRvSalesLine, TempVoucher, VoucherType, POSSaleLine);

        OnIssueVoucherBeforeNpRvSalesLineModify(POSSale, NpRvSalesLine, TempVoucher, VoucherType, POSSaleLine);

        Context.SetScopeRoot();
        NpRvSalesLine."Send via Print" := Context.GetBoolean('SendMethodPrint');
        NpRvSalesLine."Send via E-mail" := Context.GetBoolean('SendMethodEmail');
        NpRvSalesLine."Send via SMS" := Context.GetBoolean('SendMethodSMS');
        NpRvSalesLine."E-mail" := CopyStr(Context.GetString('SendToEmail'), 1, MaxStrLen(NpRvSalesLine."E-mail"));
        NpRvSalesLine."Phone No." := CopyStr(Context.GetString('SendToPhoneNo'), 1, MaxStrLen(NpRvSalesLine."Phone No."));
        NpRvSalesLine.Modify();

        IssueVoucherMgtB.CreateNpRvSalesLineRef(NpRvSalesLine, TempVoucher);
    end;

    local procedure SelectSendMethod(Context: Codeunit "NPR POS JSON Helper"; POSSale: Codeunit "NPR POS Sale") Response: JsonObject
    var
        VoucherType: Record "NPR NpRv Voucher Type";
        NpRvModuleSendDefault: Codeunit "NPR NpRv Module Send: Def.";
        IssueVoucherMgtB: Codeunit "NPR NpRv Issue POSAction Mgt-B";
        FeatureFlagsManagement: Codeunit "NPR Feature Flags Management";
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
        Response.Add('NewVoucherCustomReferenceNoExperienceEnabled', FeatureFlagsManagement.IsEnabled('newVoucherCustomReferenceNoExperienceEnabled'));
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

