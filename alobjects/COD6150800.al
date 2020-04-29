codeunit 6150800 "POS Action - Sale Gift Voucher"
{
    // // TODO - request workflow step - this should happen automatically after action callback is received in javascript
    // //        - so, no direct invocation of next step, it just happens
    // NPR5.48/TSA /20190207 CASE 345292 SalesLine UpdateAmounts() needs to invoked to get the VAT fields correctly initialized
    // NPR5.53/ALPO/20191025 CASE 371956 Dimensions: POS Store & POS Unit integration; discontinue dimensions on Cash Register
    // NPR5.53/YAHA/20191114 CASE 376207 Parameter being taken from the Retail setup for gift menu sale


    trigger OnRun()
    begin
    end;

    var
        ActionDescription: Label 'This is a built in function for handling sales of Gift Vouchers';
        PaymentTypeNotFound: Label '%1 %2 for register %3 was not found.';
        TextAmount: Label 'Enter Amount:';
        Setup: Codeunit "POS Setup";
        TextQuantity: Label 'Enter Quantity:';
        TextDiscountAmount: Label 'Enter Discount Amount:';
        TextDiscountPercent: Label 'Enter Discount Percentage:';
        TextBarcode: Label 'Enter Voucher Barcode:';
        TextVoucherNo: Label 'Enter Voucher Number:';
        TextAmountTitle: Label 'Specify Voucher Amount.';
        TextQuantityTitle: Label 'Specify Number of Vouchers.';
        TextDiscountTitle: Label 'Specify Discount.';
        TextBarcodeTitle: Label 'Specify Voucher Barcode.';
        DiscountType: Option AMOUNT,PERCENTAGE;
        TextVoucherTitle: Label 'Specify Voucher Number.';
        ActivationFailed: Label 'The gift card activation failed.\Do you want to try again?';
        ReadyToActivateMessage: Label 'Create voucher %1 of %2.';
        DiscountReference: Label 'Discount for Gift Voucher %1';
        NotFound: Label 'No %1 found with %2 %3 and %4 %5.';
        ConfirmCharge: Label 'Prepare to load voucher %1 (of %2)?';
        ConfirmCreate: Label 'Create %1 gift vouchers with value %2 and sales price %3?';
        NotSupported: Label 'Setting %1 on %2 %3 is not supported.';
        MaxAmountLimit: Label 'Maximum payment amount for %1 is %2.';
        MinAmountLimit: Label 'Minimum payment amount for %1 is %2.';
        Text0002: Label 'Gift Voucher %1 already exists with the amount of %2\\Would you like to renew this card?';
        TextNoManualMultiple: Label 'Gift Vouchers cannot have a custom numbers when inserting multiple Gift Vouchers. Please enter Gift Vouchers with custom numbers one at a time. ';

    local procedure ActionCode(): Text
    begin
        exit ('SALE_GIFTVOUCHER');
    end;

    local procedure ActionVersion(): Text
    begin
        exit ('1.0');
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
            RegisterWorkflowStep('quantity','context.prompt_quantity && numpad(labels.quantity_description,labels.quantity,context.quantity).cancel(abort);');
            RegisterWorkflowStep('amount','numpad(labels.amount_title, labels.amount,context.voucher_amount).cancel(abort);');
            RegisterWorkflowStep('discount_amount','context.prompt_discount_amount && numpad(labels.discount_title,labels.discount_amount,context.discount);');
            RegisterWorkflowStep('discount_percent','context.prompt_discount_percent && numpad(labels.discount_title,labels.discount_percent,context.discount);');
            //RegisterWorkflowStep('barcode', 'context.prompt_barcode && input(context.barcode_title,labels.barcode);');
            RegisterWorkflowStep('voucherno', 'context.prompt_voucherno && input({caption: context.voucherno_title,title: labels.voucherno,value: context.generatedvoucherno}).cancel(abort);');
            RegisterWorkflowStep('process_sale','respond();');
            RegisterWorkflowStep('editvoucherinfo','context.prompt_editvoucher && respond();');
            RegisterWorkflow(true);

            RegisterOptionParameter('DiscountType','Amount,Percentage,PaymentType','Amount');
            RegisterTextParameter('PaymentType', 'G');
          end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150702, 'OnInitializeCaptions', '', true, true)]
    local procedure OnInitializeCaptions(Captions: Codeunit "POS Caption Management")
    var
        UI: Codeunit "POS UI Management";
    begin

        Captions.AddActionCaption (ActionCode, 'amount', TextAmount);
        Captions.AddActionCaption (ActionCode, 'quantity', TextQuantity);
        Captions.AddActionCaption (ActionCode, 'discount_amount', TextDiscountAmount);
        Captions.AddActionCaption (ActionCode, 'discount_percent', TextDiscountPercent);
        Captions.AddActionCaption (ActionCode, 'barcode', TextBarcode);
        Captions.AddActionCaption (ActionCode, 'voucherno', TextVoucherNo);

        Captions.AddActionCaption (ActionCode, 'amount_title', TextAmountTitle);
        Captions.AddActionCaption (ActionCode, 'quantity_title', TextQuantityTitle);
        Captions.AddActionCaption (ActionCode, 'discount_title', TextDiscountTitle);
        Captions.AddActionCaption (ActionCode, 'barcode_title', TextBarcodeTitle);
        Captions.AddActionCaption (ActionCode, 'voucherno_title', TextVoucherTitle);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "POS Action";WorkflowStep: Text;Context: DotNet npNetJObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    var
        JSON: Codeunit "POS JSON Management";
        VoucherNo: Code[20];
    begin
        if not Action.IsThisAction(ActionCode) then
          exit;

        // TODO: Remove this
        //MESSAGE('DEBUG: %3 in step - %1!\\%2', WorkflowStep, Context.ToString(), ActionCode());
        POSSession.GetSetup (Setup);

        case WorkflowStep of
          'process_sale': OnProcessSale(POSSession,FrontEnd,Context);
          'editvoucherinfo' :
            begin
              JSON.InitializeJObjectParser (Context,FrontEnd);
              JSON.SetScope('$voucherno',true);
              VoucherNo := JSON.GetString ('input', true);
              //xx FrontEnd.PauseWorkflow;
              SetGiftVoucherInfo(POSSession,VoucherNo);
              //xx FrontEnd.ResumeWorkflow;
            end;
        end;

        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnBeforeWorkflow', '', true, true)]
    local procedure OnBeforeWorkflow("Action": Record "POS Action";Parameters: DotNet npNetJObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    var
        Context: Codeunit "POS JSON Management";
        JSON: Codeunit "POS JSON Management";
        POSPaymentLine: Codeunit "POS Payment Line";
        NoSeriesManagement: Codeunit NoSeriesManagement;
        Utility: Codeunit Utility;
        RetailSetup: Record "Retail Setup";
        PaymentTypePOS: Record "Payment Type POS";
        Register: Record Register;
        ItemNo: Code[20];
        TempVoucherNo: Code[20];
    begin

        if not Action.IsThisAction(ActionCode()) then
          exit;

        RetailSetup.Get ();
        POSSession.GetSetup (Setup);
        Register.Get (Setup.Register());
        ValidateSetupBeforeWorkflow (Register);

        JSON.InitializeJObjectParser (Parameters,FrontEnd);
        DiscountType := JSON.GetInteger ('DiscountType', true);

        ItemNo := SelectVoucherToSell (JSON.GetString ('PaymentType', true));
        Context.SetContext ('VoucherItemNo', ItemNo);

        POSSession.GetPaymentLine (POSPaymentLine);
        if (not POSPaymentLine.GetPaymentType(PaymentTypePOS, ItemNo, Setup.Register())) then
          Error (PaymentTypeNotFound, PaymentTypePOS.TableCaption, ItemNo, Setup.Register());

        Context.SetContext ('prompt_discount_amount', RetailSetup."Popup Gift Voucher Quantity" and (DiscountType = DiscountType::AMOUNT));
        Context.SetContext ('prompt_discount_percent', RetailSetup."Popup Gift Voucher Quantity" and (DiscountType = DiscountType::PERCENTAGE));

        //-NPR5.53 [376207]
        Context.SetContext ('prompt_quantity', RetailSetup."Popup Gift Voucher Quantity");
        //Context.SetContext ('prompt_quantity', FALSE);
        //+NPR5.53 [376207]



        //Context.SetContext ('prompt_barcode', PaymentTypePOS."PBS Gift Voucher Barcode");
        Context.SetContext ('prompt_voucherno', true);
        TempVoucherNo := NoSeriesManagement.GetNextNo(RetailSetup."Gift Voucher No. Management",Today,false);
        if RetailSetup."EAN Mgt. Gift voucher" <> '' then
          TempVoucherNo := Utility.CreateEAN(TempVoucherNo, Format(RetailSetup."EAN Mgt. Gift voucher") );
        Context.SetContext ('generatedvoucherno', TempVoucherNo );
        Context.SetContext ('prompt_editvoucher', RetailSetup."Show Create Giftcertificat" );



        // Suggested / default values
        Context.SetContext ('quantity', 1);
        Context.SetContext ('discount', 0.0);

        FrontEnd.SetActionContext (ActionCode(), Context);
        Handled := true;
    end;

    local procedure OnProcessSale(POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";Context: DotNet npNetJObject)
    var
        JSON: Codeunit "POS JSON Management";
        POSPaymentLine: Codeunit "POS Payment Line";
        POSSaleLine: Codeunit "POS Sale Line";
        Register: Record Register;
        PaymentTypePOS: Record "Payment Type POS";
        SaleLine: Record "Sale Line POS";
        PaymentLine: Record "Sale Line POS";
        DiscountLine: Record "Sale Line POS";
        SalesQuantity: Decimal;
        UnitAmount: Decimal;
        UnitDiscountAmount: Decimal;
        Barcode: Text[30];
        CardActivated: Boolean;
        VoucherItemNo: Code[20];
        VoucherNo: Code[20];
        GeneratedVoucherNo: Code[20];
        VoucherCount: Integer;
    begin

        POSSession.GetPaymentLine(POSPaymentLine);
        POSSession.GetSaleLine(POSSaleLine);

        JSON.InitializeJObjectParser (Context,FrontEnd);
        VoucherItemNo := JSON.GetString ('VoucherItemNo', true);
        GeneratedVoucherNo := JSON.GetString ('generatedvoucherno', true);
        JSON.SetScope('$voucherno',true);
        VoucherNo := JSON.GetString ('input', true);
        DiscountType := GetDiscountType (Context, FrontEnd);

        if (not POSPaymentLine.GetPaymentType(PaymentTypePOS, VoucherItemNo, Setup.Register())) then
          Error (PaymentTypeNotFound, PaymentTypePOS.TableCaption, VoucherItemNo, Setup.Register());

        SalesQuantity := GetQuantity(Context,FrontEnd);
        UnitAmount := GetAmount(Context,FrontEnd);

        if (VoucherNo <> GeneratedVoucherNo) and (SalesQuantity > 1) then
          Error(TextNoManualMultiple);

        UnitDiscountAmount := CalculateDiscountUnitAmount (UnitAmount, DiscountType, GetDiscount(Context,FrontEnd));

        ValidateMinMaxAmount (PaymentTypePOS, UnitAmount);

        // Field can not be set on page, but is handled in current code.
        if (PaymentTypePOS."PBS Gift Voucher Barcode") then
          Error (NotSupported, PaymentTypePOS."PBS Gift Voucher Barcode", PaymentTypePOS.TableCaption(), PaymentTypePOS."No.");

        //IF (SalesQuantity > 1) THEN
        //  IF (NOT CONFIRM (ConfirmCreate, TRUE, SalesQuantity, UnitAmount, (UnitAmount - UnitDiscountAmount))) THEN
        //    EXIT;

        for VoucherCount := 1 to SalesQuantity do begin

          POSSaleLine.GetNewSaleLine (SaleLine);
          SetVoucherSaleInfo (SaleLine, PaymentTypePOS, UnitAmount);
          SaleLine.Insert (true);

          if (PaymentTypePOS."Via Terminal") then begin
            CardActivated := GiftCardPinPadActivation (POSPaymentLine, SaleLine, PaymentTypePOS, UnitAmount, UnitDiscountAmount, VoucherCount, SalesQuantity);
          end else begin
            CardActivated := CreateGiftVoucher (SaleLine, VoucherNo, GeneratedVoucherNo);
          end;

          if (not CardActivated) then
            if (Confirm (ActivationFailed, true)) then VoucherCount -=1 else VoucherCount := SalesQuantity+1;

          if (CardActivated) then begin
            SaleLine.Modify ();
            if (UnitDiscountAmount <> 0) then begin
              POSSaleLine.GetNewSaleLine (DiscountLine);
              SetVoucherDiscountInfo (DiscountLine, UnitDiscountAmount, SaleLine."Gift Voucher Ref.");
              DiscountLine.Insert();
            end;
          end else begin
            SaleLine.Delete ();
          end;

        end;

        POSSession.RequestRefreshData();
    end;

    local procedure "--"()
    begin
    end;

    local procedure GetAmount(Context: DotNet npNetJObject;FrontEnd: Codeunit "POS Front End Management"): Decimal
    var
        JSON: Codeunit "POS JSON Management";
    begin

        JSON.InitializeJObjectParser (Context,FrontEnd);
        JSON.SetScope ('$amount', true);
        exit (JSON.GetDecimal ('numpad', true));
    end;

    local procedure GetQuantity(Context: DotNet npNetJObject;FrontEnd: Codeunit "POS Front End Management"): Decimal
    var
        JSON: Codeunit "POS JSON Management";
    begin

        JSON.InitializeJObjectParser (Context,FrontEnd);
        if (JSON.SetScope ('$quantity', false)) then
          exit (JSON.GetDecimal ('numpad', true));

        exit (1);
    end;

    local procedure GetDiscount(Context: DotNet npNetJObject;FrontEnd: Codeunit "POS Front End Management"): Decimal
    var
        JSON: Codeunit "POS JSON Management";
    begin
        JSON.InitializeJObjectParser (Context,FrontEnd);
        if (JSON.SetScope ('$discount_amount', false)) then
          exit (JSON.GetDecimal ('numpad', true));

        JSON.InitializeJObjectParser (Context,FrontEnd);
        if (JSON.SetScope ('$discount_percent', false)) then
          exit (JSON.GetDecimal ('numpad', true));

        exit (0);
    end;

    local procedure GetDiscountType(Context: DotNet npNetJObject;FrontEnd: Codeunit "POS Front End Management"): Integer
    var
        JSON: Codeunit "POS JSON Management";
    begin

        JSON.InitializeJObjectParser (Context,FrontEnd);
        JSON.SetScope ('parameters', true);
        exit  (JSON.GetInteger ('DiscountType', true));
    end;

    local procedure ValidateMinMaxAmount(PaymentTypePOS: Record "Payment Type POS";AmountToCapture: Decimal)
    begin

        if (PaymentTypePOS."Maximum Amount" <> 0) then
          if (AmountToCapture > PaymentTypePOS."Maximum Amount") then
            Error  (MaxAmountLimit, PaymentTypePOS.Description, PaymentTypePOS."Maximum Amount");

        if (PaymentTypePOS."Minimum Amount" <> 0) then
          if (AmountToCapture < PaymentTypePOS."Minimum Amount") then
            Error (MaxAmountLimit, PaymentTypePOS.Description, PaymentTypePOS."Minimum Amount");
    end;

    local procedure SelectVoucherToSell(SuggestedPaymentTypeCode: Code[20]) VoucherItemNo: Code[20]
    var
        PaymentTypePOS: Record "Payment Type POS";
        PaymentDescription: Text;
        PaymentNo: Text;
        StrMenuChoice: Integer;
    begin

        PaymentTypePOS.SetCurrentKey ("Search Description");

        PaymentTypePOS.SetFilter ("No.", '=%1', SuggestedPaymentTypeCode);
        PaymentTypePOS.SetFilter (Status, '=%1', PaymentTypePOS.Status::Active);
        PaymentTypePOS.SetFilter ("Processing Type", '=%1', PaymentTypePOS."Processing Type"::"Gift Voucher");
        if (not PaymentTypePOS.FindFirst ()) then begin
          PaymentTypePOS.SetFilter ("No.", '');
          if (not PaymentTypePOS.FindFirst ()) then
            exit ('');
        end;

        if (PaymentTypePOS.Count () = 1) then
          exit (PaymentTypePOS."No.");

        Error ('No payment type matched %1 and more than one was found filtering on active gift vouchers only. Verify the parameters for this button.',SuggestedPaymentTypeCode);

        repeat
          PaymentDescription += ',' + PaymentTypePOS.Description;
          PaymentNo += ',' + PaymentTypePOS."No.";
        until (PaymentTypePOS.Next () = 0);
        PaymentDescription := DelStr (PaymentDescription, 1, 1);
        PaymentNo := DelStr (PaymentNo, 1, 1);

        StrMenuChoice := StrMenu (PaymentDescription, 1);
        if (StrMenuChoice = 0) then
          exit ('');

        exit (SelectStr (StrMenuChoice, PaymentNo));
    end;

    local procedure CalculateDiscountUnitAmount(pAmount: Decimal;pDiscountType: Option;pDiscount: Decimal) DiscountUnitAmount: Decimal
    begin

        if (pDiscountType = DiscountType::AMOUNT) then
          exit (pDiscount);

        if (pDiscountType = DiscountType::PERCENTAGE) then
          exit (pAmount * pDiscount / 100);
    end;

    local procedure SetVoucherSaleInfo(var SaleLine: Record "Sale Line POS";PaymentTypePOS: Record "Payment Type POS";pAmount: Decimal)
    var
        Register: Record Register;
    begin

        Register.Get (Setup.Register());

        with SaleLine do begin
          Type := SaleLine.Type::"G/L Entry";
          "Sale Type" := "Sale Type"::Deposit;
          Validate ("No.", PaymentTypePOS."G/L Account No.");
          "Location Code" := Register."Location Code";
          //-NPR5.53 [371956]-revoked
          //! Redundant lines. Dimensions should be properly handled by CreateDim() function, not forgetting the Dimension Set ID field.
          //"Shortcut Dimension 1 Code" := Register."Global Dimension 1 Code";
          //"Shortcut Dimension 2 Code" := Register."Global Dimension 2 Code";
          //+NPR5.53 [371956]-revoked
          Quantity := 1;
          Amount := pAmount;
        end;
    end;

    local procedure SetVoucherDiscountInfo(var SaleLine: Record "Sale Line POS";pAmount: Decimal;pVoucherReference: Text)
    var
        Register: Record Register;
    begin

        Register.Get (Setup.Register());

        with SaleLine do begin
          Type := SaleLine.Type::"G/L Entry";
          "Sale Type" := "Sale Type"::"Out payment";

          //-NPR5.48 [345292]
          //"No." := Register."Gift Voucher Discount Account";
          Validate ("No.", Register."Gift Voucher Discount Account");
          //+NPR5.48 [345292]

          "Location Code" := Register."Location Code";
          //-NPR5.53 [371956]-revoked
          //! Redundant lines. Dimensions should be properly handled by CreateDim() function, not forgetting the Dimension Set ID field.
          //"Shortcut Dimension 1 Code" := Register."Global Dimension 1 Code";
          //"Shortcut Dimension 2 Code" := Register."Global Dimension 2 Code";
          //+NPR5.53 [371956]-revoked
          Validate (Quantity, 1);
          Amount := pAmount;
          "Unit Price" := pAmount;
          "Amount Including VAT" := pAmount;
          Description := StrSubstNo (DiscountReference, pVoucherReference);

          //-NPR5.48 [345292]
          SaleLine.UpdateAmounts (SaleLine);
          //+NPR5.48 [345292]


        end;
    end;

    local procedure GiftCardPinPadActivation(POSPaymentLine: Codeunit "POS Payment Line";var SaleLine: Record "Sale Line POS";PaymentTypePOS: Record "Payment Type POS";pAmount: Decimal;pDiscountAmount: Decimal;VoucherCount: Integer;SalesQuantity: Integer) CardActivated: Boolean
    var
        PaymentLine: Record "Sale Line POS";
        Register: Record Register;
        CallTerminalIntegration: Codeunit "Call Terminal Integration";
        ReadyToActivate: Boolean;
    begin

        ReadyToActivate := true;
        if (SalesQuantity > 1) then
          ReadyToActivate := Confirm (ConfirmCharge, true, VoucherCount, SalesQuantity);

        if (not ReadyToActivate) then
          exit (false);

        //TODO: Replace this with EFTWorkflow (Call a function similar to CaptureCashTerminalPayment in Codeunit POS Action - Payments)


        with PaymentLine do begin
          "Amount Including VAT" := 0;
          //"No." := PaymentTypePOS."No.";  //NPR5.53 [371956]-revoked
          Validate("No.",PaymentTypePOS."No.");  //NPR5.53 [371956]
          "Location Code" := Register."Location Code";
          //-NPR5.53 [371956]-revoked
          //! Redundant lines. Dimensions should be properly handled by CreateDim() function, not forgetting the Dimension Set ID field.
          //"Shortcut Dimension 1 Code" := Register."Global Dimension 1 Code";
          //"Shortcut Dimension 2 Code" := Register."Global Dimension 2 Code";
          //+NPR5.53 [371956]-revoked
          Description := StrSubstNo ('%1 %2', PaymentTypePOS."Sales Line Text", 'Capture Pending');

          POSPaymentLine.InsertPaymentLine (PaymentLine, 0);
          POSPaymentLine.GetCurrentPaymentLine (PaymentLine);

          "Amount Including VAT" := -1 * pAmount;
          CallTerminalIntegration.Run (PaymentLine);

          if ("EFT Approved") then begin
            SaleLine."Unit Price"           := -"Amount Including VAT";
            SaleLine."Amount Including VAT" := -"Amount Including VAT";
            SaleLine.Validate ("No.");
            SaleLine."EFT Approved" := true;

            //-NPR5.48 [345292]
            SaleLine.UpdateAmounts (SaleLine);
            //+NPR5.48 [345292]

          end;

          "Unit Price" := 0;
          "Amount Including VAT" := 0;
          Modify ();

        end;

        exit (PaymentLine."EFT Approved");
    end;

    procedure CreateGiftVoucher(var SaleLinePOS: Record "Sale Line POS";VoucherNo: Code[20];GeneratedVoucherNo: Code[20]): Boolean
    var
        RetailSetup: Record "Retail Setup";
        GiftVoucher: Record "Gift Voucher";
        SalePOS: Record "Sale POS";
        Customer: Record Customer;
        Contact: Record Contact;
        A: Action;
        NoSeriesManagement: Codeunit NoSeriesManagement;
        Utility: Codeunit Utility;
        Text10600007: Label 'cancelled by sales person';
        TempNo: Code[20];
        NewTempNo: Code[20];
        TouchScreen: Codeunit "Touch Screen - Functions";
        Marshaller: Codeunit "POS Event Marshaller";
        GLSetup: Record "General Ledger Setup";
    begin
        GiftVoucher.Init;

        if not RetailSetup.Get then
          exit(false);
        RetailSetup.TestField("Gift Voucher No. Management");


        //-NPR5.53 [376207]
        if not RetailSetup."Popup Gift Voucher Quantity" then begin
          if GiftVoucher.Get(VoucherNo) then begin
            if GiftVoucher.Amount > 0 then begin
              if Confirm(StrSubstNo(Text0002,NewTempNo,GiftVoucher.Amount),false) then
                GiftVoucher.Delete(true)
              else
                exit;
            end else
              GiftVoucher.Delete(true);
          end;
        end;
        //+NPR5.53 [376207]


        if VoucherNo = GeneratedVoucherNo then begin
          //-NPR5.53 [376207]
          GiftVoucher."No.":= '';
          //+NPR5.53 [376207]
          NoSeriesManagement.InitSeries(RetailSetup."Gift Voucher No. Management",
          RetailSetup."Gift Voucher No. Management",0D,GiftVoucher."No.",RetailSetup."Gift Voucher No. Management");
          if RetailSetup."EAN Mgt. Gift voucher" <> '' then
            GiftVoucher."No." := Utility.CreateEAN( GiftVoucher."No.", Format(RetailSetup."EAN Mgt. Gift voucher") );
        end else
          GiftVoucher."No." := VoucherNo;

        if GiftVoucher.Amount < 0 then
          GiftVoucher.Amount := Abs(GiftVoucher.Amount)
        else
          GiftVoucher.Amount := SaleLinePOS.Amount;

        GiftVoucher."Register No."   := SaleLinePOS."Register No.";
        GiftVoucher."Sales Ticket No."     := SaleLinePOS."Sales Ticket No.";
        GiftVoucher."Issue Date" := SaleLinePOS.Date;
        GiftVoucher."Shortcut Dimension 1 Code" := SaleLinePOS."Shortcut Dimension 1 Code";
        GiftVoucher."Shortcut Dimension 2 Code" := SaleLinePOS."Shortcut Dimension 2 Code";
        GiftVoucher."Location Code" := SaleLinePOS."Location Code";
        GiftVoucher.Status := GiftVoucher.Status::Cancelled;
        GiftVoucher."Created in Company" := Format(RetailSetup."Company No.");
        GiftVoucher.Name := '';
        if SalePOS.Get(SaleLinePOS."Register No.",SaleLinePOS."Sales Ticket No.") then begin
          GiftVoucher.Salesperson    := SalePOS."Salesperson Code";
          GiftVoucher."Customer No." := SalePOS."Customer No.";
        end;
        GiftVoucher."Currency Code" := SaleLinePOS."Currency Code";
        if GiftVoucher."Currency Code" = '' then begin
          GLSetup.Get;
          GiftVoucher."Currency Code" := GLSetup."LCY Code";
          end;
        //GiftVoucher.Name := Text10600007 + SalePOS."Salesperson Code";
        GiftVoucher.Address := '';
        GiftVoucher."ZIP Code" := '';
        GiftVoucher.City := '';
        GiftVoucher.Status := GiftVoucher.Status::Cancelled;
        GiftVoucher.Insert( true );

        SaleLinePOS.Quantity := 1;
        SaleLinePOS."Unit Price" := GiftVoucher.Amount;
        SaleLinePOS."Amount Including VAT" := GiftVoucher.Amount;
        SaleLinePOS."Gift Voucher Ref." := GiftVoucher."No.";
        SaleLinePOS.Description := CopyStr (StrSubstNo ('%1 %2 %3', GiftVoucher.TableCaption, GiftVoucher.FieldCaption("No."), SaleLinePOS."Gift Voucher Ref."), 1, MaxStrLen(SaleLinePOS.Description));

        //-NPR5.48 [338181]
        SaleLinePOS.UpdateAmounts (SaleLinePOS);
        //+NPR5.48 [338181]

        exit(true);
    end;

    procedure SetGiftVoucherInfo(var POSSession: Codeunit "POS Session";VoucherNo: Code[20]): Boolean
    var
        RetailSetup: Record "Retail Setup";
        GiftVoucher: Record "Gift Voucher";
        SalePOS: Record "Sale POS";
        Customer: Record Customer;
        Contact: Record Contact;
        A: Action;
        Nrseriestyring: Codeunit NoSeriesManagement;
        Utility: Codeunit Utility;
        Text10600007: Label 'cancelled by sales person';
        TempNo: Code[20];
        NewTempNo: Code[20];
        TouchScreen: Codeunit "Touch Screen - Functions";
        Marshaller: Codeunit "POS Event Marshaller";
        GLSetup: Record "General Ledger Setup";
        Handled: Boolean;
    begin
        GiftVoucher.Get(VoucherNo);
        GiftVoucher.SetRecFilter;
        case SalePOS."Customer Type" of
          // Fetch customer information
          SalePOS."Customer Type"::Ord:
            if Customer.Get(GiftVoucher."Customer No.") then begin
              GiftVoucher.Name       := Customer.Name;
              GiftVoucher.Address    := Customer.Address;
              GiftVoucher."ZIP Code" := Customer."Post Code";
              GiftVoucher.City       := Customer.City;
              Handled := GiftVoucher.Modify;
            end;
          // Fetch contact information
          SalePOS."Customer Type"::Cash:
            if Contact.Get(GiftVoucher."Customer No.") then begin
              GiftVoucher.Name       := Contact.Name;
              GiftVoucher.Address    := Contact.Address;
              GiftVoucher."ZIP Code" := Contact."Post Code";
              GiftVoucher.City       := Contact.City;
              Handled := GiftVoucher.Modify;
            end;
          // Type in manually
        end;

        if not Handled then
          PAGE.RunModal(PAGE::"Create Gift Voucher",GiftVoucher);

        exit(true);
    end;

    local procedure "--Validations"()
    begin
    end;

    local procedure ValidateSetupBeforeWorkflow(Register: Record Register)
    begin
        Register.TestField ("Gift Voucher Account");

        if (Register."Gift Voucher Account" = Register."Credit Voucher Account") then
          Error ('Account');

        if (Register."Gift Voucher Account" = Register.Account) then
          Error ('Account 2');

        Register.TestField ("Gift Voucher Discount Account");
    end;

    local procedure ValidateSetup()
    begin
    end;
}

