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

    local procedure ActionCode(): Text
    begin
        exit('EFT_GIFT_CARD');
    end;

    local procedure ActionVersion(): Text
    begin
        exit('1.3'); //-+NPR5.53 [375525]
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    begin
        with Sender do begin
            if DiscoverAction(
              ActionCode(),
              ActionDescription,
              ActionVersion(),
              Sender.Type::Generic,
              Sender."Subscriber Instances Allowed"::Multiple) then begin
                //-NPR5.53 [375525]
                RegisterWorkflowStep('QuantityPrompt', 'param.PromptQuantity && intpad({caption: labels.EftGiftcardCaptionQuantity, value: 1}).cancel(abort);');
                RegisterWorkflowStep('AmountPrompt', 'numpad({caption: labels.EftGiftcardCaptionAmount}).cancel(abort);');
                RegisterWorkflowStep('DiscountPctPrompt', 'param.PromptDiscountPct && numpad({caption: labels.EftGiftcardCaptionDiscount}).cancel(abort);');

                RegisterWorkflowStep('PrepareGiftCardLoop', 'respond();');
                RegisterWorkflowStep('LoadGiftCardAndInsertLine', 'respond();');
                RegisterWorkflowStep('InsertDiscountLine', 'respond();');
                RegisterWorkflowStep('GiftCardLoopIterate', 'respond();');
                //+NPR5.53 [375525]

                RegisterWorkflowStep('RefreshUI', 'respond()');
                RegisterWorkflow(false);

                RegisterTextParameter('PaymentType', '');
                //-NPR5.53 [375525]
                RegisterBooleanParameter('PromptDiscountPct', false);
                RegisterBooleanParameter('PromptQuantity', false);
                //+NPR5.53 [375525]
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150702, 'OnInitializeCaptions', '', true, true)]
    local procedure OnInitializeCaptions(Captions: Codeunit "NPR POS Caption Management")
    begin
        //-NPR5.53 [375525]
        Captions.AddActionCaption(ActionCode, 'EftGiftcardCaptionAmount', GIFTCARD_CAPTION_AMOUNT);
        Captions.AddActionCaption(ActionCode, 'EftGiftcardCaptionDiscount', GIFTCARD_CAPTION_DISCOUNT);
        Captions.AddActionCaption(ActionCode, 'EftGiftcardCaptionQuantity', GIFTCARD_CAPTION_QTY);
        //+NPR5.53 [375525]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        JSON: Codeunit "NPR POS JSON Management";
        PaymentType: Text;
        Amount: Decimal;
        EFTSetup: Record "NPR EFT Setup";
        POSSale: Codeunit "NPR POS Sale";
        SalePOS: Record "NPR Sale POS";
    begin
        if not Action.IsThisAction(ActionCode) then
            exit;
        Handled := true;

        //-NPR5.53 [375525]
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
        //-NPR5.53 [375525]
    end;

    local procedure GetNumpadValue(JSON: Codeunit "NPR POS JSON Management"; Path: Text): Decimal
    begin
        JSON.SetScope('/', true);
        if (not JSON.SetScope('$' + Path, false)) then
            exit(0);

        exit(JSON.GetDecimal('numpad', true));
    end;

    local procedure GetIntpadValue(JSON: Codeunit "NPR POS JSON Management"; Path: Text): Decimal
    begin
        //-NPR5.53 [375525]
        JSON.SetScope('/', true);
        if (not JSON.SetScope('$' + Path, false)) then
            exit(0);

        exit(JSON.GetDecimal('numpad', true));
        //+NPR5.53 [375525]
    end;

    local procedure PrepareGiftCardLoop(POSSession: Codeunit "NPR POS Session"; JSON: Codeunit "NPR POS JSON Management")
    var
        PaymentType: Text;
        Amount: Decimal;
        DiscountPercent: Decimal;
        NoOfVouchers: Integer;
    begin
        //-NPR5.54 [364340]
        PrepareGiftCardLoopJSONParse(JSON, PaymentType, Amount, DiscountPercent, NoOfVouchers);
        PrepareGiftCardLoopBusinessLogic(POSSession, PaymentType, Amount, DiscountPercent, NoOfVouchers);
        //-NPR5.54 [364340]
    end;

    local procedure PrepareGiftCardLoopJSONParse(JSON: Codeunit "NPR POS JSON Management"; var PaymentType: Text; var Amount: Decimal; var DiscountPercent: Decimal; var NoOfVouchers: Integer)
    begin
        //-NPR5.54 [364340]
        PaymentType := JSON.GetStringParameter('PaymentType', true);
        Amount := GetNumpadValue(JSON, 'AmountPrompt');
        DiscountPercent := GetNumpadValue(JSON, 'DiscountPctPrompt');
        NoOfVouchers := GetIntpadValue(JSON, 'QuantityPrompt');
        //+NPR5.54 [364340]
    end;

    procedure PrepareGiftCardLoopBusinessLogic(POSSession: Codeunit "NPR POS Session"; PaymentType: Text; Amount: Decimal; DiscountPercent: Decimal; NoOfVouchers: Integer)
    var
        POSSale: Codeunit "NPR POS Sale";
        SalePOS: Record "NPR Sale POS";
    begin
        //-NPR5.54 [364340]
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
        //+NPR5.54 [364340]
    end;

    procedure LoadGiftCard(POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"): Integer
    var
        Amount: Decimal;
        PaymentType: Text;
        EftEntryNo: Integer;
        Variant: Variant;
        POSSale: Codeunit "NPR POS Sale";
        EFTSetup: Record "NPR EFT Setup";
        SalePOS: Record "NPR Sale POS";
        POSPaymentMethod: Record "NPR POS Payment Method";
        EFTPaymentMgt: Codeunit "NPR EFT Transaction Mgt.";
    begin
        //-NPR5.53 [375525]
        POSSession.RetrieveActionState('eft_gift_card_amount', Variant);
        Amount := Variant;
        POSSession.RetrieveActionState('eft_gift_card_payment_type', Variant);
        PaymentType := Variant;

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        POSPaymentMethod.Get(PaymentType);
        EFTSetup.FindSetup(SalePOS."Register No.", POSPaymentMethod.Code);

        //-NPR5.54 [364340]
        EftEntryNo := EFTPaymentMgt.StartGiftCardLoad(EFTSetup, Amount, '', SalePOS);
        //+NPR5.54 [364340]
        POSSession.StoreActionState('eft_gift_card_entry_no', EftEntryNo);
        //+NPR5.53 [375525]

        //-NPR5.54 [364340]
        exit(EftEntryNo);
        //+NPR5.54 [364340]
    end;

    procedure InsertVoucherDiscountLine(POSSession: Codeunit "NPR POS Session"): Guid
    var
        SaleLinePOS: Record "NPR Sale Line POS";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSPaymentMethod: Record "NPR POS Payment Method";
        LineAmount: Decimal;
        EftEntryNo: Integer;
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        Amount: Decimal;
        DiscountPercent: Decimal;
        Currency: Record Currency;
        Variant: Variant;
    begin
        //-NPR5.53 [375525]
        POSSession.RetrieveActionState('eft_gift_card_entry_no', Variant);
        EftEntryNo := Variant;
        POSSession.RetrieveActionState('eft_gift_card_discount_percent', Variant);
        DiscountPercent := Variant;
        POSSession.RetrieveActionState('eft_gift_card_amount', Variant);
        Amount := Variant;

        //-NPR5.54 [364340]
        EFTTransactionRequest.Get(EftEntryNo);
        if (not EFTTransactionRequest.Successful) or (EFTTransactionRequest."Result Amount" = 0) or (EFTTransactionRequest."Processing Type" <> EFTTransactionRequest."Processing Type"::GIFTCARD_LOAD) then begin
            Error('');
        end;
        EFTTransactionRequest.TestField(Successful);
        EFTTransactionRequest.TestField("Result Amount");
        //+NPR5.54 [364340]

        if DiscountPercent = 0 then
            exit;

        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetNewSaleLine(SaleLinePOS);
        POSPaymentMethod.Get(EFTTransactionRequest."Original POS Payment Type Code");

        if SaleLinePOS."Currency Code" = '' then begin
            Currency.InitRoundingPrecision();
        end else begin
            Currency.Get(SaleLinePOS."Currency Code");
        end;

        LineAmount := Round((Amount / 100) * (DiscountPercent), Currency."Amount Rounding Precision") * -1;

        SaleLinePOS.Validate("Sale Type", SaleLinePOS."Sale Type"::Deposit);
        SaleLinePOS.Validate(Type, SaleLinePOS.Type::"G/L Entry");
        SaleLinePOS.Validate("No.", POSPaymentMethod."Account No.");
        SaleLinePOS.Validate(Quantity, 1);
        SaleLinePOS.Description := CopyStr(SaleLinePOS.Description + ' - ' + DISCOUNT, 1, MaxStrLen(SaleLinePOS.Description));
        SaleLinePOS.Validate("Unit Price", LineAmount);
        SaleLinePOS.Validate("Amount Including VAT", LineAmount);
        SaleLinePOS.UpdateAmounts(SaleLinePOS);
        POSSaleLine.InsertLineRaw(SaleLinePOS, true);

        POSSession.RequestRefreshData();
        //+NPR5.53 [375525]

        //-NPR5.54 [364340]
        exit(SaleLinePOS."Retail ID");
        //+NPR5.54 [364340]
    end;

    local procedure GiftCardLoopIterate(POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        TotalNumber: Integer;
        CurrentNumber: Integer;
        Variant: Variant;
    begin
        //-NPR5.53 [375525]
        POSSession.RetrieveActionState('eft_gift_card_total_number', Variant);
        TotalNumber := Variant;
        POSSession.RetrieveActionState('eft_gift_card_current_number', Variant);
        CurrentNumber := Variant;

        if CurrentNumber >= TotalNumber then
            exit; //Done

        POSSession.StoreActionState('eft_gift_card_current_number', CurrentNumber + 1);
        FrontEnd.ContinueAtStep('LoadGiftCardAndInsertLine');
        //+NPR5.53 [375525]
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnGetParameterNameCaption', '', false, false)]
    procedure OnGetParameterNameCaption(POSParameterValue: Record "NPR POS Parameter Value"; var Caption: Text)
    begin
        if POSParameterValue."Action Code" <> ActionCode then
            exit;

        case POSParameterValue.Name of
            'PaymentType':
                Caption := CaptionPaymentType;
            //-NPR5.53 [375525]
            'PromptDiscountPct':
                Caption := CAPTION_DISC_PROMPT;
            'PromptQuantity':
                Caption := CAPTION_QTY_PROMPT;
        //+NPR5.53 [375525]
        end;
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnGetParameterDescriptionCaption', '', false, false)]
    procedure OnGetParameterDescriptionCaption(POSParameterValue: Record "NPR POS Parameter Value"; var Caption: Text)
    begin
        if POSParameterValue."Action Code" <> ActionCode then
            exit;

        case POSParameterValue.Name of
            'PaymentType':
                Caption := DescPaymentType;
            //-NPR5.53 [375525]
            'PromptDiscountPct':
                Caption := DESC_DISC_PROMPT;
            'PromptQuantity':
                Caption := DESC_QTY_PROMPT;
        //+NPR5.53 [375525]
        end;
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnLookupValue', '', false, false)]
    local procedure OnLookupParameter(var POSParameterValue: Record "NPR POS Parameter Value"; Handled: Boolean)
    var
        POSPaymentMethod: Record "NPR POS Payment Method";
    begin
        if POSParameterValue."Action Code" <> ActionCode then
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

    [EventSubscriber(ObjectType::Table, 6150705, 'OnValidateValue', '', false, false)]
    local procedure OnValidateParameter(var POSParameterValue: Record "NPR POS Parameter Value")
    var
        POSPaymentMethod: Record "NPR POS Payment Method";
    begin
        if POSParameterValue."Action Code" <> ActionCode then
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

