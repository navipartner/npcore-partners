codeunit 6150799 "NPR POSAction: CreditGift Vch."
{
    // NPR5.35/TSA /20170830 CASE 288575 Made the refresh unconditional
    // NPR5.48/TSA /20190207 CASE 345327 Added call to UpdateAmounts()
    // NPR5.53/ALPO/20191025 CASE 371956 Dimensions: POS Store & POS Unit integration; discontinue dimensions on Cash Register


    trigger OnRun()
    begin
    end;

    var
        ActionDescription: Label 'This is a built in function for handling return sales with Gift Vouchers';
        PaymentTypeNotFound: Label '%1 %2 for register %3 was not found.';
        TextAmount: Label 'Enter Amount:';
        Setup: Codeunit "NPR POS Setup";
        TextAmountTitle: Label 'Specify Voucher Amount.';
        DiscountType: Option AMOUNT,PERCENTAGE;
        ActivationFailed: Label 'The gift card activation failed.';
        NotFound: Label 'No %1 found with %2 %3 and %4 %5.';
        NotSupported: Label 'Setting %1 on %2 %3 is not supported.';
        MustNotBeEqual: Label '%1 %2 cant be equal to %2 %4.';
        InvalidAmount: Label 'The SubTotal must be negative to able to create a Credit Voucher.';

    local procedure ActionCode(): Text
    begin
        exit('CREDIT_GIFTVOUCHER');
    end;

    local procedure ActionVersion(): Text
    begin
        exit('1.0');
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
                RegisterWorkflowStep('amount', 'numpad(labels.amount_title, labels.amount,context.voucher_amount).cancel(abort);');
                RegisterWorkflowStep('process_sale', 'respond();');
                RegisterWorkflow(true);

            end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150702, 'OnInitializeCaptions', '', true, true)]
    local procedure OnInitializeCaptions(Captions: Codeunit "NPR POS Caption Management")
    var
        UI: Codeunit "NPR POS UI Management";
    begin
        Captions.AddActionCaption(ActionCode(), 'amount', TextAmount);
        Captions.AddActionCaption(ActionCode(), 'amount_title', TextAmountTitle);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    begin

        if not Action.IsThisAction(ActionCode) then
            exit;

        POSSession.GetSetup(Setup);

        case WorkflowStep of
            'process_sale':
                OnProcessSale(POSSession, FrontEnd, Context);
        end;

        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnBeforeWorkflow', '', true, true)]
    local procedure OnBeforeWorkflow("Action": Record "NPR POS Action"; Parameters: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        Context: Codeunit "NPR POS JSON Management";
        POSPaymentLine: Codeunit "NPR POS Payment Line";
        RetailSetup: Record "NPR Retail Setup";
        Register: Record "NPR Register";
        SalesAmount: Decimal;
        PaidAmount: Decimal;
        ReturnAmount: Decimal;
        SubTotal: Decimal;
    begin

        if not Action.IsThisAction(ActionCode()) then
            exit;

        RetailSetup.Get();
        POSSession.GetSetup(Setup);
        Register.Get(Setup.Register());
        ValidateSetupBeforeWorkflow(Register);

        POSSession.GetPaymentLine(POSPaymentLine);
        POSPaymentLine.CalculateBalance(SalesAmount, PaidAmount, ReturnAmount, SubTotal);

        if (SubTotal >= 0) then
            SubTotal := 0;

        Context.SetContext('voucher_amount', Abs(SubTotal));

        FrontEnd.SetActionContext(ActionCode(), Context);
        Handled := true;
    end;

    local procedure OnProcessSale(POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; Context: JsonObject)
    var
        JSON: Codeunit "NPR POS JSON Management";
        POSPaymentLine: Codeunit "NPR POS Payment Line";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSSale: Codeunit "NPR POS Sale";
        Register: Record "NPR Register";
        PaymentTypePOS: Record "NPR Payment Type POS";
        SaleLine: Record "NPR Sale Line POS";
        PaymentLine: Record "NPR Sale Line POS";
        DiscountLine: Record "NPR Sale Line POS";
        POSStore: Record "NPR POS Store";
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
        POSSession.GetSale(POSSale);
        Register.Get(Setup.Register());
        Setup.GetPOSStore(POSStore);

        JSON.InitializeJObjectParser(Context, FrontEnd);

        POSPaymentLine.CalculateBalance(SalesAmount, PaidAmount, ReturnAmount, SubTotal);

        if (SubTotal >= 0) then
            Error(InvalidAmount);

        UnitAmount := GetAmount(Context, FrontEnd);

        POSSaleLine.GetNewSaleLine(SaleLine);
        SetVoucherSaleInfo(SaleLine, Register, Abs(UnitAmount), POSStore);
        SaleLine.Insert();

        CardActivated := CreateGiftVoucher(SaleLine);

        if (CardActivated) then begin
            SaleLine.Modify();
        end else begin
            SaleLine.Delete();
        end;

        //-NPR5.35 [288575]
        // IF (NOT POSSale.EndSale (POSSession)) THEN
        //  POSSession.RequestRefreshData();

        POSSession.RequestRefreshData();
        POSSale.TryEndSale(POSSession)
        //+NPR5.35 [288575]
    end;

    local procedure "--"()
    begin
    end;

    local procedure GetAmount(Context: JsonObject; FrontEnd: Codeunit "NPR POS Front End Management"): Decimal
    var
        JSON: Codeunit "NPR POS JSON Management";
    begin

        JSON.InitializeJObjectParser(Context, FrontEnd);
        JSON.SetScope('$amount', true);
        exit(JSON.GetDecimal('numpad', true));
    end;

    local procedure SetVoucherSaleInfo(var SaleLine: Record "NPR Sale Line POS"; Register: Record "NPR Register"; pAmount: Decimal; POSStore: Record "NPR POS Store")
    begin
        SaleLine.Type := SaleLine.Type::"G/L Entry";
        SaleLine."Sale Type" := SaleLine."Sale Type"::Deposit;
        SaleLine."Register No." := Register."Register No.";
        SaleLine.Validate("No.", Register."Credit Voucher Account");
        SaleLine."Location Code" := POSStore."Location Code";
        SaleLine.Quantity := 1;
        SaleLine.Amount := pAmount;
    end;

    local procedure CreateGiftVoucher(var SaleLine: Record "NPR Sale Line POS") Activated: Boolean
    var
        RetailFormCode: Codeunit "NPR Retail Form Code";
        PaymentLinePOS: Codeunit "NPR Touch: Payment Line POS";
        CustomerNameOut: Text;
        CreditVoucher: Record "NPR Credit Voucher";
    begin

        PaymentLinePOS.SetTableView(SaleLine."Register No.", SaleLine."Sales Ticket No.");
        PaymentLinePOS.GETPOSITION();
        Activated := PaymentLinePOS.CreateGiftVoucher(SaleLine, SaleLine.Amount);

        if (Activated) then
            SaleLine.Description := CopyStr(StrSubstNo('%1 %2 %3', CreditVoucher.TableCaption, CreditVoucher.FieldCaption("No."), SaleLine."Credit voucher ref."), 1, MaxStrLen(SaleLine.Description));

        //-NPR5.48 [345327]
        SaleLine.UpdateAmounts(SaleLine);
        //+NPR5.48 [345327]

        exit(Activated);
    end;

    local procedure "--Validations"()
    begin
    end;

    local procedure ValidateSetupBeforeWorkflow(Register: Record "NPR Register")
    begin
        Register.TestField(Account);
        Register.TestField("Gift Voucher Account");
        Register.TestField("Credit Voucher Account");
        Register.TestField("Gift Voucher Discount Account");

        if (Register."Gift Voucher Account" = Register."Credit Voucher Account") then
            Error(MustNotBeEqual, Register.TableCaption, Register."Gift Voucher Account", Register, Register."Credit Voucher Account");

        if (Register."Gift Voucher Account" = Register.Account) then
            Error(MustNotBeEqual, Register, Register."Gift Voucher Account", Register, Register.Account);
    end;
}

