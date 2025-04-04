﻿codeunit 6151016 "NPR NpRv Ret. POSAction Mgt."
{
    Access = Internal;
    ObsoleteState = Pending;
    ObsoleteTag = '2023-06-28';
    ObsoleteReason = 'Use new action ISSUE_RETURN_VCHR_2';

    var
        Text000: Label 'This action Issues Return Retail Vouchers.';
        Text001: Label 'Select Voucher Type';
        Text002: Label 'Issue Return Retail Voucher';
        Text003: Label 'Enter Amount';

        Text005: Label 'Nothing to return';
        Text006: Label 'The amount of %1 is less that the Minimum Amount allowed (%2) to create a Voucher';
        Text007: Label 'Minimum Amount for %1 %2 is %3';
        ReadingErr: Label 'reading in %1';
        SettingScopeErr: Label 'setting scope in %1';

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Action", 'OnDiscoverActions', '', true, true)]
    local procedure OnDiscoverActions(var Sender: Record "NPR POS Action")
    begin
        DiscoverIssueReturnVoucherAction(Sender);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS UI Management", 'OnInitializeCaptions', '', true, true)]
    local procedure OnInitializeCaptions(Captions: Codeunit "NPR POS Caption Management")
    begin
        InitializeIssueReturnVoucherCaptions(Captions);
    end;

    local procedure DiscoverIssueReturnVoucherAction(var Sender: Record "NPR POS Action")
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
    begin
        if not Sender.DiscoverAction(
          ActionCode(),
          Text000,
          ActionVersion(),
          Sender.Type::Generic,
          Sender."Subscriber Instances Allowed"::Multiple) then
            exit;

        Sender.RegisterWorkflowStep('voucher_type_input', 'if (!param.VoucherTypeCode) {respond()} else {context.VoucherTypeCode = param.VoucherTypeCode}');
        Sender.RegisterWorkflowStep('amt_input', 'if (!context.IsUnattendedPOS) {numpad({title: labels.IssueReturnVoucherTitle,caption: labels.Amount,value: context.voucher_amount,notBlank: true}).cancel(abort)};');
        Sender.RegisterWorkflowStep('validate_amt', 'respond();');
        Sender.RegisterWorkflowStep('select_send_method', 'respond();');
        Sender.RegisterWorkflowStep('send_method_email',
          'context.$send_method_email = {input: context.SendToEmail};' +
          'if (context.SendMethodEmail) {' +
          '  input({' +
          '    title: "' + NpRvVoucher.FieldCaption("Send via E-mail") + '"' +
          '    ,caption: "' + NpRvVoucher.FieldCaption("E-mail") + '"' +
          '    ,value: context.SendToEmail' +
          '    ,notBlank: true' +
          '  }).cancel(abort)' +
          '};');
        Sender.RegisterWorkflowStep('send_method_sms',
        'context.$send_method_sms = {input: context.SendToPhoneNo};' +
        'if (context.SendMethodSMS) {' +
        '  input({' +
        '    title: "' + NpRvVoucher.FieldCaption("Send via SMS") + '"' +
        '    ,caption: "' + NpRvVoucher.FieldCaption("Phone No.") + '"' +
        '    ,value: context.SendToPhoneNo' +
        '    ,notBlank: true' +
        '  }).cancel(abort)' +
        '};');
        Sender.RegisterWorkflowStep('issue_return_voucher', 'respond ();');
        Sender.RegisterWorkflowStep('contact_info', 'if(param.ContactInfo) {respond()}');
        Sender.RegisterWorkflowStep('scan_reference_nos', 'if(param.ScanReferenceNos) {respond()}');
        Sender.RegisterWorkflowStep('end_sale', 'if(param.EndSale) {respond()};');
        Sender.RegisterWorkflow(true);

        Sender.RegisterTextParameter('VoucherTypeCode', '');
        Sender.RegisterBooleanParameter('ContactInfo', false);
        Sender.RegisterBooleanParameter('ScanReferenceNos', false);
        Sender.RegisterBooleanParameter('EndSale', true);
    end;

    local procedure InitializeIssueReturnVoucherCaptions(var Captions: Codeunit "NPR POS Caption Management")
    begin
        Captions.AddActionCaption(ActionCode(), 'IssueReturnVoucherPrompt', Text001);
        Captions.AddActionCaption(ActionCode(), 'IssueReturnVoucherTitle', Text002);
        Captions.AddActionCaption(ActionCode(), 'Amount', Text003);
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

        if PAGE.RunModal(0, NpRvVoucherType) = ACTION::LookupOK then
            POSParameterValue.Value := NpRvVoucherType.Code;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnValidateValue', '', true, true)]
    local procedure OnValidateVoucherTypeCode(var POSParameterValue: Record "NPR POS Parameter Value")
    var
        NpRvVoucherType: Record "NPR NpRv Voucher Type";
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
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

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS JavaScript Interface", 'OnBeforeWorkflow', '', true, true)]
    local procedure OnBeforeWorkflow("Action": Record "NPR POS Action"; Parameters: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        NpRvVoucherType: Record "NPR NpRv Voucher Type";
        POSPaymentMethod: Record "NPR POS Payment Method";
        POSUnit: Record "NPR POS Unit";
        Context: Codeunit "NPR POS JSON Management";
        POSPaymentLine: Codeunit "NPR POS Payment Line";
        Setup: Codeunit "NPR POS Setup";
        PaidAmount: Decimal;
        ReturnAmount: Decimal;
        SaleAmount: Decimal;
        SubTotal: Decimal;
        VoucherTypeCode: Code[20];
    begin
        if not Action.IsThisAction(ActionCode()) then
            exit;

        Handled := true;

        POSSession.GetPaymentLine(POSPaymentLine);
        POSPaymentLine.CalculateBalance(SaleAmount, PaidAmount, ReturnAmount, SubTotal);
        ReturnAmount := SaleAmount - PaidAmount;

        Context.InitializeJObjectParser(Parameters, FrontEnd);
        VoucherTypeCode := CopyStr(Context.GetString('VoucherTypeCode'), 1, MaxStrLen(VoucherTypeCode));
        NpRvVoucherType.Get(VoucherTypeCode);
        POSPaymentMethod.Get(NpRvVoucherType."Payment Type");
        if POSPaymentMethod."Rounding Precision" > 0 then
            ReturnAmount := Round(SaleAmount - PaidAmount, POSPaymentMethod."Rounding Precision");
        if ReturnAmount >= 0 then
            Error(Text005);

        if POSPaymentMethod."Minimum Amount" < 0 then
            POSPaymentMethod."Minimum Amount" := 0;
        if (POSPaymentMethod."Minimum Amount" > 0) and (-ReturnAmount < POSPaymentMethod."Minimum Amount") then
            Error(Text007, POSPaymentMethod.TableCaption, POSPaymentMethod.Code, POSPaymentMethod."Minimum Amount");

        if NpRvVoucherType."Minimum Amount Issue" < 0 then
            NpRvVoucherType."Minimum Amount Issue" := 0;
        if (NpRvVoucherType."Minimum Amount Issue" > 0) and (-ReturnAmount < NpRvVoucherType."Minimum Amount Issue") then
            Error(Text007, NpRvVoucherType.TableCaption, NpRvVoucherType.Code, NpRvVoucherType."Minimum Amount Issue");

        Context.SetContext('voucher_amount', -ReturnAmount);
        POSSession.GetSetup(Setup);
        Setup.GetPOSUnit(POSUnit);
        Context.SetContext('IsUnattendedPOS', POSUnit."POS Type" = POSUnit."POS Type"::UNATTENDED);
        FrontEnd.SetActionContext(ActionCode(), Context);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS JavaScript Interface", 'OnAction', '', true, true)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        JSON: Codeunit "NPR POS JSON Management";
    begin
        if Handled then
            exit;

        if not Action.IsThisAction(ActionCode()) then
            exit;
        Handled := true;

        JSON.InitializeJObjectParser(Context, FrontEnd);
        case WorkflowStep of
            'voucher_type_input':
                VoucherTypeInput(JSON, FrontEnd);
            'validate_amt':
                ValidateAmt(JSON, FrontEnd);
            'select_send_method':
                SelectSendMethod(JSON, POSSession, FrontEnd);
            'issue_return_voucher':
                IssueReturnVoucher(JSON, POSSession);
            'contact_info':
                ContactInfo(POSSession);
            'scan_reference_nos':
                ScanReferenceNos(POSSession);
            'end_sale':
                EndSale(JSON, POSSession);
        end;
    end;

    local procedure ContactInfo(POSSession: Codeunit "NPR POS Session")
    var
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSPaymentLine: Codeunit "NPR POS Payment Line";
    begin
        POSSession.GetPaymentLine(POSPaymentLine);
        POSPaymentLine.GetCurrentPaymentLine(SaleLinePOS);

        NpRvSalesLine.SetRange("Register No.", SaleLinePOS."Register No.");
        NpRvSalesLine.SetRange("Sales Ticket No.", SaleLinePOS."Sales Ticket No.");
        NpRvSalesLine.SetRange("Sale Date", SaleLinePOS.Date);
        NpRvSalesLine.SetRange("Sale Line No.", SaleLinePOS."Line No.");
        if not NpRvSalesLine.FindSet() then
            exit;

        repeat
            PAGE.RunModal(PAGE::"NPR NpRv Sales Line Card", NpRvSalesLine);
            Commit();
        until NpRvSalesLine.Next() = 0;
    end;

    local procedure ScanReferenceNos(POSSession: Codeunit "NPR POS Session")
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        POSPaymentLine: Codeunit "NPR POS Payment Line";
        NpRvPOSIssueVoucherRefs: Page "NPR NpRv Sales Line Ref.";
    begin
        if not GuiAllowed then
            exit;

        POSSession.GetPaymentLine(POSPaymentLine);
        POSPaymentLine.GetCurrentPaymentLine(SaleLinePOS);

        NpRvSalesLine.SetRange("Retail ID", SaleLinePOS.SystemId);
        NpRvSalesLine.SetRange(Type, NpRvSalesLine.Type::"New Voucher");
        if not NpRvSalesLine.FindFirst() then
            exit;

        NpRvPOSIssueVoucherRefs.SetNpRvSalesLine(NpRvSalesLine, SaleLinePOS.Quantity);
        NpRvPOSIssueVoucherRefs.RunModal();
    end;

    local procedure EndSale(JSON: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session")
    var
        NpRvVoucherType: Record "NPR NpRv Voucher Type";
        POSPaymentMethod: Record "NPR POS Payment Method";
        ReturnPOSPaymentMethod: Record "NPR POS Payment Method";
        POSPaymentLine: Codeunit "NPR POS Payment Line";
        POSSetup: Codeunit "NPR POS Setup";
        POSSale: Codeunit "NPR POS Sale";
        PaidAmount: Decimal;
        ReturnAmount: Decimal;
        SaleAmount: Decimal;
        Subtotal: Decimal;
        VoucherTypeCode: Text;
    begin
        POSSession.GetPaymentLine(POSPaymentLine);
        POSPaymentLine.CalculateBalance(SaleAmount, PaidAmount, ReturnAmount, Subtotal);

        POSSession.GetSetup(POSSetup);
        if Abs(Subtotal) > Abs(POSSetup.AmountRoundingPrecision()) then
            exit;

        JSON.SetScopeParameters(ActionCode());
        VoucherTypeCode := UpperCase(JSON.GetStringOrFail('VoucherTypeCode', StrSubstNo(ReadingErr, ActionCode())));
        NpRvVoucherType.Get(VoucherTypeCode);
        if not POSPaymentMethod.Get(NpRvVoucherType."Payment Type") then
            exit;
        if not ReturnPOSPaymentMethod.Get(POSPaymentMethod."Return Payment Method Code") then
            exit;
        if POSPaymentLine.CalculateRemainingPaymentSuggestion(SaleAmount, PaidAmount, POSPaymentMethod, ReturnPOSPaymentMethod, false) <> 0 then
            exit;

        POSSession.GetSale(POSSale);
        if not POSSale.TryEndDirectSaleWithBalancing(POSSession, POSPaymentMethod, ReturnPOSPaymentMethod) then
            exit;
    end;

    local procedure IssueReturnVoucher(JSON: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session")
    var
        NpRvVoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
        VoucherTypeCode: Text;
        Amount: Decimal;
        SendMethodPrint, SendMethodEmail, SendMethodSMS : Boolean;
        Email: Text[80];
        PhoneNo: Text[30];
    begin
        JSON.SetScopeRoot();
        Amount := JSON.GetDecimalOrFail('ReturnVoucherAmount', StrSubstNo(ReadingErr, ActionCode()));
        if Amount = 0 then
            exit;

        JSON.SetScopeRoot();
        VoucherTypeCode := UpperCase(JSON.GetStringOrFail('VoucherTypeCode', StrSubstNo(ReadingErr, ActionCode())));

        JSON.SetScopeRoot();
        SendMethodPrint := JSON.GetBoolean('SendMethodPrint');
        SendMethodEmail := JSON.GetBoolean('SendMethodEmail');
        SendMethodSMS := JSON.GetBoolean('SendMethodSMS');
        if JSON.SetScope('$send_method_email') then
            Email := CopyStr(JSON.GetString('input'), 1, MaxStrLen(Email));
        JSON.SetScopeRoot();
        if JSON.SetScope('$send_method_sms') then
            PhoneNo := CopyStr(JSON.GetString('input'), 1, MaxStrLen(PhoneNo));


        NpRvVoucherMgt.IssueReturnVoucher(POSSession, VoucherTypeCode, Amount, Email, PhoneNo, SendMethodPrint, SendMethodEmail, SendMethodSMS);
    end;

    local procedure VoucherTypeInput(JSON: Codeunit "NPR POS JSON Management"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        VoucherTypeCode: Text;
    begin
        if not SelectVoucherType(VoucherTypeCode) then
            Error('');

        JSON.SetScopeParameters(ActionCode());
        JSON.SetContext('VoucherTypeCode', VoucherTypeCode);
        FrontEnd.SetActionContext(ActionCode(), JSON);
    end;

    local procedure ValidateAmt(JSON: Codeunit "NPR POS JSON Management"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        POSPaymentMethod: Record "NPR POS Payment Method";
        VoucherType: Record "NPR NpRv Voucher Type";
        VoucherTypeCode: Text;
        Amount: Decimal;
        IsUnattendedPOS: Boolean;
    begin
        JSON.SetScopeRoot();
        VoucherTypeCode := UpperCase(JSON.GetStringOrFail('VoucherTypeCode', StrSubstNo(ReadingErr, ActionCode())));
        VoucherType.Get(VoucherTypeCode);
        POSPaymentMethod.Get(VoucherType."Payment Type");

        IsUnattendedPOS := JSON.GetBoolean('IsUnattendedPOS');
        if IsUnattendedPOS then
            Amount := JSON.GetDecimalOrFail('voucher_amount', StrSubstNo(ReadingErr, ActionCode()))
        else begin
            JSON.SetScopeRoot();
            JSON.SetScope('$amt_input', StrSubstNo(SettingScopeErr, ActionCode()));
            Amount := JSON.GetDecimalOrFail('numpad', StrSubstNo(ReadingErr, ActionCode()));
            if POSPaymentMethod."Rounding Precision" > 0 then
                Amount := Round(Amount, POSPaymentMethod."Rounding Precision");

            if VoucherType."Minimum Amount Issue" < 0 then
                VoucherType."Minimum Amount Issue" := 0;
            if Amount < VoucherType."Minimum Amount Issue" then
                Error(Text006, Amount, VoucherType."Minimum Amount Issue");
        end;

        JSON.SetContext('ReturnVoucherAmount', Amount);
        FrontEnd.SetActionContext(ActionCode(), JSON);
    end;

    local procedure SelectVoucherType(var VoucherTypeCode: Text): Boolean
    var
        VoucherType: Record "NPR NpRv Voucher Type";
    begin
        VoucherTypeCode := '';
        if PAGE.RunModal(0, VoucherType) <> ACTION::LookupOK then
            exit(false);

        VoucherTypeCode := VoucherType.Code;
        exit(true);
    end;

    local procedure SelectSendMethod(JSON: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        Customer: Record Customer;
        VoucherType: Record "NPR NpRv Voucher Type";
        SalePOS: Record "NPR POS Sale";
        NpRvModuleSendDefault: Codeunit "NPR NpRv Module Send: Def.";
        POSSale: Codeunit "NPR POS Sale";
        Email: Text;
        PhoneNo: Text;
        VoucherTypeCode: Text;
        Selection: Integer;
    begin
        VoucherTypeCode := CopyStr(UpperCase(JSON.GetStringOrFail('VoucherTypeCode', StrSubstNo(ReadingErr, ActionCode()))), 1, MaxStrLen(VoucherType.Code));
        VoucherType.Get(VoucherTypeCode);

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        if SalePOS."Customer No." <> '' then begin
            if Customer.Get(SalePOS."Customer No.") then begin
                Email := Customer."E-Mail";
                PhoneNo := Customer."Phone No.";
            end;
        end;
        JSON.SetContext('SendToEmail', Email);
        JSON.SetContext('SendToPhoneNo', PhoneNo);

        Selection := NpRvModuleSendDefault.SelectSendMethod(VoucherType);
        JSON.SetContext('SendMethodPrint', Selection = VoucherType."Send Method via POS"::Print);
        JSON.SetContext('SendMethodEmail', Selection = VoucherType."Send Method via POS"::"E-mail");
        JSON.SetContext('SendMethodSMS', Selection = VoucherType."Send Method via POS"::SMS);
        FrontEnd.SetActionContext(ActionCode(), JSON);
    end;

    procedure ActionCode(): Code[20]
    begin
        exit('ISSUE_RETURN_VOUCHER');
    end;

    local procedure ActionVersion(): Code[20]
    begin
        exit('1.1');
    end;
}
