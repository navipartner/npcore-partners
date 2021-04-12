codeunit 6151023 "NPR NpRv POS Action Top-up"
{
    var
        Text000: Label 'Apply Top-up (refill) on existing Retail Voucher.';
        Text001: Label 'Top-up Retail Voucher';
        Text002: Label 'Enter Reference No.';
        Text003: Label 'Enter Amount';
        Text004: Label 'Enter Discount Amount';
        Text005: Label 'Enter Discount Percent';
        Text006: Label 'Top-up is not allowed for Retail Voucher %1';
        ReadingErr: Label 'reading in %1';
        SettingScopeErr: Label 'setting scope in %1';

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', true, true)]
    local procedure OnDiscoverActions(var Sender: Record "NPR POS Action")
    begin
        if not Sender.DiscoverAction(
          ActionCode(),
          Text000,
          ActionVersion(),
          Sender.Type::Generic,
          Sender."Subscriber Instances Allowed"::Multiple) then
            exit;

        Sender.RegisterWorkflowStep('voucher_input', 'if(!param.ReferenceNo) {input({title: labels.TopupVoucherTitle,caption: labels.ReferenceNo,value: "",notBlank: true}).cancel(abort)} ' +
                                                    'else {context.$voucher_input = {"input": param.ReferenceNo}};');
        Sender.RegisterWorkflowStep('validate_voucher', 'respond();');
        Sender.RegisterWorkflowStep('amt_input', 'if(param.Amount <= 0) {numpad({title: labels.TopupVoucherTitle,caption: labels.Amount,value: 0,notBlank: true}).cancel(abort)} ' +
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
        Sender.RegisterWorkflowStep('show_voucher_card', 'if(param.ShowVoucherCard) {respond()}');
        Sender.RegisterWorkflowStep('topup_voucher', 'respond();');
        Sender.RegisterWorkflow(false);

        Sender.RegisterTextParameter('VoucherTypeFilter', '');
        Sender.RegisterTextParameter('ReferenceNo', '');
        Sender.RegisterDecimalParameter('Amount', 0);
        Sender.RegisterOptionParameter('DiscountType', 'Amount,Percent,None', 'Amount');
        Sender.RegisterDecimalParameter('DiscountAmount', 0);
        Sender.RegisterBooleanParameter('ShowVoucherCard', true);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150702, 'OnInitializeCaptions', '', true, true)]
    local procedure OnInitializeCaptions(Captions: Codeunit "NPR POS Caption Management")
    begin
        Captions.AddActionCaption(ActionCode(), 'TopupVoucherTitle', Text001);
        Captions.AddActionCaption(ActionCode(), 'ReferenceNo', Text002);
        Captions.AddActionCaption(ActionCode(), 'Amount', Text003);
        Captions.AddActionCaption(ActionCode(), 'DiscountAmount', Text004);
        Captions.AddActionCaption(ActionCode(), 'DiscountPercent', Text005);
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnLookupValue', '', true, true)]
    local procedure OnLookupVoucherTypeCode(var POSParameterValue: Record "NPR POS Parameter Value"; Handled: Boolean)
    var
        NpRvVoucherType: Record "NPR NpRv Voucher Type";
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;
        if POSParameterValue.Name <> 'VoucherTypeFilter' then
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
        if POSParameterValue.Name <> 'VoucherTypeFilter' then
            exit;
        if POSParameterValue."Data Type" <> POSParameterValue."Data Type"::Text then
            exit;

        if POSParameterValue.Value = '' then
            exit;

        POSParameterValue.Value := UpperCase(POSParameterValue.Value);
        NpRvVoucherType.SetFilter(Code, POSParameterValue.Value);
        NpRvVoucherType.FindFirst();
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

        if not Action.IsThisAction(ActionCode()) then
            exit;
        Handled := true;

        JSON.InitializeJObjectParser(Context, FrontEnd);
        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        case WorkflowStep of
            'validate_voucher':
                OnActionValidateVoucher(JSON, FrontEnd);
            'show_voucher_card':
                OnActionShowVoucherCard(JSON, SaleLinePOS);
            'topup_voucher':
                OnActionTopupVoucher(JSON, POSSession);
        end;
    end;

    local procedure OnActionValidateVoucher(JSON: Codeunit "NPR POS JSON Management"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        VoucherTypeFilter: Text;
        ReferenceNo: Text;
    begin
        VoucherTypeFilter := JSON.GetStringParameter('VoucherTypeFilter');

        JSON.SetScopeRoot();
        JSON.SetScope('$voucher_input', StrSubstNo(SettingScopeErr, ActionCode()));
        ReferenceNo := UpperCase(JSON.GetStringOrFail('input', StrSubstNo(ReadingErr, ActionCode())));

        NpRvVoucher.SetFilter("Voucher Type", VoucherTypeFilter);
        NpRvVoucher.SetFilter("Reference No.", '=%1', ReferenceNo);
        NpRvVoucher.FindFirst();
        if not NpRvVoucher."Allow Top-up" then
            Error(Text006, NpRvVoucher."Reference No.");

        JSON.SetContext('VoucherNo', NpRvVoucher."No.");
        FrontEnd.SetActionContext(ActionCode(), JSON);
    end;

    local procedure OnActionShowVoucherCard(JSON: Codeunit "NPR POS JSON Management"; SaleLinePOS: Record "NPR POS Sale Line")
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        VoucherNo: Text;
    begin
        JSON.SetScopeRoot();
        VoucherNo := JSON.GetString('VoucherNo');
        NpRvVoucher.Get(VoucherNo);
        PAGE.RunModal(PAGE::"NPR NpRv Voucher Card", NpRvVoucher);
    end;

    local procedure OnActionTopupVoucher(JSON: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session")
    var
        NpRvVoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
        VoucherNo: Text;
        DiscountType: Text;
        AmtInput, DiscountAmount, DiscountPct : Decimal;
    begin
        JSON.SetScopeRoot();
        VoucherNo := JSON.GetString('VoucherNo');
        JSON.SetScopeRoot();
        JSON.SetScope('$amt_input', StrSubstNo(SettingScopeErr, ActionCode()));
        AmtInput := JSON.GetDecimalOrFail('numpad', StrSubstNo(ReadingErr, ActionCode()));

        JSON.SetScopeRoot();
        JSON.SetScopeParameters(ActionCode());
        DiscountType := JSON.GetStringOrFail('DiscountType', StrSubstNo(ReadingErr, ActionCode()));
        case DiscountType of
            '0':
                begin
                    JSON.SetScopeRoot();
                    JSON.SetScope('$discount_input', StrSubstNo(SettingScopeErr, ActionCode()));
                    DiscountAmount := JSON.GetDecimalOrFail('numpad', StrSubstNo(ReadingErr, ActionCode()));
                end;
            '1':
                begin
                    JSON.SetScopeRoot();
                    JSON.SetScope('$discount_input', StrSubstNo(SettingScopeErr, ActionCode()));
                    DiscountPct := JSON.GetDecimalOrFail('numpad', StrSubstNo(ReadingErr, ActionCode()));
                end;
        end;

        NpRvVoucherMgt.TopUpVoucher(POSSession, VoucherNo, DiscountType, AmtInput, DiscountAmount, DiscountPct);
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
