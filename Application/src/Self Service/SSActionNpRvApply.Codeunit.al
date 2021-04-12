codeunit 6151292 "NPR SS Action: NpRv Apply"
{
    //this action is a SelfService variant of 'SCAN_VOUCHER' action (codeunit 6151014 "NPR NpRv Scan POSAction Mgt.")
    local procedure ActionCode(): Text
    begin
        exit('SS-VOUCHER-APPLY');
    end;

    local procedure ActionVersion(): Text
    begin
        exit('1.0');
    end;

    local procedure ObjectIdentifier(): Text
    begin
        exit('Codeunit SS Action Apply Voucher');
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Action", 'OnDiscoverActions', '', true, false)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    var
        ActionDescriptionTxt: Label 'This is a built-in action for self-service, applying a retail voucher as payment for current transaction', MaxLength = 250;
    begin
        if Sender.DiscoverAction20(ActionCode(), ActionDescriptionTxt, ActionVersion()) then begin
            Sender.RegisterWorkflow20(
              'let result = await popup.stringpad({title: $captions.ApplyVoucherCaption, caption: $captions.EnterRefNoCaption});' +
              'if (result === null) {' +
              '    return;' +
              '}' +
              'await workflow.respond("", { VourchRefNo: result });'
            );

            Sender.RegisterTextParameter('VoucherTypeCode', '');
            Sender.RegisterBlockingUI(true);
            Sender.SetWorkflowTypeUnattended();
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS UI Management", 'OnInitializeCaptions', '', false, false)]
    local procedure OnInitializeCaptions(Captions: Codeunit "NPR POS Caption Management")
    var
        ApplyVoucherCaptionTxt: Label 'Apply Retail Voucher';
        EnterRefNoCaptionTxt: Label 'Enter Vourcher Reference No.';
        CaptionsDictionary: Dictionary of [Text, Text];
        ActionCaption: Text;
    begin
        CaptionsDictionary.Add('ApplyVoucherCaption', ApplyVoucherCaptionTxt);
        CaptionsDictionary.Add('EnterRefNoCaption', EnterRefNoCaptionTxt);

        OnAfterInitializeCaptionsDictionary(CaptionsDictionary);

        AddCaption(Captions, CaptionsDictionary, 'ApplyVoucherCaption', ApplyVoucherCaptionTxt);
        AddCaption(Captions, CaptionsDictionary, 'EnterRefNoCaption', EnterRefNoCaptionTxt);
    end;

    local procedure AddCaption(Captions: Codeunit "NPR POS Caption Management"; var CaptionsDictionary: Dictionary of [Text, Text]; CaptionId: Text; DefaultCaptionText: Text)
    var
        CaptionText: Text;
    begin
        if not CaptionsDictionary.Get(CaptionId, CaptionText) or (CaptionText = '') then
            CaptionText := DefaultCaptionText;
        Captions.AddActionCaption(ActionCode(), CaptionId, CaptionText);
    end;

    [EventSubscriber(ObjectType::Table, database::"NPR POS Parameter Value", 'OnLookupValue', '', true, false)]
    local procedure OnLookupVoucherTypeCode(var POSParameterValue: Record "NPR POS Parameter Value"; Handled: Boolean)
    var
        NpRvVoucherType: Record "NPR NpRv Voucher Type";
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;
        if POSParameterValue.Name <> 'VoucherTypeCode' then
            exit;

        Handled := true;

        if Page.RunModal(0, NpRvVoucherType) = Action::LookupOK then
            POSParameterValue.Value := NpRvVoucherType.Code;
    end;

    [EventSubscriber(ObjectType::Table, database::"NPR POS Parameter Value", 'OnValidateValue', '', true, false)]
    local procedure OnValidateVoucherTypeCode(var POSParameterValue: Record "NPR POS Parameter Value")
    var
        NpRvVoucherType: Record "NPR NpRv Voucher Type";
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;
        if POSParameterValue.Name <> 'VoucherTypeCode' then
            exit;
        if POSParameterValue.Value = '' then
            exit;

        POSParameterValue.Value := UpperCase(POSParameterValue.Value);
        if not NpRvVoucherType.Get(POSParameterValue.Value) then begin
            NpRvVoucherType.SetFilter(Code, '%1*', POSParameterValue.Value);
            if NpRvVoucherType.FindFirst then
                POSParameterValue.Value := NpRvVoucherType.Code;
        end;

        NpRvVoucherType.Get(POSParameterValue.Value);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnGetParameterNameCaption', '', true, false)]
    local procedure OnGetParameterNameCaption(POSParameterValue: Record "NPR POS Parameter Value"; var Caption: Text);
    var
        CaptionVoucherTypeCode: Label 'Voucher Type';
    begin
        if POSParameterValue."Action Code" <> ActionCode then
            exit;

        case POSParameterValue.Name of
            'VoucherTypeCode':
                Caption := CaptionVoucherTypeCode;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnGetParameterDescriptionCaption', '', true, false)]
    local procedure OnGetParameterDescriptionCaption(POSParameterValue: Record "NPR POS Parameter Value"; var Caption: Text);
    var
        DescVoucherTypeCode: Label 'Defines retail voucher type';
    begin
        if POSParameterValue."Action Code" <> ActionCode then
            exit;

        case POSParameterValue.Name of
            'VoucherTypeCode':
                Caption := DescVoucherTypeCode;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Workflows 2.0", 'OnAction', '', false, false)]
    local procedure OnAction20("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session"; State: Codeunit "NPR POS WF 2.0: State"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    begin
        if not Action.IsThisAction(ActionCode) then
            exit;

        Handled := true;

        ApplyVoucher(Context, POSSession, FrontEnd);

        POSSession.RequestRefreshData();
    end;

    local procedure ApplyVoucher(Context: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        NpRvVoucherBuffer: Record "NPR NpRv Voucher Buffer" temporary;
        SaleLinePOS: Record "NPR POS Sale Line";
        SalePOS: Record "NPR POS Sale";
        VoucherType: Record "NPR NpRv Voucher Type";
        NpRvVoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
        POSPaymentLine: Codeunit "NPR POS Payment Line";
        POSSale: Codeunit "NPR POS Sale";
        ReferenceNo: Text;
        VoucherTypeCode: Text;
        Handled: Boolean;
    begin
        Context.SetScopeParameters(ObjectIdentifier());
        VoucherTypeCode := UpperCase(Context.GetStringOrFail('VoucherTypeCode', ObjectIdentifier()));

        Context.SetScopeRoot();
        ReferenceNo := UpperCase(Context.GetStringOrFail('VourchRefNo', ObjectIdentifier()));
        if ReferenceNo = '' then
            exit;

        if not VoucherType.Get(VoucherTypeCode) then
            Clear(VoucherType);
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
        POSPaymentLine.GetPaymentLine(SaleLinePOS);

        SaleLinePOS."No." := VoucherType."Payment Type";
        SaleLinePOS."Register No." := SalePOS."Register No.";
        SaleLinePOS.Description := NpRvVoucherBuffer.Description;
        SaleLinePOS."Sales Ticket No." := SalePOS."Sales Ticket No.";
        SaleLinePOS."Amount Including VAT" := NpRvVoucherBuffer.Amount;
        POSPaymentLine.InsertPaymentLine(SaleLinePOS, 0);
        POSPaymentLine.GetCurrentPaymentLine(SaleLinePOS);

        NpRvSalesLine.Init;
        NpRvSalesLine.Id := CreateGuid;
        NpRvSalesLine."Document Source" := NpRvSalesLine."Document Source"::POS;
        NpRvSalesLine."Retail ID" := SaleLinePOS."Retail ID";
        NpRvSalesLine."Register No." := SalePOS."Register No.";
        NpRvSalesLine."Sales Ticket No." := SalePOS."Sales Ticket No.";
        NpRvSalesLine."Sale Type" := SaleLinePOS."Sale Type";
        NpRvSalesLine."Sale Date" := SaleLinePOS.Date;
        NpRvSalesLine."Sale Line No." := SaleLinePOS."Line No.";
        NpRvSalesLine.Type := NpRvSalesLine.Type::Payment;
        NpRvSalesLine."Voucher No." := NpRvVoucherBuffer."No.";
        NpRvSalesLine."Reference No." := NpRvVoucherBuffer."Reference No.";
        NpRvSalesLine."Voucher Type" := VoucherType.Code;
        NpRvSalesLine.Description := VoucherType.Description;
        NpRvSalesLine.Insert(true);

        NpRvVoucherMgt.ApplyPayment(FrontEnd, POSSession, NpRvSalesLine);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitializeCaptionsDictionary(var CaptionsDictionary: Dictionary of [Text, Text])
    begin
    end;
}