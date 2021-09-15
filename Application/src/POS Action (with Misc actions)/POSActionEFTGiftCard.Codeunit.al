codeunit 6150874 "NPR POS Action: EFT Gift Card"
{
    var
        ActionDescription: Label 'Sale of EFT Gift Cards';
        GIFTCARD_CAPTION_AMOUNT: Label 'Gift Card Amount';
        GIFTCARD_CAPTION_QTY: Label 'Number of Gift Cards';
        GIFTCARD_CAPTION_DISCOUNT: Label 'Gift Card Discount Percentage';
        DescPaymentType: Label 'The payment type to use for EFT & G/L Account setup';
        CaptionPaymentType: Label 'Payment Type';
        INVALID_GIFTCARD_QUANTITY: Label 'Number of giftcards must be between 1 and 100';
        INVALID_DISCOUNT: Label 'Discount percent must be between 0 and 100';
        INVALID_AMOUNT: Label 'Amount must be positive';
        DISCOUNT: Label 'Discount';
        CAPTION_QTY_PROMPT: Label 'Quantity Prompt';
        DESC_QTY_PROMPT: Label 'Prompt for number of gift cards to load';
        CAPTION_DISC_PROMPT: Label 'Discount Percent Prompt';
        DESC_DISC_PROMPT: Label 'Prompt for discount percentage to use for gift card';
        ReadingErr: Label 'reading in %1 of %2';

    local procedure ActionCode(): Code[20]
    begin
        exit('EFT_GIFT_CARD');
    end;

    local procedure ActionVersion(): Text[30]
    begin
        exit('1.3');
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Action", 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    begin
        if Sender.DiscoverAction(
            ActionCode(),
            ActionDescription,
            ActionVersion(),
            Sender.Type::Generic,
            Sender."Subscriber Instances Allowed"::Multiple) then begin
            Sender.RegisterWorkflowStep('QuantityPrompt', 'param.PromptQuantity && intpad({caption: labels.EftGiftcardCaptionQuantity, value: 1}).cancel(abort);');
            Sender.RegisterWorkflowStep('AmountPrompt', 'numpad({caption: labels.EftGiftcardCaptionAmount}).cancel(abort);');
            Sender.RegisterWorkflowStep('DiscountPctPrompt', 'param.PromptDiscountPct && numpad({caption: labels.EftGiftcardCaptionDiscount}).cancel(abort);');

            Sender.RegisterWorkflowStep('PrepareGiftCardLoop', 'respond();');
            Sender.RegisterWorkflowStep('LoadGiftCardAndInsertLine', 'respond();');
            Sender.RegisterWorkflowStep('InsertDiscountLine', 'respond();');
            Sender.RegisterWorkflowStep('GiftCardLoopIterate', 'respond();');

            Sender.RegisterWorkflowStep('RefreshUI', 'respond()');
            Sender.RegisterWorkflow(false);

            Sender.RegisterTextParameter('PaymentType', '');
            Sender.RegisterBooleanParameter('PromptDiscountPct', false);
            Sender.RegisterBooleanParameter('PromptQuantity', false);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS UI Management", 'OnInitializeCaptions', '', true, true)]
    local procedure OnInitializeCaptions(Captions: Codeunit "NPR POS Caption Management")
    begin
        Captions.AddActionCaption(ActionCode(), 'EftGiftcardCaptionAmount', GIFTCARD_CAPTION_AMOUNT);
        Captions.AddActionCaption(ActionCode(), 'EftGiftcardCaptionDiscount', GIFTCARD_CAPTION_DISCOUNT);
        Captions.AddActionCaption(ActionCode(), 'EftGiftcardCaptionQuantity', GIFTCARD_CAPTION_QTY);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS JavaScript Interface", 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        JSON: Codeunit "NPR POS JSON Management";
    begin
        if not Action.IsThisAction(ActionCode()) then
            exit;
        Handled := true;

        JSON.InitializeJObjectParser(Context, FrontEnd);

        case WorkflowStep of
            'RefreshUI':
                ;
            'PrepareGiftCardLoop':
                PrepareGiftCardLoop(POSSession, JSON);
            'LoadGiftCardAndInsertLine':
                LoadGiftCard(POSSession, FrontEnd);
            'InsertDiscountLine':
                InsertVoucherDiscountLine(POSSession);
            'GiftCardLoopIterate':
                GiftCardLoopIterate(POSSession, FrontEnd);
        end;
    end;

    local procedure GetNumpadValue(JSON: Codeunit "NPR POS JSON Management"; Path: Text): Decimal
    begin
        JSON.SetScopeRoot();
        if (not JSON.SetScope('$' + Path)) then
            exit(0);

        exit(JSON.GetDecimalOrFail('numpad', StrSubstNo(ReadingErr, 'GetNumpadValue', ActionCode())));
    end;

    local procedure GetIntpadValue(JSON: Codeunit "NPR POS JSON Management"; Path: Text): Decimal
    begin
        JSON.SetScopeRoot();
        if (not JSON.SetScope('$' + Path)) then
            exit(0);

        exit(JSON.GetDecimalOrFail('numpad', StrSubstNo(ReadingErr, 'GetInpadValue', ActionCode())));
    end;

    local procedure PrepareGiftCardLoop(POSSession: Codeunit "NPR POS Session"; JSON: Codeunit "NPR POS JSON Management")
    var
        PaymentType: Text;
        Amount: Decimal;
        DiscountPercent: Decimal;
        NoOfVouchers: Integer;
    begin
        PrepareGiftCardLoopJSONParse(JSON, PaymentType, Amount, DiscountPercent, NoOfVouchers);
        PrepareGiftCardLoopBusinessLogic(POSSession, PaymentType, Amount, DiscountPercent, NoOfVouchers);
    end;

    local procedure PrepareGiftCardLoopJSONParse(JSON: Codeunit "NPR POS JSON Management"; var PaymentType: Text; var Amount: Decimal; var DiscountPercent: Decimal; var NoOfVouchers: Integer)
    begin
        PaymentType := JSON.GetStringParameterOrFail('PaymentType', ActionCode());
        Amount := GetNumpadValue(JSON, 'AmountPrompt');
        DiscountPercent := GetNumpadValue(JSON, 'DiscountPctPrompt');
        NoOfVouchers := GetIntpadValue(JSON, 'QuantityPrompt');
    end;

    procedure PrepareGiftCardLoopBusinessLogic(POSSession: Codeunit "NPR POS Session"; PaymentType: Text; Amount: Decimal; DiscountPercent: Decimal; NoOfVouchers: Integer)
    var
        POSSale: Codeunit "NPR POS Sale";
        SalePOS: Record "NPR POS Sale";
    begin
        if NoOfVouchers = 0 then
            NoOfVouchers := 1;

        if (NoOfVouchers < 1) or (NoOfVouchers > 100) then
            Error(INVALID_GIFTCARD_QUANTITY);
        if (DiscountPercent < 0) or (DiscountPercent > 100) then
            Error(INVALID_DISCOUNT);
        if (Amount < 0) then
            Error(INVALID_AMOUNT);

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        POSSession.ClearActionState();
        POSSession.BeginAction(ActionCode());
        POSSession.StoreActionState('eft_gift_card_payment_type', PaymentType);
        POSSession.StoreActionState('eft_gift_card_amount', Amount);
        POSSession.StoreActionState('eft_gift_card_discount_percent', DiscountPercent);
        POSSession.StoreActionState('eft_gift_card_total_number', NoOfVouchers);
        POSSession.StoreActionState('eft_gift_card_current_number', 1);
    end;

    procedure LoadGiftCard(POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"): Integer
    var
        Amount: Decimal;
        PaymentType: Text;
        EftEntryNo: Integer;
        Variant: Variant;
        POSSale: Codeunit "NPR POS Sale";
        EFTSetup: Record "NPR EFT Setup";
        SalePOS: Record "NPR POS Sale";
        POSPaymentMethod: Record "NPR POS Payment Method";
        EFTPaymentMgt: Codeunit "NPR EFT Transaction Mgt.";
    begin
        POSSession.RetrieveActionState('eft_gift_card_amount', Variant);
        Amount := Variant;
        POSSession.RetrieveActionState('eft_gift_card_payment_type', Variant);
        PaymentType := Variant;

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        POSPaymentMethod.Get(PaymentType);

        EFTSetup.FindSetup(SalePOS."Register No.", POSPaymentMethod.Code);
        EFTPaymentMgt.GetPOSPostingSetupAccountNo(POSSession, POSPaymentMethod.Code);

        EftEntryNo := EFTPaymentMgt.StartGiftCardLoad(EFTSetup, Amount, '', SalePOS);
        POSSession.StoreActionState('eft_gift_card_entry_no', EftEntryNo);

        exit(EftEntryNo);
    end;

    procedure InsertVoucherDiscountLine(POSSession: Codeunit "NPR POS Session"): Guid
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        EFTTransactionMgt: Codeunit "NPR EFT Transaction Mgt.";
        LineAmount: Decimal;
        EftEntryNo: Integer;
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        Amount: Decimal;
        DiscountPercent: Decimal;
        Currency: Record Currency;
        Variant: Variant;
    begin
        POSSession.RetrieveActionState('eft_gift_card_entry_no', Variant);
        EftEntryNo := Variant;
        POSSession.RetrieveActionState('eft_gift_card_discount_percent', Variant);
        DiscountPercent := Variant;
        POSSession.RetrieveActionState('eft_gift_card_amount', Variant);
        Amount := Variant;

        EFTTransactionRequest.Get(EftEntryNo);
        if (not EFTTransactionRequest.Successful) or (EFTTransactionRequest."Result Amount" = 0) or (EFTTransactionRequest."Processing Type" <> EFTTransactionRequest."Processing Type"::GIFTCARD_LOAD) then begin
            Error('');
        end;
        EFTTransactionRequest.TestField(Successful);
        EFTTransactionRequest.TestField("Result Amount");

        if DiscountPercent = 0 then
            exit;

        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetNewSaleLine(SaleLinePOS);


        if SaleLinePOS."Currency Code" = '' then begin
            Currency.InitRoundingPrecision();
        end else begin
            Currency.Get(SaleLinePOS."Currency Code");
        end;

        LineAmount := Round((Amount / 100) * (DiscountPercent), Currency."Amount Rounding Precision") * -1;

        SaleLinePOS.Validate("Sale Type", SaleLinePOS."Sale Type"::Deposit);
        SaleLinePOS.Validate(Type, SaleLinePOS.Type::"G/L Entry");
        SaleLinePOS.Validate("No.", EFTTransactionMgt.GetPOSPostingSetupAccountNo(POSSession, EFTTransactionRequest."Original POS Payment Type Code"));
        SaleLinePOS.Validate(Quantity, 1);
        SaleLinePOS.Description := CopyStr(SaleLinePOS.Description + ' - ' + DISCOUNT, 1, MaxStrLen(SaleLinePOS.Description));
        SaleLinePOS.Validate("Unit Price", LineAmount);
        SaleLinePOS.Validate("Amount Including VAT", LineAmount);
        SaleLinePOS.UpdateAmounts(SaleLinePOS);
        POSSaleLine.InsertLineRaw(SaleLinePOS, true);

        POSSession.RequestRefreshData();

        exit(SaleLinePOS.SystemId);
    end;

    local procedure GiftCardLoopIterate(POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        TotalNumber: Integer;
        CurrentNumber: Integer;
        Variant: Variant;
    begin
        POSSession.RetrieveActionState('eft_gift_card_total_number', Variant);
        TotalNumber := Variant;
        POSSession.RetrieveActionState('eft_gift_card_current_number', Variant);
        CurrentNumber := Variant;

        if CurrentNumber >= TotalNumber then
            exit; //Done

        POSSession.StoreActionState('eft_gift_card_current_number', CurrentNumber + 1);
        FrontEnd.ContinueAtStep('LoadGiftCardAndInsertLine');
    end;


    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnGetParameterNameCaption', '', false, false)]
    local procedure OnGetParameterNameCaption(POSParameterValue: Record "NPR POS Parameter Value"; var Caption: Text)
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;

        case POSParameterValue.Name of
            'PaymentType':
                Caption := CaptionPaymentType;
            'PromptDiscountPct':
                Caption := CAPTION_DISC_PROMPT;
            'PromptQuantity':
                Caption := CAPTION_QTY_PROMPT;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnGetParameterDescriptionCaption', '', false, false)]
    local procedure OnGetParameterDescriptionCaption(POSParameterValue: Record "NPR POS Parameter Value"; var Caption: Text)
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;

        case POSParameterValue.Name of
            'PaymentType':
                Caption := DescPaymentType;
            'PromptDiscountPct':
                Caption := DESC_DISC_PROMPT;
            'PromptQuantity':
                Caption := DESC_QTY_PROMPT;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnLookupValue', '', false, false)]
    local procedure OnLookupParameter(var POSParameterValue: Record "NPR POS Parameter Value"; Handled: Boolean)
    var
        POSPaymentMethod: Record "NPR POS Payment Method";
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;

        case POSParameterValue.Name of
            'PaymentType':
                begin
                    POSPaymentMethod.SetRange("Processing Type", POSPaymentMethod."Processing Type"::Voucher);
                    if PAGE.RunModal(0, POSPaymentMethod) = ACTION::LookupOK then
                        POSParameterValue.Validate(Value, POSPaymentMethod.Code);
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnValidateValue', '', false, false)]
    local procedure OnValidateParameter(var POSParameterValue: Record "NPR POS Parameter Value")
    var
        POSPaymentMethod: Record "NPR POS Payment Method";
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;

        case POSParameterValue.Name of
            'PaymentType':
                begin
                    if POSParameterValue.Value <> '' then begin
                        POSPaymentMethod.Get(POSParameterValue.Value);
                        POSPaymentMethod.TestField("Processing Type", POSPaymentMethod."Processing Type"::Voucher);
                    end;
                end;
        end;
    end;
}
