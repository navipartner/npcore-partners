codeunit 6150850 "POS Action - CK Payment"
{
    // NPR5.43/CLVA/20180307 CASE 291921 Object created
    // NPR5.43/CLVA/20180205 CASE 308887 Removed numpad step
    // NPR5.43/CLVA/20180529 CASE 316560 Removed CashKeeper UI when amout = 0


    trigger OnRun()
    begin
    end;

    var
        ActionDescription: Label 'This is a built-in action for CashKeeper Payments';
        Setup: Codeunit "POS Setup";
        TextAmountLabel: Label 'Enter Amount:';
        PaymentTypeNotFound: Label '%1 %2 for register %3 was not found.';
        CashkeeperNotFound: Label 'CashKeeper Setup for register %3 was not found.';
        NoCashBackErr: Label 'It is not allowed to enter an amount that is bigger than what is stated on the receipt for this payment type';
        RequestNotFound: Label 'Action Code %1 tried retrieving "TransactionRequest_EntryNo" from POS Session and got %2. There is however no record in %3 to match that entry number.';
        NoNegativeCashBackErr: Label 'It is not allowed to enter an amount that is different from what is stated on the receipt for this payment type';
        NegativeCashBackErr: Label 'It is not allowed to enter an negative amount';

    local procedure ActionCode(): Text
    begin
        exit ('CK_PAYMENT');
    end;

    local procedure ActionVersion(): Text
    begin
        exit ('1.30');
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

          //Sender.RegisterWorkflowStep ('Amount', 'context.capture_amount && numpad({title: context.amount_description, caption: labels.Amount, value: context.amounttocapture}).respond().cancel(abort);');
          //NPR5.43-
          //Sender.RegisterWorkflowStep ('Amount', 'if ((context.capture_amount) && (context.amounttocapture != 0)) { numpad({title: context.amount_description, caption: labels.Amount, value: context.amounttocapture}).respond().cancel(abort); }');
          //NPR5.43+

          Sender.RegisterWorkflowStep ('CreateTransaction', 'respond();');
          Sender.RegisterWorkflowStep ('InvokeDevice', 'respond();');
          Sender.RegisterWorkflowStep ('CheckTransactionResult', 'respond();');

          Sender.RegisterWorkflow(true);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150702, 'OnInitializeCaptions', '', true, true)]
    local procedure OnInitializeCaptions(Captions: Codeunit "POS Caption Management")
    begin
        Captions.AddActionCaption (ActionCode(), 'Amount', TextAmountLabel);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnBeforeWorkflow', '', true, true)]
    local procedure OnBeforeWorkflow("Action": Record "POS Action";Parameters: DotNet JObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    var
        Context: Codeunit "POS JSON Management";
        JSON: Codeunit "POS JSON Management";
        PaymentNo: Code[20];
        PaymentTypePOS: Record "Payment Type POS";
        Register: Record Register;
        POSPaymentLine: Codeunit "POS Payment Line";
        SalesAmount: Decimal;
        ReturnAmount: Decimal;
        PaidAmount: Decimal;
        SubTotal: Decimal;
        ReturnPaymentTypePOS: Record "Payment Type POS";
        CurrentView: DotNet npNetView0;
        CurrentViewType: DotNet npNetViewType0;
        CashKeeperSetup: Record "CashKeeper Setup";
    begin
        if not Action.IsThisAction(ActionCode()) then
          exit;

        POSSession.GetCurrentView (CurrentView);
        if (CurrentView.Type.Equals (CurrentViewType.Sale)) then
          POSSession.ChangeViewPayment();

        POSSession.GetSetup (Setup);
        Setup.GetRegisterRecord(Register);

        if not CashKeeperSetup.Get(Register."Register No.") then
          Error(CashkeeperNotFound,Register."Register No.");

        PaymentNo := CashKeeperSetup."Payment Type";

        POSSession.GetPaymentLine (POSPaymentLine);
        POSPaymentLine.CalculateBalance (SalesAmount, PaidAmount, ReturnAmount, SubTotal);

        if (not POSPaymentLine.GetPaymentType(PaymentTypePOS, PaymentNo, Setup.Register())) then
          Error (PaymentTypeNotFound, PaymentTypePOS.TableCaption, PaymentNo, Setup.Register());

        if (not POSPaymentLine.GetPaymentType(ReturnPaymentTypePOS, Register."Return Payment Type", Setup.Register())) then
          Error (PaymentTypeNotFound, PaymentTypePOS.TableCaption, Register."Return Payment Type", Setup.Register());

        Handled := ConfigureCashWorkflow(Context, PaymentTypePOS, ReturnPaymentTypePOS, SalesAmount, PaidAmount);

        FrontEnd.SetActionContext(ActionCode, Context);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "POS Action";WorkflowStep: Text;Context: DotNet JObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    var
        EFTHandled: Boolean;
        PaymentTypeNo: Code[20];
        PaymentTypePOS: Record "Payment Type POS";
        Register: Record Register;
        ConfirmId: Text;
        Confirmed: Boolean;
        JSON: Codeunit "POS JSON Management";
        tmpVariant: Variant;
        AmountToCapture: Decimal;
        NumpadAmount: Decimal;
        CashKeeperTransaction: Record "CashKeeper Transaction";
    begin
        if not Action.IsThisAction(ActionCode()) then
          exit;

        JSON.InitializeJObjectParser(Context,FrontEnd);

        Handled := true;

        case WorkflowStep of
          'Amount' :
            begin
              POSSession.ClearActionState();
            end;

          'CreateTransaction' :
            begin
              //NPR5.43-
              POSSession.ClearActionState();
              //NPR5.43+

              PaymentTypeNo := JSON.GetString('paymenttypeno',true);
              AmountToCapture := JSON.GetDecimal('amounttocapture',true);

        //NPR5.43-
        //      NumpadAmount := 0;
        //      IF AmountToCapture <> 0 THEN BEGIN
        //        JSON.SetScope ('$Amount', TRUE);
        //        NumpadAmount := JSON.GetDecimal('numpad', TRUE);
        //      END ELSE
        //        POSSession.ClearActionState();
              NumpadAmount := AmountToCapture;
        //NPR5.43+

              JSON.SetContext('TransactionRequest_EntryNo', '');
              FrontEnd.SetActionContext(ActionCode, JSON);

        //NPR5.43-
        //      EFTHandled := CreateTransaction(POSSession,AmountToCapture,PaymentTypeNo,NumpadAmount);
              EFTHandled := CreateTransaction(POSSession,AmountToCapture,PaymentTypeNo,NumpadAmount);
        //NPR5.43+

            end;

          'InvokeDevice' :
            begin
              EFTHandled := true;
              GetTransactionRequest(POSSession, CashKeeperTransaction);
              FrontEnd.PauseWorkflow();
              OnInvokeDevice(CashKeeperTransaction);
            end;

          'CheckTransactionResult' :
            begin
              EFTHandled := true;
              GetTransactionRequest(POSSession, CashKeeperTransaction);
              CheckTransactionResult(POSSession, FrontEnd, CashKeeperTransaction);
            end;

        end;
    end;

    local procedure CreateTransaction(POSSession: Codeunit "POS Session";AmountToCapture: Decimal;PaymentTypeNo: Code[20];NumpadAmount: Decimal): Boolean
    var
        Register: Record Register;
        POSLine: Record "Sale Line POS";
        POSPaymentLine: Codeunit "POS Payment Line";
        PaymentTypePOS: Record "Payment Type POS";
        Handled: Boolean;
        tmpVariant: Variant;
        SalesAmount: Decimal;
        PaidAmount: Decimal;
        ReturnAmount: Decimal;
        SubTotal: Decimal;
        CashKeeperTransaction: Record "CashKeeper Transaction";
        POSSaleLine: Codeunit "POS Sale Line";
        SaleLinePOS: Record "Sale Line POS";
    begin
        Setup.GetRegisterRecord(Register);
        POSSession.GetPaymentLine(POSPaymentLine);
        POSPaymentLine.GetCurrentPaymentLine(POSLine);
        POSPaymentLine.GetPaymentType(PaymentTypePOS, PaymentTypeNo, POSLine."Register No.");
        POSPaymentLine.CalculateBalance(SalesAmount, PaidAmount, ReturnAmount, SubTotal);

        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        if (AmountToCapture >= 0) then begin

          if (NumpadAmount > Abs (SubTotal)) then
            Error(NoCashBackErr);

          if (NumpadAmount < 0) then
            Error(NegativeCashBackErr);

          CashKeeperTransaction.Init;
          CashKeeperTransaction."Register No." := SaleLinePOS."Register No.";
          CashKeeperTransaction."Sales Ticket No." := SaleLinePOS."Sales Ticket No.";
          CashKeeperTransaction.Amount := NumpadAmount;
          CashKeeperTransaction."Order ID" := StrSubstNo('%1-%2',CashKeeperTransaction."Register No.",
                                                                   CashKeeperTransaction."Sales Ticket No.");
          CashKeeperTransaction."Value In Cents" := CashKeeperTransaction.Amount * 100;
          CashKeeperTransaction.Action := CashKeeperTransaction.Action::Capture;
          CashKeeperTransaction."Payment Type" := PaymentTypeNo;
          CashKeeperTransaction.Insert(true);

        end;

        if (AmountToCapture < 0) then begin

          if (NumpadAmount <> SubTotal) then
            Error(NoNegativeCashBackErr);

          CashKeeperTransaction.Init;
          CashKeeperTransaction."Register No." := SaleLinePOS."Register No.";
          CashKeeperTransaction."Sales Ticket No." := SaleLinePOS."Sales Ticket No.";
          CashKeeperTransaction.Amount := NumpadAmount * -1;
          CashKeeperTransaction."Order ID" := StrSubstNo('%1-%2',CashKeeperTransaction."Register No.",
                                                                 CashKeeperTransaction."Sales Ticket No.");
          CashKeeperTransaction."Value In Cents" := CashKeeperTransaction.Amount * 100;
          CashKeeperTransaction.Action := CashKeeperTransaction.Action::Pay;
          CashKeeperTransaction."Payment Type" := PaymentTypeNo;
          CashKeeperTransaction.Insert;

        end;

        Handled := true;

        SetTransactionRequest(POSSession, CashKeeperTransaction);

        exit (Handled);
    end;

    local procedure CheckTransactionResult(POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";var CashKeeperTransaction: Record "CashKeeper Transaction"): Boolean
    var
        PaymentTypeNo: Code[10];
        PaymentTypePOS: Record "Payment Type POS";
        Context: DotNet JObject;
        JSON: Codeunit "POS JSON Management";
        Txt001: Label 'CashKeeper error: %1 - %2';
        Txt002: Label 'Payment was cancelled';
    begin
        if (CashKeeperTransaction.Status = CashKeeperTransaction.Status::Error) then begin
          Message(Txt001, CashKeeperTransaction."CK Error Code", CashKeeperTransaction."CK Error Description");
          exit(false);
        end;

        if (CashKeeperTransaction.Status = CashKeeperTransaction.Status::Cancelled) then begin
          Message(Txt002);
          exit(false);
        end;

        PaymentTypeNo := CashKeeperTransaction."Payment Type";
        PaymentTypePOS.Get(PaymentTypeNo, '');
        UpdatePaymentLine(CashKeeperTransaction, PaymentTypePOS, Context, POSSession, FrontEnd);
        POSSession.RequestRefreshData();
        POSSession.ClearActionState();
        exit(true);
    end;

    local procedure "--WorkflowHandlers"()
    begin
    end;

    local procedure ConfigureCashWorkflow(var Context: Codeunit "POS JSON Management";PaymentType: Record "Payment Type POS";ReturnPaymentType: Record "Payment Type POS";SalesAmount: Decimal;PaidAmount: Decimal): Boolean
    begin
        Context.SetContext ('capture_amount', true);
        Context.SetContext ('amounttocapture', SuggestAmount(SalesAmount, PaidAmount, PaymentType, ReturnPaymentType));
        Context.SetContext ('amount_description', PaymentType.Description);
        Context.SetContext ('paymenttypeno', PaymentType."No.");
        exit (true);
    end;

    local procedure SuggestAmount(SalesAmount: Decimal;PaidAmount: Decimal;PaymentType: Record "Payment Type POS";ReturnPaymentType: Record "Payment Type POS"): Decimal
    var
        POSPaymentLine: Codeunit "POS Payment Line";
    begin
        exit (CalculateRemainingPaymentSuggestion(SalesAmount, PaidAmount, PaymentType, ReturnPaymentType));
    end;

    procedure CalculateRemainingPaymentSuggestion(SalesAmount: Decimal;PaidAmount: Decimal;PaymentType: Record "Payment Type POS";ReturnPaymentType: Record "Payment Type POS"): Decimal
    var
        Balance: Decimal;
        ReturnRoundedBalance: Decimal;
        Result: Decimal;
    begin
        Balance := PaidAmount - SalesAmount;

        if (SalesAmount >= 0) and (Balance >= 0) then //Paid exact or more.
          exit(0);

        if (SalesAmount >= 0) and (Balance < 0) then //Not paid enough.
          exit(RoundAmount(PaymentType, CalculateForeignAmount(PaymentType, Balance)) * -1);

        if (SalesAmount < 0) and (Balance >= 0) then //Not returned enough.
          exit(RoundAmount(PaymentType, CalculateForeignAmount(PaymentType, Balance)) * -1);

        if (SalesAmount < 0) and (Balance < 0) then begin //Returned too much.
          if ReturnPaymentType."Rounding Precision" = 0 then
            Result := Balance
          else begin
            ReturnRoundedBalance := Round(Balance, ReturnPaymentType."Rounding Precision", '=');
            Result := ReturnRoundedBalance + Round(Balance - ReturnRoundedBalance, ReturnPaymentType."Rounding Precision", '=');
          end;
          exit(RoundAmount(ReturnPaymentType, CalculateForeignAmount(ReturnPaymentType, Result)) * -1);
        end;
    end;

    procedure CalculateForeignAmount(PaymentTypePOS: Record "Payment Type POS";AmountLCY: Decimal) Amount: Decimal
    begin
        if (PaymentTypePOS."Fixed Rate" <> 0) then
          Amount := AmountLCY / PaymentTypePOS."Fixed Rate" * 100
        else
          Amount := AmountLCY;
    end;

    procedure RoundAmount(PaymentTypePOS: Record "Payment Type POS";Amount: Decimal): Decimal
    begin
        if (PaymentTypePOS."Rounding Precision" = 0) then
          exit(Amount);

        if PaymentTypePOS."Processing Type" = PaymentTypePOS."Processing Type"::"Foreign Currency" then
          exit (Round(Amount, PaymentTypePOS."Rounding Precision", '>')); //Amount is not in LCY - Round up to avoid hitting a value causing LCY loss.

        exit (Round(Amount, PaymentTypePOS."Rounding Precision", '='));
    end;

    local procedure UpdatePaymentLine(CashKeeperTransaction: Record "CashKeeper Transaction";PaymentTypePOS: Record "Payment Type POS";Context: DotNet JObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management") Handled: Boolean
    var
        POSPaymentLine: Codeunit "POS Payment Line";
        AlternativTransactionRequest: Record "EFT Transaction Request";
        POSLine: Record "Sale Line POS";
        SalesAmount: Decimal;
        ReturnAmount: Decimal;
        PaidAmount: Decimal;
        SubTotal: Decimal;
        POSSaleLine: Codeunit "POS Sale Line";
        POSSale: Codeunit "POS Sale";
    begin
        POSSession.GetSale(POSSale);
        POSSession.GetPaymentLine (POSPaymentLine);
        POSPaymentLine.GetPaymentLine (POSLine);
        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(POSLine);

        POSLine."No." := PaymentTypePOS."No.";
        POSLine."Cash Terminal Approved" := (CashKeeperTransaction.Status = CashKeeperTransaction.Status::Ok);

        if (CashKeeperTransaction.Action = CashKeeperTransaction.Action::Capture) then
          POSLine."Amount Including VAT" := Abs(CashKeeperTransaction.Amount);

        if (CashKeeperTransaction.Action = CashKeeperTransaction.Action::Pay) then
          POSLine."Amount Including VAT" := Abs(CashKeeperTransaction.Amount) * -1;

        POSLine."No." := PaymentTypePOS."No.";
        POSLine."Currency Amount" := POSLine."Amount Including VAT";

        POSPaymentLine.InsertPaymentLine (POSLine, 0);
        POSPaymentLine.CalculateBalance (SalesAmount, PaidAmount, ReturnAmount, SubTotal);
        Commit;

        POSSale.TryEndSaleWithBalancing (POSSession, PaymentTypePOS, PaymentTypePOS);

        exit (true);
    end;

    local procedure SetTransactionRequest(POSSession: Codeunit "POS Session";CashKeeperTransaction: Record "CashKeeper Transaction")
    begin
        POSSession.BeginAction('TransactionRequest');
        POSSession.StoreActionState('TransactionRequest_EntryNo', CashKeeperTransaction."Transaction No.");
    end;

    local procedure GetTransactionRequest(POSSession: Codeunit "POS Session";var CashKeeperTransaction: Record "CashKeeper Transaction")
    var
        EntryNo: Integer;
        Token: Guid;
        TmpVariant: Variant;
        AlternativTransactionRequest: Record "EFT Transaction Request";
    begin
        POSSession.RetrieveActionState('TransactionRequest_EntryNo', TmpVariant);
        EntryNo := TmpVariant;

        if (not CashKeeperTransaction.Get(EntryNo)) then
          Error (RequestNotFound, ActionCode, TmpVariant, CashKeeperTransaction.TableCaption);
    end;

    local procedure "--Stargate"()
    begin
    end;

    procedure OnInvokeDevice(var CashKeeperTransaction: Record "CashKeeper Transaction")
    var
        CashKeeperRequest: DotNet npNetCashKeeperRequest0;
        State: DotNet npNetState4;
        StateEnum: DotNet npNetState_Action2;
        CashKeeperSetup: Record "CashKeeper Setup";
        FrontEnd: Codeunit "POS Front End Management";
        POSSession: Codeunit "POS Session";
        StepTxt: Text;
    begin
        //-NPR5.43 [316560]
        if CashKeeperTransaction.Amount = 0 then begin
          CashKeeperTransaction."Paid In Value" := 0;
          CashKeeperTransaction."Paid Out Value" := 0;
          CashKeeperTransaction.Status := CashKeeperTransaction.Status::Ok;
          CashKeeperTransaction.Modify(true);
          exit;
        end;
        //+NPR5.43 [316560]

        CashKeeperSetup.Get(CashKeeperTransaction."Register No.");

        State := State.State();
        case CashKeeperTransaction.Action of
          CashKeeperTransaction.Action::Capture : begin
                                           State.ActionType := StateEnum.Capture;
                                           StepTxt := 'Capture';
                                         end;
          CashKeeperTransaction.Action::Pay : begin
                                           State.ActionType := StateEnum.Pay;
                                           StepTxt := 'Pay';
                                         end;
          CashKeeperTransaction.Action::Setup : begin
                                           State.ActionType := StateEnum.Setup;
                                           StepTxt := 'Setup';
                                         end;
        end;

        State.Amount := CashKeeperTransaction.Amount;
        State.ValueInCents := CashKeeperTransaction."Value In Cents";
        State.PaidInValue := CashKeeperTransaction."Paid In Value";
        State.PaidOutValue := CashKeeperTransaction."Paid Out Value";
        State.ReceiptNo := Format(CashKeeperTransaction."Transaction No.");
        if not CashKeeperSetup."Debug Mode" then begin
          CashKeeperSetup.TestField("CashKeeper IP");
          State.IP := CashKeeperSetup."CashKeeper IP";
        end else
          State.IP := 'localhost';

        CashKeeperRequest := CashKeeperRequest.CashKeeperRequest();
        CashKeeperRequest.State := State;

        FrontEnd.InvokeDevice(CashKeeperRequest, 'CK_PAYMENT', StepTxt);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150716, 'OnDeviceResponse', '', true, true)]
    local procedure OnDeviceResponse(ActionName: Text;Step: Text;Envelope: DotNet npNetResponseEnvelope0;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management")
    begin
        if (ActionName <> 'CK_PAYMENT') then
          exit;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150716, 'OnAppGatewayProtocol', '', true, true)]
    local procedure OnDeviceEvent(ActionName: Text;EventName: Text;Data: Text;ResponseRequired: Boolean;var ReturnData: Text;var Handled: Boolean)
    var
        FrontEnd: Codeunit "POS Front End Management";
    begin
        if (ActionName <> 'CK_PAYMENT') then
          exit;

        Handled := true;
        case EventName of
          'CloseForm': CloseForm(Data);
        end;
    end;

    local procedure "--- Protocol Events"()
    begin
    end;

    local procedure CloseForm(Data: Text)
    var
        State: DotNet npNetState4;
        FrontEnd: Codeunit "POS Front End Management";
        CashKeeperTransaction: Record "CashKeeper Transaction";
        POSSession: Codeunit "POS Session";
        TransactionNo: Integer;
        PaymentTypeNo: Code[20];
        PaymentTypePOS: Record "Payment Type POS";
    begin
        State := State.Deserialize(Data);

        Evaluate(TransactionNo,State.ReceiptNo);

        CashKeeperTransaction.Get(TransactionNo);
        CashKeeperTransaction."Paid In Value" := State.PaidInValue;
        CashKeeperTransaction."Paid Out Value" := State.PaidOutValue;

        if State.RunWithSucces then
          CashKeeperTransaction.Status := CashKeeperTransaction.Status::Ok
        else if State.CancelledByUser then
          CashKeeperTransaction.Status := CashKeeperTransaction.Status::Cancelled
        else if not State.RunWithSucces and not State.CancelledByUser then
          CashKeeperTransaction.Status := CashKeeperTransaction.Status::Error;

        CashKeeperTransaction."CK Error Code" := State.ErrorCode;
        CashKeeperTransaction."CK Error Description" := State.ErrorText;

        CashKeeperTransaction.Modify(true);

        Commit;
    end;

    local procedure "---Subscriber"()
    begin
    end;

    [EventSubscriber(ObjectType::Table, 6059946, 'OnAfterModifyEvent', '', true, true)]
    local procedure OnCashKeeperTransModify(var Rec: Record "CashKeeper Transaction";var xRec: Record "CashKeeper Transaction";RunTrigger: Boolean)
    var
        FrontEnd: Codeunit "POS Front End Management";
        POSSession: Codeunit "POS Session";
    begin
        if not RunTrigger then
          exit;

        if POSSession.IsActiveSession(FrontEnd) then
          FrontEnd.ResumeWorkflow();
    end;
}

