codeunit 6151012 "NpRv Issue POS Action Mgt."
{
    // NPR5.37/MHA /20171023  CASE 267346 Object created - NaviPartner Retail Voucher
    // NPR5.48/MHA /20190123  CASE 341711 Added Send methods E-mail and SMS
    // NPR5.49/MHA /20190228  CASE 342811 Added functions OnLookupVoucherTypeCode(), OnValidateVoucherTypeCode()
    // NPR5.52/ALPO/20190925  CASE 369420 Disallow negative quantity of gift vouchers to be sold
    // NPR5.53/MHA /20200103  CASE 384055 Customer No. is carried to Retail Voucher in IssueVoucher()
    // NPR5.54/MHA /20200310  CASE 372135 Added Generation of Voucher- and Reference No. in IssueVoucher() in order to display Reference No on POS Sales Line
    // NPR5.55/MHA /20200427  CASE 402015 New Primary Key on Sale Line POS Voucher
    // NPR5.55/MHA /20200520  CASE 405889 Reference No. should only be generated if not already exists


    trigger OnRun()
    begin
    end;

    var
        Text000: Label 'This action Issues Retail Vouchers.';
        Text001: Label 'Select Voucher Type:';
        Text002: Label 'Issue Retail Vouchers';
        Text003: Label 'Enter Quantity:';
        Text004: Label 'Enter Amount:';
        Text005: Label 'Enter Discount Amount:';
        Text006: Label 'Enter Discount Percent:';
        QtyNotPositiveErr: Label 'You must specify a positive quantity.';
        ConfirmReenterQtyMsg: Label '\Do you want to re-enter the quantity?';

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', true, true)]
    local procedure OnDiscoverActions(var Sender: Record "POS Action")
    var
        FunctionOptionString: Text;
        JSArr: Text;
        OptionName: Text;
        N: Integer;
    begin
        DiscoverIssueVoucherAction(Sender);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150702, 'OnInitializeCaptions', '', true, true)]
    local procedure OnInitializeCaptions(Captions: Codeunit "POS Caption Management")
    begin
        InitializeIssueVoucherCaptions(Captions);
    end;

    local procedure DiscoverIssueVoucherAction(var Sender: Record "POS Action")
    var
        NpRvVoucher: Record "NpRv Voucher";
    begin
        if not Sender.DiscoverAction(
          IssueVoucherActionCode(),
          Text000,
          IssueVoucherActionVersion(),
          Sender.Type::Generic,
          Sender."Subscriber Instances Allowed"::Multiple) then
         exit;

        Sender.RegisterWorkflowStep('voucher_type_input','if (!param.VoucherTypeCode) {respond()} else {context.VoucherTypeCode = param.VoucherTypeCode}');
        Sender.RegisterWorkflowStep('qty_input','if(param.Quantity <= 0) {intpad({title: labels.IssueVoucherTitle,caption: labels.Quantity,value: 1,notBlank: true}).cancel(abort)} ' +
                                                'else {context.$qty_input = {"numpad": param.Quantity}};');
        //-NPR5.52 [369420]
        Sender.RegisterWorkflowStep('check_qty','respond();');
        //+NPR5.52 [369420]
        Sender.RegisterWorkflowStep('amt_input','if(param.Amount <= 0) {numpad({title: labels.IssueVoucherTitle,caption: labels.Amount,value: 0,notBlank: true}).cancel(abort)} ' +
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
          //-NPR5.48 [341711]
          //'    goto("issue_voucher");' +
          '    goto("select_send_method");' +
          //+NPR5.48 [341711]
          '}');
        //-NPR5.48 [341711]
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
        //+NPR5.48 [341711]
        Sender.RegisterWorkflowStep ('issue_voucher','respond ();');
        Sender.RegisterWorkflowStep('contact_info','if(param.ContactInfo) {respond()}');
        Sender.RegisterWorkflowStep('scan_reference_nos','if(param.ScanReferenceNos) {respond()}');
        Sender.RegisterWorkflow(false);

        Sender.RegisterTextParameter('VoucherTypeCode','');
        Sender.RegisterIntegerParameter('Quantity',0);
        Sender.RegisterDecimalParameter('Amount',0);
        Sender.RegisterOptionParameter('DiscountType','Amount,Percent,None','Amount');
        Sender.RegisterDecimalParameter('DiscountAmount',0);
        Sender.RegisterBooleanParameter('ContactInfo',true);
        Sender.RegisterBooleanParameter('ScanReferenceNos',false);
    end;

    local procedure InitializeIssueVoucherCaptions(var Captions: Codeunit "POS Caption Management")
    begin
        Captions.AddActionCaption(IssueVoucherActionCode,'IssueVoucherPrompt',Text001);
        Captions.AddActionCaption(IssueVoucherActionCode,'IssueVoucherTitle',Text002);
        Captions.AddActionCaption(IssueVoucherActionCode,'Quantity',Text003);
        Captions.AddActionCaption(IssueVoucherActionCode,'Amount',Text004);
        Captions.AddActionCaption(IssueVoucherActionCode,'DiscountAmount',Text005);
        Captions.AddActionCaption(IssueVoucherActionCode,'DiscountPercent',Text006);
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnLookupValue', '', true, true)]
    local procedure OnLookupVoucherTypeCode(var POSParameterValue: Record "POS Parameter Value";Handled: Boolean)
    var
        NpRvVoucherType: Record "NpRv Voucher Type";
    begin
        //-NPR5.49 [342811]
        if POSParameterValue."Action Code" <> IssueVoucherActionCode() then
          exit;
        if POSParameterValue.Name <> 'VoucherTypeCode' then
          exit;
        if POSParameterValue."Data Type" <> POSParameterValue."Data Type"::Text then
          exit;

        Handled := true;

        if PAGE.RunModal(0,NpRvVoucherType) = ACTION::LookupOK then
          POSParameterValue.Value := NpRvVoucherType.Code;
        //+NPR5.49 [342811]
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnValidateValue', '', true, true)]
    local procedure OnValidateVoucherTypeCode(var POSParameterValue: Record "POS Parameter Value")
    var
        NpRvVoucherType: Record "NpRv Voucher Type";
    begin
        //-NPR5.49 [342811]
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
          NpRvVoucherType.SetFilter(Code,'%1',POSParameterValue.Value + '*');
          if NpRvVoucherType.FindFirst then
            POSParameterValue.Value := NpRvVoucherType.Code;
        end;

        NpRvVoucherType.Get(POSParameterValue.Value);
        //+NPR5.49 [342811]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150706, 'OnBeforeSetQuantity', '', true, true)]
    local procedure OnBeforeSetQuantity(var Sender: Codeunit "POS Sale Line";SaleLinePOS: Record "Sale Line POS";var NewQuantity: Decimal)
    begin
        ScanReferenceNos(SaleLinePOS,NewQuantity);
    end;

    local procedure "--- POS Action"()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', true, true)]
    local procedure OnAction("Action": Record "POS Action";WorkflowStep: Text;Context: JsonObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    var
        SaleLinePOS: Record "Sale Line POS";
        POSSaleLine: Codeunit "POS Sale Line";
        JSON: Codeunit "POS JSON Management";
    begin
        if Handled then
          exit;

        if not Action.IsThisAction(IssueVoucherActionCode()) then
          exit;
        Handled := true;

        JSON.InitializeJObjectParser(Context,FrontEnd);
        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        case WorkflowStep of
          //-NPR5.52 [369420]
          'check_qty':
            CheckQty(JSON,FrontEnd);
          //+NPR5.52 [369420]
          'voucher_type_input':
            VoucherTypeInput(JSON,FrontEnd);
          //-NPR5.48 [341711]
          'select_send_method':
            SelectSendMethod(JSON,POSSession,FrontEnd);
          //+NPR5.48 [341711]
          'issue_voucher':
            IssueVoucher(JSON,POSSession);
          'contact_info':
            ContactInfo(JSON,SaleLinePOS);
          'scan_reference_nos':
            ScanReferenceNos(SaleLinePOS,SaleLinePOS.Quantity);
        end;
    end;

    local procedure ContactInfo(JSON: Codeunit "POS JSON Management";SaleLinePOS: Record "Sale Line POS")
    var
        NpRvSalesLine: Record "NpRv Sales Line";
    begin
        NpRvSalesLine.SetRange("Register No.",SaleLinePOS."Register No.");
        NpRvSalesLine.SetRange("Sales Ticket No.",SaleLinePOS."Sales Ticket No.");
        NpRvSalesLine.SetRange("Sale Type",SaleLinePOS."Sale Type");
        NpRvSalesLine.SetRange("Sale Date",SaleLinePOS.Date);
        NpRvSalesLine.SetRange("Sale Line No.",SaleLinePOS."Line No.");
        if not NpRvSalesLine.FindSet then
          exit;

        repeat
          PAGE.RunModal(PAGE::"NpRv Sales Line Card",NpRvSalesLine);
          Commit;
        until NpRvSalesLine.Next = 0;
    end;

    local procedure IssueVoucher(JSON: Codeunit "POS JSON Management";POSSession: Codeunit "POS Session")
    var
        NpRvSalesLine: Record "NpRv Sales Line";
        NpRvSalesLineReference: Record "NpRv Sales Line Reference";
        VoucherType: Record "NpRv Voucher Type";
        SalePOS: Record "Sale POS";
        SaleLinePOS: Record "Sale Line POS";
        TempVoucher: Record "NpRv Voucher" temporary;
        NpRvVoucherMgt: Codeunit "NpRv Voucher Mgt.";
        POSSale: Codeunit "POS Sale";
        POSSaleLine: Codeunit "POS Sale Line";
        VoucherTypeCode: Text;
        DiscountType: Text;
    begin
        VoucherTypeCode := UpperCase(JSON.GetString('VoucherTypeCode',true));
        VoucherType.Get(VoucherTypeCode);

        //-NPR5.55 [402015]
        NpRvVoucherMgt.GenerateTempVoucher(VoucherType,TempVoucher);
        //+NPR5.55 [402015]

        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetNewSaleLine(SaleLinePOS);
        SaleLinePOS.Validate("Sale Type",SaleLinePOS."Sale Type"::Deposit);
        SaleLinePOS.Validate(Type,SaleLinePOS.Type::"G/L Entry");
        SaleLinePOS.Validate("No.",VoucherType."Account No.");
        SaleLinePOS.Description := VoucherType.Description;
        JSON.SetScope('/',true);
        JSON.SetScope('$qty_input',true);
        SaleLinePOS.Quantity := JSON.GetInteger('numpad',true);
        //-NPR5.52 [369420]
        if SaleLinePOS.Quantity < 0 then
          Error(QtyNotPositiveErr);
        //+NPR5.52 [369420]

        POSSaleLine.InsertLine(SaleLinePOS);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        JSON.SetScope('/',true);
        JSON.SetScope('$amt_input',true);
        SaleLinePOS."Unit Price" := JSON.GetDecimal('numpad',true);

        JSON.SetScope ('/', true);
        JSON.SetScope('parameters',true);
        DiscountType := JSON.GetString('DiscountType',true);
        case DiscountType of
          '0':
            begin
              JSON.SetScope('/',true);
              JSON.SetScope('$discount_input',true);
              SaleLinePOS."Discount Amount" := JSON.GetDecimal('numpad',true) * SaleLinePOS.Quantity;
            end;
          '1':
            begin
              JSON.SetScope('/',true);
              JSON.SetScope('$discount_input',true);
              SaleLinePOS."Discount %" := JSON.GetDecimal('numpad',true);
            end;
        end;
        SaleLinePOS.UpdateAmounts(SaleLinePOS);
        if SaleLinePOS."Discount Amount" > 0 then
          SaleLinePOS."Discount Type" := SaleLinePOS."Discount Type"::Manual;
        //-NPR5.55 [402015]
        SaleLinePOS.Description := TempVoucher.Description;
        //+NPR5.55 [402015]
        SaleLinePOS.Modify(true);
        POSSession.RequestRefreshData();

        //-NPR5.55 [402015]
        NpRvSalesLine.Init;
        NpRvSalesLine.Id := CreateGuid;
        NpRvSalesLine."Document Source" := NpRvSalesLine."Document Source"::POS;
        NpRvSalesLine."Retail ID" := SaleLinePOS."Retail ID";
        NpRvSalesLine."Register No." := SaleLinePOS."Register No.";
        NpRvSalesLine."Sales Ticket No." := SaleLinePOS."Sales Ticket No.";
        NpRvSalesLine."Sale Type" := SaleLinePOS."Sale Type";
        NpRvSalesLine."Sale Date" := SaleLinePOS.Date;
        NpRvSalesLine."Sale Line No." := SaleLinePOS."Line No.";
        NpRvSalesLine."Voucher No." := TempVoucher."No.";
        NpRvSalesLine."Reference No." := TempVoucher."Reference No.";
        NpRvSalesLine.Description := TempVoucher.Description;
        //+NPR5.55 [402015]
        NpRvSalesLine.Type := NpRvSalesLine.Type::"New Voucher";
        NpRvSalesLine."Voucher Type" := VoucherType.Code;
        NpRvSalesLine.Description := VoucherType.Description;
        NpRvSalesLine."Starting Date" := CurrentDateTime;
        //-NPR5.53 [384055]
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        case SalePOS."Customer Type" of
          SalePOS."Customer Type"::Ord:
            begin
              NpRvSalesLine.Validate("Customer No.",SalePOS."Customer No.");
            end;
          SalePOS."Customer Type"::Cash:
            begin
              NpRvSalesLine.Validate("Contact No.",SalePOS."Customer No.");
            end;
        end;
        //+NPR5.53 [384055]
        //-NPR5.48 [341711]
        JSON.SetScope('/',true);
        NpRvSalesLine."Send via Print" := JSON.GetBoolean('SendMethodPrint',false);
        NpRvSalesLine."Send via E-mail" := JSON.GetBoolean('SendMethodEmail',false);
        NpRvSalesLine."Send via SMS" := JSON.GetBoolean('SendMethodSMS',false);
        if JSON.SetScope('$send_method_email',false) then
          NpRvSalesLine."E-mail" := CopyStr(JSON.GetString('input',false),1,MaxStrLen(NpRvSalesLine."E-mail"));
        JSON.SetScope('/',true);
        if JSON.SetScope('$send_method_sms',false) then
          NpRvSalesLine."Phone No." := CopyStr(JSON.GetString('input',false),1,MaxStrLen(NpRvSalesLine."Phone No."));
        //+NPR5.48 [341711]
        NpRvSalesLine.Insert;

        //-NPR5.54 [372135]
        //-NPR5.55 [405889]
        NpRvVoucherMgt.SetSalesLineReferenceFilter(NpRvSalesLine,NpRvSalesLineReference);
        if NpRvSalesLineReference.IsEmpty then begin
        //+NPR5.55 [405889]
          //-NPR5.55 [402015]
          NpRvSalesLineReference.Init;
          NpRvSalesLineReference.Id := CreateGuid;
          NpRvSalesLineReference."Voucher No." := TempVoucher."No.";
          NpRvSalesLineReference."Reference No." := TempVoucher."Reference No.";
          NpRvSalesLineReference."Sales Line Id" := NpRvSalesLine.Id;
          NpRvSalesLineReference.Insert(true);
          //+NPR5.55 [402015]
        //-NPR5.55 [405889]
        end;
        //+NPR5.55 [405889]
        POSSession.RequestRefreshData();
        //+NPR5.54 [372135]
    end;

    local procedure ScanReferenceNos(SaleLinePOS: Record "Sale Line POS";Quantity: Decimal)
    var
        NpRvSalesLine: Record "NpRv Sales Line";
        NpRvSalesLineReference: Record "NpRv Sales Line Reference";
        NpRvSalesLineReferences: Page "NpRv Sales Line References";
    begin
        if not GuiAllowed then
          exit;

        //-NPR5.55 [402015]
        NpRvSalesLine.SetRange("Retail ID",SaleLinePOS."Retail ID");
        //+NPR5.55 [402015]
        NpRvSalesLine.SetRange(Type,NpRvSalesLine.Type::"New Voucher");
        if not NpRvSalesLine.FindFirst then
          exit;

        NpRvSalesLineReferences.SetNpRvSalesLine(NpRvSalesLine,Quantity);
        NpRvSalesLineReferences.RunModal;
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
        //-NPR5.48 [341711]
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
        FrontEnd.SetActionContext(IssueVoucherActionCode(),JSON);
        //+NPR5.48 [341711]
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
        FrontEnd.SetActionContext(IssueVoucherActionCode(),JSON);
    end;

    local procedure CheckQty(JSON: Codeunit "POS JSON Management";FrontEnd: Codeunit "POS Front End Management")
    var
        Qty: Decimal;
    begin
        //-NPR5.52 [369420]
        JSON.SetScope('/',true);
        JSON.SetScope('$qty_input',true);
        Qty := JSON.GetInteger('numpad',true);
        if Qty <= 0 then begin
          if Confirm(QtyNotPositiveErr + ConfirmReenterQtyMsg,true) then
            FrontEnd.ContinueAtStep('qty_input')
          else
            Error('');
        end;
        //+NPR5.52 [369420]
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

    local procedure "--- Constants"()
    begin
    end;

    local procedure IssueVoucherActionCode(): Text
    begin
        exit('ISSUE_VOUCHER');
    end;

    local procedure IssueVoucherActionVersion(): Text
    begin
        //-NPR5.48 [341711]
        exit('1.1');
        //+NPR5.48 [341711]
        exit('1.0');
    end;
}

