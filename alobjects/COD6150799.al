codeunit 6150799 "POS Action - Credit Gift Vouch"
{
    // NPR5.35/TSA /20170830 CASE 288575 Made the refresh unconditional
    // NPR5.48/TSA /20190207 CASE 345327 Added call to UpdateAmounts()


    trigger OnRun()
    begin
    end;

    var
        ActionDescription: Label 'This is a built in function for handling return sales with Gift Vouchers';
        PaymentTypeNotFound: Label '%1 %2 for register %3 was not found.';
        TextAmount: Label 'Enter Amount:';
        Setup: Codeunit "POS Setup";
        TextAmountTitle: Label 'Specify Voucher Amount.';
        DiscountType: Option AMOUNT,PERCENTAGE;
        ActivationFailed: Label 'The gift card activation failed.';
        NotFound: Label 'No %1 found with %2 %3 and %4 %5.';
        NotSupported: Label 'Setting %1 on %2 %3 is not supported.';
        MustNotBeEqual: Label '%1 %2 cant be equal to %2 %4.';
        InvalidAmount: Label 'The SubTotal must be negative to able to create a Credit Voucher.';

    local procedure ActionCode(): Text
    begin
        exit ('CREDIT_GIFTVOUCHER');
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
            RegisterWorkflowStep('amount','numpad(labels.amount_title, labels.amount,context.voucher_amount).cancel(abort);');
            RegisterWorkflowStep('process_sale','respond();');
            RegisterWorkflow(true);

          end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150702, 'OnInitializeCaptions', '', true, true)]
    local procedure OnInitializeCaptions(Captions: Codeunit "POS Caption Management")
    var
        UI: Codeunit "POS UI Management";
    begin
        Captions.AddActionCaption (ActionCode(), 'amount', TextAmount);
        Captions.AddActionCaption (ActionCode(), 'amount_title', TextAmountTitle);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "POS Action";WorkflowStep: Text;Context: DotNet npNetJObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    begin

        if not Action.IsThisAction(ActionCode) then
          exit;

        POSSession.GetSetup (Setup);

        case WorkflowStep of
          'process_sale': OnProcessSale(POSSession,FrontEnd,Context);
        end;

        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnBeforeWorkflow', '', true, true)]
    local procedure OnBeforeWorkflow("Action": Record "POS Action";Parameters: DotNet npNetJObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    var
        Context: Codeunit "POS JSON Management";
        POSPaymentLine: Codeunit "POS Payment Line";
        RetailSetup: Record "Retail Setup";
        Register: Record Register;
        SalesAmount: Decimal;
        PaidAmount: Decimal;
        ReturnAmount: Decimal;
        SubTotal: Decimal;
    begin

        if not Action.IsThisAction(ActionCode()) then
          exit;

        RetailSetup.Get ();
        POSSession.GetSetup (Setup);
        Register.Get (Setup.Register());
        ValidateSetupBeforeWorkflow (Register);

        POSSession.GetPaymentLine(POSPaymentLine);
        POSPaymentLine.CalculateBalance (SalesAmount, PaidAmount, ReturnAmount, SubTotal);

        if (SubTotal >= 0) then
          SubTotal := 0;

        Context.SetContext ('voucher_amount', Abs(SubTotal));

        FrontEnd.SetActionContext (ActionCode(), Context);
        Handled := true;
    end;

    local procedure OnProcessSale(POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";Context: DotNet npNetJObject)
    var
        JSON: Codeunit "POS JSON Management";
        POSPaymentLine: Codeunit "POS Payment Line";
        POSSaleLine: Codeunit "POS Sale Line";
        POSSale: Codeunit "POS Sale";
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
        VoucherCount: Integer;
        SalesAmount: Decimal;
        PaidAmount: Decimal;
        ReturnAmount: Decimal;
        SubTotal: Decimal;
    begin

        POSSession.GetPaymentLine(POSPaymentLine);
        POSSession.GetSaleLine(POSSaleLine);
        POSSession.GetSale (POSSale);
        Register.Get (Setup.Register());

        JSON.InitializeJObjectParser (Context,FrontEnd);

        POSPaymentLine.CalculateBalance (SalesAmount, PaidAmount, ReturnAmount, SubTotal);

        if (SubTotal >= 0) then
          Error (InvalidAmount);

        UnitAmount := GetAmount (Context, FrontEnd);

        POSSaleLine.GetNewSaleLine (SaleLine);
        SetVoucherSaleInfo (SaleLine, Register, Abs(UnitAmount));
        SaleLine.Insert ();

        CardActivated := CreateGiftVoucher (SaleLine);

        if (CardActivated) then begin
          SaleLine.Modify ();
        end else begin
          SaleLine.Delete ();
        end;

        //-NPR5.35 [288575]
        // IF (NOT POSSale.EndSale (POSSession)) THEN
        //  POSSession.RequestRefreshData();

        POSSession.RequestRefreshData();
        POSSale.TryEndSale (POSSession)
        //+NPR5.35 [288575]
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

    local procedure SetVoucherSaleInfo(var SaleLine: Record "Sale Line POS";Register: Record Register;pAmount: Decimal)
    begin

        with SaleLine do begin
          Type := SaleLine.Type::"G/L Entry";
          "Sale Type" := "Sale Type"::Deposit;
          "Register No." := Register."Register No.";
          Validate ("No.", Register."Credit Voucher Account");
          "Location Code" := Register."Location Code";
          "Shortcut Dimension 1 Code" := Register."Global Dimension 1 Code";
          "Shortcut Dimension 2 Code" := Register."Global Dimension 2 Code";
          Quantity := 1;
          Amount := pAmount;

        end;
    end;

    local procedure CreateGiftVoucher(var SaleLine: Record "Sale Line POS") Activated: Boolean
    var
        RetailFormCode: Codeunit "Retail Form Code";
        PaymentLinePOS: Codeunit "Touch - Payment Line POS";
        CustomerNameOut: Text;
        CreditVoucher: Record "Credit Voucher";
    begin

        PaymentLinePOS.SetTableView (SaleLine."Register No.", SaleLine."Sales Ticket No.");
        PaymentLinePOS.GETPOSITION ();
        Activated := PaymentLinePOS.CreateGiftVoucher(SaleLine, SaleLine.Amount);

        if (Activated) then
          SaleLine.Description := CopyStr (StrSubstNo ('%1 %2 %3', CreditVoucher.TableCaption, CreditVoucher.FieldCaption("No."), SaleLine."Credit voucher ref."), 1, MaxStrLen(SaleLine.Description));

        //-NPR5.48 [345327]
        SaleLine.UpdateAmounts (SaleLine);
        //+NPR5.48 [345327]

        exit (Activated);
    end;

    local procedure "--Validations"()
    begin
    end;

    local procedure ValidateSetupBeforeWorkflow(Register: Record Register)
    begin
        Register.TestField (Account);
        Register.TestField ("Gift Voucher Account");
        Register.TestField ("Credit Voucher Account");
        Register.TestField ("Gift Voucher Discount Account");

        if (Register."Gift Voucher Account" = Register."Credit Voucher Account") then
          Error (MustNotBeEqual, Register.TableCaption, Register."Gift Voucher Account", Register, Register."Credit Voucher Account");

        if (Register."Gift Voucher Account" = Register.Account) then
          Error (MustNotBeEqual, Register, Register."Gift Voucher Account", Register, Register.Account);
    end;
}

