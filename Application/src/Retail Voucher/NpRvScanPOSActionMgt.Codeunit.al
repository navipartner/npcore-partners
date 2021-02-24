codeunit 6151014 "NPR NpRv Scan POSAction Mgt."
{
    var
        Text000: Label 'This action handles Scan Retail Vouchers (Payment).';
        Text001: Label 'Retail Voucher Payment';
        Text002: Label 'Enter Reference No.:';

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', true, true)]
    local procedure OnDiscoverActions(var Sender: Record "NPR POS Action")
    var
        FunctionOptionString: Text;
        JSArr: Text;
        OptionName: Text;
        N: Integer;
    begin
        DiscoverVoucherPaymentAction(Sender);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150702, 'OnInitializeCaptions', '', true, true)]
    local procedure OnInitializeCaptions(Captions: Codeunit "NPR POS Caption Management")
    begin
        InitializeVoucherPaymentCaptions(Captions);
    end;

    local procedure DiscoverVoucherPaymentAction(var Sender: Record "NPR POS Action")
    begin
        if not Sender.DiscoverAction(
          VoucherPaymentActionCode(),
          Text000,
          VoucherPaymentActionVersion(),
          Sender.Type::Generic,
          Sender."Subscriber Instances Allowed"::Multiple) then
            exit;

        Sender.RegisterWorkflowStep('voucher_input', 'if(!param.ReferenceNo) {input({title: labels.VoucherPaymentTitle,caption: labels.ReferenceNo,value: "",notBlank: true}).cancel(abort)} ' +
                                                    'else {context.$voucher_input = {"input": param.ReferenceNo}};');
        Sender.RegisterWorkflowStep('voucher_payment', 'respond ();');
        Sender.RegisterWorkflowStep('end_sale', 'if(param.EndSale) {respond()};');
        Sender.RegisterWorkflow(false);

        Sender.RegisterTextParameter('VoucherTypeCode', '');
        Sender.RegisterTextParameter('ReferenceNo', '');
        Sender.RegisterBooleanParameter('EndSale', true);
    end;

    local procedure InitializeVoucherPaymentCaptions(var Captions: Codeunit "NPR POS Caption Management")
    begin
        Captions.AddActionCaption(VoucherPaymentActionCode, 'VoucherPaymentTitle', Text001);
        Captions.AddActionCaption(VoucherPaymentActionCode, 'ReferenceNo', Text002);
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnLookupValue', '', true, true)]
    local procedure OnLookupVoucherTypeCode(var POSParameterValue: Record "NPR POS Parameter Value"; Handled: Boolean)
    var
        NpRvVoucherType: Record "NPR NpRv Voucher Type";
    begin
        if POSParameterValue."Action Code" <> VoucherPaymentActionCode() then
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
            NpRvVoucherType.SetFilter(Code, '%1', POSParameterValue.Value + '*');
            if NpRvVoucherType.FindFirst then
                POSParameterValue.Value := NpRvVoucherType.Code;
        end;

        NpRvVoucherType.Get(POSParameterValue.Value);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', true, true)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        JSON: Codeunit "NPR POS JSON Management";
    begin
        if Handled then
            exit;

        if not Action.IsThisAction(VoucherPaymentActionCode()) then
            exit;
        Handled := true;

        JSON.InitializeJObjectParser(Context, FrontEnd);
        case WorkflowStep of
            'voucher_payment':
                VoucherPayment(FrontEnd, JSON, POSSession);
            'end_sale':
                EndSale(JSON, POSSession);
        end;
    end;

    local procedure VoucherPayment(FrontEnd: Codeunit "NPR POS Front End Management"; JSON: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session")
    var
        NpRvVoucherBuffer: Record "NPR NpRv Voucher Buffer" temporary;
        SalePOS: Record "NPR Sale POS";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        VoucherType: Record "NPR NpRv Voucher Type";
        NpRvVoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
        POSSale: Codeunit "NPR POS Sale";
        VoucherTypeCode: Text;
        ReferenceNo: Text;
        Handled: Boolean;
        POSPaymentLine: Codeunit "NPR POS Payment Line";
        POSLine: Record "NPR Sale Line POS";
    begin
        JSON.SetScope('parameters', true);
        VoucherTypeCode := UpperCase(JSON.GetString('VoucherTypeCode', true));

        JSON.SetScope('/', true);
        JSON.SetScope('$voucher_input', true);
        ReferenceNo := UpperCase(JSON.GetString('input', true));
        if ReferenceNo = '' then
            exit;

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
        POSSession.GetPaymentLine(POSPaymentLine);
        POSPaymentLine.GetPaymentLine(POSLine);

        POSLine."No." := VoucherType."Payment Type";
        POSLine."Register No." := SalePOS."Register No.";
        POSLine.Description := NpRvVoucherBuffer.Description;
        POSLine."Sales Ticket No." := SalePOS."Sales Ticket No.";
        POSLine."Amount Including VAT" := NpRvVoucherBuffer.Amount;
        POSPaymentLine.InsertPaymentLine(POSLine, 0);
        POSPaymentLine.GetCurrentPaymentLine(POSLine);

        POSSession.RequestRefreshData();

        NpRvSalesLine.Init;
        NpRvSalesLine.Id := CreateGuid;
        NpRvSalesLine."Document Source" := NpRvSalesLine."Document Source"::POS;
        NpRvSalesLine."Retail ID" := POSLine."Retail ID";
        NpRvSalesLine."Register No." := SalePOS."Register No.";
        NpRvSalesLine."Sales Ticket No." := SalePOS."Sales Ticket No.";
        NpRvSalesLine."Sale Type" := POSLine."Sale Type";
        NpRvSalesLine."Sale Date" := POSLine.Date;
        NpRvSalesLine."Sale Line No." := POSLine."Line No.";

        NpRvSalesLine.Type := NpRvSalesLine.Type::Payment;
        NpRvSalesLine."Voucher No." := NpRvVoucherBuffer."No.";
        NpRvSalesLine."Reference No." := NpRvVoucherBuffer."Reference No.";
        NpRvSalesLine."Voucher Type" := VoucherType.Code;
        NpRvSalesLine.Description := VoucherType.Description;
        NpRvSalesLine.Insert(true);

        NpRvVoucherMgt.ApplyPayment(FrontEnd, POSSession, NpRvSalesLine);

        JSON.SetContext('VoucherType', NpRvVoucherBuffer."Voucher Type");
        FrontEnd.SetActionContext(VoucherPaymentActionCode(), JSON);
    end;

    local procedure EndSale(JSON: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session")
    var
        NpRvVoucherType: Record "NPR NpRv Voucher Type";
        POSPaymentMethod: Record "NPR POS Payment Method";
        ReturnPOSPaymentMethod: Record "NPR POS Payment Method";
        POSPaymentLine: Codeunit "NPR POS Payment Line";
        POSSale: Codeunit "NPR POS Sale";
        POSSetup: Codeunit "NPR POS Setup";
        PaidAmount: Decimal;
        ReturnAmount: Decimal;
        SaleAmount: Decimal;
        Subtotal: Decimal;
        VoucherTypeCode: Text;
    begin
        POSSession.GetPaymentLine(POSPaymentLine);
        POSPaymentLine.CalculateBalance(SaleAmount, PaidAmount, ReturnAmount, Subtotal);

        POSSession.GetSetup(POSSetup);
        if Abs(Subtotal) > Abs(POSSetup.AmountRoundingPrecision) then
            exit;

        VoucherTypeCode := UpperCase(JSON.GetString('VoucherType', true));
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

    local procedure VoucherPaymentActionCode(): Text
    begin
        exit('SCAN_VOUCHER');
    end;

    local procedure VoucherPaymentActionVersion(): Text
    begin
        exit('1.0');
    end;
}

