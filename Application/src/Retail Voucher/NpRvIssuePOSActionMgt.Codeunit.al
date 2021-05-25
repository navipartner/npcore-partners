codeunit 6151012 "NPR NpRv Issue POSAction Mgt."
{
    var
        Text000: Label 'This action Issues Retail Vouchers.';
        Text001: Label 'Select Voucher Type';
        Text002: Label 'Issue Retail Vouchers';
        Text003: Label 'Enter Quantity';
        Text004: Label 'Enter Amount';
        Text005: Label 'Enter Discount Amount';
        Text006: Label 'Enter Discount Percent';
        QtyNotPositiveErr: Label 'You must specify a positive quantity.';
        ConfirmReenterQtyMsg: Label '\Do you want to re-enter the quantity?';
        ReadingErr: Label 'reading in %1 of %2';
        SettingScopeErr: Label 'setting scope in %1';

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', true, true)]
    local procedure OnDiscoverActions(var Sender: Record "NPR POS Action")
    begin
        DiscoverIssueVoucherAction(Sender);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150702, 'OnInitializeCaptions', '', true, true)]
    local procedure OnInitializeCaptions(Captions: Codeunit "NPR POS Caption Management")
    begin
        InitializeIssueVoucherCaptions(Captions);
    end;

    local procedure DiscoverIssueVoucherAction(var Sender: Record "NPR POS Action")
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
    begin
        if not Sender.DiscoverAction(
          IssueVoucherActionCode(),
          Text000,
          IssueVoucherActionVersion(),
          Sender.Type::Generic,
          Sender."Subscriber Instances Allowed"::Multiple) then
            exit;

        Sender.RegisterWorkflowStep('voucher_type_input', 'if (!param.VoucherTypeCode) {respond()} else {context.VoucherTypeCode = param.VoucherTypeCode}');
        Sender.RegisterWorkflowStep('qty_input', 'if(param.Quantity <= 0) {intpad({title: labels.IssueVoucherTitle,caption: labels.Quantity,value: 1,notBlank: true}).cancel(abort)} ' +
                                                'else {context.$qty_input = {"numpad": param.Quantity}};');
        Sender.RegisterWorkflowStep('check_qty', 'respond();');
        Sender.RegisterWorkflowStep('amt_input', 'if(param.Amount <= 0) {numpad({title: labels.IssueVoucherTitle,caption: labels.Amount,value: 0,notBlank: true}).cancel(abort)} ' +
                                                'else {context.$amt_input = {"numpad": param.Amount}};');
        Sender.RegisterWorkflowStep('discount_input',
          'switch(param.DiscountType + "") {' +
          '  case "0":' +
          '    if(param.DiscountAmount <= 0) {numpad({title: labels.IssueVoucherTitle,caption: labels.DiscountAmount,value: 0}).cancel(abort)} ' +
          '    else {context.$discount_input = {"numpad": param.DiscountAmount}};' +
          '    break;' +
          '  case "1":' +
          '    if(param.DiscountAmount <= 0) {numpad({title: labels.IssueVoucherTitle,caption: labels.DiscountPercent,value: 0}).cancel(abort)}' +
          '    else {context.$discount_input = {"numpad": param.DiscountAmount}};' +
          '    break;' +
          '  default:' +
          '    goto("select_send_method");' +
          '}');
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
        Sender.RegisterWorkflowStep('issue_voucher', 'respond ();');
        Sender.RegisterWorkflowStep('contact_info', 'if(param.ContactInfo) {respond()}');
        Sender.RegisterWorkflowStep('scan_reference_nos', 'if(param.ScanReferenceNos) {respond()}');
        Sender.RegisterWorkflow(false);

        Sender.RegisterTextParameter('VoucherTypeCode', '');
        Sender.RegisterIntegerParameter('Quantity', 0);
        Sender.RegisterDecimalParameter('Amount', 0);
        Sender.RegisterOptionParameter('DiscountType', 'Amount,Percent,None', 'Amount');
        Sender.RegisterDecimalParameter('DiscountAmount', 0);
        Sender.RegisterBooleanParameter('ContactInfo', true);
        Sender.RegisterBooleanParameter('ScanReferenceNos', false);
    end;

    local procedure InitializeIssueVoucherCaptions(var Captions: Codeunit "NPR POS Caption Management")
    begin
        Captions.AddActionCaption(IssueVoucherActionCode(), 'IssueVoucherPrompt', Text001);
        Captions.AddActionCaption(IssueVoucherActionCode(), 'IssueVoucherTitle', Text002);
        Captions.AddActionCaption(IssueVoucherActionCode(), 'Quantity', Text003);
        Captions.AddActionCaption(IssueVoucherActionCode(), 'Amount', Text004);
        Captions.AddActionCaption(IssueVoucherActionCode(), 'DiscountAmount', Text005);
        Captions.AddActionCaption(IssueVoucherActionCode(), 'DiscountPercent', Text006);
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnLookupValue', '', true, true)]
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

        if PAGE.RunModal(0, NpRvVoucherType) = ACTION::LookupOK then
            POSParameterValue.Value := NpRvVoucherType.Code;
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnValidateValue', '', true, true)]
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

    [EventSubscriber(ObjectType::Codeunit, 6150706, 'OnBeforeSetQuantity', '', true, true)]
    local procedure OnBeforeSetQuantity(var Sender: Codeunit "NPR POS Sale Line"; SaleLinePOS: Record "NPR POS Sale Line"; var NewQuantity: Decimal)
    begin
        ScanReferenceNos(SaleLinePOS, NewQuantity);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', true, true)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        JSON: Codeunit "NPR POS JSON Management";
    begin
        if Handled then
            exit;

        if not Action.IsThisAction(IssueVoucherActionCode()) then
            exit;
        Handled := true;

        JSON.InitializeJObjectParser(Context, FrontEnd);
        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        case WorkflowStep of
            'check_qty':
                CheckQty(JSON, FrontEnd);
            'voucher_type_input':
                VoucherTypeInput(JSON, FrontEnd);
            'select_send_method':
                SelectSendMethod(JSON, POSSession, FrontEnd);
            'issue_voucher':
                IssueVoucher(JSON, POSSession);
            'contact_info':
                ContactInfo(SaleLinePOS);
            'scan_reference_nos':
                ScanReferenceNos(SaleLinePOS, SaleLinePOS.Quantity);
        end;
    end;

    local procedure ContactInfo(SaleLinePOS: Record "NPR POS Sale Line")
    var
        NpRvSalesLine: Record "NPR NpRv Sales Line";
    begin
        NpRvSalesLine.SetRange("Register No.", SaleLinePOS."Register No.");
        NpRvSalesLine.SetRange("Sales Ticket No.", SaleLinePOS."Sales Ticket No.");
        NpRvSalesLine.SetRange("Sale Type", SaleLinePOS."Sale Type");
        NpRvSalesLine.SetRange("Sale Date", SaleLinePOS.Date);
        NpRvSalesLine.SetRange("Sale Line No.", SaleLinePOS."Line No.");
        if not NpRvSalesLine.FindSet() then
            exit;

        repeat
            PAGE.RunModal(PAGE::"NPR NpRv Sales Line Card", NpRvSalesLine);
            Commit();
        until NpRvSalesLine.Next() = 0;
    end;

    local procedure IssueVoucher(JSON: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session")
    var
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        NpRvSalesLineReference: Record "NPR NpRv Sales Line Ref.";
        VoucherType: Record "NPR NpRv Voucher Type";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        TempVoucher: Record "NPR NpRv Voucher" temporary;
        NpRvVoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        VoucherTypeCode: Text;
        DiscountType: Text;
    begin
        VoucherTypeCode := UpperCase(JSON.GetStringOrFail('VoucherTypeCode', StrSubstNo(ReadingErr, 'IssueVoucher', IssueVoucherActionCode())));
        VoucherType.Get(VoucherTypeCode);

        NpRvVoucherMgt.GenerateTempVoucher(VoucherType, TempVoucher);

        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetNewSaleLine(SaleLinePOS);
        SaleLinePOS.Validate("Sale Type", SaleLinePOS."Sale Type"::Deposit);
        SaleLinePOS.Validate(Type, SaleLinePOS.Type::"G/L Entry");
        SaleLinePOS.Validate("No.", VoucherType."Account No.");
        SaleLinePOS.Description := VoucherType.Description;
        JSON.SetScopeRoot();
        JSON.SetScope('$qty_input', StrSubstNo(SettingScopeErr, IssueVoucherActionCode()));
        SaleLinePOS.Quantity := JSON.GetIntegerOrFail('numpad', StrSubstNo(ReadingErr, 'IssueVoucher', IssueVoucherActionCode()));
        if SaleLinePOS.Quantity < 0 then
            Error(QtyNotPositiveErr);

        POSSaleLine.InsertLine(SaleLinePOS);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        JSON.SetScopeRoot();
        JSON.SetScope('$amt_input', StrSubstNo(SettingScopeErr, IssueVoucherActionCode()));
        SaleLinePOS."Unit Price" := JSON.GetDecimalOrFail('numpad', StrSubstNo(ReadingErr, 'IssueVoucher', IssueVoucherActionCode()));

        JSON.SetScopeRoot();
        JSON.SetScopeParameters(IssueVoucherActionCode());
        DiscountType := JSON.GetStringOrFail('DiscountType', StrSubstNo(ReadingErr, 'IssueVoucher', IssueVoucherActionCode()));
        case DiscountType of
            '0':
                begin
                    JSON.SetScopeRoot();
                    JSON.SetScope('$discount_input', StrSubstNo(SettingScopeErr, IssueVoucherActionCode()));
                    SaleLinePOS."Discount Amount" := JSON.GetDecimalOrFail('numpad', StrSubstNo(ReadingErr, 'IssueVoucher', IssueVoucherActionCode())) * SaleLinePOS.Quantity;
                end;
            '1':
                begin
                    JSON.SetScopeRoot();
                    JSON.SetScope('$discount_input', StrSubstNo(SettingScopeErr, IssueVoucherActionCode()));
                    SaleLinePOS."Discount %" := JSON.GetDecimalOrFail('numpad', StrSubstNo(ReadingErr, 'IssueVoucher', IssueVoucherActionCode()));
                end;
        end;
        SaleLinePOS.UpdateAmounts(SaleLinePOS);
        if SaleLinePOS."Discount Amount" > 0 then
            SaleLinePOS."Discount Type" := SaleLinePOS."Discount Type"::Manual;
        SaleLinePOS.Description := TempVoucher.Description;
        SaleLinePOS.Modify(true);
        POSSession.RequestRefreshData();

        NpRvSalesLine.Init();
        NpRvSalesLine.Id := CreateGuid();
        NpRvSalesLine."Document Source" := NpRvSalesLine."Document Source"::POS;
        NpRvSalesLine."Retail ID" := SaleLinePOS.SystemId;
        NpRvSalesLine."Register No." := SaleLinePOS."Register No.";
        NpRvSalesLine."Sales Ticket No." := SaleLinePOS."Sales Ticket No.";
        NpRvSalesLine."Sale Type" := SaleLinePOS."Sale Type";
        NpRvSalesLine."Sale Date" := SaleLinePOS.Date;
        NpRvSalesLine."Sale Line No." := SaleLinePOS."Line No.";
        NpRvSalesLine."Voucher No." := TempVoucher."No.";
        NpRvSalesLine."Reference No." := TempVoucher."Reference No.";
        NpRvSalesLine.Description := TempVoucher.Description;
        NpRvSalesLine.Type := NpRvSalesLine.Type::"New Voucher";
        NpRvSalesLine."Voucher Type" := VoucherType.Code;
        NpRvSalesLine.Description := VoucherType.Description;
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
        NpRvSalesLine.Insert();

        NpRvVoucherMgt.SetSalesLineReferenceFilter(NpRvSalesLine, NpRvSalesLineReference);
        if NpRvSalesLineReference.IsEmpty then begin
            NpRvSalesLineReference.Init();
            NpRvSalesLineReference.Id := CreateGuid();
            NpRvSalesLineReference."Voucher No." := TempVoucher."No.";
            NpRvSalesLineReference."Reference No." := TempVoucher."Reference No.";
            NpRvSalesLineReference."Sales Line Id" := NpRvSalesLine.Id;
            NpRvSalesLineReference.Insert(true);
        end;
        POSSession.RequestRefreshData();
    end;

    local procedure ScanReferenceNos(SaleLinePOS: Record "NPR POS Sale Line"; Quantity: Decimal)
    var
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        NpRvSalesLineReferences: Page "NPR NpRv Sales Line Ref.";
    begin
        if not GuiAllowed then
            exit;

        NpRvSalesLine.SetRange("Retail ID", SaleLinePOS.SystemId);
        NpRvSalesLine.SetRange(Type, NpRvSalesLine.Type::"New Voucher");
        if not NpRvSalesLine.FindFirst() then
            exit;

        NpRvSalesLineReferences.SetNpRvSalesLine(NpRvSalesLine, Quantity);
        NpRvSalesLineReferences.RunModal();
    end;

    local procedure SelectSendMethod(JSON: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        Contact: Record Contact;
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
        VoucherTypeCode := CopyStr(UpperCase(JSON.GetStringOrFail('VoucherTypeCode', StrSubstNo(ReadingErr, 'SelectSendMethod', IssueVoucherActionCode()))), 1, MaxStrLen(VoucherType.Code));
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
        FrontEnd.SetActionContext(IssueVoucherActionCode(), JSON);
    end;

    local procedure VoucherTypeInput(JSON: Codeunit "NPR POS JSON Management"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        VoucherTypeCode: Text;
    begin
        if not SelectVoucherType(VoucherTypeCode) then
            Error('');

        JSON.SetScopeParameters(IssueVoucherActionCode());
        JSON.SetContext('VoucherTypeCode', VoucherTypeCode);
        FrontEnd.SetActionContext(IssueVoucherActionCode(), JSON);
    end;

    local procedure CheckQty(JSON: Codeunit "NPR POS JSON Management"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        Qty: Decimal;
    begin
        JSON.SetScopeRoot();
        JSON.SetScope('$qty_input', StrSubstNo(SettingScopeErr, IssueVoucherActionCode()));
        Qty := JSON.GetIntegerOrFail('numpad', StrSubstNo(ReadingErr, 'CheckQty', IssueVoucherActionCode()));
        if Qty <= 0 then begin
            if Confirm(QtyNotPositiveErr + ConfirmReenterQtyMsg, true) then
                FrontEnd.ContinueAtStep('qty_input')
            else
                Error('');
        end;
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

    local procedure IssueVoucherActionCode(): Text
    begin
        exit('ISSUE_VOUCHER');
    end;

    local procedure IssueVoucherActionVersion(): Text
    begin
        exit('1.1');
    end;
}

