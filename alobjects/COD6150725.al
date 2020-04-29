codeunit 6150725 "POS Action - Payment"
{
    // 
    // This is the main POS Action for handling payments. To extend payment functionality, subscribe to the events
    //  - OnBeforeActionWorkflow: to adapt the workflow to suit your payment method
    //  - OnBeforeAction: to handle the payment before NPR does. When Handled == TRUE, NPR will not bother with the paymentmethod
    //  - OnAfterAction:  to change NPR behaviour or provide functionality where NPR does not
    // 
    // NPR5.36/MMV /20170925 CASE 283791 Print function signature change.
    // NPR5.37/ANEN/20170920 CASE 290857 Added default support for Procesing Type = Manual Card
    // NPR5.37/TSA /20171024 CASE 283422 mPOS return dialog.
    // NPR5.37/MMV /20171024 CASE 293784 Abort workflow for failed EFT transactions instead of attempting to end.
    // NPR5.37.03/MMV /20171123 CASE 296642 Changed EndSale call
    // NPR5.38/MMV /20180108 CASE 300957 Rounding fix.
    // NPR5.38/MMV /20180111 CASE 298025 Calculate mPOS confirm differently.
    // NPR5.38/MMV /20180122 CASE 300957 Use already calculated amount when forced amount is enabled.
    // NPR5.39/MHA /20180208 CASE 303968 Added Parameters HideAmountDialog and HideZeroAmountDialog
    // NPR5.39/TSA /20180214 CASE 305291 When payment type is setup per register only, payment line needs to carry the register no.
    // NPR5.39/TSA /20180214 CASE 303399 If not payment view, change view (that will invoke workflow on view change)
    // NPR5.40/TSA /20180314 CASE 308003 Added a check for zero sales lines to disallow payment (end of sale)
    // NPR5.40/MMV /20180115 CASE 293106 Refactored tax free module.
    // NPR5.40/TSA /20171013 CASE 293479 Added Context,SubTotal as a param to the "POS Action - Payment" event publisher OnBeforeActionWorkflow
    // NPR5.42/TSA /20180502 CASE 312104 Made the zero sales line configurable via setting on NP Retail Setup.
    // NPR5.42/JC  /20180515 CASE 315194 Update Register no. & Sales ticket no. on POS Line
    // NPR5.42/MHA /20180524 CASE 303968 Updated EventPublisherElement for OnBeforeEditPaymentParameters()
    // NPR5.43/MMV /20180620 CASE 315838 Added server stopwatch
    // NPR5.44/THRO/20180724 CASE 322837 More informative message for invalid Gift Voucher
    // NPR5.45/TSA /20180803 CASE 323780 Added call to Sale.SetModified() to have the data driver refresh data
    // NPR5.46/MMV /20180716 CASE 290734 Moved return amount dialog to separate action.
    //                                   EFT refactoring.
    // NPR5.47/THRO/20181011 CASE 322837 More informative message for invalid Credit Voucher
    // NPR5.48/MMV /20181211 CASE 318028 Moved zero sales check
    // NPR5.48/MMV /20190201 CASE 341237 Re-added skip after failed EFT
    // NPR5.49/MHA /20190404 CASE 351069 Zero payment should simply be skipped in CapturePayment()
    // NPR5.50/MMV /20190503 CASE 353807 Fixed 351069. Broke cashback as the zero check is not on user input.
    // NPR5.50/MMV /20190508 CASE 354510 Fixed 341237. Line No. in filter could be re-used and cause invalid decision to skip.
    // NPR5.51/MMV /20190624 CASE 359714 Error when using advanced posting without a default payment bin.
    // NPR5.51/MMV /20190625 CASE 359896 Look for linked successfull EFT record on failure, in skip check function.
    // NPR5.51/THRO/20190718 CASE 361514 EventPublisherElement changed in OnBeforeEditPaymentParameters. Action renamed on Page 6150702
    // NPR5.51/MMV /20190820 CASE 364694 Allow ending sale with voided payment even without items.
    // NPR5.53/MHA /20200114 CASE 384841 Added parameter to SuggestAmount() to allow for negative payment balance
    // NPR5.54/TSA /20200220 CASE 391850 Refactored initial parameters for payment action to hand POS Setup profiles per unit
    // NPR5.54/MMV /20200304 CASE 364340 Isolated CapturePayment & TryEndSale from JSON parsing for test purposes.


    trigger OnRun()
    begin
    end;

    var
        ActionDescription: Label 'This is a built-in action for inserting a payment line into the current transaction';
        EFTIntegration: Codeunit "EFT Framework Mgt.";
        Setup: Codeunit "POS Setup";
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
        exit ('PAYMENT');
    end;

    local procedure ActionVersion(): Text
    begin
        exit ('1.3');
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "POS Action")
    begin
        if Sender.DiscoverAction(
          ActionCode(),
          ActionDescription,
          ActionVersion(),
          Sender.Type::Generic,
          Sender."Subscriber Instances Allowed"::Multiple)
        then begin
          Sender.RegisterWorkflowStep ('voucher','context.capture_voucher && input({caption: labels.Voucher}).cancel(abort)');
          Sender.RegisterWorkflowStep ('amount', 'if ((context.capture_amount) && (!param.HideAmountDialog) && ((!param.HideZeroAmountDialog) || (context.amounttocapture > 0))) {' +
                                                 '  numpad({title: context.amount_description, caption: labels.Amount, value: context.amounttocapture}).cancel(abort);' +
                                                 '}');

          Sender.RegisterWorkflowStep ('capture_payment', 'respond();');
          Sender.RegisterWorkflowStep ('tryEndSale', 'respond();');

          Sender.RegisterWorkflow (true);
          Sender.RegisterDataBinding ();
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150702, 'OnInitializeCaptions', '', true, true)]
    local procedure OnInitializeCaptions(Captions: Codeunit "POS Caption Management")
    begin

        Captions.AddActionCaption (ActionCode(), 'Amount', TextAmountLabel);
        Captions.AddActionCaption (ActionCode(), 'Voucher', TextVoucherLabel);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnBeforeWorkflow', '', true, true)]
    local procedure OnBeforeWorkflow("Action": Record "POS Action";Parameters: DotNet npNetJObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    var
        Context: Codeunit "POS JSON Management";
        JSON: Codeunit "POS JSON Management";
        PaymentNo: Code[20];
        PaymentTypePOS: Record "Payment Type POS";
        Register: Record Register;
        POSPaymentLine: Codeunit "POS Payment Line";
        POSSaleLine: Codeunit "POS Sale Line";
        SaleLinePOS: Record "Sale Line POS";
        SalesAmount: Decimal;
        ReturnAmount: Decimal;
        PaidAmount: Decimal;
        SubTotal: Decimal;
        ReturnPaymentTypePOS: Record "Payment Type POS";
        CurrentView: DotNet npNetView0;
        CurrentViewType: DotNet npNetViewType0;
        NPRetailSetup: Record "NP Retail Setup";
        POSUnit: Record "POS Unit";
        POSAuditProfile: Record "POS Audit Profile";
        POSSale: Codeunit "POS Sale";
        SalePOS: Record "Sale POS";
    begin

        if not Action.IsThisAction(ActionCode()) then
          exit;

        POSSession.GetSetup (Setup);
        //-NPR5.51 [359714]
        Setup.GetPOSUnit(POSUnit);
        Register.Get(Setup.Register());
        NPRetailSetup.Get;
        //+NPR5.51 [359714]

        //-NPR5.51 [359714]
        if NPRetailSetup."Advanced Posting Activated" then begin
          POSUnit.TestField("Default POS Payment Bin");
        end;
        //+NPR5.51 [359714]

        //-NPR5.51 [364694]
        // POSSession.GetSaleLine (POSSaleLine);
        // POSSaleLine.GetCurrentSaleLine (SaleLinePOS);
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        SaleLinePOS.SetFilter("Register No.", '=%1', SalePOS."Register No.");
        SaleLinePOS.SetFilter("Sales Ticket No.", '=%1', SalePOS."Sales Ticket No.");
        //+NPR5.51 [364694]
        SaleLinePOS.SetFilter (Type, '<>%1', SaleLinePOS.Type::Comment);

        if (SaleLinePOS.IsEmpty ()) then begin
          if POSAuditProfile.Get(POSUnit."POS Audit Profile") then
            if not POSAuditProfile."Allow Zero Amount Sales" then
              Error (NO_SALES_LINES);
        end;

        POSSession.GetCurrentView (CurrentView);
        if (CurrentView.Type.Equals (CurrentViewType.Sale)) then
          POSSession.ChangeViewPayment();

        JSON.InitializeJObjectParser(Parameters,FrontEnd);
        PaymentNo := JSON.GetString('paymentNo',true);

        //-NPR5.51 [359714]
        //Register.GET (Setup.Register());
        //+NPR5.51 [359714]

        POSSession.GetPaymentLine (POSPaymentLine);
        POSPaymentLine.CalculateBalance (SalesAmount, PaidAmount, ReturnAmount, SubTotal);

        if (not POSPaymentLine.GetPaymentType(PaymentTypePOS, PaymentNo, Setup.Register())) then
          Error (PaymentTypeNotFound, PaymentTypePOS.TableCaption, PaymentNo, Setup.Register());

        if (not POSPaymentLine.GetPaymentType(ReturnPaymentTypePOS, Register."Return Payment Type", Setup.Register())) then
          Error (PaymentTypeNotFound, PaymentTypePOS.TableCaption, Register."Return Payment Type", Setup.Register());

        OnBeforeActionWorkflow (PaymentTypePOS, Parameters, POSSession, FrontEnd, Context, SubTotal, Handled);

        if (not Handled) then begin
          case PaymentTypePOS."Processing Type" of
            PaymentTypePOS."Processing Type"::Cash :                     Handled := ConfigureCashWorkflow (Context, PaymentTypePOS, ReturnPaymentTypePOS, SalesAmount, PaidAmount);
            PaymentTypePOS."Processing Type"::"Foreign Currency" :       Handled := ConfigureForeignCashWorkflow (Context, PaymentTypePOS, ReturnPaymentTypePOS, SalesAmount, PaidAmount);
            PaymentTypePOS."Processing Type"::"Gift Voucher" :           Handled := ConfigureVoucherWorkflow (Context, PaymentTypePOS, ReturnPaymentTypePOS, SalesAmount, PaidAmount);
            PaymentTypePOS."Processing Type"::"Credit Voucher" :         Handled := ConfigureVoucherWorkflow (Context, PaymentTypePOS, ReturnPaymentTypePOS, SalesAmount, PaidAmount);
            PaymentTypePOS."Processing Type"::"Foreign Gift Voucher" :   Handled := ConfigureForeignVoucherWorkflow (Context, PaymentTypePOS, ReturnPaymentTypePOS, SalesAmount, PaidAmount);
            PaymentTypePOS."Processing Type"::"Foreign Credit Voucher" : Handled := ConfigureForeignVoucherWorkflow (Context, PaymentTypePOS, ReturnPaymentTypePOS, SalesAmount, PaidAmount);
            PaymentTypePOS."Processing Type"::EFT :          Handled := ConfigureCashTerminalWorkflow (Context, PaymentTypePOS, ReturnPaymentTypePOS, SalesAmount, PaidAmount);
            PaymentTypePOS."Processing Type"::"Manual Card" :            Handled := ConfigureManualCardWorkflow (Context, PaymentTypePOS, ReturnPaymentTypePOS, SalesAmount, PaidAmount);
            else
              // provide a resonable default
              Handled := ConfigureCashWorkflow (Context, PaymentTypePOS, ReturnPaymentTypePOS, SalesAmount, PaidAmount);
          end;
        end;

        FrontEnd.SetActionContext (ActionCode, Context);
    end;

    [EventSubscriber(ObjectType::Page, 6150702, 'OnBeforeActionEvent', 'RefreshActionCodeParameters', true, true)]
    local procedure OnBeforeEditPaymentParameters(var Rec: Record "POS Menu Button")
    var
        POSSetup: Record "POS Setup";
        ParamValue: Record "POS Parameter Value";
        IsPaymentAction: Boolean;
    begin
        if Rec."Action Type" <> Rec."Action Type"::PaymentType then
          exit;

        //-NPR5.54 [391850]
        // IF NOT POSSetup.GET THEN
        //  EXIT;
        // IF POSSetup."Payment Action Code" <>  ActionCode() THEN
        //  EXIT;
        if (not POSSetup.FindSet ()) then
          exit;

        IsPaymentAction := false;
        repeat
          IsPaymentAction := IsPaymentAction or (POSSetup."Payment Action Code" = ActionCode());
        until ((POSSetup.Next () = 0) or (IsPaymentAction));
        //-NPR5.54 [391850]

        ParamValue.FilterParameters(Rec.RecordId,0);
        if not ParamValue.IsEmpty then
          exit;

        InitParameters(Rec);
    end;

    local procedure InitParameters(var POSMenuButton: Record "POS Menu Button")
    var
        POSParameterValue: Record "POS Parameter Value";
    begin
        InitParameter(POSMenuButton,'HideAmountDialog',POSParameterValue."Data Type"::Boolean,'false');
        InitParameter(POSMenuButton,'HideZeroAmountDialog',POSParameterValue."Data Type"::Boolean,'false');
    end;

    local procedure InitParameter(var POSMenuButton: Record "POS Menu Button";Name: Text;DataType: Option;DefaultValue: Text)
    var
        POSParameterValue: Record "POS Parameter Value";
    begin
        POSParameterValue.FilterParameters(POSMenuButton.RecordId,0);
        POSParameterValue.SetRange("Action Code",ActionCode());
        POSParameterValue.SetRange(Name,Name);
        if not POSParameterValue.IsEmpty then
          exit;

        POSParameterValue.InitForMenuButton(POSMenuButton);
        POSParameterValue."Action Code" := ActionCode();
        POSParameterValue.Name := Name;
        POSParameterValue."Data Type" := DataType;
        POSParameterValue.Value := DefaultValue;
        POSParameterValue.Insert;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "POS Action";WorkflowStep: Text;Context: DotNet npNetJObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    var
        JSON: Codeunit "POS JSON Management";
        POSSale: Codeunit "POS Sale";
        POSPaymentLine: Codeunit "POS Payment Line";
        PaymentTypePOS: Record "Payment Type POS";
        SalePOS: Record "Sale POS";
        PaymentNo: Code[20];
        Register: Record Register;
        EFTTransactionRequest: Record "EFT Transaction Request";
        TaxFreeUnit: Record "Tax Free POS Unit";
        TaxFree: Codeunit "Tax Free Handler Mgt.";
        PaymentHandled: Boolean;
        ShowConfirmMessage: Boolean;
        SaleIsEnded: Boolean;
        MPOSAppSetup: Record "MPOS App Setup";
        SalesAmount: Decimal;
        ReturnAmount: Decimal;
        PaidAmount: Decimal;
        SubTotal: Decimal;
        ReturnPaymentTypePOS: Record "Payment Type POS";
    begin

        if not Action.IsThisAction(ActionCode()) then
          exit;

        Handled := true;

        POSSession.GetSetup (Setup);
        JSON.InitializeJObjectParser(Context,FrontEnd);
        JSON.SetScope ('parameters', true);
        PaymentNo := JSON.GetString ('paymentNo', true);

        POSSession.GetPaymentLine(POSPaymentLine);
        if (not POSPaymentLine.GetPaymentType (PaymentTypePOS, PaymentNo, Setup.Register)) then
          Error (PaymentTypeNotFound, PaymentTypePOS.TableCaption, PaymentNo, Setup.Register);

        POSSession.GetSale (POSSale);

        case WorkflowStep of
          'capture_payment' :
            begin
              POSSession.ClearActionState();
              POSSession.StoreActionState ('ContextId', POSSession.BeginAction (ActionCode));

              OnBeforeAction (WorkflowStep, PaymentTypePOS, Context, POSSession, FrontEnd, PaymentHandled);
        //-NPR5.54 [364340]
              CapturePayment (PaymentTypePOS, POSSession, FrontEnd, GetAmount(Context, FrontEnd), GetVoucherNo(Context, FrontEnd), PaymentHandled);
        //+NPR5.54 [364340]
              OnAfterAction (WorkflowStep, PaymentTypePOS, Context, POSSession, FrontEnd, PaymentHandled);
            end;

          'tryEndSale' :
            begin
              PaymentHandled := true;
        //-NPR5.54 [364340]
              TryEndSale(PaymentTypePOS, POSSession);
        //      POSSale.SetModified ();
        //      POSSession.RequestRefreshData ();
        //      IF SkipAfterEFTTransaction(POSSession) THEN
        //        EXIT;
        //
        //      IF PaymentTypePOS."Auto End Sale" THEN BEGIN
        //        Register.GET(Setup.Register);
        //        IF (NOT POSPaymentLine.GetPaymentType (ReturnPaymentTypePOS, Register."Return Payment Type", Register."Register No.")) THEN
        //          ERROR (PaymentTypeNotFound, PaymentTypePOS.TABLECAPTION, PaymentNo, Setup.Register);
        //        SaleIsEnded := POSSale.TryEndSaleWithBalancing(POSSession, PaymentTypePOS, ReturnPaymentTypePOS);
        //      END;
        //+NPR5.54 [364340]
            end;
        end;

        if (not PaymentHandled) then
          Message (MissingImpl, PaymentTypePOS.TableCaption(), PaymentTypePOS."No.", PaymentTypePOS.FieldCaption ("Processing Type"), PaymentTypePOS."Processing Type", Register.TableCaption(), Setup.Register());

        //-NPR5.54 [364340]
        // CASE NextWorkflowStep OF
        //  NextWorkflowStep::InvokeEFTDevice : FrontEnd.ContinueAtStep ('EftPayment_invokedevice');
        //  NextWorkflowStep::CheckResult : FrontEnd.ContinueAtStep ('EftPayment_createpospayment');
        //  NextWorkflowStep::VoidPayment : FrontEnd.ContinueAtStep ('EftPayment_voidpayment');
        // END;
        //+NPR5.54 [364340]
    end;

    local procedure "--Publishers"()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeActionWorkflow(PaymentTypePOS: Record "Payment Type POS";Parameters: DotNet npNetJObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";Context: Codeunit "POS JSON Management";SubTotal: Decimal;var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeAction(WorkflowStep: Text;PaymentType: Record "Payment Type POS";Context: DotNet npNetJObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterAction(WorkflowStep: Text;PaymentType: Record "Payment Type POS";Context: DotNet npNetJObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    begin
    end;

    local procedure "--WorkflowHandlers"()
    begin
    end;

    local procedure ConfigureCashWorkflow(var Context: Codeunit "POS JSON Management";PaymentType: Record "Payment Type POS";ReturnPaymentType: Record "Payment Type POS";SalesAmount: Decimal;PaidAmount: Decimal): Boolean
    begin

        Context.SetContext ('capture_amount', true);
        //-NPR5.53 [384841]
        Context.SetContext ('amounttocapture', SuggestAmount (SalesAmount, PaidAmount, PaymentType, ReturnPaymentType, true));
        //+NPR5.53 [384841]
        Context.SetContext ('amount_description', PaymentType.Description);
        exit (true);
    end;

    local procedure ConfigureManualCardWorkflow(var Context: Codeunit "POS JSON Management";PaymentType: Record "Payment Type POS";ReturnPaymentType: Record "Payment Type POS";SalesAmount: Decimal;PaidAmount: Decimal): Boolean
    begin
        Context.SetContext ('capture_amount', true);
        //-NPR5.53 [384841]
        Context.SetContext ('amounttocapture', SuggestAmount (SalesAmount, PaidAmount, PaymentType, ReturnPaymentType, false));
        //+NPR5.53 [384841]
        Context.SetContext ('amount_description', PaymentType.Description);
        exit (true);
    end;

    local procedure ConfigureForeignCashWorkflow(var Context: Codeunit "POS JSON Management";PaymentType: Record "Payment Type POS";ReturnPaymentType: Record "Payment Type POS";SalesAmount: Decimal;PaidAmount: Decimal): Boolean
    begin

        Context.SetContext ('capture_amount', true);
        //-NPR5.53 [384841]
        Context.SetContext ('amounttocapture', SuggestAmount (SalesAmount, PaidAmount, PaymentType, ReturnPaymentType, false));
        //+NPR5.53 [384841]
        Context.SetContext ('amount_description', PaymentType.Description);
        exit (true);
    end;

    local procedure ConfigureVoucherWorkflow(var Context: Codeunit "POS JSON Management";PaymentType: Record "Payment Type POS";ReturnPaymentType: Record "Payment Type POS";SalesAmount: Decimal;PaidAmount: Decimal): Boolean
    begin

        Context.SetContext ('capture_amount', false);
        Context.SetContext ('capture_voucher', true);
        //-NPR5.53 [384841]
        Context.SetContext ('amounttocapture', SuggestAmount (SalesAmount, PaidAmount, PaymentType, ReturnPaymentType, false));
        //+NPR5.53 [384841]
        exit (true);
    end;

    local procedure ConfigureForeignVoucherWorkflow(var Context: Codeunit "POS JSON Management";PaymentType: Record "Payment Type POS";ReturnPaymentType: Record "Payment Type POS";SalesAmount: Decimal;PaidAmount: Decimal): Boolean
    var
        Amount: Decimal;
    begin
        //-NPR5.53 [384841]
        Amount := SuggestAmount(SalesAmount, PaidAmount, PaymentType, ReturnPaymentType,false);
        //+NPR5.53 [384841]
        if Amount < 0 then
          Amount := 0;

        Context.SetContext ('capture_amount', (PaymentType."Forced Amount" = false));
        Context.SetContext ('capture_voucher', (PaymentType."Reference Incoming"));
        Context.SetContext ('amounttocapture', Amount);
        exit (true);
    end;

    local procedure ConfigureCashTerminalWorkflow(var Context: Codeunit "POS JSON Management";PaymentType: Record "Payment Type POS";ReturnPaymentType: Record "Payment Type POS";SalesAmount: Decimal;PaidAmount: Decimal): Boolean
    begin

        Context.SetContext ('capture_amount', (PaymentType."Forced Amount" = false));
        //-NPR5.53 [384841]
        Context.SetContext ('amounttocapture', SuggestAmount (SalesAmount, PaidAmount, PaymentType, ReturnPaymentType, false));
        //+NPR5.53 [384841]
        Context.SetContext ('amount_description', PaymentType.Description);
        exit (true);
    end;

    local procedure "--ActionHandlers"()
    begin
    end;

    procedure CapturePayment(PaymentTypePOS: Record "Payment Type POS";POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";AmountToCapture: Decimal;VoucherNo: Text;var Handled: Boolean)
    var
        POSPaymentLine: Codeunit "POS Payment Line";
        POSLine: Record "Sale Line POS";
        SalesAmount: Decimal;
        ReturnAmount: Decimal;
        PaidAmount: Decimal;
        SubTotal: Decimal;
        POSSetup: Codeunit "POS Setup";
        SalePOS: Record "Sale POS";
        POSSale: Codeunit "POS Sale";
    begin

        if (not Handled) then begin
        //-NPR5.54 [364340]
        //  JSON.InitializeJObjectParser (Context,FrontEnd);
        //+NPR5.54 [364340]
          POSSession.GetPaymentLine (POSPaymentLine);
          POSPaymentLine.CalculateBalance (SalesAmount, PaidAmount, ReturnAmount, SubTotal);
          POSSession.GetSale (POSSale);
          POSSale.GetCurrentSale (SalePOS);

          Clear (POSLine);
          POSSession.GetSetup (POSSetup);
          POSLine."Register No." := POSSetup.Register();

          POSLine."No." := PaymentTypePOS."No.";
          POSLine."Register No." := SalePOS."Register No." ;
          POSLine."Sales Ticket No." := SalePOS."Sales Ticket No.";

        //-NPR5.54 [364340]
          case PaymentTypePOS."Processing Type" of
            PaymentTypePOS."Processing Type"::Cash : Handled := CaptureCashPayment (AmountToCapture, POSPaymentLine, POSLine, PaymentTypePOS);
            PaymentTypePOS."Processing Type"::"Foreign Currency" : Handled := CaptureForeignCashPayment (AmountToCapture, POSPaymentLine, POSLine, PaymentTypePOS);
            PaymentTypePOS."Processing Type"::"Gift Voucher" : Handled := CaptureGiftVoucherPayment (VoucherNo, POSPaymentLine, POSLine, PaymentTypePOS);
            PaymentTypePOS."Processing Type"::"Credit Voucher" : Handled := CaptureCreditVoucherPayment (VoucherNo, POSPaymentLine, POSLine, PaymentTypePOS);
            PaymentTypePOS."Processing Type"::EFT : Handled := CaptureEftPayment (AmountToCapture, POSSession, POSPaymentLine, POSLine, PaymentTypePOS, FrontEnd);
            PaymentTypePOS."Processing Type"::"Foreign Gift Voucher" : Handled := CaptureForeignVoucherPayment (AmountToCapture, VoucherNo, POSPaymentLine, POSLine, PaymentTypePOS);
            PaymentTypePOS."Processing Type"::"Foreign Credit Voucher": Handled := CaptureForeignVoucherPayment (AmountToCapture, VoucherNo, POSPaymentLine, POSLine, PaymentTypePOS);
            PaymentTypePOS."Processing Type"::"Manual Card" : Handled := CaptureManualCardPayment (AmountToCapture, POSPaymentLine, POSLine, PaymentTypePOS);
            else
              Handled := false;
          end;
        //+NPR5.54 [364340]
        end;
    end;

    local procedure CaptureCashPayment(AmountToCaptureLCY: Decimal;POSPaymentLine: Codeunit "POS Payment Line";var POSLine: Record "Sale Line POS";PaymentType: Record "Payment Type POS"): Boolean
    var
        AmountToCapture: Decimal;
    begin
        //-NPR5.54 [364340]
        // JSON.SetScope ('/', TRUE);
        // AmountToCaptureLCY := JSON.GetDecimal('amounttocapture',FALSE);
        // IF JSON.SetScope('$amount',FALSE) THEN
        //  AmountToCaptureLCY := JSON.GetDecimal('numpad',TRUE);
        //+NPR5.54 [364340]

        AmountToCapture := 0;

        if AmountToCaptureLCY = 0 then
          exit(true);

        ValidateAmount (PaymentType, AmountToCaptureLCY);

        POSLine."Amount Including VAT" := AmountToCaptureLCY;
        POSPaymentLine.InsertPaymentLine (POSLine, AmountToCapture);

        exit (true);
    end;

    local procedure CaptureManualCardPayment(AmountToCaptureLCY: Decimal;POSPaymentLine: Codeunit "POS Payment Line";var POSLine: Record "Sale Line POS";PaymentType: Record "Payment Type POS"): Boolean
    var
        AmountToCapture: Decimal;
    begin
        //-NPR5.54 [364340]
        // JSON.SetScope ('/', TRUE);
        // AmountToCaptureLCY := JSON.GetDecimal('amounttocapture',FALSE);
        // IF JSON.SetScope('$amount',FALSE) THEN
        //  AmountToCaptureLCY := JSON.GetDecimal('numpad',TRUE);
        //+NPR5.54 [364340]

        AmountToCapture := 0;

        if AmountToCaptureLCY = 0 then
          exit(true);

        ValidateAmount (PaymentType, AmountToCaptureLCY);

        POSLine."Amount Including VAT" := AmountToCaptureLCY;
        POSPaymentLine.InsertPaymentLine (POSLine, AmountToCapture);

        exit (true);
    end;

    local procedure CaptureForeignCashPayment(AmountToCapture: Decimal;POSPaymentLine: Codeunit "POS Payment Line";var POSLine: Record "Sale Line POS";PaymentType: Record "Payment Type POS"): Boolean
    var
        AmountToCaptureLCY: Decimal;
    begin
        //-NPR5.54 [364340]
        // JSON.SetScope ('/', TRUE);
        // AmountToCapture := JSON.GetDecimal('amounttocapture',FALSE);
        // IF JSON.SetScope('$amount',FALSE) THEN
        //  AmountToCapture := JSON.GetDecimal('numpad',TRUE);
        //+NPR5.54 [364340]

        AmountToCaptureLCY := 0;

        if AmountToCapture = 0 then
          exit(true);

        ValidateAmount (PaymentType, AmountToCapture);

        POSLine."Amount Including VAT" := AmountToCaptureLCY;
        POSPaymentLine.InsertPaymentLine (POSLine, AmountToCapture);

        exit (true);
    end;

    local procedure CaptureGiftVoucherPayment(VoucherNumber: Code[20];POSPaymentLine: Codeunit "POS Payment Line";var POSLine: Record "Sale Line POS";PaymentType: Record "Payment Type POS"): Boolean
    var
        AmountCapturedLCY: Decimal;
        AmountCaptured: Decimal;
        VoucherStatusMsg: Text;
    begin
        //-NPR5.54 [364340]
        // JSON.SetScope ('/', TRUE);
        // JSON.SetScope ('$voucher', TRUE);
        // VoucherNumber := JSON.GetString ('input', FALSE);
        //+NPR5.54 [364340]

        if not (VerifyGiftVoucherNumber (VoucherNumber,VoucherStatusMsg)) then begin
          if VoucherStatusMsg <> '' then
            Error(VoucherStatusMsg);
          Error (VoucherNotValid, VoucherNumber);
        end;

        ApplyGiftVoucherToPaymentLine (VoucherNumber, POSLine, PaymentType, AmountCapturedLCY, AmountCaptured);

        POSLine."Amount Including VAT" := AmountCapturedLCY;
        POSPaymentLine.InsertPaymentLine (POSLine, AmountCaptured);

        exit (true);
    end;

    local procedure CaptureCreditVoucherPayment(VoucherNumber: Code[20];POSPaymentLine: Codeunit "POS Payment Line";var POSLine: Record "Sale Line POS";PaymentType: Record "Payment Type POS"): Boolean
    var
        AmountCapturedLCY: Decimal;
        AmountCaptured: Decimal;
        VoucherStatusMsg: Text;
    begin
        //-NPR5.54 [364340]
        // JSON.SetScope ('/', TRUE);
        // JSON.SetScope ('$voucher', TRUE);
        // VoucherNumber := JSON.GetString ('input', FALSE);
        //+NPR5.54 [364340]

        if not (VerifyCreditVoucherNumber (VoucherNumber,VoucherStatusMsg)) then begin
          if VoucherStatusMsg <> '' then
            Error(VoucherStatusMsg);
          Error (VoucherNotValid, VoucherNumber);
        end;

        ApplyCreditVoucherToPaymentLine (VoucherNumber, POSLine, PaymentType, AmountCapturedLCY, AmountCaptured);

        POSLine."Amount Including VAT" := AmountCapturedLCY;
        POSPaymentLine.InsertPaymentLine (POSLine, AmountCaptured);

        exit (true);
    end;

    local procedure CaptureEftPayment(AmountToCapture: Decimal;POSSession: Codeunit "POS Session";POSPaymentLine: Codeunit "POS Payment Line";var POSLine: Record "Sale Line POS";PaymentType: Record "Payment Type POS";FrontEnd: Codeunit "POS Front End Management"): Boolean
    var
        Register: Record Register;
        Handled: Boolean;
        EFTTransactionRequest: Record "EFT Transaction Request";
        POSSale: Codeunit "POS Sale";
        EFTTransactionMgt: Codeunit "EFT Transaction Mgt.";
        EFTSetup: Record "EFT Setup";
        SalePOS: Record "Sale POS";
    begin
        //-NPR5.54 [364340]
        // Register.GET (Setup.Register);
        //
        // POSPaymentLine.GetPaymentLine (POSLine);
        //
        // IF (PaymentType."Forced Amount") THEN BEGIN
        //  AmountToCapture := JSON.GetDecimal('amounttocapture',TRUE);
        // END ELSE BEGIN
        //  JSON.SetScope ('/', TRUE);
        //  AmountToCapture := JSON.GetDecimal('amounttocapture',FALSE);
        //  IF JSON.SetScope('$amount',FALSE) THEN
        //    AmountToCapture := JSON.GetDecimal('numpad',TRUE);
        //  ValidateAmount (PaymentType, AmountToCapture);
        // END;

        ValidateAmount(PaymentType, AmountToCapture);
        //+NPR5.54 [364340]

        if AmountToCapture = 0 then
          exit(true);

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        EFTSetup.FindSetup(SalePOS."Register No.", PaymentType."No.");
        //-NPR5.54 [364340]
        FrontEnd.PauseWorkflow(); //THIS IS ONLY REQUIRED BECAUSE A CONFIRM DIALOG IN THE EFT MODULE TO LOOKUP LAST TRX WOULD, IN NAV2016, CAUSE A CONTINUE IN THE FRONT END...
        EFTTransactionMgt.StartPayment(EFTSetup, PaymentType, AmountToCapture, POSLine."Currency Code", SalePOS);
        //+NPR5.54 [364340]

        exit(true);
    end;

    local procedure CaptureForeignVoucherPayment(AmountToCapture: Decimal;VoucherNumber: Code[20];POSPaymentLine: Codeunit "POS Payment Line";var POSLine: Record "Sale Line POS";PaymentType: Record "Payment Type POS"): Boolean
    var
        AmountToCaptureLCY: Decimal;
        IComm: Codeunit "I-Comm";
        RetailFormCode: Codeunit "Retail Form Code";
    begin
        //-NPR5.54 [364340]
        // IF (PaymentType."Forced Amount") THEN BEGIN
        //  AmountToCapture := JSON.GetDecimal('amounttocapture',TRUE);
        // END ELSE BEGIN
        //  JSON.SetScope ('/', TRUE);
        //  AmountToCapture := JSON.GetDecimal('amounttocapture',FALSE);
        //  IF JSON.SetScope('$amount',FALSE) THEN
        //    AmountToCapture := JSON.GetDecimal('numpad',TRUE);
        //  ValidateAmount (PaymentType, AmountToCapture);
        // END;

        ValidateAmount (PaymentType, AmountToCapture);
        //+NPR5.54 [364340]

        if (PaymentType."Reference Incoming") then begin
        //-NPR5.54 [364340]
        //  JSON.SetScope ('/', TRUE);
        //  JSON.SetScope ('$voucher', TRUE);
        //  VoucherNumber := JSON.GetString ('input', TRUE);
        //+NPR5.54 [364340]
          if (VoucherNumber = '') then
            Error (VoucherNotValid, VoucherNumber);

          if (PaymentType."Processing Type" = PaymentType."Processing Type"::"Foreign Gift Voucher") then
            IComm.TestForeignGiftVoucher (VoucherNumber);
          if (PaymentType."Processing Type" = PaymentType."Processing Type"::"Foreign Credit Voucher") then
            IComm.TestForeignCreditVoucher (VoucherNumber);

          POSLine.Reference      := VoucherNumber;
          POSLine.Description    := CopyStr(POSLine.Description + ' ' + VoucherNumber, 1,30);
        end;

        POSLine."Amount Including VAT" := 0;
        POSPaymentLine.InsertPaymentLine (POSLine, AmountToCapture);

        RetailFormCode.PaymentGCVo (POSLine, PaymentType);
        exit (true);
    end;

    local procedure SkipAfterEFTTransaction(POSSession: Codeunit "POS Session"): Boolean
    var
        EFTTransactionRequest: Record "EFT Transaction Request";
        EntryNo: Integer;
        Token: Guid;
        TmpVariant: Variant;
        SecondaryEFTTransactionRequest: Record "EFT Transaction Request";
    begin
        if POSSession.RetrieveActionStateSafe ('TransactionRequest_EntryNo', TmpVariant) then
          EntryNo := TmpVariant;
        if POSSession.RetrieveActionStateSafe ('TransactionRequest_Token', TmpVariant) then
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
          SecondaryEFTTransactionRequest.SetFilter ("Initiated from Entry No.", '=%1', EFTTransactionRequest."Entry No.");
          if SecondaryEFTTransactionRequest.FindLast () then begin
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

    local procedure "--"()
    begin
    end;

    procedure CalculateForeignAmount(PaymentTypePOS: Record "Payment Type POS";AmountLCY: Decimal) Amount: Decimal
    var
        POSPaymentLine: Codeunit "POS Payment Line";
    begin

        exit (POSPaymentLine.CalculateForeignAmount (PaymentTypePOS, AmountLCY));
    end;

    procedure RoundAmount(PaymentTypePOS: Record "Payment Type POS";Amount: Decimal): Decimal
    var
        POSPaymentLine: Codeunit "POS Payment Line";
    begin

        exit (POSPaymentLine.RoundAmount (PaymentTypePOS, Amount));
    end;

    local procedure ValidateAmount(PaymentTypePOS: Record "Payment Type POS";AmountToCapture: Decimal)
    begin

        if (PaymentTypePOS."Maximum Amount" <> 0) then
          if (AmountToCapture > PaymentTypePOS."Maximum Amount") then
            Error  (MaxAmountLimit, PaymentTypePOS.Description, PaymentTypePOS."Maximum Amount");

        if (PaymentTypePOS."Minimum Amount" <> 0) then
          if (AmountToCapture < PaymentTypePOS."Minimum Amount") then
            Error (MaxAmountLimit, PaymentTypePOS.Description, PaymentTypePOS."Minimum Amount");

        if (PaymentTypePOS."Rounding Precision" <> 0) then
          if (AmountToCapture mod PaymentTypePOS."Rounding Precision") <> 0 then
            Error (InvalidAmount, AmountToCapture, PaymentTypePOS.Description);
    end;

    local procedure SuggestAmount(SalesAmount: Decimal;PaidAmount: Decimal;PaymentType: Record "Payment Type POS";ReturnPaymentType: Record "Payment Type POS";AllowNegativePaymentBalance: Boolean): Decimal
    var
        POSPaymentLine: Codeunit "POS Payment Line";
    begin
        //-NPR5.53 [384841]
        exit (POSPaymentLine.CalculateRemainingPaymentSuggestion(SalesAmount, PaidAmount, PaymentType, ReturnPaymentType, AllowNegativePaymentBalance));
        //+NPR5.53 [384841]
    end;

    local procedure GetAmount(Context: DotNet npNetJObject;FrontEnd: Codeunit "POS Front End Management"): Decimal
    var
        JSON: Codeunit "POS JSON Management";
        AmountToCapture: Decimal;
    begin
        //-NPR5.54 [364340]
        JSON.InitializeJObjectParser(Context,FrontEnd);
        AmountToCapture := JSON.GetDecimal('amounttocapture',false);
        if JSON.SetScope('$amount',false) then begin
          AmountToCapture := JSON.GetDecimal('numpad',true);
        end;
        exit(AmountToCapture);
        //+NPR5.54 [364340]
    end;

    local procedure GetVoucherNo(Context: DotNet npNetJObject;FrontEnd: Codeunit "POS Front End Management"): Text
    var
        JSON: Codeunit "POS JSON Management";
    begin
        //-NPR5.54 [364340]
        JSON.InitializeJObjectParser(Context,FrontEnd);
        if JSON.SetScope ('$voucher', false) then begin
          exit(JSON.GetString ('input', true));
        end;
        exit('');
        //+NPR5.54 [364340]
    end;

    procedure TryEndSale(PaymentTypePOS: Record "Payment Type POS";POSSession: Codeunit "POS Session")
    var
        POSSale: Codeunit "POS Sale";
        Register: Record Register;
        Setup: Codeunit "POS Setup";
        ReturnPaymentTypePOS: Record "Payment Type POS";
    begin
        //+NPR5.54 [364340]
        POSSession.GetSale(POSSale);
        POSSession.GetSetup(Setup);

        POSSale.SetModified ();
        POSSession.RequestRefreshData ();
        if SkipAfterEFTTransaction(POSSession) then
          exit;

        if PaymentTypePOS."Auto End Sale" then begin
          Register.Get(Setup.Register);
          ReturnPaymentTypePOS.GetByRegister(Register."Return Payment Type", Register."Register No.");
          POSSale.TryEndSaleWithBalancing(POSSession, PaymentTypePOS, ReturnPaymentTypePOS);
        end;
        //+NPR5.54 [364340]
    end;

    local procedure "-- GiftVouchers"()
    begin
    end;

    local procedure SelectGiftVoucherFromList(var VoucherNoOut: Code[20]): Boolean
    var
        GiftVoucher: Record "Gift Voucher";
        PageAction: Action;
    begin

        Clear (VoucherNoOut);

        GiftVoucher.Reset();
        GiftVoucher.SetFilter (Status, '=%1', GiftVoucher.Status::Open);
        GiftVoucher.SetFilter (Blocked, '=%1', false);

        PageAction := PAGE.RunModal (PAGE::"Touch Screen - Gift Vouchers", GiftVoucher);

        if (PageAction = ACTION::LookupOK) then
          VoucherNoOut := GiftVoucher."No.";

        if (VoucherNoOut = '') then
          exit (false);

        exit ((PageAction = ACTION::LookupOK));
    end;

    local procedure SelectGiftVoucherFromOfflineList(var VoucherNoOut: Code[20];OfflineVoucherNo: Code[20]): Boolean
    var
        GiftVoucher: Record "Gift Voucher";
        PageAction: Action;
    begin

        if (OfflineVoucherNo = '') then
          exit (false);

        GiftVoucher.Reset();
        GiftVoucher.SetCurrentKey("Offline - No.");
        GiftVoucher.SetFilter (Status, '=%1', GiftVoucher.Status::Open);
        GiftVoucher.SetFilter (Blocked, '=%1', false);
        GiftVoucher.SetFilter ("Offline - No.", '=%1', OfflineVoucherNo);
        if (GiftVoucher.IsEmpty ()) then
          exit (false);

        if (GiftVoucher.Count = 1) then begin
          GiftVoucher.FindFirst ();
          VoucherNoOut := GiftVoucher."No.";
          exit (VoucherNoOut <> '');
        end;

        PageAction := PAGE.RunModal (PAGE::"Touch Screen - Gift Vouchers", GiftVoucher);

        if (PageAction = ACTION::LookupOK) then
          VoucherNoOut := GiftVoucher."No.";

        if (VoucherNoOut = '') then
          exit (false);

        exit (PageAction = ACTION::LookupOK);
    end;

    local procedure GiftVoucherExist(VoucherNo: Code[20];var VoucherStatusMsg: Text): Boolean
    var
        GiftVoucher: Record "Gift Voucher";
    begin

        if (VoucherNo = '') then
          exit (false);

        if GiftVoucher.Get(VoucherNo) then begin
          if GiftVoucher.Blocked then begin
            VoucherStatusMsg := StrSubstNo(VoucherBlocked,VoucherNo);
            exit(false);
          end;
          if GiftVoucher.Status <> GiftVoucher.Status::Open then begin
            VoucherStatusMsg := StrSubstNo(VoucherStatusNotOpen,VoucherNo,GiftVoucher.Status);
            exit(false);
          end;
          exit(true);
        end else begin
          VoucherStatusMsg := StrSubstNo(VoucherNotFound,VoucherNo);
          exit(false);
        end;
    end;

    local procedure VerifyGiftVoucherNumber(var VoucherNumber: Code[20];var VoucherStatusMsg: Text): Boolean
    begin

        if (VoucherNumber = '') then
          if (not SelectGiftVoucherFromList (VoucherNumber)) then
            VoucherNumber := '';

        if (not GiftVoucherExist (VoucherNumber,VoucherStatusMsg)) then
          if (not SelectGiftVoucherFromOfflineList (VoucherNumber, VoucherNumber)) then
            if (not CopyGiftVoucherFromCommonCompany (VoucherNumber)) then
              VoucherNumber := '';

        if (VoucherNumber <> '') then
          exit (GiftVoucherExist (VoucherNumber,VoucherStatusMsg));

        exit (false);
    end;

    local procedure CopyGiftVoucherFromCommonCompany(VoucherNo: Code[20]): Boolean
    var
        RetailSetup: Record "Retail Setup";
        ICommSetup: Record "I-Comm";
        CommonGiftVoucher: Record "Gift Voucher";
        LocalGiftVoucher: Record "Gift Voucher";
    begin

        RetailSetup.Get();
        if (not RetailSetup."Use I-Comm") then
          exit (false);

        if (not ICommSetup.Get()) then
          exit (false);

        if (ICommSetup."Company - Clearing" = '') then
          exit (false);

        CommonGiftVoucher.ChangeCompany (ICommSetup."Company - Clearing");
        CommonGiftVoucher.SetFilter ("No.", '=%1', VoucherNo);
        if (not CommonGiftVoucher.FindFirst()) then
          exit (false);

        LocalGiftVoucher.Init();
        LocalGiftVoucher.Copy (CommonGiftVoucher);
        LocalGiftVoucher."External Gift Voucher" := true;
        LocalGiftVoucher."Issuing Register No." := CommonGiftVoucher."Register No.";
        LocalGiftVoucher."Issuing Sales Ticket No."   := CommonGiftVoucher."Sales Ticket No.";
        exit (LocalGiftVoucher.Insert());
    end;

    local procedure ApplyGiftVoucherToPaymentLine(VoucherNo: Code[20];var PaymentLine: Record "Sale Line POS";PaymentType: Record "Payment Type POS";var AmountCapturedLCY: Decimal;AmountCaptured: Decimal): Boolean
    var
        GiftVoucher: Record "Gift Voucher";
    begin

        GiftVoucher.Get (VoucherNo);
        GiftVoucher.TestField (Status, GiftVoucher.Status::Open);
        GiftVoucher.TestField (Blocked, false);

        PaymentLine.Description := PaymentType."Sales Line Text" + ' - ' + GiftVoucher."No.";
        PaymentLine."Custom Descr" := true;
        PaymentLine."Gift Voucher Ref." := GiftVoucher."No.";

        if (GiftVoucher."External Gift Voucher") and (GiftVoucher."Created in Company" <> '') then
          PaymentLine.Reference := GiftVoucher."Sales Ticket No.";

        PaymentLine.Clearing := PaymentLine.Clearing::Gavekort;
        PaymentLine."Discount Code" := GiftVoucher."No.";

        AmountCapturedLCY := GiftVoucher.Amount;
        AmountCaptured := 0;

        exit (true);
    end;

    local procedure "-- CreditVouchers"()
    begin
    end;

    local procedure SelectCreditVoucherFromList(var VoucherNoOut: Code[20]): Boolean
    var
        CreditVoucher: Record "Credit Voucher";
        PageAction: Action;
    begin

        Clear (VoucherNoOut);

        CreditVoucher.Reset();
        CreditVoucher.SetFilter (Status, '=%1', CreditVoucher.Status::Open);
        CreditVoucher.SetFilter (Blocked, '=%1', false);

        PageAction := PAGE.RunModal (PAGE::"Touch Screen - Credit Vouchers", CreditVoucher);

        if (PageAction = ACTION::LookupOK) then
          VoucherNoOut := CreditVoucher."No.";

        if (VoucherNoOut = '') then
          exit (false);

        exit ((PageAction = ACTION::LookupOK));
    end;

    local procedure SelectCreditVoucherFromOfflineList(var VoucherNoOut: Code[20];OfflineVoucherNo: Code[20]): Boolean
    var
        CreditVoucher: Record "Credit Voucher";
        PageAction: Action;
    begin

        if (OfflineVoucherNo = '') then
          exit (false);

        CreditVoucher.Reset();
        CreditVoucher.SetCurrentKey("Offline - No.");
        CreditVoucher.SetFilter (Status, '=%1', CreditVoucher.Status::Open);
        CreditVoucher.SetFilter (Blocked, '=%1', false);
        CreditVoucher.SetFilter ("Offline - No.", '=%1', OfflineVoucherNo);
        if (CreditVoucher.IsEmpty ()) then
          exit (false);

        if (CreditVoucher.Count = 1) then begin
          CreditVoucher.FindFirst ();
          VoucherNoOut := CreditVoucher."No.";
          exit (VoucherNoOut <> '');
        end;

        PageAction := PAGE.RunModal (PAGE::"Touch Screen - Credit Vouchers", CreditVoucher);

        if (PageAction = ACTION::LookupOK) then
          VoucherNoOut := CreditVoucher."No.";

        if (VoucherNoOut = '') then
          exit (false);

        exit (PageAction = ACTION::LookupOK);
    end;

    local procedure CreditVoucherExist(VoucherNo: Code[20];var VoucherStatusMsg: Text): Boolean
    var
        CreditVoucher: Record "Credit Voucher";
    begin

        if (VoucherNo = '') then
          exit (false);

        //-NPR5.47 [322837]
        //CreditVoucher.RESET();
        //CreditVoucher.SETFILTER (Status, '=%1', CreditVoucher.Status::Open);
        //CreditVoucher.SETFILTER (Blocked, '=%1', FALSE);
        //CreditVoucher.SETFILTER ("No.", '=%1', VoucherNo);

        //EXIT (NOT CreditVoucher.ISEMPTY ());
        if CreditVoucher.Get(VoucherNo) then begin
          if CreditVoucher.Blocked then begin
            VoucherStatusMsg := StrSubstNo(VoucherBlocked,VoucherNo);
            exit(false);
          end;
          if CreditVoucher.Status <> CreditVoucher.Status::Open then begin
            VoucherStatusMsg := StrSubstNo(VoucherStatusNotOpen,VoucherNo,CreditVoucher.Status);
            exit(false);
          end;
          exit(true);
        end else begin
          VoucherStatusMsg := StrSubstNo(VoucherNotFound,VoucherNo);
          exit(false);
        end;
        //+NPR5.47 [322837]
    end;

    local procedure VerifyCreditVoucherNumber(var VoucherNumber: Code[20];var VoucherStatusMsg: Text): Boolean
    begin

        if (VoucherNumber = '') then
          if (not SelectCreditVoucherFromList (VoucherNumber)) then
            VoucherNumber := '';

        //-NPR5.47 [322837]
        if (not CreditVoucherExist (VoucherNumber,VoucherStatusMsg)) then
        //+NPR5.47 [322837]
          if (not SelectCreditVoucherFromOfflineList (VoucherNumber, VoucherNumber)) then
            if (not CopyCreditVoucherFromCommonCompany (VoucherNumber)) then
              VoucherNumber := '';

        if (VoucherNumber <> '') then
          //-NPR5.47 [322837]
          exit (CreditVoucherExist (VoucherNumber,VoucherStatusMsg));
          //+NPR5.47 [322837]

        exit (false);
    end;

    local procedure CopyCreditVoucherFromCommonCompany(VoucherNo: Code[20]): Boolean
    var
        RetailSetup: Record "Retail Setup";
        ICommSetup: Record "I-Comm";
        CommonCreditVoucher: Record "Credit Voucher";
        LocalCreditVoucher: Record "Credit Voucher";
    begin

        RetailSetup.Get();
        if (not RetailSetup."Use I-Comm") then
          exit (false);

        if (not ICommSetup.Get()) then
          exit (false);

        if (ICommSetup."Company - Clearing" = '') then
          exit (false);

        CommonCreditVoucher.ChangeCompany (ICommSetup."Company - Clearing");
        CommonCreditVoucher.SetFilter ("No.", '=%1', VoucherNo);
        if (not CommonCreditVoucher.FindFirst()) then
          exit (false);

        LocalCreditVoucher.Init();
        LocalCreditVoucher.Copy (CommonCreditVoucher);
        LocalCreditVoucher."External Credit Voucher" := true;
        LocalCreditVoucher."Issued on Drawer No" := CommonCreditVoucher."Register No.";
        LocalCreditVoucher."Issued on Ticket No"   := CommonCreditVoucher."Sales Ticket No.";
        exit (LocalCreditVoucher.Insert());
    end;

    local procedure ApplyCreditVoucherToPaymentLine(VoucherNo: Code[20];var PaymentLine: Record "Sale Line POS";PaymentType: Record "Payment Type POS";var AmountCapturedLCY: Decimal;AmountCaptured: Decimal): Boolean
    var
        CreditVoucher: Record "Credit Voucher";
    begin

        CreditVoucher.Get (VoucherNo);
        CreditVoucher.TestField (Status, CreditVoucher.Status::Open);
        CreditVoucher.TestField (Blocked, false);

        PaymentLine.Description := PaymentType."Sales Line Text" + ' - ' + CreditVoucher."No.";
        PaymentLine."Custom Descr" := true;
        PaymentLine."Credit voucher ref." := CreditVoucher."No.";

        if (CreditVoucher."External Credit Voucher") and (CreditVoucher."Created in Company" <> '') then
          PaymentLine.Reference := CreditVoucher."Sales Ticket No.";

        PaymentLine.Clearing := PaymentLine.Clearing::Tilgodebevis;
        PaymentLine."Discount Code" := CreditVoucher."No.";

        AmountCapturedLCY := CreditVoucher.Amount;
        AmountCaptured := 0;

        exit (true);
    end;
}

