codeunit 6151016 "NpRv Return POS Action Mgt."
{
    // NPR5.37/MHA /20171023  CASE 267346 Object created - NaviPartner Retail Voucher
    // NPR5.48/TSA /20190211  CASE 345467 UpdateAmounts() is required to get VAT calculations correct
    // NPR5.48/MHA /20190213  CASE 342920 Return Amount should not be rounded and it should consider Min. Amount on Payment Type and also End Sale with balancing
    // NPR5.49/MHA /20190306  CASE 342920 ScanReferenceNos parameter added
    // NPR5.50/ALST/20190521  CASE 352073 implemented selection method for printing
    // NPR5.51/MHA /20190819  CASE 364542 Added function ValidateAmt() for validating Minimum Amount


    trigger OnRun()
    begin
    end;

    var
        Text000: Label 'This action Issues Return Retail Vouchers.';
        Text001: Label 'Select Voucher Type:';
        Text002: Label 'Issue Return Retail Voucher';
        Text003: Label 'Enter Amount:';
        Text004: Label 'Maximum Return Amount is: %1';
        Text005: Label 'Nothing to return';
        Text006: Label 'Invalid Amount: %1\\Min. amount is %2';
        Text007: Label 'Minimum Amount is %1';

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', true, true)]
    local procedure OnDiscoverActions(var Sender: Record "POS Action")
    var
        FunctionOptionString: Text;
        JSArr: Text;
        OptionName: Text;
        N: Integer;
    begin
        DiscoverIssueReturnVoucherAction(Sender);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150702, 'OnInitializeCaptions', '', true, true)]
    local procedure OnInitializeCaptions(Captions: Codeunit "POS Caption Management")
    begin
        InitializeIssueReturnVoucherCaptions(Captions);
    end;

    local procedure DiscoverIssueReturnVoucherAction(var Sender: Record "POS Action")
    var
        NpRvVoucher: Record "NpRv Voucher";
    begin
        if not Sender.DiscoverAction(
          ActionCode(),
          Text000,
          ActionVersion(),
          Sender.Type::Generic,
          Sender."Subscriber Instances Allowed"::Multiple) then
         exit;

        Sender.RegisterWorkflowStep('voucher_type_input','if (!param.VoucherTypeCode) {respond()} else {context.VoucherTypeCode = param.VoucherTypeCode}');
        Sender.RegisterWorkflowStep('amt_input','{numpad({title: labels.IssueReturnVoucherTitle,caption: labels.Amount,value: context.voucher_amount,notBlank: true}).cancel(abort)};');
        //-NPR5.51 [364542]
        Sender.RegisterWorkflowStep('validate_amt','respond();');
        //+NPR5.51 [364542]
        //-NPR5.50
        Sender.RegisterWorkflowStep('select_send_method','respond();');
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
        //+NPR5.50
        Sender.RegisterWorkflowStep ('issue_return_voucher','respond ();');
        Sender.RegisterWorkflowStep('contact_info','if(param.ContactInfo) {respond()}');
        //-NPR5.49 [342920]
        Sender.RegisterWorkflowStep('scan_reference_nos','if(param.ScanReferenceNos) {respond()}');
        //+NPR5.49 [342920]
        Sender.RegisterWorkflowStep('end_sale','if(param.EndSale) {respond()};');
        Sender.RegisterWorkflow(true);

        Sender.RegisterTextParameter('VoucherTypeCode','');
        Sender.RegisterBooleanParameter('ContactInfo',false);
        //-NPR5.49 [342920]
        Sender.RegisterBooleanParameter('ScanReferenceNos',false);
        //+NPR5.49 [342920]
        Sender.RegisterBooleanParameter('EndSale',true);
    end;

    local procedure InitializeIssueReturnVoucherCaptions(var Captions: Codeunit "POS Caption Management")
    begin
        Captions.AddActionCaption(ActionCode(),'IssueReturnVoucherPrompt',Text001);
        Captions.AddActionCaption(ActionCode(),'IssueReturnVoucherTitle',Text002);
        Captions.AddActionCaption(ActionCode(),'Amount',Text003);
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnLookupValue', '', true, true)]
    local procedure OnLookupVoucherTypeCode(var POSParameterValue: Record "POS Parameter Value";Handled: Boolean)
    var
        NpRvVoucherType: Record "NpRv Voucher Type";
    begin
        //-NPR5.49 [342920]
        if POSParameterValue."Action Code" <> ActionCode() then
          exit;
        if POSParameterValue.Name <> 'VoucherTypeCode' then
          exit;
        if POSParameterValue."Data Type" <> POSParameterValue."Data Type"::Text then
          exit;

        Handled := true;

        if PAGE.RunModal(0,NpRvVoucherType) = ACTION::LookupOK then
          POSParameterValue.Value := NpRvVoucherType.Code;
        //+342920 [342920]
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnValidateValue', '', true, true)]
    local procedure OnValidateVoucherTypeCode(var POSParameterValue: Record "POS Parameter Value")
    var
        NpRvVoucherType: Record "NpRv Voucher Type";
    begin
        //-342920 [342920]
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
          NpRvVoucherType.SetFilter(Code,'%1',POSParameterValue.Value + '*');
          if NpRvVoucherType.FindFirst then
            POSParameterValue.Value := NpRvVoucherType.Code;
        end;

        NpRvVoucherType.Get(POSParameterValue.Value);
        //+NPR5.49 [342920]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnBeforeWorkflow', '', true, true)]
    local procedure OnBeforeWorkflow("Action": Record "POS Action";Parameters: DotNet npNetJObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    var
        NpRvVoucherType: Record "NpRv Voucher Type";
        PaymentTypePOS: Record "Payment Type POS";
        Context: Codeunit "POS JSON Management";
        POSPaymentLine: Codeunit "POS Payment Line";
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
        POSPaymentLine.CalculateBalance(SaleAmount,PaidAmount,ReturnAmount,SubTotal);
        //-NPR5.48 [342920]
        ReturnAmount := SaleAmount - PaidAmount;

        Context.InitializeJObjectParser(Parameters,FrontEnd);
        VoucherTypeCode := Context.GetString('VoucherTypeCode',false);
        NpRvVoucherType.Get(VoucherTypeCode);
        PaymentTypePOS.Get(NpRvVoucherType."Payment Type");
        if PaymentTypePOS."Rounding Precision" > 0 then
          ReturnAmount := Round(SaleAmount - PaidAmount,PaymentTypePOS."Rounding Precision");

        //-NPR5.51 [364542]
        if (PaymentTypePOS."Minimum Amount" > 0) and (Abs(ReturnAmount) < Abs(PaymentTypePOS."Minimum Amount")) then
          Error(Text007,PaymentTypePOS."Minimum Amount");
        //+NPR5.51 [364542]
        //+NPR5.48 [342920]
        if ReturnAmount >= 0 then
          Error(Text005);

        Context.SetContext('voucher_amount',-ReturnAmount);
        FrontEnd.SetActionContext(ActionCode(),Context);
    end;

    local procedure "--- POS Action"()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', true, true)]
    local procedure OnAction("Action": Record "POS Action";WorkflowStep: Text;Context: DotNet npNetJObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    var
        JSON: Codeunit "POS JSON Management";
    begin
        if Handled then
          exit;

        if not Action.IsThisAction(ActionCode()) then
          exit;
        Handled := true;

        JSON.InitializeJObjectParser(Context,FrontEnd);
        case WorkflowStep of
          'voucher_type_input':
            VoucherTypeInput(JSON,FrontEnd);
          //-NPR5.51 [364542]
          'validate_amt':
            ValidateAmt(JSON,FrontEnd);
          //+NPR5.51 [364542]
          //-NPR5.50
          'select_send_method':
            SelectSendMethod(JSON,POSSession,FrontEnd);
          //+NPR5.50
          'issue_return_voucher':
            IssueReturnVoucher(JSON,POSSession);
          'contact_info':
            ContactInfo(JSON,POSSession);
          //-NPR5.49 [342920]
          'scan_reference_nos':
            ScanReferenceNos(POSSession);
          //+NPR5.49 [342920]
          'end_sale':
            //+NPR5.48 [342920]
            EndSale(JSON,POSSession);
            //-NPR5.48 [342920]
        end;
    end;

    local procedure ContactInfo(JSON: Codeunit "POS JSON Management";POSSession: Codeunit "POS Session")
    var
        SaleLinePOSVoucher: Record "NpRv Sale Line POS Voucher";
        SaleLinePOS: Record "Sale Line POS";
        POSSaleLine: Codeunit "POS Sale Line";
    begin
        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        SaleLinePOSVoucher.SetRange("Register No.",SaleLinePOS."Register No.");
        SaleLinePOSVoucher.SetRange("Sales Ticket No.",SaleLinePOS."Sales Ticket No.");
        SaleLinePOSVoucher.SetRange("Sale Type",SaleLinePOS."Sale Type");
        SaleLinePOSVoucher.SetRange("Sale Date",SaleLinePOS.Date);
        SaleLinePOSVoucher.SetRange("Sale Line No.",SaleLinePOS."Line No.");
        if not SaleLinePOSVoucher.FindSet then
          exit;

        repeat
          PAGE.RunModal(PAGE::"NpRv POS Issue Voucher Card",SaleLinePOSVoucher);
          Commit;
        until SaleLinePOSVoucher.Next = 0;
    end;

    local procedure ScanReferenceNos(POSSession: Codeunit "POS Session")
    var
        SaleLinePOS: Record "Sale Line POS";
        SaleLinePOSVoucher: Record "NpRv Sale Line POS Voucher";
        SaleLinePOSReference: Record "NpRv Sale Line POS Reference";
        POSSaleLine: Codeunit "POS Sale Line";
        NpRvPOSIssueVoucherRefs: Page "NpRv POS Issue Voucher Refs.";
    begin
        //-NPR5.49 [342920]
        if not GuiAllowed then
          exit;
        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        SaleLinePOSVoucher.SetRange("Register No.",SaleLinePOS."Register No.");
        SaleLinePOSVoucher.SetRange("Sales Ticket No.",SaleLinePOS."Sales Ticket No.");
        SaleLinePOSVoucher.SetRange("Sale Type",SaleLinePOS."Sale Type");
        SaleLinePOSVoucher.SetRange("Sale Date",SaleLinePOS.Date);
        SaleLinePOSVoucher.SetRange("Sale Line No.",SaleLinePOS."Line No.");
        SaleLinePOSVoucher.SetRange(Type,SaleLinePOSVoucher.Type::"New Voucher");
        if not SaleLinePOSVoucher.FindFirst then
          exit;

        NpRvPOSIssueVoucherRefs.SetSaleLinePOSVoucher(SaleLinePOSVoucher,SaleLinePOS.Quantity);
        NpRvPOSIssueVoucherRefs.RunModal;
        //+NPR5.49 [342920]
    end;

    local procedure EndSale(JSON: Codeunit "POS JSON Management";POSSession: Codeunit "POS Session")
    var
        NpRvVoucherType: Record "NpRv Voucher Type";
        PaymentTypePOS: Record "Payment Type POS";
        ReturnPaymentTypePOS: Record "Payment Type POS";
        Register: Record Register;
        POSPaymentLine: Codeunit "POS Payment Line";
        POSSetup: Codeunit "POS Setup";
        POSSale: Codeunit "POS Sale";
        PaidAmount: Decimal;
        ReturnAmount: Decimal;
        SaleAmount: Decimal;
        Subtotal: Decimal;
        VoucherTypeCode: Text;
    begin
        POSSession.GetPaymentLine(POSPaymentLine);
        POSPaymentLine.CalculateBalance(SaleAmount,PaidAmount,ReturnAmount,Subtotal);

        //-NPR5.48 [342920]
        POSSession.GetSetup(POSSetup);
        POSSetup.GetRegisterRecord(Register);
        if Abs(Subtotal) >= Abs(POSSetup.AmountRoundingPrecision()) then
          exit;

        JSON.SetScope('parameters',true);
        VoucherTypeCode := UpperCase(JSON.GetString('VoucherTypeCode',true));
        NpRvVoucherType.Get(VoucherTypeCode);
        if not POSPaymentLine.GetPaymentType(PaymentTypePOS,NpRvVoucherType."Payment Type",Register."Register No.") then
          exit;
        if not POSPaymentLine.GetPaymentType(ReturnPaymentTypePOS,Register."Return Payment Type",Register."Register No.") then
          exit;
        //-NPR5.51 [364542]
        if POSPaymentLine.CalculateRemainingPaymentSuggestion(SaleAmount,PaidAmount,PaymentTypePOS,ReturnPaymentTypePOS) <> 0 then
          exit;
        //+NPR5.51 [364542]

        POSSession.GetSale(POSSale);
        if not POSSale.TryEndSaleWithBalancing(POSSession,PaymentTypePOS,ReturnPaymentTypePOS) then
          exit;
        //+NPR5.48 [342920]
    end;

    local procedure IssueReturnVoucher(JSON: Codeunit "POS JSON Management";POSSession: Codeunit "POS Session")
    var
        SaleLinePOSVoucher: Record "NpRv Sale Line POS Voucher";
        VoucherType: Record "NpRv Voucher Type";
        SaleLinePOS: Record "Sale Line POS";
        PaymentTypePOS: Record "Payment Type POS";
        POSPaymentLine: Codeunit "POS Payment Line";
        POSSaleLine: Codeunit "POS Sale Line";
        VoucherTypeCode: Text;
        DiscountType: Text;
        Amount: Decimal;
        PaidAmount: Decimal;
        ReturnAmount: Decimal;
        SaleAmount: Decimal;
        SubTotal: Decimal;
    begin
        JSON.SetScope('/',true);
        //-NPR5.51 [364542]
        Amount := JSON.GetDecimal('ReturnVoucherAmount',true);
        //+NPR5.51 [364542]
        if Amount = 0 then
          exit;

        POSSession.GetPaymentLine(POSPaymentLine);
        POSPaymentLine.CalculateBalance(SaleAmount,PaidAmount,ReturnAmount,SubTotal);

        JSON.SetScope('/',true);
        VoucherTypeCode := UpperCase(JSON.GetString('VoucherTypeCode',true));
        VoucherType.Get(VoucherTypeCode);

        //-NPR5.51 [364542]
        ReturnAmount := PaidAmount - SaleAmount;
        PaymentTypePOS.Get(VoucherType."Payment Type");
        if PaymentTypePOS."Rounding Precision" > 0 then
          ReturnAmount := Round(ReturnAmount,PaymentTypePOS."Rounding Precision");

        if Amount > ReturnAmount then
          Error(Text004,ReturnAmount);

        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetNewSaleLine(SaleLinePOS);
        SaleLinePOS.Validate("Sale Type",SaleLinePOS."Sale Type"::Payment);
        SaleLinePOS.Validate(Type,SaleLinePOS.Type::Payment);
        SaleLinePOS.Validate("No.",VoucherType."Payment Type");
        SaleLinePOS.Description := VoucherType.Description;
        SaleLinePOS.Quantity := 0;
        SaleLinePOS."Unit Price" := 0;
        SaleLinePOS."Amount Including VAT" := -Amount;
        POSPaymentLine.InsertPaymentLine(SaleLinePOS,0);
        POSPaymentLine.GetCurrentPaymentLine(SaleLinePOS);
        SaleLinePOS.Quantity := 1;
        //+NPR5.51 [364542]
        //+NPR5.49 [342920]

        //-NPR5.48 [345467]
        POSSession.RequestRefreshData();

        SaleLinePOSVoucher.Init;
        SaleLinePOSVoucher."Register No." := SaleLinePOS."Register No.";
        SaleLinePOSVoucher."Sales Ticket No." := SaleLinePOS."Sales Ticket No.";
        SaleLinePOSVoucher."Sale Type" := SaleLinePOS."Sale Type";
        SaleLinePOSVoucher."Sale Date" := SaleLinePOS.Date;
        SaleLinePOSVoucher."Sale Line No." := SaleLinePOS."Line No.";
        SaleLinePOSVoucher."Line No." := 10000;
        SaleLinePOSVoucher.Type := SaleLinePOSVoucher.Type::"New Voucher";
        SaleLinePOSVoucher."Voucher Type" := VoucherType.Code;
        SaleLinePOSVoucher.Description := VoucherType.Description;
        SaleLinePOSVoucher."Starting Date" := CurrentDateTime;
        //-NPR5.50
        JSON.SetScope('/',true);
        SaleLinePOSVoucher."Send via Print" := JSON.GetBoolean('SendMethodPrint',false);
        SaleLinePOSVoucher."Send via E-mail" := JSON.GetBoolean('SendMethodEmail',false);
        SaleLinePOSVoucher."Send via SMS" := JSON.GetBoolean('SendMethodSMS',false);
        if JSON.SetScope('$send_method_email',false) then
          SaleLinePOSVoucher."E-mail" := CopyStr(JSON.GetString('input',false),1,MaxStrLen(SaleLinePOSVoucher."E-mail"));
        JSON.SetScope('/',true);
        if JSON.SetScope('$send_method_sms',false) then
          SaleLinePOSVoucher."Phone No." := CopyStr(JSON.GetString('input',false),1,MaxStrLen(SaleLinePOSVoucher."Phone No."));
        //+NPR5.50
        SaleLinePOSVoucher.Insert;
    end;

    local procedure VoucherTypeInput(JSON: Codeunit "POS JSON Management";FrontEnd: Codeunit "POS Front End Management")
    var
        VoucherType: Record "NpRv Voucher Type";
        VoucherTypeCode: Text;
    begin
        if not SelectVoucherType(VoucherTypeCode) then
          Error('');

        JSON.SetScope('parameters',true);
        JSON.SetContext('VoucherTypeCode',VoucherTypeCode);
        FrontEnd.SetActionContext(ActionCode(),JSON);
    end;

    local procedure ValidateAmt(JSON: Codeunit "POS JSON Management";FrontEnd: Codeunit "POS Front End Management")
    var
        PaymentTypePOS: Record "Payment Type POS";
        VoucherType: Record "NpRv Voucher Type";
        VoucherTypeCode: Text;
        Amount: Decimal;
    begin
        //-NPR5.51 [364542]
        JSON.SetScope('/',true);
        VoucherTypeCode := UpperCase(JSON.GetString('VoucherTypeCode',true));
        VoucherType.Get(VoucherTypeCode);
        PaymentTypePOS.Get(VoucherType."Payment Type");

        JSON.SetScope('/',true);
        JSON.SetScope('$amt_input',true);
        Amount := JSON.GetDecimal('numpad',true);
        if PaymentTypePOS."Rounding Precision" > 0 then
          Amount := Round(Amount,PaymentTypePOS."Rounding Precision");

        if PaymentTypePOS."Minimum Amount" < 0 then
          PaymentTypePOS."Minimum Amount" := Abs(PaymentTypePOS."Minimum Amount");

        if Amount < PaymentTypePOS."Minimum Amount" then
          Error(Text006,Amount,PaymentTypePOS."Minimum Amount");

        JSON.SetContext('ReturnVoucherAmount',Amount);
        FrontEnd.SetActionContext(ActionCode(),JSON);
        //+NPR5.51 [364542]
    end;

    local procedure "--- Select"()
    begin
    end;

    local procedure SelectVoucherType(var VoucherTypeCode: Text): Boolean
    var
        VoucherType: Record "NpRv Voucher Type";
    begin
        VoucherTypeCode := '';
        if PAGE.RunModal(0,VoucherType) <>  ACTION::LookupOK then
          exit(false);

        VoucherTypeCode := VoucherType.Code;
        exit(true);
    end;

    local procedure SelectSendMethod(JSON: Codeunit "POS JSON Management";POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management")
    var
        Contact: Record Contact;
        Customer: Record Customer;
        VoucherType: Record "NpRv Voucher Type";
        SalePOS: Record "Sale POS";
        NpRvModuleSendDefault: Codeunit "NpRv Module Send - Default";
        POSSale: Codeunit "POS Sale";
        Email: Text;
        PhoneNo: Text;
        VoucherTypeCode: Text;
        Selection: Integer;
    begin
        //-NPR5.50
        VoucherTypeCode := CopyStr(UpperCase(JSON.GetString('VoucherTypeCode',true)),1,MaxStrLen(VoucherType.Code));
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
        JSON.SetContext('SendToEmail',Email);
        JSON.SetContext('SendToPhoneNo',PhoneNo);

        Selection := NpRvModuleSendDefault.SelectSendMethod(VoucherType);
        JSON.SetContext('SendMethodPrint',Selection = VoucherType."Send Method via POS"::Print);
        JSON.SetContext('SendMethodEmail',Selection = VoucherType."Send Method via POS"::"E-mail");
        JSON.SetContext('SendMethodSMS',Selection = VoucherType."Send Method via POS"::SMS);
        FrontEnd.SetActionContext(ActionCode(),JSON);
        //+NPR5.50
    end;

    local procedure "--- Constants"()
    begin
    end;

    procedure ActionCode(): Text
    begin
        exit('ISSUE_RETURN_VOUCHER');
    end;

    local procedure ActionVersion(): Text
    begin
        //-342920 [342920]
        exit('1.1');
        //+342920 [342920]
        exit('1.0');
    end;
}

