codeunit 6151014 "NpRv Scan POS Action Mgt."
{
    // NPR5.37/MHA /20171023  CASE 267346 Object created - NaviPartner Retail Voucher
    // NPR5.42/MHA /20180525  CASE 307022 Added Publisher OnScanVoucher() to enable extension of Finding Voucher
    // NPR5.48/MHA /20190215  CASE 342920 EndSale is now performed with balancing
    // NPR5.49/MHA /20190228  CASE 342811 Added functions OnLookupVoucherTypeCode(), OnValidateVoucherTypeCode() and implemented new Voucher Validation interface
    // NPR5.50/MHA /20190426  CASE 353079 Removed wrong quotation marks in workflow step voucher_input
    // NPR5.51/MHA /20190823  CASE 364542 VoucherType in EndSale() should depend on the Scanned Voucher in VoucherPayment()


    trigger OnRun()
    begin
    end;

    var
        Text000: Label 'This action handles Scan Retail Vouchers (Payment).';
        Text001: Label 'Retail Voucher Payment';
        Text002: Label 'Enter Reference No.:';
        Text003: Label 'VoucherReference No. is too long';
        Text004: Label 'Invalid Voucher Reference No.';

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', true, true)]
    local procedure OnDiscoverActions(var Sender: Record "POS Action")
    var
        FunctionOptionString: Text;
        JSArr: Text;
        OptionName: Text;
        N: Integer;
    begin
        DiscoverVoucherPaymentAction(Sender);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150702, 'OnInitializeCaptions', '', true, true)]
    local procedure OnInitializeCaptions(Captions: Codeunit "POS Caption Management")
    begin
        InitializeVoucherPaymentCaptions(Captions);
    end;

    local procedure DiscoverVoucherPaymentAction(var Sender: Record "POS Action")
    begin
        if not Sender.DiscoverAction(
          VoucherPaymentActionCode(),
          Text000,
          VoucherPaymentActionVersion(),
          Sender.Type::Generic,
          Sender."Subscriber Instances Allowed"::Multiple) then
         exit;

        Sender.RegisterWorkflowStep('voucher_input','if(!param.ReferenceNo) {input({title: labels.VoucherPaymentTitle,caption: labels.ReferenceNo,value: "",notBlank: true}).cancel(abort)} ' +
                                                    //-NPR5.50 [353079]
                                                    //'else {context.$voucher_input = {"input": "param.ReferenceNo"}};');
                                                    'else {context.$voucher_input = {"input": param.ReferenceNo}};');
                                                    //+NPR5.50 [353079]
        Sender.RegisterWorkflowStep('voucher_payment','respond ();');
        Sender.RegisterWorkflowStep('end_sale','if(param.EndSale) {respond()};');
        Sender.RegisterWorkflow(false);

        Sender.RegisterTextParameter('VoucherTypeCode','');
        Sender.RegisterTextParameter('ReferenceNo','');
        Sender.RegisterBooleanParameter('EndSale',true);
    end;

    local procedure InitializeVoucherPaymentCaptions(var Captions: Codeunit "POS Caption Management")
    begin
        Captions.AddActionCaption(VoucherPaymentActionCode,'VoucherPaymentTitle',Text001);
        Captions.AddActionCaption(VoucherPaymentActionCode,'ReferenceNo',Text002);
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnLookupValue', '', true, true)]
    local procedure OnLookupVoucherTypeCode(var POSParameterValue: Record "POS Parameter Value";Handled: Boolean)
    var
        NpRvVoucherType: Record "NpRv Voucher Type";
    begin
        //-NPR5.49 [342811]
        if POSParameterValue."Action Code" <> VoucherPaymentActionCode() then
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
        if POSParameterValue."Action Code" <> VoucherPaymentActionCode() then
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

        if not Action.IsThisAction(VoucherPaymentActionCode()) then
          exit;
        Handled := true;

        JSON.InitializeJObjectParser(Context,FrontEnd);
        case WorkflowStep of
          'voucher_payment':
            VoucherPayment(FrontEnd,JSON,POSSession);
          'end_sale':
            //-NPR5.48 [342920]
            EndSale(JSON,POSSession);
            //+NPR5.48 [342920]
        end;
    end;

    local procedure VoucherPayment(FrontEnd: Codeunit "POS Front End Management";JSON: Codeunit "POS JSON Management";POSSession: Codeunit "POS Session")
    var
        NpRvVoucherBuffer: Record "NpRv Voucher Buffer" temporary;
        SalePOS: Record "Sale POS";
        SaleLinePOS: Record "Sale Line POS";
        SaleLinePOSVoucher: Record "NpRv Sale Line POS Voucher";
        VoucherType: Record "NpRv Voucher Type";
        NpRvVoucherMgt: Codeunit "NpRv Voucher Mgt.";
        POSSale: Codeunit "POS Sale";
        POSSaleLine: Codeunit "POS Sale Line";
        POSSetup: Codeunit "POS Setup";
        VoucherTypeCode: Text;
        ReferenceNo: Text;
        Handled: Boolean;
    begin
        JSON.SetScope('parameters',true);
        VoucherTypeCode := UpperCase(JSON.GetString('VoucherTypeCode',true));

        JSON.SetScope ('/', true);
        JSON.SetScope('$voucher_input',true);
        ReferenceNo := UpperCase(JSON.GetString('input',true));
        if ReferenceNo = '' then
          exit;

        //-NPR5.49 [342811]
        if VoucherType.Get(VoucherTypeCode) then;
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        NpRvVoucherBuffer.Init;
        NpRvVoucherBuffer."Voucher Type" := VoucherType.Code;
        NpRvVoucherBuffer."Validate Voucher Module" := VoucherType."Validate Voucher Module";
        NpRvVoucherBuffer."Reference No." := ReferenceNo;
        NpRvVoucherBuffer."Redeem Date" := SalePOS.Date;
        NpRvVoucherBuffer."Redeem Partner Code" := VoucherType."Partner Code";
        NpRvVoucherBuffer."Redeem Register No." := SalePOS."Register No.";
        NpRvVoucherBuffer."Redeem Sales Ticket No." := SalePOS."Sales Ticket No.";
        NpRvVoucherBuffer."Redeem User ID" := SalePOS."Salesperson Code";

        NpRvVoucherMgt.ValidateVoucher(NpRvVoucherBuffer);

        VoucherType.Get(NpRvVoucherBuffer."Voucher Type");
        //+NPR5.49 [342811]

        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetNewSaleLine(SaleLinePOS);

        SaleLinePOS.Validate("Sale Type",SaleLinePOS."Sale Type"::Payment);
        SaleLinePOS.Validate(Type,SaleLinePOS.Type::Payment);
        SaleLinePOS.Validate("No.",VoucherType."Payment Type");
        //-NPR5.49 [342811]
        SaleLinePOS.Description := NpRvVoucherBuffer.Description;
        //+NPR5.49 [342811]

        POSSaleLine.InsertLine(SaleLinePOS);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        //-NPR5.49 [342811]
        SaleLinePOS."Currency Amount" := NpRvVoucherBuffer.Amount;
        SaleLinePOS."Amount Including VAT" := NpRvVoucherBuffer.Amount;
        //+NPR5.49 [342811]
        SaleLinePOS.Modify(true);
        POSSession.RequestRefreshData();

        SaleLinePOSVoucher.Init;
        SaleLinePOSVoucher."Register No." := SaleLinePOS."Register No.";
        SaleLinePOSVoucher."Sales Ticket No." := SaleLinePOS."Sales Ticket No.";
        SaleLinePOSVoucher."Sale Type" := SaleLinePOS."Sale Type";
        SaleLinePOSVoucher."Sale Date" := SaleLinePOS.Date;
        SaleLinePOSVoucher."Sale Line No." := SaleLinePOS."Line No.";
        SaleLinePOSVoucher."Line No." := 10000;
        SaleLinePOSVoucher.Type := SaleLinePOSVoucher.Type::Payment;
        //-NPR5.49 [342811]
        SaleLinePOSVoucher."Voucher No." := NpRvVoucherBuffer."No.";
        SaleLinePOSVoucher."Reference No." := NpRvVoucherBuffer."Reference No.";
        //+NPR5.49 [342811]
        SaleLinePOSVoucher."Voucher Type" := VoucherType.Code;
        SaleLinePOSVoucher.Description := VoucherType.Description;
        SaleLinePOSVoucher.Insert;

        NpRvVoucherMgt.ApplyPayment(FrontEnd,POSSession,SaleLinePOSVoucher);

        //-NPR5.51 [364542]
        JSON.SetContext('VoucherType',NpRvVoucherBuffer."Voucher Type");
        FrontEnd.SetActionContext(VoucherPaymentActionCode(),JSON);
        //+NPR5.51 [364542]
    end;

    local procedure EndSale(JSON: Codeunit "POS JSON Management";POSSession: Codeunit "POS Session")
    var
        NpRvVoucherType: Record "NpRv Voucher Type";
        PaymentTypePOS: Record "Payment Type POS";
        ReturnPaymentTypePOS: Record "Payment Type POS";
        Register: Record Register;
        POSPaymentLine: Codeunit "POS Payment Line";
        POSSale: Codeunit "POS Sale";
        POSSetup: Codeunit "POS Setup";
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
        if Abs(Subtotal) > Abs(POSSetup.AmountRoundingPrecision) then
          exit;

        //-NPR5.51 [364542]
        VoucherTypeCode := UpperCase(JSON.GetString('VoucherType',true));
        //+NPR5.51 [364542]
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

    local procedure "--- Constants"()
    begin
    end;

    local procedure VoucherPaymentActionCode(): Text
    begin
        exit('SCAN_VOUCHER');
    end;

    local procedure VoucherPaymentActionVersion(): Text
    begin
        exit('1.0');
    end;
}

