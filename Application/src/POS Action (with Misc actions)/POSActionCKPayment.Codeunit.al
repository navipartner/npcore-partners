codeunit 6150850 "NPR POS Action: CK Payment"
{
    var
        ActionDescription: Label 'This is a built-in action for CashKeeper Payments';
        Setup: Codeunit "NPR POS Setup";
        TextAmountLabel: Label 'Enter Amount';
        PaymentTypeNotFound: Label '%1 %2 for POS unit was not found.';
        CashkeeperNotFound: Label 'CashKeeper Setup for POS unit %3 was not found.';
        NoCashBackErr: Label 'It is not allowed to enter an amount that is bigger than what is stated on the receipt for this payment type';
        RequestNotFound: Label 'Action Code %1 tried retrieving "TransactionRequest_EntryNo" from POS Session and got %2. There is however no record in %3 to match that entry number.';
        NoNegativeCashBackErr: Label 'It is not allowed to enter an amount that is different from what is stated on the receipt for this payment type';
        NegativeCashBackErr: Label 'It is not allowed to enter an negative amount';

    local procedure ActionCode(): Code[20]
    begin
        exit('CK_PAYMENT');
    end;

    local procedure ActionVersion(): Text[30]
    begin
        exit('1.40');
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
            Sender.RegisterWorkflowStep('CreateTransaction', 'respond();');
            Sender.RegisterWorkflowStep('InvokeDevice', 'respond();');
            Sender.RegisterWorkflowStep('CheckTransactionResult', 'respond();');

            Sender.RegisterWorkflow(true);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS UI Management", 'OnInitializeCaptions', '', true, true)]
    local procedure OnInitializeCaptions(Captions: Codeunit "NPR POS Caption Management")
    begin
        Captions.AddActionCaption(ActionCode(), 'Amount', TextAmountLabel);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS JavaScript Interface", 'OnBeforeWorkflow', '', true, true)]
    local procedure OnBeforeWorkflow("Action": Record "NPR POS Action"; Parameters: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        Context: Codeunit "NPR POS JSON Management";
        PaymentNo: Code[10];
        POSPaymentMethod: Record "NPR POS Payment Method";
        ReturnPOSPaymentMethod: Record "NPR POS Payment Method";
        POSUnit: Record "NPR POS Unit";
        POSPaymentLine: Codeunit "NPR POS Payment Line";
        SalesAmount: Decimal;
        ReturnAmount: Decimal;
        PaidAmount: Decimal;
        SubTotal: Decimal;
        CurrentView: Codeunit "NPR POS View";
        CashKeeperSetup: Record "NPR CashKeeper Setup";
    begin
        if not Action.IsThisAction(ActionCode()) then
            exit;

        POSSession.GetCurrentView(CurrentView);
        if (CurrentView.Type() = CurrentView.Type() ::Sale) then
            POSSession.ChangeViewPayment();

        POSSession.GetSetup(Setup);
        Setup.GetPOSUnit(POSUnit);

        if not CashKeeperSetup.Get(POSUnit."No.") then
            Error(CashkeeperNotFound, POSUnit."No.");
#pragma warning disable AA0139
        PaymentNo := CashKeeperSetup."Payment Type";
#pragma warning restore
        POSSession.GetPaymentLine(POSPaymentLine);
        POSPaymentLine.CalculateBalance(SalesAmount, PaidAmount, ReturnAmount, SubTotal);

        if (not POSPaymentLine.GetPOSPaymentMethod(POSPaymentMethod, PaymentNo)) then
            Error(PaymentTypeNotFound, POSPaymentMethod.TableCaption, PaymentNo);

        if (not POSPaymentLine.GetPOSPaymentMethod(ReturnPOSPaymentMethod, POSPaymentMethod."Return Payment Method Code")) then
            Error(PaymentTypeNotFound, POSPaymentMethod.TableCaption, POSPaymentMethod."Return Payment Method Code");

        Handled := ConfigureCashWorkflow(Context, POSPaymentMethod, ReturnPOSPaymentMethod, SalesAmount, PaidAmount);

        FrontEnd.SetActionContext(ActionCode(), Context);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS JavaScript Interface", 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        PaymentTypeNo: Code[10];
        JSON: Codeunit "NPR POS JSON Management";
        AmountToCapture: Decimal;
        NumpadAmount: Decimal;
        CashKeeperTransaction: Record "NPR CashKeeper Transaction";
        ReadingErr: Label 'reading in %1';
    begin
        if not Action.IsThisAction(ActionCode()) then
            exit;

        JSON.InitializeJObjectParser(Context, FrontEnd);

        Handled := true;

        case WorkflowStep of
            'Amount':
                begin
                    POSSession.ClearActionState();
                end;

            'CreateTransaction':
                begin
                    POSSession.ClearActionState();

                    PaymentTypeNo := CopyStr(JSON.GetStringOrFail('paymenttypeno', StrSubstNo(ReadingErr, ActionCode())), 1, MaxStrLen(PaymentTypeNo));
                    AmountToCapture := JSON.GetDecimalOrFail('amounttocapture', StrSubstNo(ReadingErr, ActionCode()));
                    NumpadAmount := AmountToCapture;

                    JSON.SetContext('TransactionRequest_EntryNo', '');
                    FrontEnd.SetActionContext(ActionCode(), JSON);

                    CreateTransaction(POSSession, AmountToCapture, PaymentTypeNo, NumpadAmount);
                end;

            'InvokeDevice':
                begin
                    GetTransactionRequest(POSSession, CashKeeperTransaction);
                    FrontEnd.PauseWorkflow();
                    OnInvokeDevice(CashKeeperTransaction);
                end;

            'CheckTransactionResult':
                begin
                    GetTransactionRequest(POSSession, CashKeeperTransaction);
                    CheckTransactionResult(POSSession, CashKeeperTransaction);
                end;

        end;
    end;

    local procedure CreateTransaction(POSSession: Codeunit "NPR POS Session"; AmountToCapture: Decimal; PaymentTypeNo: Code[10]; NumpadAmount: Decimal): Boolean
    var
        POSLine: Record "NPR POS Sale Line";
        POSPaymentLine: Codeunit "NPR POS Payment Line";
        Handled: Boolean;
        SalesAmount: Decimal;
        PaidAmount: Decimal;
        ReturnAmount: Decimal;
        SubTotal: Decimal;
        CashKeeperTransaction: Record "NPR CashKeeper Transaction";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        SaleLinePOS: Record "NPR POS Sale Line";
        OrderIdLbl: Label '%1-%2', Locked = true;
    begin
        POSSession.GetPaymentLine(POSPaymentLine);
        POSPaymentLine.GetCurrentPaymentLine(POSLine);
        POSPaymentLine.CalculateBalance(SalesAmount, PaidAmount, ReturnAmount, SubTotal);

        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        if (AmountToCapture >= 0) then begin

            if (NumpadAmount > Abs(SubTotal)) then
                Error(NoCashBackErr);

            if (NumpadAmount < 0) then
                Error(NegativeCashBackErr);

            CashKeeperTransaction.Init();
            CashKeeperTransaction."Register No." := SaleLinePOS."Register No.";
            CashKeeperTransaction."Sales Ticket No." := SaleLinePOS."Sales Ticket No.";
            CashKeeperTransaction.Amount := NumpadAmount;
            CashKeeperTransaction."Order ID" := StrSubstNo(OrderIdLbl, CashKeeperTransaction."Register No.",
                                                                     CashKeeperTransaction."Sales Ticket No.");
            CashKeeperTransaction."Value In Cents" := CashKeeperTransaction.Amount * 100;
            CashKeeperTransaction.Action := CashKeeperTransaction.Action::Capture;
            CashKeeperTransaction."Payment Type" := PaymentTypeNo;
            CashKeeperTransaction.Insert(true);

        end;

        if (AmountToCapture < 0) then begin

            if (NumpadAmount <> SubTotal) then
                Error(NoNegativeCashBackErr);

            CashKeeperTransaction.Init();
            CashKeeperTransaction."Register No." := SaleLinePOS."Register No.";
            CashKeeperTransaction."Sales Ticket No." := SaleLinePOS."Sales Ticket No.";
            CashKeeperTransaction.Amount := NumpadAmount * -1;
            CashKeeperTransaction."Order ID" := StrSubstNo(OrderIdLbl, CashKeeperTransaction."Register No.",
                                                                   CashKeeperTransaction."Sales Ticket No.");
            CashKeeperTransaction."Value In Cents" := CashKeeperTransaction.Amount * 100;
            CashKeeperTransaction.Action := CashKeeperTransaction.Action::Pay;
            CashKeeperTransaction."Payment Type" := PaymentTypeNo;
            CashKeeperTransaction.Insert();

        end;

        Handled := true;

        SetTransactionRequest(POSSession, CashKeeperTransaction);

        exit(Handled);
    end;

    local procedure CheckTransactionResult(POSSession: Codeunit "NPR POS Session"; var CashKeeperTransaction: Record "NPR CashKeeper Transaction"): Boolean
    var
        PaymentTypeNo: Code[10];
        POSPaymentMethod: Record "NPR POS Payment Method";
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
#pragma warning disable AA0139
        PaymentTypeNo := CashKeeperTransaction."Payment Type";
#pragma warning restore        
        POSPaymentMethod.Get(PaymentTypeNo);
        UpdatePaymentLine(CashKeeperTransaction, POSPaymentMethod, POSSession);
        POSSession.RequestRefreshData();
        POSSession.ClearActionState();
        exit(true);
    end;

    #region WorkflowHandlers
    local procedure ConfigureCashWorkflow(var Context: Codeunit "NPR POS JSON Management"; POSPaymentMethod: Record "NPR POS Payment Method"; ReturnPOSPaymentMethod: Record "NPR POS Payment Method"; SalesAmount: Decimal; PaidAmount: Decimal): Boolean
    begin
        Context.SetContext('capture_amount', true);
        Context.SetContext('amounttocapture', SuggestAmount(SalesAmount, PaidAmount, POSPaymentMethod, ReturnPOSPaymentMethod));
        Context.SetContext('amount_description', POSPaymentMethod.Description);
        Context.SetContext('paymenttypeno', POSPaymentMethod.Code);
        exit(true);
    end;

    local procedure SuggestAmount(SalesAmount: Decimal; PaidAmount: Decimal; POSPaymentMethod: Record "NPR POS Payment Method"; ReturnPOSPaymentMethod: Record "NPR POS Payment Method"): Decimal
    begin
        exit(CalculateRemainingPaymentSuggestion(SalesAmount, PaidAmount, POSPaymentMethod, ReturnPOSPaymentMethod));
    end;

    procedure CalculateRemainingPaymentSuggestion(SalesAmount: Decimal; PaidAmount: Decimal; POSPaymentMethod: Record "NPR POS Payment Method"; ReturnPOSPaymentMethod: Record "NPR POS Payment Method"): Decimal
    var
        Balance: Decimal;
        ReturnRoundedBalance: Decimal;
        Result: Decimal;
    begin
        Balance := PaidAmount - SalesAmount;

        if (SalesAmount >= 0) and (Balance >= 0) then //Paid exact or more.
            exit(0);

        if (SalesAmount >= 0) and (Balance < 0) then //Not paid enough.
            exit(RoundAmount(POSPaymentMethod, CalculateForeignAmount(POSPaymentMethod, Balance)) * -1);

        if (SalesAmount < 0) and (Balance >= 0) then //Not returned enough.
            exit(RoundAmount(POSPaymentMethod, CalculateForeignAmount(POSPaymentMethod, Balance)) * -1);

        if (SalesAmount < 0) and (Balance < 0) then begin //Returned too much.
            if ReturnPOSPaymentMethod."Rounding Precision" = 0 then
                Result := Balance
            else begin
                ReturnRoundedBalance := Round(Balance, ReturnPOSPaymentMethod."Rounding Precision", ReturnPOSPaymentMethod.GetRoundingType());
                Result := ReturnRoundedBalance + Round(Balance - ReturnRoundedBalance, ReturnPOSPaymentMethod."Rounding Precision", ReturnPOSPaymentMethod.GetRoundingType());
            end;
            exit(RoundAmount(ReturnPOSPaymentMethod, CalculateForeignAmount(ReturnPOSPaymentMethod, Result)) * -1);
        end;
    end;

    procedure CalculateForeignAmount(POSPaymentMethod: Record "NPR POS Payment Method"; AmountLCY: Decimal) Amount: Decimal
    begin
        if (POSPaymentMethod."Fixed Rate" <> 0) then
            Amount := AmountLCY / POSPaymentMethod."Fixed Rate" * 100
        else
            Amount := AmountLCY;
    end;

    procedure RoundAmount(POSPaymentMethod: Record "NPR POS Payment Method"; Amount: Decimal): Decimal
    begin
        if (POSPaymentMethod."Rounding Precision" = 0) then
            exit(Amount);

        if POSPaymentMethod."Currency Code" <> '' then
            exit(Round(Amount, POSPaymentMethod."Rounding Precision", '>')); //Amount is not in LCY - Round up to avoid hitting a value causing LCY loss.

        exit(Round(Amount, POSPaymentMethod."Rounding Precision", POSPaymentMethod.GetRoundingType()));
    end;

    local procedure UpdatePaymentLine(CashKeeperTransaction: Record "NPR CashKeeper Transaction"; POSPaymentMethod: Record "NPR POS Payment Method"; POSSession: Codeunit "NPR POS Session"): Boolean
    var
        POSPaymentLine: Codeunit "NPR POS Payment Line";
        POSLine: Record "NPR POS Sale Line";
        SalesAmount: Decimal;
        ReturnAmount: Decimal;
        PaidAmount: Decimal;
        SubTotal: Decimal;
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSSale: Codeunit "NPR POS Sale";
    begin
        POSSession.GetSale(POSSale);
        POSSession.GetPaymentLine(POSPaymentLine);
        POSPaymentLine.GetPaymentLine(POSLine);
        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(POSLine);

        POSLine."No." := POSPaymentMethod.Code;
        POSLine."EFT Approved" := (CashKeeperTransaction.Status = CashKeeperTransaction.Status::Ok);

        if (CashKeeperTransaction.Action = CashKeeperTransaction.Action::Capture) then
            POSLine."Amount Including VAT" := Abs(CashKeeperTransaction.Amount);

        if (CashKeeperTransaction.Action = CashKeeperTransaction.Action::Pay) then
            POSLine."Amount Including VAT" := Abs(CashKeeperTransaction.Amount) * -1;

        POSLine."No." := POSPaymentMethod.Code;
        POSLine."Currency Amount" := POSLine."Amount Including VAT";

        POSPaymentLine.InsertPaymentLine(POSLine, 0);
        POSPaymentLine.CalculateBalance(SalesAmount, PaidAmount, ReturnAmount, SubTotal);
        Commit();

        POSSale.TryEndDirectSaleWithBalancing(POSSession, POSPaymentMethod, POSPaymentMethod);

        exit(true);
    end;

    local procedure SetTransactionRequest(POSSession: Codeunit "NPR POS Session"; CashKeeperTransaction: Record "NPR CashKeeper Transaction")
    begin
        POSSession.BeginAction('TransactionRequest');
        POSSession.StoreActionState('TransactionRequest_EntryNo', CashKeeperTransaction."Transaction No.");
    end;

    local procedure GetTransactionRequest(POSSession: Codeunit "NPR POS Session"; var CashKeeperTransaction: Record "NPR CashKeeper Transaction")
    var
        EntryNo: Integer;
        TmpVariant: Variant;
    begin
        POSSession.RetrieveActionState('TransactionRequest_EntryNo', TmpVariant);
        EntryNo := TmpVariant;

        if (not CashKeeperTransaction.Get(EntryNo)) then
            Error(RequestNotFound, ActionCode(), TmpVariant, CashKeeperTransaction.TableCaption);
    end;
    #endregion

    #region Stargate

    procedure OnInvokeDevice(var CashKeeperTransaction: Record "NPR CashKeeper Transaction")
    var
        CashKeeperRequest: DotNet NPRNetCashKeeperRequest0;
        State: DotNet NPRNetState4;
        StateEnum: DotNet NPRNetState_Action2;
        CashKeeperSetup: Record "NPR CashKeeper Setup";
        FrontEnd: Codeunit "NPR POS Front End Management";
        StepTxt: Text;
    begin
        if CashKeeperTransaction.Amount = 0 then begin
            CashKeeperTransaction."Paid In Value" := 0;
            CashKeeperTransaction."Paid Out Value" := 0;
            CashKeeperTransaction.Status := CashKeeperTransaction.Status::Ok;
            CashKeeperTransaction.Modify(true);
            exit;
        end;

        CashKeeperSetup.Get(CashKeeperTransaction."Register No.");

        State := State.State();
        case CashKeeperTransaction.Action of
            CashKeeperTransaction.Action::Capture:
                begin
                    State.ActionType := StateEnum.Capture;
                    StepTxt := 'Capture';
                end;
            CashKeeperTransaction.Action::Pay:
                begin
                    State.ActionType := StateEnum.Pay;
                    StepTxt := 'Pay';
                end;
            CashKeeperTransaction.Action::Setup:
                begin
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

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Stargate Management", 'OnDeviceResponse', '', true, true)]
    local procedure OnDeviceResponse(ActionName: Text; Step: Text; Envelope: DotNet NPRNetResponseEnvelope0; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
    begin
        if (ActionName <> 'CK_PAYMENT') then
            exit;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Stargate Management", 'OnAppGatewayProtocol', '', true, true)]
    local procedure OnDeviceEvent(ActionName: Text; EventName: Text; Data: Text; ResponseRequired: Boolean; var ReturnData: Text; var Handled: Boolean)
    begin
        if (ActionName <> 'CK_PAYMENT') then
            exit;

        Handled := true;
        case EventName of
            'CloseForm':
                CloseForm(Data);
        end;
    end;
    #endregion

    #region Protocol Events

    local procedure CloseForm(Data: Text)
    var
        State: DotNet NPRNetState4;
        CashKeeperTransaction: Record "NPR CashKeeper Transaction";
        TransactionNo: Integer;
    begin
        State := State.Deserialize(Data);

        Evaluate(TransactionNo, State.ReceiptNo);

        CashKeeperTransaction.Get(TransactionNo);
        CashKeeperTransaction."Paid In Value" := State.PaidInValue;
        CashKeeperTransaction."Paid Out Value" := State.PaidOutValue;

        if State.RunWithSucces then
            CashKeeperTransaction.Status := CashKeeperTransaction.Status::Ok
        else
            if State.CancelledByUser then
                CashKeeperTransaction.Status := CashKeeperTransaction.Status::Cancelled
            else
                if not State.RunWithSucces and not State.CancelledByUser then
                    CashKeeperTransaction.Status := CashKeeperTransaction.Status::Error;

        CashKeeperTransaction."CK Error Code" := State.ErrorCode;
        CashKeeperTransaction."CK Error Description" := State.ErrorText;

        CashKeeperTransaction.Modify(true);

        Commit();
    end;
    #endregion

    #region Subscriber
    [EventSubscriber(ObjectType::Table, Database::"NPR CashKeeper Transaction", 'OnAfterModifyEvent', '', true, true)]
    local procedure OnCashKeeperTransModify(var Rec: Record "NPR CashKeeper Transaction"; var xRec: Record "NPR CashKeeper Transaction"; RunTrigger: Boolean)
    var
        FrontEnd: Codeunit "NPR POS Front End Management";
        POSSession: Codeunit "NPR POS Session";
    begin
        if not RunTrigger then
            exit;

        if POSSession.IsActiveSession(FrontEnd) then
            FrontEnd.ResumeWorkflow();
    end;
    #endregion
}
