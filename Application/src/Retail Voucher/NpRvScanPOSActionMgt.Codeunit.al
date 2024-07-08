codeunit 6151014 "NPR NpRv Scan POSAction Mgt."
{
    Access = Internal;
    ObsoleteState = Pending;
    ObsoleteTag = 'NPR23.0';
    ObsoleteReason = 'Use new action SCAN_VOUCHER_2';

    var
        Text000: Label 'This action handles Scan Retail Vouchers (Payment).';
        Text001: Label 'Retail Voucher Payment';
        Text002: Label 'Enter Reference No.';
        ReadingErr: Label 'reading in %1';
        SettingScopeErr: Label 'setting scope in %1';
        BlankReferenceNoErr: label 'Reference No. can''t be blank';

    local procedure ObjectIdentifier(): Text
    begin
        exit('Codeunit Scan POSAction Mgt.');
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Action", 'OnDiscoverActions', '', true, true)]
    local procedure OnDiscoverActions(var Sender: Record "NPR POS Action")
    begin
        DiscoverVoucherPaymentAction(Sender);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS UI Management", 'OnInitializeCaptions', '', true, true)]
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

        Sender.RegisterWorkflowStep('voucher_input', 'if(!param.ReferenceNo) {input({title: labels.VoucherPaymentTitle,caption: labels.ReferenceNo,value: ""}).cancel(abort)} ' +
                                                    'else {context.$voucher_input = {"input": param.ReferenceNo}};');
        Sender.RegisterWorkflowStep('voucher_payment', 'respond ();');
        Sender.RegisterWorkflowStep('end_sale', 'if(param.EndSale) {respond()};');
        Sender.RegisterWorkflow(false);

        Sender.RegisterTextParameter('VoucherTypeCode', '');
        Sender.RegisterTextParameter('ReferenceNo', '');
        Sender.RegisterBooleanParameter('EndSale', true);
        Sender.RegisterBooleanParameter('EnableVoucherList', false);
    end;

    local procedure InitializeVoucherPaymentCaptions(var Captions: Codeunit "NPR POS Caption Management")
    begin
        Captions.AddActionCaption(VoucherPaymentActionCode(), 'VoucherPaymentTitle', Text001);
        Captions.AddActionCaption(VoucherPaymentActionCode(), 'ReferenceNo', Text002);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnLookupValue', '', true, true)]
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

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnValidateValue', '', true, true)]
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
            if NpRvVoucherType.FindFirst() then
                POSParameterValue.Value := NpRvVoucherType.Code;
        end;

        NpRvVoucherType.Get(POSParameterValue.Value);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS JavaScript Interface", 'OnAction', '', true, true)]
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
        SalePOS: Record "NPR POS Sale";
        POSSale: Codeunit "NPR POS Sale";
        VoucherType: Text;
        VoucherTypeCode: Code[20];
        ReferenceNo: Text;
        POSPaymentLine: Codeunit "NPR POS Payment Line";
        NpRvVoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
        POSLine: Record "NPR POS Sale Line";
        VoucherListEnabled: Boolean;
    begin
        JSON.SetScopeParameters(ObjectIdentifier());
        VoucherType := UpperCase(JSON.GetStringOrFail('VoucherTypeCode', StrSubstNo(ReadingErr, ObjectIdentifier())));
        if StrLen(VoucherType) > 20 then
            Error('Voucher Type can be only 20 characters.');
        VoucherTypeCode := CopyStr(VoucherType, 1, 20);

        JSON.SetScopeRoot();
        JSON.SetScope('$voucher_input', StrSubstNo(SettingScopeErr, ObjectIdentifier()));

        ReferenceNo := UpperCase(JSON.GetStringOrFail('input', StrSubstNo(ReadingErr, ObjectIdentifier())));
        VoucherListEnabled := JSON.GetBooleanParameter('EnableVoucherList');

        if ReferenceNo = '' then
            if VoucherListEnabled then
                ReferenceNo := SetReferenceNo(VoucherTypeCode)
            else
                Error(BlankReferenceNoErr);

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        POSSession.GetPaymentLine(POSPaymentLine);
        POSPaymentLine.GetPaymentLine(POSLine);

        NpRvVoucherMgt.ApplyVoucherPayment(VoucherTypeCode, ReferenceNo, POSLine, SalePOS, POSSession, FrontEnd, POSPaymentLine, POSLine, false);

        JSON.SetContext('VoucherType', VoucherTypeCode);
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
        if Abs(Subtotal) > Abs(POSSetup.AmountRoundingPrecision()) then
            exit;

        VoucherTypeCode := UpperCase(JSON.GetStringOrFail('VoucherType', StrSubstNo(ReadingErr, ObjectIdentifier())));
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

    local procedure VoucherPaymentActionCode(): Code[20]
    begin
        exit('SCAN_VOUCHER');
    end;

    local procedure VoucherPaymentActionVersion(): Code[20]
    begin
        exit('1.1');
    end;

    local procedure SetReferenceNo(VoucherTypeCode: Code[20]): Text[50]
    var
        Voucher: Record "NPR NpRv Voucher";
        NpRvVouchers: Page "NPR NpRv Vouchers";
        ReferenceNo: Text[50];
    begin
        Voucher.SetCurrentKey("Voucher Type");
        Voucher.SetRange("Voucher Type", VoucherTypeCode);

        Clear(NpRvVouchers);
        NpRvVouchers.LookupMode := true;
        NpRvVouchers.SetTableView(Voucher);
        if NpRvVouchers.RunModal() = Action::LookupOK then begin
            NpRvVouchers.GetRecord(Voucher);
            ReferenceNo := Voucher."Reference No.";
        end;
        if ReferenceNo = '' then
            Error(BlankReferenceNoErr);
        exit(ReferenceNo);
    end;


    #region Ean Box Event Handling

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Input Box Setup Mgt.", 'DiscoverEanBoxEvents', '', true, true)]
    local procedure DiscoverEanBoxEvents(var EanBoxEvent: Record "NPR Ean Box Event")
    var
        NpDcCoupon: Record "NPR NpDc Coupon";
    begin
        if not EanBoxEvent.Get(VoucherPaymentActionCode()) then begin
            EanBoxEvent.Init();
            EanBoxEvent.Code := VoucherPaymentActionCode();
            EanBoxEvent."Module Name" := Text002;
            EanBoxEvent.Description := CopyStr(NpDcCoupon.FieldCaption("Reference No."), 1, MaxStrLen(EanBoxEvent.Description));
            EanBoxEvent."Action Code" := VoucherPaymentActionCode();
            EanBoxEvent."POS View" := EanBoxEvent."POS View"::Payment;
            EanBoxEvent."Event Codeunit" := CurrCodeunitId();
            EanBoxEvent.Insert(true);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Input Box Setup Mgt.", 'OnInitEanBoxParameters', '', true, true)]
    local procedure OnInitEanBoxParameters(var Sender: Codeunit "NPR POS Input Box Setup Mgt."; EanBoxEvent: Record "NPR Ean Box Event")
    begin
        case EanBoxEvent.Code of
            VoucherPaymentActionCode():
                begin
                    Sender.SetNonEditableParameterValues(EanBoxEvent, 'ReferenceNo', true, '');
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Input Box Evt Handler", 'SetEanBoxEventInScope', '', true, true)]
    local procedure SetEanBoxEventInScopeRefNo(EanBoxSetupEvent: Record "NPR Ean Box Setup Event"; EanBoxValue: Text; var InScope: Boolean)
    var
        Voucher: Record "NPR NpRv Voucher";
        NpRvVoucherType: Record "NPR NpRv Voucher Type";
        NpRvVoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
        EanBoxTxt: Text[50];
    begin
        if EanBoxSetupEvent."Event Code" <> VoucherPaymentActionCode() then
            exit;
        if StrLen(EanBoxValue) > MaxStrLen(Voucher."Reference No.") then
            exit;

        EanBoxTxt := CopyStr(EanBoxValue, 1, MaxStrLen(EanBoxTxt));
        Voucher.SetRange("Reference No.", EanBoxValue);
        if not Voucher.IsEmpty() then begin
            InScope := true;
            exit;
        end;

        if NpRvVoucherType.FindSet() then
            repeat
                if NpRvVoucherMgt.FindPartnerVoucher(NpRvVoucherType.Code, EanBoxTxt, Voucher) then begin
                    InScope := true;
                    exit;
                end;
            until NpRvVoucherType.Next() = 0;
    end;


    local procedure CurrCodeunitId(): Integer
    begin
        exit(CODEUNIT::"NPR NpRv Scan POSAction Mgt.");
    end;

    #endregion Ean Box Event Handling



}
