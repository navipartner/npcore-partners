codeunit 6150874 "POS Action - EFT Gift Card"
{
    // NPR5.51/MMV /20190625 CASE 359385 Created object


    trigger OnRun()
    begin
    end;

    var
        ActionDescription: Label 'Sale of EFT Gift Cards';
        GIFTCARD_CAPTION: Label 'Gift Card Amount';
        DescPaymentType: Label 'The payment type to use for EFT & G/L Account setup';
        CaptionPaymentType: Label 'Payment Type';

    local procedure ActionCode(): Text
    begin
        exit ('EFT_GIFT_CARD');
    end;

    local procedure ActionVersion(): Text
    begin
        exit ('1.1');
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "POS Action")
    begin
        with Sender do begin
          if DiscoverAction(
            ActionCode(),
            ActionDescription,
            ActionVersion(),
            Sender.Type::Generic,
            Sender."Subscriber Instances Allowed"::Multiple) then
          begin
            RegisterWorkflowStep('AmountPrompt','numpad({caption: labels.EftGiftcardCaption}).respond();');
            RegisterWorkflowStep('RefreshUI', 'respond()');
            RegisterWorkflow(false);

            RegisterTextParameter('PaymentType', '');
          end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150702, 'OnInitializeCaptions', '', true, true)]
    local procedure OnInitializeCaptions(Captions: Codeunit "POS Caption Management")
    begin
        Captions.AddActionCaption (ActionCode, 'EftGiftcardCaption', GIFTCARD_CAPTION);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "POS Action";WorkflowStep: Text;Context: DotNet npNetJObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    var
        JSON: Codeunit "POS JSON Management";
        PaymentType: Text;
        Amount: Decimal;
        EFTGiftCardMgt: Codeunit "EFT Gift Card Mgt.";
        EFTSetup: Record "EFT Setup";
        PaymentTypePOS: Record "Payment Type POS";
        POSSale: Codeunit "POS Sale";
        SalePOS: Record "Sale POS";
    begin
        if not Action.IsThisAction(ActionCode) then
          exit;
        Handled := true;

        if WorkflowStep = 'RefreshUI' then
          exit;

        JSON.InitializeJObjectParser(Context, FrontEnd);
        PaymentType := JSON.GetStringParameter('PaymentType', true);
        Amount := GetNumpadValue(JSON, 'AmountPrompt');

        PaymentTypePOS.Get(PaymentType);
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        EFTSetup.FindSetup(SalePOS."Register No.", PaymentTypePOS."No.");

        FrontEnd.PauseWorkflow();
        EFTGiftCardMgt.StartGiftCardLoadTransaction(EFTSetup, PaymentTypePOS, Amount, '', SalePOS);
    end;

    local procedure GetNumpadValue(JSON: Codeunit "POS JSON Management";Path: Text): Decimal
    begin
        JSON.SetScope ('/', true);
        if (not JSON.SetScope ('$'+Path, false)) then
          exit (0);

        exit (JSON.GetDecimal ('numpad', true));
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnGetParameterNameCaption', '', false, false)]
    procedure OnGetParameterNameCaption(POSParameterValue: Record "POS Parameter Value";var Caption: Text)
    begin
        if POSParameterValue."Action Code" <> ActionCode then
          exit;

        case POSParameterValue.Name of
          'PaymentType' : Caption := CaptionPaymentType;
        end;
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnGetParameterDescriptionCaption', '', false, false)]
    procedure OnGetParameterDescriptionCaption(POSParameterValue: Record "POS Parameter Value";var Caption: Text)
    begin
        if POSParameterValue."Action Code" <> ActionCode then
          exit;

        case POSParameterValue.Name of
          'PaymentType' : Caption := DescPaymentType;
        end;
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnLookupValue', '', false, false)]
    local procedure OnLookupParameter(var POSParameterValue: Record "POS Parameter Value";Handled: Boolean)
    var
        PaymentTypePOS: Record "Payment Type POS";
    begin
        if POSParameterValue."Action Code" <> ActionCode then
          exit;

        case POSParameterValue.Name of
          'PaymentType' :
            begin
              PaymentTypePOS.SetRange("Processing Type", PaymentTypePOS."Processing Type"::"Gift Voucher");
              PaymentTypePOS.SetRange("Via Terminal", true);
              if PAGE.RunModal(0, PaymentTypePOS) = ACTION::LookupOK then
                POSParameterValue.Validate(Value, PaymentTypePOS."No.");
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnValidateValue', '', false, false)]
    local procedure OnValidateParameter(var POSParameterValue: Record "POS Parameter Value")
    var
        PaymentTypePOS: Record "Payment Type POS";
    begin
        if POSParameterValue."Action Code" <> ActionCode then
          exit;

        case POSParameterValue.Name of
          'PaymentType' :
            begin
              if POSParameterValue.Value <> '' then begin
                PaymentTypePOS.Get(POSParameterValue.Value, '');
                PaymentTypePOS.TestField("Via Terminal", true);
                PaymentTypePOS.TestField("Processing Type", PaymentTypePOS."Processing Type"::"Gift Voucher");
              end;
            end;
        end;
    end;
}

