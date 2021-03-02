codeunit 6151016 "NPR NpRv Ret. POSAction Mgt."
{
    var
        Text000: Label 'This action Issues Return Retail Vouchers.';
        Text001: Label 'Select Voucher Type:';
        Text002: Label 'Issue Return Retail Voucher';
        Text003: Label 'Enter Amount:';
        Text004: Label 'Maximum Return Amount is: %1';
        Text005: Label 'Nothing to return';
        Text006: Label 'The amount of %1 is less that the Minimum Amount allowed (%2) to create a Voucher';
        Text007: Label 'Minimum Amount for %1 %2 is %3';
        ReadingErr: Label 'reading in %1';
        SettingScopeErr: Label 'setting scope in %1';

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', true, true)]
    local procedure OnDiscoverActions(var Sender: Record "NPR POS Action")
    var
        FunctionOptionString: Text;
        JSArr: Text;
        OptionName: Text;
        N: Integer;
    begin
        DiscoverIssueReturnVoucherAction(Sender);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150702, 'OnInitializeCaptions', '', true, true)]
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
        Sender.RegisterWorkflowStep('amt_input', '{numpad({title: labels.IssueReturnVoucherTitle,caption: labels.Amount,value: context.voucher_amount,notBlank: true}).cancel(abort)};');
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

    [EventSubscriber(ObjectType::Table, 6150705, 'OnLookupValue', '', true, true)]
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

    [EventSubscriber(ObjectType::Table, 6150705, 'OnValidateValue', '', true, true)]
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
            if NpRvVoucherType.FindFirst then
                POSParameterValue.Value := NpRvVoucherType.Code;
        end;

        NpRvVoucherType.Get(POSParameterValue.Value);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnBeforeWorkflow', '', true, true)]
    local procedure OnBeforeWorkflow("Action": Record "NPR POS Action"; Parameters: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        NpRvVoucherType: Record "NPR NpRv Voucher Type";
        POSPaymentMethod: Record "NPR POS Payment Method";
        Context: Codeunit "NPR POS JSON Management";
        POSPaymentLine: Codeunit "NPR POS Payment Line";
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
        VoucherTypeCode := Context.GetString('VoucherTypeCode');
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
        FrontEnd.SetActionContext(ActionCode(), Context);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', true, true)]
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
                ContactInfo(JSON, POSSession);
            'scan_reference_nos':
                ScanReferenceNos(POSSession);
            'end_sale':
                EndSale(JSON, POSSession);
        end;
    end;

    local procedure ContactInfo(JSON: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session")
    var
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        SaleLinePOS: Record "NPR Sale Line POS";
        POSPaymentLine: Codeunit "NPR POS Payment Line";
    begin
        POSSession.GetPaymentLine(POSPaymentLine);
        POSPaymentLine.GetCurrentPaymentLine(SaleLinePOS);

        NpRvSalesLine.SetRange("Register No.", SaleLinePOS."Register No.");
        NpRvSalesLine.SetRange("Sales Ticket No.", SaleLinePOS."Sales Ticket No.");
        NpRvSalesLine.SetRange("Sale Type", SaleLinePOS."Sale Type");
        NpRvSalesLine.SetRange("Sale Date", SaleLinePOS.Date);
        NpRvSalesLine.SetRange("Sale Line No.", SaleLinePOS."Line No.");
        if not NpRvSalesLine.FindSet then
            exit;

        repeat
            PAGE.RunModal(PAGE::"NPR NpRv Sales Line Card", NpRvSalesLine);
            Commit;
        until NpRvSalesLine.Next = 0;
    end;

    local procedure ScanReferenceNos(POSSession: Codeunit "NPR POS Session")
    var
        SaleLinePOS: Record "NPR Sale Line POS";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        NpRvSalesLineReference: Record "NPR NpRv Sales Line Ref.";
        POSPaymentLine: Codeunit "NPR POS Payment Line";
        NpRvPOSIssueVoucherRefs: Page "NPR NpRv Sales Line Ref.";
    begin
        if not GuiAllowed then
            exit;

        POSSession.GetPaymentLine(POSPaymentLine);
        POSPaymentLine.GetCurrentPaymentLine(SaleLinePOS);

        NpRvSalesLine.SetRange("Retail ID", SaleLinePOS."Retail ID");
        NpRvSalesLine.SetRange(Type, NpRvSalesLine.Type::"New Voucher");
        if not NpRvSalesLine.FindFirst then
            exit;

        NpRvPOSIssueVoucherRefs.SetNpRvSalesLine(NpRvSalesLine, SaleLinePOS.Quantity);
        NpRvPOSIssueVoucherRefs.RunModal;
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
        if not POSSale.TryEndSaleWithBalancing(POSSession, POSPaymentMethod, ReturnPOSPaymentMethod) then
            exit;
    end;

    local procedure IssueReturnVoucher(JSON: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session")
    var
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        VoucherType: Record "NPR NpRv Voucher Type";
        SalePOS: Record "NPR Sale POS";
        SaleLinePOS: Record "NPR Sale Line POS";
        NpRvSalesLineReference: Record "NPR NpRv Sales Line Ref.";
        POSPaymentMethod: Record "NPR POS Payment Method";
        TempVoucher: Record "NPR NpRv Voucher" temporary;
        NpRvVoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
        POSPaymentLine: Codeunit "NPR POS Payment Line";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        VoucherTypeCode: Text;
        DiscountType: Text;
        Amount: Decimal;
        PaidAmount: Decimal;
        ReturnAmount: Decimal;
        SaleAmount: Decimal;
        SubTotal: Decimal;
    begin
        JSON.SetScopeRoot();
        Amount := JSON.GetDecimalOrFail('ReturnVoucherAmount', StrSubstNo(ReadingErr, ActionCode()));
        if Amount = 0 then
            exit;

        POSSession.GetPaymentLine(POSPaymentLine);
        POSPaymentLine.CalculateBalance(SaleAmount, PaidAmount, ReturnAmount, SubTotal);

        JSON.SetScopeRoot();
        VoucherTypeCode := UpperCase(JSON.GetStringOrFail('VoucherTypeCode', StrSubstNo(ReadingErr, ActionCode())));
        VoucherType.Get(VoucherTypeCode);

        ReturnAmount := PaidAmount - SaleAmount;
        POSPaymentMethod.Get(VoucherType."Payment Type");
        if POSPaymentMethod."Rounding Precision" > 0 then
            ReturnAmount := Round(ReturnAmount, POSPaymentMethod."Rounding Precision");

        if Amount > ReturnAmount then
            Error(Text004, ReturnAmount);

        NpRvVoucherMgt.GenerateTempVoucher(VoucherType, TempVoucher);

        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetNewSaleLine(SaleLinePOS);
        SaleLinePOS.Validate("Sale Type", SaleLinePOS."Sale Type"::Payment);
        SaleLinePOS.Validate(Type, SaleLinePOS.Type::Payment);
        SaleLinePOS.Validate("No.", VoucherType."Payment Type");
        SaleLinePOS.Description := VoucherType.Description;
        SaleLinePOS.Quantity := 0;
        SaleLinePOS."Unit Price" := 0;
        SaleLinePOS."Amount Including VAT" := -Amount;
        POSPaymentLine.InsertPaymentLine(SaleLinePOS, 0);
        POSPaymentLine.GetCurrentPaymentLine(SaleLinePOS);
        SaleLinePOS.Quantity := 1;
        SaleLinePOS.Description := TempVoucher.Description;
        SaleLinePOS.Modify;

        POSSession.RequestRefreshData();

        NpRvSalesLine.Init;
        NpRvSalesLine.Id := CreateGuid;
        NpRvSalesLine."Document Source" := NpRvSalesLine."Document Source"::POS;
        NpRvSalesLine."Retail ID" := SaleLinePOS."Retail ID";
        NpRvSalesLine."Register No." := SaleLinePOS."Register No.";
        NpRvSalesLine."Sales Ticket No." := SaleLinePOS."Sales Ticket No.";
        NpRvSalesLine."Sale Type" := SaleLinePOS."Sale Type";
        NpRvSalesLine."Sale Date" := SaleLinePOS.Date;
        NpRvSalesLine."Sale Line No." := SaleLinePOS."Line No.";
        NpRvSalesLine.Type := NpRvSalesLine.Type::"New Voucher";
        NpRvSalesLine."Voucher Type" := VoucherType.Code;
        NpRvSalesLine."Starting Date" := CurrentDateTime;
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        case SalePOS."Customer Type" of
            SalePOS."Customer Type"::Ord:
                begin
                    NpRvSalesLine.Validate("Customer No.", SalePOS."Customer No.");
                end;
            SalePOS."Customer Type"::Cash:
                begin
                    NpRvSalesLine.Validate("Contact No.", SalePOS."Customer No.");
                end;
        end;
        JSON.SetScopeRoot();
        NpRvSalesLine."Send via Print" := JSON.GetBoolean('SendMethodPrint');
        NpRvSalesLine."Send via E-mail" := JSON.GetBoolean('SendMethodEmail');
        NpRvSalesLine."Send via SMS" := JSON.GetBoolean('SendMethodSMS');
        if JSON.SetScope('$send_method_email') then
            NpRvSalesLine."E-mail" := CopyStr(JSON.GetString('input'), 1, MaxStrLen(NpRvSalesLine."E-mail"));
        JSON.SetScopeRoot();
        if JSON.SetScope('$send_method_sms') then
            NpRvSalesLine."Phone No." := CopyStr(JSON.GetString('input'), 1, MaxStrLen(NpRvSalesLine."Phone No."));
        NpRvSalesLine."Voucher No." := TempVoucher."No.";
        NpRvSalesLine."Reference No." := TempVoucher."Reference No.";
        NpRvSalesLine.Description := TempVoucher.Description;
        NpRvSalesLine.Insert;

        NpRvVoucherMgt.SetSalesLineReferenceFilter(NpRvSalesLine, NpRvSalesLineReference);
        if NpRvSalesLineReference.IsEmpty then begin
            NpRvSalesLineReference.Init;
            NpRvSalesLineReference.Id := CreateGuid;
            NpRvSalesLineReference."Voucher No." := TempVoucher."No.";
            NpRvSalesLineReference."Reference No." := TempVoucher."Reference No.";
            NpRvSalesLineReference."Sales Line Id" := NpRvSalesLine.Id;
            NpRvSalesLineReference.Insert;

            SaleLinePOS.Description := TempVoucher.Description;
            SaleLinePOS.Modify;
        end;

        POSSession.RequestRefreshData();
    end;

    local procedure VoucherTypeInput(JSON: Codeunit "NPR POS JSON Management"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        VoucherType: Record "NPR NpRv Voucher Type";
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
    begin
        JSON.SetScopeRoot();
        VoucherTypeCode := UpperCase(JSON.GetStringOrFail('VoucherTypeCode', StrSubstNo(ReadingErr, ActionCode())));
        VoucherType.Get(VoucherTypeCode);
        POSPaymentMethod.Get(VoucherType."Payment Type");

        JSON.SetScopeRoot();
        JSON.SetScope('$amt_input', StrSubstNo(SettingScopeErr, ActionCode()));
        Amount := JSON.GetDecimalOrFail('numpad', StrSubstNo(ReadingErr, ActionCode()));
        if POSPaymentMethod."Rounding Precision" > 0 then
            Amount := Round(Amount, POSPaymentMethod."Rounding Precision");

        if VoucherType."Minimum Amount Issue" < 0 then
            VoucherType."Minimum Amount Issue" := 0;
        if Amount < VoucherType."Minimum Amount Issue" then
            Error(Text006, Amount, VoucherType."Minimum Amount Issue");

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
        Contact: Record Contact;
        Customer: Record Customer;
        VoucherType: Record "NPR NpRv Voucher Type";
        SalePOS: Record "NPR Sale POS";
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
            case SalePOS."Customer Type" of
                SalePOS."Customer Type"::Ord:
                    begin
                        if Customer.Get(SalePOS."Customer No.") then begin
                            Email := Customer."E-Mail";
                            PhoneNo := Customer."Phone No.";
                        end;
                    end;
                SalePOS."Customer Type"::Cash:
                    begin
                        if Contact.Get(SalePOS."Customer No.") then begin
                            Email := Contact."E-Mail";
                            PhoneNo := Contact."Mobile Phone No.";
                            if PhoneNo = '' then
                                PhoneNo := Contact."Phone No.";
                        end;
                    end;
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

    procedure ActionCode(): Text
    begin
        exit('ISSUE_RETURN_VOUCHER');
    end;

    local procedure ActionVersion(): Text
    begin
        exit('1.1');
    end;
}
