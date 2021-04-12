codeunit 6150725 "NPR POS Action: Payment"
{
    var
        ActionDescription: Label 'This is a built-in action for inserting a payment line into the current transaction';
        Setup: Codeunit "NPR POS Setup";
        PaymentTypeNotFound: Label '%1 %2 for POS unit %3 was not found.';
        TextAmountLabel: Label 'Enter Amount';
        TextVoucherLabel: Label 'Enter Voucher Number';
        MissingImpl: Label 'Payment failed!\%1 = %2, %3 = %4 on %5 = %6 did not respond with being handled.\\Check the setup for %1 and %5.';
        NO_SALES_LINES: Label 'There are no sales lines in the POS. You must add at least one sales line before handling payment.';
        ReadingErr: Label 'reading in %1';
        VoucherNotValid: Label 'Voucher %1 is not valid.';
        VoucherNotFound: Label 'Voucher %1 is not found.';

    procedure ActionCode(): Text
    begin
        exit('PAYMENT');
    end;

    local procedure ActionVersion(): Text
    begin
        exit('1.6');
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
            Sender.RegisterWorkflowStep('showEftError', 'context.eft_error && message ({caption: context.eft_error});');

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
        POSPaymentMethod: Record "NPR POS Payment Method";
        ReturnPOSPaymentMethod: Record "NPR POS Payment Method";
        POSPaymentLine: Codeunit "NPR POS Payment Line";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        SaleLinePOS: Record "NPR POS Sale Line";
        SalesAmount: Decimal;
        ReturnAmount: Decimal;
        PaidAmount: Decimal;
        SubTotal: Decimal;
        CurrentView: Codeunit "NPR POS View";
        POSUnit: Record "NPR POS Unit";
        POSAuditProfile: Record "NPR POS Audit Profile";
        POSSale: Codeunit "NPR POS Sale";
        SalePOS: Record "NPR POS Sale";
    begin

        if not Action.IsThisAction(ActionCode()) then
            exit;

        POSSession.GetSetup(Setup);
        Setup.GetPOSUnit(POSUnit);

        PosUnit.TestField("Default POS Payment Bin");

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
        PaymentNo := JSON.GetStringOrFail('paymentNo', StrSubstNo(ReadingErr, ActionCode()));

        POSSession.GetPaymentLine(POSPaymentLine);
        POSPaymentLine.CalculateBalance(SalesAmount, PaidAmount, ReturnAmount, SubTotal);

        if not POSPaymentMethod.Get(PaymentNo) then
            Error(PaymentTypeNotFound, POSPaymentMethod.TableCaption, PaymentNo, Setup.GetPOSUnitNo());

        if not ReturnPOSPaymentMethod.Get(POSPaymentMethod."Return Payment Method Code") then
            POSPaymentMethod.Testfield("Return Payment Method Code");

        OnBeforeActionWorkflow(POSPaymentMethod, Parameters, POSSession, FrontEnd, Context, SubTotal, Handled);

        if (not Handled) then begin
            case POSPaymentMethod."Processing Type" of
                POSPaymentMethod."Processing Type"::Cash:
                    Handled := ConfigureCashWorkflow(Context, POSPaymentMethod, ReturnPOSPaymentMethod, SalesAmount, PaidAmount);
                POSPaymentMethod."Processing Type"::VOUCHER:
                    Handled := ConfigureVoucherWorkflow(Context, POSPaymentMethod, ReturnPOSPaymentMethod, SalesAmount, PaidAmount);
                POSPaymentMethod."Processing Type"::CHECK:
                    Handled := ConfigureCheckWorkflow(Context, POSPaymentMethod, ReturnPOSPaymentMethod, SalesAmount, PaidAmount);
                POSPaymentMethod."Processing Type"::EFT:
                    Handled := ConfigureCashTerminalWorkflow(Context, POSPaymentMethod, ReturnPOSPaymentMethod, SalesAmount, PaidAmount);
                POSPaymentMethod."Processing Type"::CUSTOMER:
                    Handled := ConfigureCustomerWorkflow(Context, POSPaymentMethod, ReturnPOSPaymentMethod, SalesAmount, PaidAmount);
                POSPaymentMethod."Processing Type"::PAYOUT:
                    Handled := ConfigurePayoutWorkflow(Context, POSPaymentMethod, ReturnPOSPaymentMethod, SalesAmount, PaidAmount);
                else                    // provide a resonable default
                    Handled := ConfigureCashWorkflow(Context, POSPaymentMethod, ReturnPOSPaymentMethod, SalesAmount, PaidAmount);
            end;
        end;

        FrontEnd.SetActionContext(ActionCode(), Context);
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
        POSParameterValue.Insert();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS JavaScript Interface", 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        JSON: Codeunit "NPR POS JSON Management";
        POSSale: Codeunit "NPR POS Sale";
        POSPaymentLine: Codeunit "NPR POS Payment Line";
        POSPaymentMethod: Record "NPR POS Payment Method";
        SalePOS: Record "NPR POS Sale";
        PaymentMethodCode: Code[20];
        PaymentHandled: Boolean;
        POSUnit: Record "NPR POS Unit";
    begin
        if not Action.IsThisAction(ActionCode()) then
            exit;

        Handled := true;

        POSSession.GetSetup(Setup);
        JSON.InitializeJObjectParser(Context, FrontEnd);
        JSON.SetScopeParameters(ActionCode());
        PaymentMethodCode := JSON.GetStringOrFail('paymentNo', StrSubstNo(ReadingErr, ActionCode()));

        POSSession.GetPaymentLine(POSPaymentLine);
        if not POSPaymentMethod.Get(PaymentMethodCode) then
            Error(PaymentTypeNotFound, POSPaymentMethod.TableCaption, PaymentMethodCode, Setup.GetPOSUnitNo());

        POSSession.GetSale(POSSale);

        case WorkflowStep of
            'capture_payment':
                begin
                    POSSession.ClearActionState();
                    POSSession.StoreActionState('ContextId', POSSession.BeginAction(ActionCode));

                    OnBeforeAction(WorkflowStep, POSPaymentMethod, Context, POSSession, FrontEnd, PaymentHandled);
                    CapturePayment(POSPaymentMethod, POSSession, FrontEnd, GetAmount(Context, FrontEnd), GetVoucherNo(Context, FrontEnd), PaymentHandled);
                    OnAfterAction(WorkflowStep, POSPaymentMethod, Context, POSSession, FrontEnd, PaymentHandled);
                end;
            'tryEndSale':
                begin
                    PaymentHandled := true;
                    TryEndSale(POSPaymentMethod, POSSession);
                end;
        end;

        if (not PaymentHandled) then
            Message(MissingImpl, POSPaymentMethod.TableCaption(), POSPaymentMethod.Code, POSPaymentMethod.FieldCaption("Processing Type"), POSPaymentMethod."Processing Type", POSUnit.TableCaption(), Setup.GetPOSUnitNo());
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeActionWorkflow(POSPaymentMethod: Record "NPR POS Payment Method"; Parameters: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; Context: Codeunit "NPR POS JSON Management"; SubTotal: Decimal; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeAction(WorkflowStep: Text; POSPaymentMethod: Record "NPR POS Payment Method"; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterAction(WorkflowStep: Text; POSPaymentMethod: Record "NPR POS Payment Method"; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    begin
    end;

    local procedure ConfigureCashWorkflow(var Context: Codeunit "NPR POS JSON Management"; POSPaymentMethod: Record "NPR POS Payment Method"; ReturnPOSPaymentMethod: Record "NPR POS Payment Method"; SalesAmount: Decimal; PaidAmount: Decimal): Boolean
    begin
        Context.SetContext('capture_amount', true);
        SetContextAmounts(Context, POSPaymentMethod, ReturnPOSPaymentMethod, SalesAmount, PaidAmount, true, false);
        Context.SetContext('amount_description', POSPaymentMethod.Description);
        exit(true);
    end;

    local procedure ConfigureManualCardWorkflow(var Context: Codeunit "NPR POS JSON Management"; POSPaymentMethod: Record "NPR POS Payment Method"; ReturnPOSPaymentMethod: Record "NPR POS Payment Method"; SalesAmount: Decimal; PaidAmount: Decimal): Boolean
    begin
        Context.SetContext('capture_amount', true);
        SetContextAmounts(Context, POSPaymentMethod, ReturnPOSPaymentMethod, SalesAmount, PaidAmount, false, false);
        Context.SetContext('amount_description', POSPaymentMethod.Description);
        exit(true);
    end;


    local procedure ConfigureVoucherWorkflow(var Context: Codeunit "NPR POS JSON Management"; POSPaymentMethod: Record "NPR POS Payment Method"; ReturnPOSPaymentMethod: Record "NPR POS Payment Method"; SalesAmount: Decimal; PaidAmount: Decimal): Boolean
    begin
        Context.SetContext('capture_amount', false);
        Context.SetContext('capture_voucher', true);
        SetContextAmounts(Context, POSPaymentMethod, ReturnPOSPaymentMethod, SalesAmount, PaidAmount, false, false);
        exit(true);
    end;

    local procedure ConfigureCheckWorkflow(var Context: Codeunit "NPR POS JSON Management"; POSPaymentMethod: Record "NPR POS Payment Method"; ReturnPOSPaymentMethod: Record "NPR POS Payment Method"; SalesAmount: Decimal; PaidAmount: Decimal): Boolean
    begin
        Context.SetContext('capture_amount', true);
        Context.SetContext('capture_voucher', false);
        SetContextAmounts(Context, POSPaymentMethod, ReturnPOSPaymentMethod, SalesAmount, PaidAmount, false, false);
        exit(true);
    end;

    local procedure ConfigureCashTerminalWorkflow(var Context: Codeunit "NPR POS JSON Management"; POSPaymentMethod: Record "NPR POS Payment Method"; ReturnPOSPaymentMethod: Record "NPR POS Payment Method"; SalesAmount: Decimal; PaidAmount: Decimal): Boolean
    begin
        Context.SetContext('capture_amount', (POSPaymentMethod."Forced Amount" = false));
        SetContextAmounts(Context, POSPaymentMethod, ReturnPOSPaymentMethod, SalesAmount, PaidAmount, false, false);  //NPR5.55 [410991]
        Context.SetContext('amount_description', POSPaymentMethod.Description);
        exit(true);
    end;

    local procedure ConfigureCustomerWorkflow(var Context: Codeunit "NPR POS JSON Management"; POSPaymentMethod: Record "NPR POS Payment Method"; ReturnPOSPaymentMethod: Record "NPR POS Payment Method"; SalesAmount: Decimal; PaidAmount: Decimal): Boolean
    begin
        Context.SetContext('capture_amount', true);
        Context.SetContext('capture_voucher', false);
        SetContextAmounts(Context, POSPaymentMethod, ReturnPOSPaymentMethod, SalesAmount, PaidAmount, false, false);
        exit(true);
    end;

    local procedure ConfigurePayoutWorkflow(var Context: Codeunit "NPR POS JSON Management"; POSPaymentMethod: Record "NPR POS Payment Method"; ReturnPOSPaymentMethod: Record "NPR POS Payment Method"; SalesAmount: Decimal; PaidAmount: Decimal): Boolean
    begin
        Context.SetContext('capture_amount', true);
        Context.SetContext('capture_voucher', false);
        SetContextAmounts(Context, POSPaymentMethod, ReturnPOSPaymentMethod, SalesAmount, PaidAmount, false, false);
        exit(true);
    end;


    local procedure SetContextAmounts(var Context: Codeunit "NPR POS JSON Management"; POSPaymentMethod: Record "NPR POS Payment Method"; ReturnPOSPaymentMethod: Record "NPR POS Payment Method"; SalesAmount: Decimal; PaidAmount: Decimal; AllowNegativePaymentBalance: Boolean; PositiveOnly: Boolean)
    var
        AmtToCapture: Decimal;
    begin
        AmtToCapture := SuggestAmount(SalesAmount, PaidAmount, POSPaymentMethod, ReturnPOSPaymentMethod, AllowNegativePaymentBalance);
        if PositiveOnly and (AmtToCapture < 0) then
            AmtToCapture := 0;

        Context.SetContext('amounttocapture', AmtToCapture);
        if POSPaymentMethod."Zero as Default on Popup" then
            Context.SetContext('defaultamount', 0)
        else
            Context.SetContext('defaultamount', AmtToCapture);
    end;

    procedure CapturePayment(POSPaymentMethod: Record "NPR POS Payment Method"; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; AmountToCapture: Decimal; VoucherNo: Text; var Handled: Boolean)
    var
        POSPaymentLine: Codeunit "NPR POS Payment Line";
        POSLine: Record "NPR POS Sale Line";
        SalesAmount: Decimal;
        ReturnAmount: Decimal;
        PaidAmount: Decimal;
        SubTotal: Decimal;
        POSSetup: Codeunit "NPR POS Setup";
        SalePOS: Record "NPR POS Sale";
        POSSale: Codeunit "NPR POS Sale";
    begin

        if (not Handled) then begin
            POSSession.GetPaymentLine(POSPaymentLine);
            POSPaymentLine.CalculateBalance(SalesAmount, PaidAmount, ReturnAmount, SubTotal);
            POSSession.GetSale(POSSale);
            POSSale.GetCurrentSale(SalePOS);

            Clear(POSLine);
            POSSession.GetSetup(POSSetup);
            POSLine."Register No." := POSSetup.GetPOSUnitNo();

            POSLine."No." := POSPaymentMethod.Code;
            POSLine."Register No." := SalePOS."Register No.";
            POSLine."Sales Ticket No." := SalePOS."Sales Ticket No.";

            case POSPaymentMethod."Processing Type" of
                POSPaymentMethod."Processing Type"::Cash:
                    Handled := CaptureCashPayment(AmountToCapture, POSPaymentLine, POSLine, POSPaymentMethod);
                POSPaymentMethod."Processing Type"::"Voucher":
                    Handled := CaptureVoucherPayment(AmountToCapture, POSPaymentLine, POSLine, POSPaymentMethod, VoucherNo, SalePOS, POSSession, FrontEnd);
                POSPaymentMethod."Processing Type"::EFT:
                    Handled := CaptureEftPayment(AmountToCapture, POSSession, POSPaymentLine, POSLine, POSPaymentMethod, FrontEnd);
                POSPaymentMethod."Processing Type"::CUSTOMER:
                    Handled := CaptureCustomerPayment(AmountToCapture, POSPaymentLine, POSLine, POSPaymentMethod);
                POSPaymentMethod."Processing Type"::PAYOUT:
                    Handled := CapturePayoutPayment(AmountToCapture, POSPaymentLine, POSLine, POSPaymentMethod);
                else
                    Handled := false;
            end;
        end;
    end;

    local procedure CaptureCashPayment(AmountToCaptureLCY: Decimal; POSPaymentLine: Codeunit "NPR POS Payment Line"; var POSLine: Record "NPR POS Sale Line"; POSPaymentMethod: Record "NPR POS Payment Method"): Boolean
    var
        AmountToCapture: Decimal;
    begin
        AmountToCapture := AmountToCaptureLCY;

        if AmountToCaptureLCY = 0 then
            exit(true);

        POSPaymentLine.ValidateAmountBeforePayment(POSPaymentMethod, AmountToCaptureLCY);

        if (POSPaymentMethod."Fixed Rate" <> 0) then begin
            POSLine."Amount Including VAT" := 0;
            POSPaymentLine.InsertPaymentLine(POSLine, AmountToCapture);
        end else begin
            POSLine."Amount Including VAT" := AmountToCaptureLCY;
            POSPaymentLine.InsertPaymentLine(POSLine, 0);
        end;
        exit(true);
    end;

    local procedure CapturePayoutPayment(AmountToCaptureLCY: Decimal; POSPaymentLine: Codeunit "NPR POS Payment Line"; var POSLine: Record "NPR POS Sale Line"; POSPaymentMethod: Record "NPR POS Payment Method"): Boolean
    var
        AmountToCapture: Decimal;
    begin
        AmountToCapture := 0;

        if AmountToCaptureLCY = 0 then
            exit(true);

        POSPaymentLine.ValidateAmountBeforePayment(POSPaymentMethod, AmountToCaptureLCY);

        POSLine."Amount Including VAT" := AmountToCaptureLCY;
        POSPaymentLine.InsertPaymentLine(POSLine, AmountToCapture);

        exit(true);
    end;

    local procedure CaptureCustomerPayment(AmountToCaptureLCY: Decimal; POSPaymentLine: Codeunit "NPR POS Payment Line"; var POSLine: Record "NPR POS Sale Line"; POSPaymentMethod: Record "NPR POS Payment Method"): Boolean
    var
        AmountToCapture: Decimal;
    begin
        AmountToCapture := 0;

        if AmountToCaptureLCY = 0 then
            exit(true);

        POSPaymentLine.ValidateAmountBeforePayment(POSPaymentMethod, AmountToCaptureLCY);

        POSLine."Amount Including VAT" := AmountToCaptureLCY;
        POSPaymentLine.InsertPaymentLine(POSLine, AmountToCapture);

        exit(true);
    end;

    local procedure CaptureVoucherPayment(AmountToCaptureLCY: Decimal; POSPaymentLine: Codeunit "NPR POS Payment Line"; var POSLine: Record "NPR POS Sale Line"; POSPaymentMethod: Record "NPR POS Payment Method"; VoucherNumber: Text; SalePOS: Record "NPR POS Sale"; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"): Boolean
    var
        AmountToCapture: Decimal;
        VoucherStatusMsg: Text;
        VoucherTypeCode: Code[20];
    begin
        AmountToCapture := 0;

        if AmountToCaptureLCY = 0 then
            exit(true);

        if not (VerifyCreditVoucherNumber(VoucherNumber, VoucherTypeCode, VoucherStatusMsg)) then begin
            if VoucherStatusMsg <> '' then
                Error(VoucherStatusMsg);
            Error(VoucherNotValid, VoucherNumber);
        end;

        POSPaymentLine.ValidateAmountBeforePayment(POSPaymentMethod, AmountToCaptureLCY);
        ApplyCreditVoucherToPaymentLine(VoucherTypeCode, VoucherNumber, POSLine, POSPaymentMethod, AmountToCaptureLCY, AmountToCapture, SalePOS, POSSession, FrontEnd);

        exit(true);
    end;


    local procedure CaptureEftPayment(AmountToCapture: Decimal; POSSession: Codeunit "NPR POS Session"; POSPaymentLine: Codeunit "NPR POS Payment Line"; var POSLine: Record "NPR POS Sale Line"; POSPaymentMethod: Record "NPR POS Payment Method"; FrontEnd: Codeunit "NPR POS Front End Management"): Boolean
    var
        POSSale: Codeunit "NPR POS Sale";
        EFTTransactionMgt: Codeunit "NPR EFT Transaction Mgt.";
        EFTSetup: Record "NPR EFT Setup";
        SalePOS: Record "NPR POS Sale";
    begin
        POSPaymentLine.ValidateAmountBeforePayment(POSPaymentMethod, AmountToCapture);

        if AmountToCapture = 0 then
            exit(true);

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        EFTSetup.FindSetup(SalePOS."Register No.", POSPaymentMethod.Code);
        FrontEnd.PauseWorkflow(); //THIS IS ONLY REQUIRED BECAUSE A CONFIRM DIALOG IN THE EFT MODULE TO LOOKUP LAST TRX WOULD, IN NAV2016, CAUSE A CONTINUE IN THE FRONT END...
        EFTTransactionMgt.StartPayment(EFTSetup, AmountToCapture, POSLine."Currency Code", SalePOS);
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
                    SetEftError(SecondaryEFTTransactionRequest, POSSession); //TODO: Remove workaround to BC17 message bug
                    exit(not SecondaryEFTTransactionRequest.Successful);
                end;
            end;

            SetEftError(EFTTransactionRequest, POSSession);  //TODO: Remove workaround to BC17 message bug
            exit(true);
        end;

        exit(false);
    end;

    local procedure SetEftError(EftTransactionRequest: Record "NPR EFT Transaction Request"; POSSession: Codeunit "NPR POS Session")
    var
        TRX_ERROR: Label '%1 failed\%2\%3\%4';
        POSFrontEnd: Codeunit "NPR POS Front End Management";
        Context: Codeunit "NPR POS JSON Management";
    begin
        //TODO: Cleanup Workaround to BC17 message bug

        if (not EftTransactionRequest.Successful) then begin
            if (EftTransactionRequest."Self Service") and (not EftTransactionRequest."External Result Known") then begin
                error(TRX_ERROR, Format(EftTransactionRequest."Processing Type"), EftTransactionRequest."Result Description", EftTransactionRequest."Result Display Text", EftTransactionRequest."NST Error");
            end;

            POSSession.GetFrontEnd(POSFrontEnd, true);
            Context.SetContext('eft_error', StrSubstNo(TRX_ERROR, Format(EftTransactionRequest."Processing Type"), EftTransactionRequest."Result Description", EftTransactionRequest."Result Display Text", EftTransactionRequest."NST Error"));
            POSFrontEnd.SetActionContext(ActionCode(), Context);
        end
    end;

    local procedure SuggestAmount(SalesAmount: Decimal; PaidAmount: Decimal; POSPaymentMethod: Record "NPR POS Payment Method"; ReturnPOSPaymentMethod: Record "NPR POS Payment Method"; AllowNegativePaymentBalance: Boolean): Decimal
    var
        POSPaymentLine: Codeunit "NPR POS Payment Line";
    begin
        exit(POSPaymentLine.CalculateRemainingPaymentSuggestion(SalesAmount, PaidAmount, POSPaymentMethod, ReturnPOSPaymentMethod, AllowNegativePaymentBalance));
    end;

    local procedure GetAmount(Context: JsonObject; FrontEnd: Codeunit "NPR POS Front End Management"): Decimal
    var
        JSON: Codeunit "NPR POS JSON Management";
        AmountToCapture: Decimal;
    begin
        JSON.InitializeJObjectParser(Context, FrontEnd);
        AmountToCapture := JSON.GetDecimal('amounttocapture');
        if JSON.SetScope('$amount') then begin
            AmountToCapture := JSON.GetDecimalOrFail('numpad', StrSubstNo(ReadingErr, ActionCode()));
        end;
        exit(AmountToCapture);
    end;

    local procedure GetVoucherNo(Context: JsonObject; FrontEnd: Codeunit "NPR POS Front End Management"): Text
    var
        JSON: Codeunit "NPR POS JSON Management";
    begin
        JSON.InitializeJObjectParser(Context, FrontEnd);
        if JSON.SetScope('$voucher') then begin
            exit(JSON.GetStringOrFail('input', StrSubstNo(ReadingErr, ActionCode())));
        end;
        exit('');
    end;

    local procedure VerifyCreditVoucherNumber(VoucherNumber: Text; var VoucherTypeCode: Code[20]; VoucherStatusMsg: Text): Boolean
    begin
        if (VoucherNumber <> '') then
            exit(CreditVoucherExist(VoucherNumber, VoucherTypeCode, VoucherStatusMsg));

        exit(false);
    end;

    local procedure SelectCreditVoucherFromList(var VoucherNoOut: Text): Boolean
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        PageAction: Action;
    begin

        Clear(VoucherNoOut);

        NpRvVoucher.Reset();

        PageAction := PAGE.RunModal(0, NpRvVoucher);

        if (PageAction = ACTION::LookupOK) then
            VoucherNoOut := NpRvVoucher."Reference No.";

        if (VoucherNoOut = '') then
            exit(false);

        exit((PageAction = ACTION::LookupOK));
    end;

    local procedure CreditVoucherExist(VoucherNo: Text; var VoucherTypeCode: Code[20]; var VoucherStatusMsg: Text): Boolean
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
    begin
        if (VoucherNo = '') then
            exit(false);
        NpRvVoucher.SetFilter("Reference No.", VoucherNo);
        if NpRvVoucher.FindFirst() then begin
            VoucherTypeCode := NpRvVoucher."Voucher Type";
            exit(true)
        end else begin
            VoucherStatusMsg := StrSubstNo(VoucherNotFound, VoucherNo);
            exit(false);
        end;
    end;

    local procedure ApplyCreditVoucherToPaymentLine(VoucherTypeCode: Code[20]; VoucherNumber: Text; var PaymentLine: Record "NPR POS Sale Line"; POSPaymentMethod: Record "NPR POS Payment Method"; AmountToCaptureLCY: Decimal; AmountToCapture: Decimal; SalePOS: Record "NPR POS Sale"; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"): Boolean
    var
        POSPaymentLine: Codeunit "NPR POS Payment Line";
        NpRvVoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
        POSLine: Record "NPR POS Sale Line";
    begin
        POSSession.GetPaymentLine(POSPaymentLine);
        POSPaymentLine.GetPaymentLine(POSLine);

        NpRvVoucherMgt.ApplyVoucherPayment(VoucherTypeCode, VoucherNumber, PaymentLine, SalePOS, POSSession, FrontEnd, POSPaymentLine, POSLine);

        AmountToCaptureLCY := POSLine."Amount Including VAT";
        AmountToCapture := AmountToCapture;
        exit(true);
    end;



    procedure TryEndSale(POSPaymentMethod: Record "NPR POS Payment Method"; POSSession: Codeunit "NPR POS Session")
    var
        POSSale: Codeunit "NPR POS Sale";
        POSUnit: Record "NPR POS Unit";
        Setup: Codeunit "NPR POS Setup";
        ReturnPOSPaymentMethod: Record "NPR POS Payment Method";
    begin
        POSSession.GetSale(POSSale);
        POSSession.GetSetup(Setup);

        POSSale.SetModified();
        POSSession.RequestRefreshData();
        if SkipAfterEFTTransaction(POSSession) then
            exit;

        if POSPaymentMethod."Auto End Sale" then begin
            POSUnit.Get(Setup.GetPOSUnitNo());
            ReturnPOSPaymentMethod.Get(POSPaymentMethod."Return Payment Method Code");
            POSSale.TryEndSaleWithBalancing(POSSession, POSPaymentMethod, ReturnPOSPaymentMethod);
        end;
    end;
}
