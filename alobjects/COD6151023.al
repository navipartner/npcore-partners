codeunit 6151023 "NpRv POS Action Top-up"
{
    // NPR5.50/MHA /20190426  CASE 353079 Object created - Top-up functionality for NaviPartner Retail Vouchers
    // NPR5.55/MHA /20200427  CASE 402015 New Primary Key on Sale Line POS Voucher


    trigger OnRun()
    begin
    end;

    var
        Text000: Label 'Apply Top-up (refill) on existing Retail Voucher.';
        Text001: Label 'Top-up Retail Voucher';
        Text002: Label 'Enter Reference No.:';
        Text003: Label 'Enter Amount:';
        Text004: Label 'Enter Discount Amount:';
        Text005: Label 'Enter Discount Percent:';
        Text006: Label 'Top-up is not allowed for Retail Voucher %1';

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', true, true)]
    local procedure OnDiscoverActions(var Sender: Record "POS Action")
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

        Sender.RegisterWorkflowStep('voucher_input','if(!param.ReferenceNo) {input({title: labels.TopupVoucherTitle,caption: labels.ReferenceNo,value: "",notBlank: true}).cancel(abort)} ' +
                                                    'else {context.$voucher_input = {"input": param.ReferenceNo}};');
        Sender.RegisterWorkflowStep('validate_voucher','respond();');
        Sender.RegisterWorkflowStep('amt_input','if(param.Amount <= 0) {numpad({title: labels.TopupVoucherTitle,caption: labels.Amount,value: 0,notBlank: true}).cancel(abort)} ' +
                                                'else {context.$amt_input = {"numpad": param.Amount}};');
        Sender.RegisterWorkflowStep('discount_input',
          'switch(param.DiscountType + "") {' +
          '  case "0":' +
          '    if(param.DiscountAmount <= 0) {numpad({title: labels.TopupVoucherTitle,caption: labels.DiscountAmount,value: 0}).cancel(abort)} ' +
          '    else {context.$discount_input = {"numpad": param.DiscountAmount}};' +
          '    break;' +
          '  case "1":' +
          '    if(param.DiscountAmount <= 0) {numpad({title: labels.TopupVoucherTitle,caption: labels.DiscountPercent,value: 0}).cancel(abort)}' +
          '    else {context.$discount_input = {"numpad": param.DiscountAmount}};' +
          '    break;' +
          '  default:' +
          '    goto("show_voucher_card");' +
          '}');
        Sender.RegisterWorkflowStep('show_voucher_card','if(param.ShowVoucherCard) {respond()}');
        Sender.RegisterWorkflowStep('topup_voucher','respond();');
        Sender.RegisterWorkflow(false);

        Sender.RegisterTextParameter('VoucherTypeFilter','');
        Sender.RegisterTextParameter('ReferenceNo','');
        Sender.RegisterDecimalParameter('Amount',0);
        Sender.RegisterOptionParameter('DiscountType','Amount,Percent,None','Amount');
        Sender.RegisterDecimalParameter('DiscountAmount',0);
        Sender.RegisterBooleanParameter('ShowVoucherCard',true);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150702, 'OnInitializeCaptions', '', true, true)]
    local procedure OnInitializeCaptions(Captions: Codeunit "POS Caption Management")
    begin
        Captions.AddActionCaption(ActionCode(),'TopupVoucherTitle',Text001);
        Captions.AddActionCaption(ActionCode(),'ReferenceNo',Text002);
        Captions.AddActionCaption(ActionCode(),'Amount',Text003);
        Captions.AddActionCaption(ActionCode(),'DiscountAmount',Text004);
        Captions.AddActionCaption(ActionCode(),'DiscountPercent',Text005);
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnLookupValue', '', true, true)]
    local procedure OnLookupVoucherTypeCode(var POSParameterValue: Record "POS Parameter Value";Handled: Boolean)
    var
        NpRvVoucherType: Record "NpRv Voucher Type";
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
          exit;
        if POSParameterValue.Name <> 'VoucherTypeFilter' then
          exit;
        if POSParameterValue."Data Type" <> POSParameterValue."Data Type"::Text then
          exit;

        Handled := true;

        if PAGE.RunModal(0,NpRvVoucherType) = ACTION::LookupOK then
          POSParameterValue.Value := NpRvVoucherType.Code;
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnValidateValue', '', true, true)]
    local procedure OnValidateVoucherTypeCode(var POSParameterValue: Record "POS Parameter Value")
    var
        NpRvVoucherType: Record "NpRv Voucher Type";
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
          exit;
        if POSParameterValue.Name <> 'VoucherTypeFilter' then
          exit;
        if POSParameterValue."Data Type" <> POSParameterValue."Data Type"::Text then
          exit;

        if POSParameterValue.Value = '' then
          exit;

        POSParameterValue.Value := UpperCase(POSParameterValue.Value);
        NpRvVoucherType.SetFilter(Code,POSParameterValue.Value);
        NpRvVoucherType.FindFirst;
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

        if not Action.IsThisAction(ActionCode()) then
          exit;
        Handled := true;

        JSON.InitializeJObjectParser(Context,FrontEnd);
        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        case WorkflowStep of
          'validate_voucher':
            OnActionValidateVoucher(JSON,FrontEnd);
          'show_voucher_card':
            OnActionShowVoucherCard(JSON,SaleLinePOS);
          'topup_voucher':
            OnActionTopupVoucher(JSON,POSSession);
        end;
    end;

    local procedure OnActionValidateVoucher(JSON: Codeunit "POS JSON Management";FrontEnd: Codeunit "POS Front End Management")
    var
        NpRvVoucher: Record "NpRv Voucher";
        VoucherTypeFilter: Text;
        ReferenceNo: Text;
    begin
        VoucherTypeFilter := JSON.GetStringParameter('VoucherTypeFilter',false);

        JSON.SetScope('/',true);
        JSON.SetScope('$voucher_input',true);
        ReferenceNo := UpperCase(JSON.GetString('input',true));

        NpRvVoucher.SetFilter("Voucher Type",VoucherTypeFilter);
        NpRvVoucher.SetFilter("Reference No.",'=%1',ReferenceNo);
        NpRvVoucher.FindFirst;
        if not NpRvVoucher."Allow Top-up" then
          Error(Text006,NpRvVoucher."Reference No.");

        JSON.SetContext('VoucherNo',NpRvVoucher."No.");
        FrontEnd.SetActionContext(ActionCode(),JSON);
    end;

    local procedure OnActionShowVoucherCard(JSON: Codeunit "POS JSON Management";SaleLinePOS: Record "Sale Line POS")
    var
        NpRvVoucher: Record "NpRv Voucher";
        VoucherNo: Text;
    begin
        JSON.SetScope('/',true);
        VoucherNo := JSON.GetString('VoucherNo',false);
        NpRvVoucher.Get(VoucherNo);
        PAGE.RunModal(PAGE::"NpRv Voucher Card",NpRvVoucher);
    end;

    local procedure OnActionTopupVoucher(JSON: Codeunit "POS JSON Management";POSSession: Codeunit "POS Session")
    var
        NpRvVoucher: Record "NpRv Voucher";
        SaleLinePOS: Record "Sale Line POS";
        NpRvSalesLine: Record "NpRv Sales Line";
        POSSaleLine: Codeunit "POS Sale Line";
        VoucherNo: Text;
        DiscountType: Text;
    begin
        JSON.SetScope('/',true);
        VoucherNo := JSON.GetString('VoucherNo',false);
        NpRvVoucher.Get(VoucherNo);

        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetNewSaleLine(SaleLinePOS);
        SaleLinePOS.Validate("Sale Type",SaleLinePOS."Sale Type"::Deposit);
        SaleLinePOS.Validate(Type,SaleLinePOS.Type::"G/L Entry");
        SaleLinePOS.Validate("No.",NpRvVoucher."Account No.");
        SaleLinePOS.Description := NpRvVoucher.Description;
        SaleLinePOS.Quantity := 1;
        POSSaleLine.InsertLine(SaleLinePOS);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        JSON.SetScope('/',true);
        JSON.SetScope('$amt_input',true);
        SaleLinePOS."Unit Price" := JSON.GetDecimal('numpad',true);

        JSON.SetScope('/',true);
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
        SaleLinePOS.Modify(true);
        POSSession.RequestRefreshData();

        NpRvSalesLine.Init;
        //-NPR5.55 [402015]
        NpRvSalesLine.Id := CreateGuid;
        NpRvSalesLine."Document Source" := NpRvSalesLine."Document Source"::POS;
        NpRvSalesLine."Retail ID" := SaleLinePOS."Retail ID";
        NpRvSalesLine."Register No." := SaleLinePOS."Register No.";
        NpRvSalesLine."Sales Ticket No." := SaleLinePOS."Sales Ticket No.";
        NpRvSalesLine."Sale Type" := SaleLinePOS."Sale Type";
        NpRvSalesLine."Sale Date" := SaleLinePOS.Date;
        NpRvSalesLine."Sale Line No." := SaleLinePOS."Line No.";
        NpRvSalesLine.Type := NpRvSalesLine.Type::"Top-up";
        NpRvSalesLine."Voucher No." := NpRvVoucher."No.";
        NpRvSalesLine."Voucher Type" := NpRvVoucher."Voucher Type";
        NpRvSalesLine.Description := NpRvVoucher.Description;
        NpRvSalesLine."Starting Date" := CurrentDateTime;
        NpRvSalesLine."Send via Print" := NpRvVoucher."Send via Print";
        NpRvSalesLine."Send via E-mail" := NpRvVoucher."Send via E-mail";
        NpRvSalesLine."Send via SMS" := NpRvVoucher."Send via SMS";
        if NpRvVoucher."Send via E-mail" then
          NpRvSalesLine."E-mail" := NpRvVoucher."E-mail";
        if NpRvVoucher."Send via SMS" then
          NpRvSalesLine."Phone No." := NpRvVoucher."Phone No.";
        NpRvSalesLine.Insert(true);
        //+NPR5.55 [402015]
    end;

    local procedure "--- Constants"()
    begin
    end;

    local procedure ActionCode(): Text
    begin
        exit('TOPUP_VOUCHER');
    end;

    local procedure ActionVersion(): Text
    begin
        exit('1.0');
    end;
}

