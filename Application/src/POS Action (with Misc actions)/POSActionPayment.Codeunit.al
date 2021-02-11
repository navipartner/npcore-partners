codeunit 6150725 "NPR POS Action: Payment"
{
    // 
    // This is the main POS Action for handling payments. To extend payment functionality, subscribe to the events
    //  - OnBeforeActionWorkflow: to adapt the workflow to suit your payment method
    //  - OnBeforeAction: to handle the payment before NPR does. When Handled == TRUE, NPR will not bother with the paymentmethod
    //  - OnAfterAction:  to change NPR behaviour or provide functionality where NPR does not
    var
        ActionDescription: Label 'This is a built-in action for inserting a payment line into the current transaction';
        EFTIntegration: Codeunit "NPR EFT Framework Mgt.";
        Setup: Codeunit "NPR POS Setup";
        PaymentTypeNotFound: Label '%1 %2 for register %3 was not found.';
        TextAmountLabel: Label 'Enter Amount:';
        TextVoucherLabel: Label 'Enter Voucher Number:';
        VoucherNotValid: Label 'Voucher %1 is not valid.';
        VoucherNotFound: Label 'Voucher %1 is not found.';
        VoucherBlocked: Label 'Voucher %1 is Blocked.';
        VoucherStatusNotOpen: Label 'Voucher %1 is %2.';
        MaxAmountLimit: Label 'Maximum payment amount for %1 is %2.';
        MissingImpl: Label 'Payment failed!\%1 = %2, %3 = %4 on %5 = %6 did not respond with being handled.\\Check the setup for %1 and %5.';
        NextWorkflowStep: Option Resume,InvokeEFTDevice,Pause,CheckResult,VoidPayment;
        InvalidAmount: Label 'Amount %1 is not valid for payment type %2';
        NO_SALES_LINES: Label 'There are no sales lines in the POS. You must add at least one sales line before handling payment.';

    procedure ActionCode(): Text
    begin
        exit('PAYMENT');
    end;

    local procedure ActionVersion(): Text
    begin
        exit('1.4');
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Action", 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    begin
        if Sender.DiscoverAction(
          ActionCode(),
          ActionDescription,
          ActionVersion(),
          Sender.Type::Generic,
          Sender."Subscriber Instances Allowed"::Multiple)
        then begin
            Sender.RegisterWorkflowStep('voucher', 'context.capture_voucher && input({caption: labels.Voucher}).cancel(abort)');
            Sender.RegisterWorkflowStep('amount', 'if ((context.capture_amount) && (!param.HideAmountDialog) && ((!param.HideZeroAmountDialog) || (context.amounttocapture > 0))) {' +
                                                 '  numpad({title: context.amount_description, caption: labels.Amount, value: context.defaultamount}).cancel(abort);' +
                                                   '}');

            Sender.RegisterWorkflowStep('capture_payment', 'respond();');
            Sender.RegisterWorkflowStep('tryEndSale', 'respond();');

            Sender.RegisterWorkflow(true);
            Sender.RegisterDataBinding();
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS UI Management", 'OnInitializeCaptions', '', true, true)]
    local procedure OnInitializeCaptions(Captions: Codeunit "NPR POS Caption Management")
    begin

        Captions.AddActionCaption(ActionCode(), 'Amount', TextAmountLabel);
        Captions.AddActionCaption(ActionCode(), 'Voucher', TextVoucherLabel);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS JavaScript Interface", 'OnBeforeWorkflow', '', true, true)]
    local procedure OnBeforeWorkflow("Action": Record "NPR POS Action"; Parameters: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        Context: Codeunit "NPR POS JSON Management";
        JSON: Codeunit "NPR POS JSON Management";
        PaymentNo: Code[20];
        PaymentTypePOS: Record "NPR Payment Type POS";
        Register: Record "NPR Register";
        POSPaymentLine: Codeunit "NPR POS Payment Line";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        SaleLinePOS: Record "NPR Sale Line POS";
        SalesAmount: Decimal;
        ReturnAmount: Decimal;
        PaidAmount: Decimal;
        SubTotal: Decimal;
        ReturnPaymentTypePOS: Record "NPR Payment Type POS";
        CurrentView: Codeunit "NPR POS View";
        NPRetailSetup: Record "NPR NP Retail Setup";
        POSUnit: Record "NPR POS Unit";
        POSAuditProfile: Record "NPR POS Audit Profile";
        POSSale: Codeunit "NPR POS Sale";
        SalePOS: Record "NPR Sale POS";
    begin

        if not Action.IsThisAction(ActionCode()) then
            exit;

        POSSession.GetSetup(Setup);
        Setup.GetPOSUnit(POSUnit);
        Register.Get(Setup.Register());
        NPRetailSetup.Get();

        if NPRetailSetup."Advanced Posting Activated" then begin
            POSUnit.TestField("Default POS Payment Bin");
        end;

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        SaleLinePOS.SetFilter("Register No.", '=%1', SalePOS."Register No.");
        SaleLinePOS.SetFilter("Sales Ticket No.", '=%1', SalePOS."Sales Ticket No.");
        SaleLinePOS.SetFilter(Type, '<>%1', SaleLinePOS.Type::Comment);

        if (SaleLinePOS.IsEmpty()) then begin
            if POSAuditProfile.Get(POSUnit."POS Audit Profile") then
                if not POSAuditProfile."Allow Zero Amount Sales" then
                    Error(NO_SALES_LINES);
        end;

        POSSession.GetCurrentView(CurrentView);
        if (CurrentView.Type = CurrentView.Type::Sale) then
            POSSession.ChangeViewPayment();

        JSON.InitializeJObjectParser(Parameters, FrontEnd);
        PaymentNo := JSON.GetString('paymentNo', true);

        POSSession.GetPaymentLine(POSPaymentLine);
        POSPaymentLine.CalculateBalance(SalesAmount, PaidAmount, ReturnAmount, SubTotal);

        if (not POSPaymentLine.GetPaymentType(PaymentTypePOS, PaymentNo, Setup.Register())) then
            Error(PaymentTypeNotFound, PaymentTypePOS.TableCaption, PaymentNo, Setup.Register());

        if (not POSPaymentLine.GetPaymentType(ReturnPaymentTypePOS, Register."Return Payment Type", Setup.Register())) then
            Error(PaymentTypeNotFound, PaymentTypePOS.TableCaption, Register."Return Payment Type", Setup.Register());

        OnBeforeActionWorkflow(PaymentTypePOS, Parameters, POSSession, FrontEnd, Context, SubTotal, Handled);

        if (not Handled) then begin
            case PaymentTypePOS."Processing Type" of
                PaymentTypePOS."Processing Type"::Cash:
                    Handled := ConfigureCashWorkflow(Context, PaymentTypePOS, ReturnPaymentTypePOS, SalesAmount, PaidAmount);
                PaymentTypePOS."Processing Type"::"Foreign Currency":
                    Handled := ConfigureForeignCashWorkflow(Context, PaymentTypePOS, ReturnPaymentTypePOS, SalesAmount, PaidAmount);
                PaymentTypePOS."Processing Type"::"Gift Voucher":
                    Handled := ConfigureVoucherWorkflow(Context, PaymentTypePOS, ReturnPaymentTypePOS, SalesAmount, PaidAmount);
                PaymentTypePOS."Processing Type"::"Credit Voucher":
                    Handled := ConfigureVoucherWorkflow(Context, PaymentTypePOS, ReturnPaymentTypePOS, SalesAmount, PaidAmount);
                PaymentTypePOS."Processing Type"::"Foreign Gift Voucher":
                    Handled := ConfigureForeignVoucherWorkflow(Context, PaymentTypePOS, ReturnPaymentTypePOS, SalesAmount, PaidAmount);
                PaymentTypePOS."Processing Type"::"Foreign Credit Voucher":
                    Handled := ConfigureForeignVoucherWorkflow(Context, PaymentTypePOS, ReturnPaymentTypePOS, SalesAmount, PaidAmount);
                PaymentTypePOS."Processing Type"::EFT:
                    Handled := ConfigureCashTerminalWorkflow(Context, PaymentTypePOS, ReturnPaymentTypePOS, SalesAmount, PaidAmount);
                PaymentTypePOS."Processing Type"::"Manual Card":
                    Handled := ConfigureManualCardWorkflow(Context, PaymentTypePOS, ReturnPaymentTypePOS, SalesAmount, PaidAmount);
                else
                    // provide a resonable default
                    Handled := ConfigureCashWorkflow(Context, PaymentTypePOS, ReturnPaymentTypePOS, SalesAmount, PaidAmount);
            end;
        end;

        FrontEnd.SetActionContext(ActionCode, Context);
    end;

    [EventSubscriber(ObjectType::Page, Page::"NPR POS Menu Buttons", 'OnBeforeActionEvent', 'RefreshActionCodeParameters', true, true)]
    local procedure OnBeforeEditPaymentParameters(var Rec: Record "NPR POS Menu Button")
    var
        POSSetup: Record "NPR POS Setup";
        ParamValue: Record "NPR POS Parameter Value";
        IsPaymentAction: Boolean;
    begin
        if Rec."Action Type" <> Rec."Action Type"::PaymentType then
            exit;

        if (not POSSetup.FindSet()) then
            exit;

        IsPaymentAction := false;
        repeat
            IsPaymentAction := IsPaymentAction or (POSSetup."Payment Action Code" = ActionCode());
        until ((POSSetup.Next() = 0) or (IsPaymentAction));

        ParamValue.FilterParameters(Rec.RecordId, 0);
        if not ParamValue.IsEmpty then
            exit;

        InitParameters(Rec);
    end;

    local procedure InitParameters(var POSMenuButton: Record "NPR POS Menu Button")
    var
        POSParameterValue: Record "NPR POS Parameter Value";
    begin
        InitParameter(POSMenuButton, 'HideAmountDialog', POSParameterValue."Data Type"::Boolean, 'false');
        InitParameter(POSMenuButton, 'HideZeroAmountDialog', POSParameterValue."Data Type"::Boolean, 'false');
    end;

    local procedure InitParameter(var POSMenuButton: Record "NPR POS Menu Button"; Name: Text; DataType: Option; DefaultValue: Text)
    var
        POSParameterValue: Record "NPR POS Parameter Value";
    begin
        POSParameterValue.FilterParameters(POSMenuButton.RecordId, 0);
        POSParameterValue.SetRange("Action Code", ActionCode());
        POSParameterValue.SetRange(Name, Name);
        if not POSParameterValue.IsEmpty then
            exit;

        POSParameterValue.InitForMenuButton(POSMenuButton);
        POSParameterValue."Action Code" := ActionCode();
        POSParameterValue.Name := Name;
        POSParameterValue."Data Type" := DataType;
        POSParameterValue.Value := DefaultValue;
        POSParameterValue.Insert;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS JavaScript Interface", 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        JSON: Codeunit "NPR POS JSON Management";
        POSSale: Codeunit "NPR POS Sale";
        POSPaymentLine: Codeunit "NPR POS Payment Line";
        PaymentTypePOS: Record "NPR Payment Type POS";
        SalePOS: Record "NPR Sale POS";
        PaymentNo: Code[20];
        Register: Record "NPR Register";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        TaxFreeUnit: Record "NPR Tax Free POS Unit";
        TaxFree: Codeunit "NPR Tax Free Handler Mgt.";
        PaymentHandled: Boolean;
        ShowConfirmMessage: Boolean;
        SaleIsEnded: Boolean;
        SalesAmount: Decimal;
        ReturnAmount: Decimal;
        PaidAmount: Decimal;
        SubTotal: Decimal;
        ReturnPaymentTypePOS: Record "NPR Payment Type POS";
    begin

        if not Action.IsThisAction(ActionCode()) then
            exit;

        Handled := true;

        POSSession.GetSetup(Setup);
        JSON.InitializeJObjectParser(Context, FrontEnd);
        JSON.SetScope('parameters', true);
        PaymentNo := JSON.GetString('paymentNo', true);

        POSSession.GetPaymentLine(POSPaymentLine);
        if (not POSPaymentLine.GetPaymentType(PaymentTypePOS, PaymentNo, Setup.Register)) then
            Error(PaymentTypeNotFound, PaymentTypePOS.TableCaption, PaymentNo, Setup.Register);

        POSSession.GetSale(POSSale);

        case WorkflowStep of
            'capture_payment':
                begin
                    POSSession.ClearActionState();
                    POSSession.StoreActionState('ContextId', POSSession.BeginAction(ActionCode));

                    OnBeforeAction(WorkflowStep, PaymentTypePOS, Context, POSSession, FrontEnd, PaymentHandled);
                    CapturePayment(PaymentTypePOS, POSSession, FrontEnd, GetAmount(Context, FrontEnd), GetVoucherNo(Context, FrontEnd), PaymentHandled);
                    OnAfterAction(WorkflowStep, PaymentTypePOS, Context, POSSession, FrontEnd, PaymentHandled);
                end;

            'tryEndSale':
                begin
                    PaymentHandled := true;
                    TryEndSale(PaymentTypePOS, POSSession);
                end;
        end;

        if (not PaymentHandled) then
            Message(MissingImpl, PaymentTypePOS.TableCaption(), PaymentTypePOS."No.", PaymentTypePOS.FieldCaption("Processing Type"), PaymentTypePOS."Processing Type", Register.TableCaption(), Setup.Register());
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeActionWorkflow(PaymentTypePOS: Record "NPR Payment Type POS"; Parameters: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; Context: Codeunit "NPR POS JSON Management"; SubTotal: Decimal; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeAction(WorkflowStep: Text; PaymentType: Record "NPR Payment Type POS"; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterAction(WorkflowStep: Text; PaymentType: Record "NPR Payment Type POS"; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    begin
    end;

    local procedure ConfigureCashWorkflow(var Context: Codeunit "NPR POS JSON Management"; PaymentType: Record "NPR Payment Type POS"; ReturnPaymentType: Record "NPR Payment Type POS"; SalesAmount: Decimal; PaidAmount: Decimal): Boolean
    begin
        Context.SetContext('capture_amount', true);
        SetContextAmounts(Context, PaymentType, ReturnPaymentType, SalesAmount, PaidAmount, true, false);
        Context.SetContext('amount_description', PaymentType.Description);
        exit(true);
    end;

    local procedure ConfigureManualCardWorkflow(var Context: Codeunit "NPR POS JSON Management"; PaymentType: Record "NPR Payment Type POS"; ReturnPaymentType: Record "NPR Payment Type POS"; SalesAmount: Decimal; PaidAmount: Decimal): Boolean
    begin
        Context.SetContext('capture_amount', true);
        SetContextAmounts(Context, PaymentType, ReturnPaymentType, SalesAmount, PaidAmount, false, false);
        Context.SetContext('amount_description', PaymentType.Description);
        exit(true);
    end;

    local procedure ConfigureForeignCashWorkflow(var Context: Codeunit "NPR POS JSON Management"; PaymentType: Record "NPR Payment Type POS"; ReturnPaymentType: Record "NPR Payment Type POS"; SalesAmount: Decimal; PaidAmount: Decimal): Boolean
    begin
        Context.SetContext('capture_amount', true);
        SetContextAmounts(Context, PaymentType, ReturnPaymentType, SalesAmount, PaidAmount, false, false);
        Context.SetContext('amount_description', PaymentType.Description);
        exit(true);
    end;

    local procedure ConfigureVoucherWorkflow(var Context: Codeunit "NPR POS JSON Management"; PaymentType: Record "NPR Payment Type POS"; ReturnPaymentType: Record "NPR Payment Type POS"; SalesAmount: Decimal; PaidAmount: Decimal): Boolean
    begin
        Context.SetContext('capture_amount', false);
        Context.SetContext('capture_voucher', true);
        SetContextAmounts(Context, PaymentType, ReturnPaymentType, SalesAmount, PaidAmount, false, false);
        exit(true);
    end;

    local procedure ConfigureForeignVoucherWorkflow(var Context: Codeunit "NPR POS JSON Management"; PaymentType: Record "NPR Payment Type POS"; ReturnPaymentType: Record "NPR Payment Type POS"; SalesAmount: Decimal; PaidAmount: Decimal): Boolean
    var
        Amount: Decimal;
    begin
        Context.SetContext('capture_amount', (PaymentType."Forced Amount" = false));
        Context.SetContext('capture_voucher', (PaymentType."Reference Incoming"));
        SetContextAmounts(Context, PaymentType, ReturnPaymentType, SalesAmount, PaidAmount, false, true);
        exit(true);

    end;

    local procedure ConfigureCashTerminalWorkflow(var Context: Codeunit "NPR POS JSON Management"; PaymentType: Record "NPR Payment Type POS"; ReturnPaymentType: Record "NPR Payment Type POS"; SalesAmount: Decimal; PaidAmount: Decimal): Boolean
    begin
        Context.SetContext('capture_amount', (PaymentType."Forced Amount" = false));
        SetContextAmounts(Context, PaymentType, ReturnPaymentType, SalesAmount, PaidAmount, false, false);  //NPR5.55 [410991]
        Context.SetContext('amount_description', PaymentType.Description);
        exit(true);
    end;

    local procedure SetContextAmounts(var Context: Codeunit "NPR POS JSON Management"; PaymentType: Record "NPR Payment Type POS"; ReturnPaymentType: Record "NPR Payment Type POS"; SalesAmount: Decimal; PaidAmount: Decimal; AllowNegativePaymentBalance: Boolean; PositiveOnly: Boolean)
    var
        AmtToCapture: Decimal;
    begin
        AmtToCapture := SuggestAmount(SalesAmount, PaidAmount, PaymentType, ReturnPaymentType, AllowNegativePaymentBalance);
        if PositiveOnly and (AmtToCapture < 0) then
            AmtToCapture := 0;

        Context.SetContext('amounttocapture', AmtToCapture);
        if PaymentType."Zero as Default on Popup" then
            Context.SetContext('defaultamount', 0)
        else
            Context.SetContext('defaultamount', AmtToCapture);
    end;

    procedure CapturePayment(PaymentTypePOS: Record "NPR Payment Type POS"; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; AmountToCapture: Decimal; VoucherNo: Text; var Handled: Boolean)
    var
        POSPaymentLine: Codeunit "NPR POS Payment Line";
        POSLine: Record "NPR Sale Line POS";
        SalesAmount: Decimal;
        ReturnAmount: Decimal;
        PaidAmount: Decimal;
        SubTotal: Decimal;
        POSSetup: Codeunit "NPR POS Setup";
        SalePOS: Record "NPR Sale POS";
        POSSale: Codeunit "NPR POS Sale";
    begin

        if (not Handled) then begin
            POSSession.GetPaymentLine(POSPaymentLine);
            POSPaymentLine.CalculateBalance(SalesAmount, PaidAmount, ReturnAmount, SubTotal);
            POSSession.GetSale(POSSale);
            POSSale.GetCurrentSale(SalePOS);

            Clear(POSLine);
            POSSession.GetSetup(POSSetup);
            POSLine."Register No." := POSSetup.Register();

            POSLine."No." := PaymentTypePOS."No.";
            POSLine."Register No." := SalePOS."Register No.";
            POSLine."Sales Ticket No." := SalePOS."Sales Ticket No.";

            case PaymentTypePOS."Processing Type" of
                PaymentTypePOS."Processing Type"::Cash:
                    Handled := CaptureCashPayment(AmountToCapture, POSPaymentLine, POSLine, PaymentTypePOS);
                PaymentTypePOS."Processing Type"::"Foreign Currency":
                    Handled := CaptureForeignCashPayment(AmountToCapture, POSPaymentLine, POSLine, PaymentTypePOS);
                PaymentTypePOS."Processing Type"::"Gift Voucher":
                    Handled := CaptureGiftVoucherPayment(VoucherNo, POSPaymentLine, POSLine, PaymentTypePOS);
                PaymentTypePOS."Processing Type"::"Credit Voucher":
                    Handled := CaptureCreditVoucherPayment(VoucherNo, POSPaymentLine, POSLine, PaymentTypePOS);
                PaymentTypePOS."Processing Type"::EFT:
                    Handled := CaptureEftPayment(AmountToCapture, POSSession, POSPaymentLine, POSLine, PaymentTypePOS, FrontEnd);
                PaymentTypePOS."Processing Type"::"Foreign Gift Voucher":
                    Handled := CaptureForeignVoucherPayment(AmountToCapture, VoucherNo, POSPaymentLine, POSLine, PaymentTypePOS);
                PaymentTypePOS."Processing Type"::"Foreign Credit Voucher":
                    Handled := CaptureForeignVoucherPayment(AmountToCapture, VoucherNo, POSPaymentLine, POSLine, PaymentTypePOS);
                PaymentTypePOS."Processing Type"::"Manual Card":
                    Handled := CaptureManualCardPayment(AmountToCapture, POSPaymentLine, POSLine, PaymentTypePOS);
                else
                    Handled := false;
            end;
        end;
    end;

    local procedure CaptureCashPayment(AmountToCaptureLCY: Decimal; POSPaymentLine: Codeunit "NPR POS Payment Line"; var POSLine: Record "NPR Sale Line POS"; PaymentType: Record "NPR Payment Type POS"): Boolean
    var
        AmountToCapture: Decimal;
    begin
        AmountToCapture := 0;

        if AmountToCaptureLCY = 0 then
            exit(true);

        POSPaymentLine.ValidateAmountBeforePayment(PaymentType, AmountToCaptureLCY);

        POSLine."Amount Including VAT" := AmountToCaptureLCY;
        POSPaymentLine.InsertPaymentLine(POSLine, AmountToCapture);

        exit(true);
    end;

    local procedure CaptureManualCardPayment(AmountToCaptureLCY: Decimal; POSPaymentLine: Codeunit "NPR POS Payment Line"; var POSLine: Record "NPR Sale Line POS"; PaymentType: Record "NPR Payment Type POS"): Boolean
    var
        AmountToCapture: Decimal;
    begin
        AmountToCapture := 0;

        if AmountToCaptureLCY = 0 then
            exit(true);

        POSPaymentLine.ValidateAmountBeforePayment(PaymentType, AmountToCaptureLCY);

        POSLine."Amount Including VAT" := AmountToCaptureLCY;
        POSPaymentLine.InsertPaymentLine(POSLine, AmountToCapture);

        exit(true);
    end;

    local procedure CaptureForeignCashPayment(AmountToCapture: Decimal; POSPaymentLine: Codeunit "NPR POS Payment Line"; var POSLine: Record "NPR Sale Line POS"; PaymentType: Record "NPR Payment Type POS"): Boolean
    var
        AmountToCaptureLCY: Decimal;
    begin
        AmountToCaptureLCY := 0;

        if AmountToCapture = 0 then
            exit(true);

        POSPaymentLine.ValidateAmountBeforePayment(PaymentType, AmountToCapture);

        POSLine."Amount Including VAT" := AmountToCaptureLCY;
        POSPaymentLine.InsertPaymentLine(POSLine, AmountToCapture);

        exit(true);
    end;

    local procedure CaptureGiftVoucherPayment(VoucherNumber: Code[20]; POSPaymentLine: Codeunit "NPR POS Payment Line"; var POSLine: Record "NPR Sale Line POS"; PaymentType: Record "NPR Payment Type POS"): Boolean
    var
        AmountCapturedLCY: Decimal;
        AmountCaptured: Decimal;
        VoucherStatusMsg: Text;
    begin
        if not (VerifyGiftVoucherNumber(VoucherNumber, VoucherStatusMsg)) then begin
            if VoucherStatusMsg <> '' then
                Error(VoucherStatusMsg);
            Error(VoucherNotValid, VoucherNumber);
        end;

        ApplyGiftVoucherToPaymentLine(VoucherNumber, POSLine, PaymentType, AmountCapturedLCY, AmountCaptured);

        POSLine."Amount Including VAT" := AmountCapturedLCY;
        POSPaymentLine.InsertPaymentLine(POSLine, AmountCaptured);

        exit(true);
    end;

    local procedure CaptureCreditVoucherPayment(VoucherNumber: Code[20]; POSPaymentLine: Codeunit "NPR POS Payment Line"; var POSLine: Record "NPR Sale Line POS"; PaymentType: Record "NPR Payment Type POS"): Boolean
    var
        AmountCapturedLCY: Decimal;
        AmountCaptured: Decimal;
        VoucherStatusMsg: Text;
    begin
        if not (VerifyCreditVoucherNumber(VoucherNumber, VoucherStatusMsg)) then begin
            if VoucherStatusMsg <> '' then
                Error(VoucherStatusMsg);
            Error(VoucherNotValid, VoucherNumber);
        end;

        ApplyCreditVoucherToPaymentLine(VoucherNumber, POSLine, PaymentType, AmountCapturedLCY, AmountCaptured);

        POSLine."Amount Including VAT" := AmountCapturedLCY;
        POSPaymentLine.InsertPaymentLine(POSLine, AmountCaptured);

        exit(true);
    end;

    local procedure CaptureEftPayment(AmountToCapture: Decimal; POSSession: Codeunit "NPR POS Session"; POSPaymentLine: Codeunit "NPR POS Payment Line"; var POSLine: Record "NPR Sale Line POS"; PaymentType: Record "NPR Payment Type POS"; FrontEnd: Codeunit "NPR POS Front End Management"): Boolean
    var
        Register: Record "NPR Register";
        Handled: Boolean;
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        POSSale: Codeunit "NPR POS Sale";
        EFTTransactionMgt: Codeunit "NPR EFT Transaction Mgt.";
        EFTSetup: Record "NPR EFT Setup";
        SalePOS: Record "NPR Sale POS";
    begin
        POSPaymentLine.ValidateAmountBeforePayment(PaymentType, AmountToCapture);

        if AmountToCapture = 0 then
            exit(true);

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        EFTSetup.FindSetup(SalePOS."Register No.", PaymentType."No.");
        FrontEnd.PauseWorkflow(); //THIS IS ONLY REQUIRED BECAUSE A CONFIRM DIALOG IN THE EFT MODULE TO LOOKUP LAST TRX WOULD, IN NAV2016, CAUSE A CONTINUE IN THE FRONT END...
        EFTTransactionMgt.StartPayment(EFTSetup, PaymentType, AmountToCapture, POSLine."Currency Code", SalePOS);

        exit(true);
    end;

    local procedure CaptureForeignVoucherPayment(AmountToCapture: Decimal; VoucherNumber: Code[20]; POSPaymentLine: Codeunit "NPR POS Payment Line"; var POSLine: Record "NPR Sale Line POS"; PaymentType: Record "NPR Payment Type POS"): Boolean
    var
        AmountToCaptureLCY: Decimal;
        IComm: Codeunit "NPR I-Comm";
        RetailFormCode: Codeunit "NPR Retail Form Code";
    begin
        POSPaymentLine.ValidateAmountBeforePayment(PaymentType, AmountToCapture);

        if (PaymentType."Reference Incoming") then begin
            if (VoucherNumber = '') then
                Error(VoucherNotValid, VoucherNumber);

            if (PaymentType."Processing Type" = PaymentType."Processing Type"::"Foreign Gift Voucher") then
                IComm.TestForeignGiftVoucher(VoucherNumber);
            if (PaymentType."Processing Type" = PaymentType."Processing Type"::"Foreign Credit Voucher") then
                IComm.TestForeignCreditVoucher(VoucherNumber);

            POSLine.Reference := VoucherNumber;
            POSLine.Description := CopyStr(POSLine.Description + ' ' + VoucherNumber, 1, 30);
        end;

        POSLine."Amount Including VAT" := 0;
        POSPaymentLine.InsertPaymentLine(POSLine, AmountToCapture);

        RetailFormCode.PaymentGCVo(POSLine, PaymentType);
        exit(true);
    end;

    local procedure SkipAfterEFTTransaction(POSSession: Codeunit "NPR POS Session"): Boolean
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        EntryNo: Integer;
        Token: Guid;
        TmpVariant: Variant;
        SecondaryEFTTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        if POSSession.RetrieveActionStateSafe('TransactionRequest_EntryNo', TmpVariant) then
            EntryNo := TmpVariant;
        if POSSession.RetrieveActionStateSafe('TransactionRequest_Token', TmpVariant) then
            Token := TmpVariant;

        if EntryNo = 0 then
            exit(false);
        if not EFTTransactionRequest.Get(EntryNo) then
            exit(false);
        if EFTTransactionRequest.Token <> Token then
            exit(false);

        if EFTTransactionRequest."Processing Type" = EFTTransactionRequest."Processing Type"::LOOK_UP then
            exit(true);

        if (not EFTTransactionRequest.Successful) then begin
            SecondaryEFTTransactionRequest.SetFilter("Initiated from Entry No.", '=%1', EFTTransactionRequest."Entry No.");
            if SecondaryEFTTransactionRequest.FindLast() then begin
                if ((SecondaryEFTTransactionRequest."Pepper Transaction Type Code" = EFTTransactionRequest."Pepper Transaction Type Code") and
                  (SecondaryEFTTransactionRequest."Pepper Trans. Subtype Code" = EFTTransactionRequest."Pepper Trans. Subtype Code") and
                  (SecondaryEFTTransactionRequest."Amount Input" = EFTTransactionRequest."Amount Input")) then begin
                    exit(not SecondaryEFTTransactionRequest.Successful);
                end;
            end;

            exit(true);
        end;

        exit(false);
    end;

    procedure CalculateForeignAmount(PaymentTypePOS: Record "NPR Payment Type POS"; AmountLCY: Decimal) Amount: Decimal
    var
        POSPaymentLine: Codeunit "NPR POS Payment Line";
    begin

        exit(POSPaymentLine.CalculateForeignAmount(PaymentTypePOS, AmountLCY));
    end;

    procedure RoundAmount(PaymentTypePOS: Record "NPR Payment Type POS"; Amount: Decimal): Decimal
    var
        POSPaymentLine: Codeunit "NPR POS Payment Line";
    begin

        exit(POSPaymentLine.RoundAmount(PaymentTypePOS, Amount));
    end;

    local procedure SuggestAmount(SalesAmount: Decimal; PaidAmount: Decimal; PaymentType: Record "NPR Payment Type POS"; ReturnPaymentType: Record "NPR Payment Type POS"; AllowNegativePaymentBalance: Boolean): Decimal
    var
        POSPaymentLine: Codeunit "NPR POS Payment Line";
    begin
        exit(POSPaymentLine.CalculateRemainingPaymentSuggestion(SalesAmount, PaidAmount, PaymentType, ReturnPaymentType, AllowNegativePaymentBalance));
    end;

    local procedure GetAmount(Context: JsonObject; FrontEnd: Codeunit "NPR POS Front End Management"): Decimal
    var
        JSON: Codeunit "NPR POS JSON Management";
        AmountToCapture: Decimal;
    begin
        JSON.InitializeJObjectParser(Context, FrontEnd);
        AmountToCapture := JSON.GetDecimal('amounttocapture', false);
        if JSON.SetScope('$amount', false) then begin
            AmountToCapture := JSON.GetDecimal('numpad', true);
        end;
        exit(AmountToCapture);
    end;

    local procedure GetVoucherNo(Context: JsonObject; FrontEnd: Codeunit "NPR POS Front End Management"): Text
    var
        JSON: Codeunit "NPR POS JSON Management";
    begin
        JSON.InitializeJObjectParser(Context, FrontEnd);
        if JSON.SetScope('$voucher', false) then begin
            exit(JSON.GetString('input', true));
        end;
        exit('');
    end;

    procedure TryEndSale(PaymentTypePOS: Record "NPR Payment Type POS"; POSSession: Codeunit "NPR POS Session")
    var
        POSSale: Codeunit "NPR POS Sale";
        Register: Record "NPR Register";
        Setup: Codeunit "NPR POS Setup";
        ReturnPaymentTypePOS: Record "NPR Payment Type POS";
    begin
        POSSession.GetSale(POSSale);
        POSSession.GetSetup(Setup);

        POSSale.SetModified();
        POSSession.RequestRefreshData();
        if SkipAfterEFTTransaction(POSSession) then
            exit;

        if PaymentTypePOS."Auto End Sale" then begin
            Register.Get(Setup.Register);
            ReturnPaymentTypePOS.GetByRegister(Register."Return Payment Type", Register."Register No.");
            POSSale.TryEndSaleWithBalancing(POSSession, PaymentTypePOS, ReturnPaymentTypePOS);
        end;
    end;

    local procedure SelectGiftVoucherFromList(var VoucherNoOut: Code[20]): Boolean
    var
        GiftVoucher: Record "NPR Gift Voucher";
        PageAction: Action;
    begin

        Clear(VoucherNoOut);

        GiftVoucher.Reset();
        GiftVoucher.SetFilter(Status, '=%1', GiftVoucher.Status::Open);
        GiftVoucher.SetFilter(Blocked, '=%1', false);

        PageAction := PAGE.RunModal(PAGE::"NPR TouchScreen: Gift Vouchers", GiftVoucher);

        if (PageAction = ACTION::LookupOK) then
            VoucherNoOut := GiftVoucher."No.";

        if (VoucherNoOut = '') then
            exit(false);

        exit((PageAction = ACTION::LookupOK));
    end;

    local procedure SelectGiftVoucherFromOfflineList(var VoucherNoOut: Code[20]; OfflineVoucherNo: Code[20]): Boolean
    var
        GiftVoucher: Record "NPR Gift Voucher";
        PageAction: Action;
    begin

        if (OfflineVoucherNo = '') then
            exit(false);

        GiftVoucher.Reset();
        GiftVoucher.SetCurrentKey("Offline - No.");
        GiftVoucher.SetFilter(Status, '=%1', GiftVoucher.Status::Open);
        GiftVoucher.SetFilter(Blocked, '=%1', false);
        GiftVoucher.SetFilter("Offline - No.", '=%1', OfflineVoucherNo);
        if (GiftVoucher.IsEmpty()) then
            exit(false);

        if (GiftVoucher.Count = 1) then begin
            GiftVoucher.FindFirst();
            VoucherNoOut := GiftVoucher."No.";
            exit(VoucherNoOut <> '');
        end;

        PageAction := PAGE.RunModal(PAGE::"NPR TouchScreen: Gift Vouchers", GiftVoucher);

        if (PageAction = ACTION::LookupOK) then
            VoucherNoOut := GiftVoucher."No.";

        if (VoucherNoOut = '') then
            exit(false);

        exit(PageAction = ACTION::LookupOK);
    end;

    local procedure GiftVoucherExist(VoucherNo: Code[20]; var VoucherStatusMsg: Text): Boolean
    var
        GiftVoucher: Record "NPR Gift Voucher";
    begin

        if (VoucherNo = '') then
            exit(false);

        if GiftVoucher.Get(VoucherNo) then begin
            if GiftVoucher.Blocked then begin
                VoucherStatusMsg := StrSubstNo(VoucherBlocked, VoucherNo);
                exit(false);
            end;
            if GiftVoucher.Status <> GiftVoucher.Status::Open then begin
                VoucherStatusMsg := StrSubstNo(VoucherStatusNotOpen, VoucherNo, GiftVoucher.Status);
                exit(false);
            end;
            exit(true);
        end else begin
            VoucherStatusMsg := StrSubstNo(VoucherNotFound, VoucherNo);
            exit(false);
        end;
    end;

    local procedure VerifyGiftVoucherNumber(var VoucherNumber: Code[20]; var VoucherStatusMsg: Text): Boolean
    begin

        if (VoucherNumber = '') then
            if (not SelectGiftVoucherFromList(VoucherNumber)) then
                VoucherNumber := '';

        if (not GiftVoucherExist(VoucherNumber, VoucherStatusMsg)) then
            if (not SelectGiftVoucherFromOfflineList(VoucherNumber, VoucherNumber)) then
                if (not CopyGiftVoucherFromCommonCompany(VoucherNumber)) then
                    VoucherNumber := '';

        if (VoucherNumber <> '') then
            exit(GiftVoucherExist(VoucherNumber, VoucherStatusMsg));

        exit(false);
    end;

    local procedure CopyGiftVoucherFromCommonCompany(VoucherNo: Code[20]): Boolean
    var
        RetailSetup: Record "NPR Retail Setup";
        ICommSetup: Record "NPR I-Comm";
        CommonGiftVoucher: Record "NPR Gift Voucher";
        LocalGiftVoucher: Record "NPR Gift Voucher";
    begin

        RetailSetup.Get();
        if (not RetailSetup."Use I-Comm") then
            exit(false);

        if (not ICommSetup.Get()) then
            exit(false);

        if (ICommSetup."Company - Clearing" = '') then
            exit(false);

        CommonGiftVoucher.ChangeCompany(ICommSetup."Company - Clearing");
        CommonGiftVoucher.SetFilter("No.", '=%1', VoucherNo);
        if (not CommonGiftVoucher.FindFirst()) then
            exit(false);

        LocalGiftVoucher.Init();
        LocalGiftVoucher.Copy(CommonGiftVoucher);
        LocalGiftVoucher."External Gift Voucher" := true;
        LocalGiftVoucher."Issuing Register No." := CommonGiftVoucher."Register No.";
        LocalGiftVoucher."Issuing Sales Ticket No." := CommonGiftVoucher."Sales Ticket No.";
        exit(LocalGiftVoucher.Insert());
    end;

    local procedure ApplyGiftVoucherToPaymentLine(VoucherNo: Code[20]; var PaymentLine: Record "NPR Sale Line POS"; PaymentType: Record "NPR Payment Type POS"; var AmountCapturedLCY: Decimal; AmountCaptured: Decimal): Boolean
    var
        GiftVoucher: Record "NPR Gift Voucher";
    begin

        GiftVoucher.Get(VoucherNo);
        GiftVoucher.TestField(Status, GiftVoucher.Status::Open);
        GiftVoucher.TestField(Blocked, false);

        PaymentLine.Description := PaymentType."Sales Line Text" + ' - ' + GiftVoucher."No.";
        PaymentLine."Custom Descr" := true;
        PaymentLine."Gift Voucher Ref." := GiftVoucher."No.";

        if (GiftVoucher."External Gift Voucher") and (GiftVoucher."Created in Company" <> '') then
            PaymentLine.Reference := GiftVoucher."Sales Ticket No.";

        PaymentLine.Clearing := PaymentLine.Clearing::Gavekort;
        PaymentLine."Discount Code" := GiftVoucher."No.";

        AmountCapturedLCY := GiftVoucher.Amount;
        AmountCaptured := 0;

        exit(true);
    end;

    local procedure SelectCreditVoucherFromList(var VoucherNoOut: Code[20]): Boolean
    var
        CreditVoucher: Record "NPR Credit Voucher";
        PageAction: Action;
    begin

        Clear(VoucherNoOut);

        CreditVoucher.Reset();
        CreditVoucher.SetFilter(Status, '=%1', CreditVoucher.Status::Open);
        CreditVoucher.SetFilter(Blocked, '=%1', false);

        PageAction := PAGE.RunModal(PAGE::"NPR TouchScreen: Credit Vouch.", CreditVoucher);

        if (PageAction = ACTION::LookupOK) then
            VoucherNoOut := CreditVoucher."No.";

        if (VoucherNoOut = '') then
            exit(false);

        exit((PageAction = ACTION::LookupOK));
    end;

    local procedure SelectCreditVoucherFromOfflineList(var VoucherNoOut: Code[20]; OfflineVoucherNo: Code[20]): Boolean
    var
        CreditVoucher: Record "NPR Credit Voucher";
        PageAction: Action;
    begin

        if (OfflineVoucherNo = '') then
            exit(false);

        CreditVoucher.Reset();
        CreditVoucher.SetCurrentKey("Offline - No.");
        CreditVoucher.SetFilter(Status, '=%1', CreditVoucher.Status::Open);
        CreditVoucher.SetFilter(Blocked, '=%1', false);
        CreditVoucher.SetFilter("Offline - No.", '=%1', OfflineVoucherNo);
        if (CreditVoucher.IsEmpty()) then
            exit(false);

        if (CreditVoucher.Count = 1) then begin
            CreditVoucher.FindFirst();
            VoucherNoOut := CreditVoucher."No.";
            exit(VoucherNoOut <> '');
        end;

        PageAction := PAGE.RunModal(PAGE::"NPR TouchScreen: Credit Vouch.", CreditVoucher);

        if (PageAction = ACTION::LookupOK) then
            VoucherNoOut := CreditVoucher."No.";

        if (VoucherNoOut = '') then
            exit(false);

        exit(PageAction = ACTION::LookupOK);
    end;

    local procedure CreditVoucherExist(VoucherNo: Code[20]; var VoucherStatusMsg: Text): Boolean
    var
        CreditVoucher: Record "NPR Credit Voucher";
    begin

        if (VoucherNo = '') then
            exit(false);

        if CreditVoucher.Get(VoucherNo) then begin
            if CreditVoucher.Blocked then begin
                VoucherStatusMsg := StrSubstNo(VoucherBlocked, VoucherNo);
                exit(false);
            end;
            if CreditVoucher.Status <> CreditVoucher.Status::Open then begin
                VoucherStatusMsg := StrSubstNo(VoucherStatusNotOpen, VoucherNo, CreditVoucher.Status);
                exit(false);
            end;
            exit(true);
        end else begin
            VoucherStatusMsg := StrSubstNo(VoucherNotFound, VoucherNo);
            exit(false);
        end;
    end;

    local procedure VerifyCreditVoucherNumber(var VoucherNumber: Code[20]; var VoucherStatusMsg: Text): Boolean
    begin

        if (VoucherNumber = '') then
            if (not SelectCreditVoucherFromList(VoucherNumber)) then
                VoucherNumber := '';

        if (not CreditVoucherExist(VoucherNumber, VoucherStatusMsg)) then
            if (not SelectCreditVoucherFromOfflineList(VoucherNumber, VoucherNumber)) then
                if (not CopyCreditVoucherFromCommonCompany(VoucherNumber)) then
                    VoucherNumber := '';

        if (VoucherNumber <> '') then
            exit(CreditVoucherExist(VoucherNumber, VoucherStatusMsg));

        exit(false);
    end;

    local procedure CopyCreditVoucherFromCommonCompany(VoucherNo: Code[20]): Boolean
    var
        RetailSetup: Record "NPR Retail Setup";
        ICommSetup: Record "NPR I-Comm";
        CommonCreditVoucher: Record "NPR Credit Voucher";
        LocalCreditVoucher: Record "NPR Credit Voucher";
    begin

        RetailSetup.Get();
        if (not RetailSetup."Use I-Comm") then
            exit(false);

        if (not ICommSetup.Get()) then
            exit(false);

        if (ICommSetup."Company - Clearing" = '') then
            exit(false);

        CommonCreditVoucher.ChangeCompany(ICommSetup."Company - Clearing");
        CommonCreditVoucher.SetFilter("No.", '=%1', VoucherNo);
        if (not CommonCreditVoucher.FindFirst()) then
            exit(false);

        LocalCreditVoucher.Init();
        LocalCreditVoucher.Copy(CommonCreditVoucher);
        LocalCreditVoucher."External Credit Voucher" := true;
        LocalCreditVoucher."Issued on Drawer No" := CommonCreditVoucher."Register No.";
        LocalCreditVoucher."Issued on Ticket No" := CommonCreditVoucher."Sales Ticket No.";
        exit(LocalCreditVoucher.Insert());
    end;

    local procedure ApplyCreditVoucherToPaymentLine(VoucherNo: Code[20]; var PaymentLine: Record "NPR Sale Line POS"; PaymentType: Record "NPR Payment Type POS"; var AmountCapturedLCY: Decimal; AmountCaptured: Decimal): Boolean
    var
        CreditVoucher: Record "NPR Credit Voucher";
    begin

        CreditVoucher.Get(VoucherNo);
        CreditVoucher.TestField(Status, CreditVoucher.Status::Open);
        CreditVoucher.TestField(Blocked, false);

        PaymentLine.Description := PaymentType."Sales Line Text" + ' - ' + CreditVoucher."No.";
        PaymentLine."Custom Descr" := true;
        PaymentLine."Credit voucher ref." := CreditVoucher."No.";

        if (CreditVoucher."External Credit Voucher") and (CreditVoucher."Created in Company" <> '') then
            PaymentLine.Reference := CreditVoucher."Sales Ticket No.";

        PaymentLine.Clearing := PaymentLine.Clearing::Tilgodebevis;
        PaymentLine."Discount Code" := CreditVoucher."No.";

        AmountCapturedLCY := CreditVoucher.Amount;
        AmountCaptured := 0;

        exit(true);
    end;
}
