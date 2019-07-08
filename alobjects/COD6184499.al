codeunit 6184499 "EFT Framework Mgt."
{
    // NPR5.36/TSA /20170927 CASE 282251 Changed the implementation for OnBeforeBalanceRegisterEvent
    // NPR5.46/MMV /20180831 CASE 290734 Refactored
    // NPR5.49/MMV /20190410 CASE 347476 Removed hardcoded .zip from download logs function


    trigger OnRun()
    begin
    end;

    var
        ERROR_SESSION: Label 'Critical Error: Session object could not be retrieved by EFT Framework';
        ERROR_AMOUNT: Label 'Invalid amount for %1 operation';
        ERROR_REQUEST_HANDLE: Label 'Integration type %1 does not handle %2 operations';
        ERROR_OUTSIDE_POS: Label 'Can only attempt transaction %1 from the POS';
        ERROR_SAME_POS: Label 'Can only attempt transaction %1 from the same register as the request originated';

    procedure CreateBeginWorkshiftRequest(var EFTTransactionRequest: Record "EFT Transaction Request";EFTSetup: Record "EFT Setup";POSUnitNo: Code[10];SalesReceiptNo: Code[20])
    var
        EFTInterface: Codeunit "EFT Interface";
        Handled: Boolean;
    begin
        InitGenericRequest(EFTTransactionRequest, EFTSetup, POSUnitNo, SalesReceiptNo);
        EFTTransactionRequest."Processing Type" := EFTTransactionRequest."Processing Type"::Open;
        EFTInterface.OnCreateBeginWorkshiftRequest(EFTTransactionRequest, Handled);
        CheckHandled(EFTSetup."EFT Integration Type", EFTTransactionRequest, Format(EFTTransactionRequest."Processing Type"::Open), Handled);
    end;

    procedure CreateEndWorkshiftRequest(var EFTTransactionRequest: Record "EFT Transaction Request";EFTSetup: Record "EFT Setup";POSUnitNo: Code[10];SalesReceiptNo: Code[20])
    var
        EFTInterface: Codeunit "EFT Interface";
        Handled: Boolean;
    begin
        InitGenericRequest(EFTTransactionRequest, EFTSetup, POSUnitNo, SalesReceiptNo);
        EFTTransactionRequest."Processing Type" := EFTTransactionRequest."Processing Type"::Close;
        EFTInterface.OnCreateEndWorkshiftRequest(EFTTransactionRequest, Handled);
        CheckHandled(EFTSetup."EFT Integration Type", EFTTransactionRequest, Format(EFTTransactionRequest."Processing Type"::Close), Handled);
    end;

    procedure CreatePaymentOfGoodsRequest(var EFTTransactionRequest: Record "EFT Transaction Request";EFTSetup: Record "EFT Setup";POSUnitNo: Code[10];SalesReceiptNo: Code[20];CurrencyCode: Code[10];AmountToCapture: Decimal)
    var
        GLSetup: Record "General Ledger Setup";
        EFTInterface: Codeunit "EFT Interface";
        Handled: Boolean;
    begin
        if AmountToCapture < 0 then
          Error(ERROR_AMOUNT, Format(EFTTransactionRequest."Processing Type"::Payment));

        InitGenericRequest(EFTTransactionRequest, EFTSetup, POSUnitNo, SalesReceiptNo);

        EFTTransactionRequest."Processing Type" := EFTTransactionRequest."Processing Type"::Payment;
        EFTTransactionRequest."Amount Input" := AmountToCapture;
        EFTTransactionRequest."Currency Code" := CurrencyCode;
        if EFTTransactionRequest."Currency Code" = '' then begin
          GLSetup.Get;
          EFTTransactionRequest."Currency Code" := GLSetup."LCY Code";
        end;
        EFTTransactionRequest."Cashback Amount" := CalculateCashback(EFTTransactionRequest);

        EFTInterface.OnCreatePaymentOfGoodsRequest(EFTTransactionRequest, Handled);
        CheckHandled(EFTSetup."EFT Integration Type", EFTTransactionRequest, Format(EFTTransactionRequest."Processing Type"::Payment), Handled);
    end;

    procedure CreateRefundRequest(var EFTTransactionRequest: Record "EFT Transaction Request";EFTSetup: Record "EFT Setup";POSUnitNo: Code[10];SalesReceiptNo: Code[20];CurrencyCode: Code[10];AmountToRefund: Decimal;OriginalRequestEntryNo: Integer)
    var
        GLSetup: Record "General Ledger Setup";
        EFTInterface: Codeunit "EFT Interface";
        Handled: Boolean;
        OriginalEftTransactionRequest: Record "EFT Transaction Request";
    begin
        if AmountToRefund < 0 then
          Error(ERROR_AMOUNT, Format(EFTTransactionRequest."Processing Type"::Refund));

        InitGenericRequest(EFTTransactionRequest, EFTSetup, POSUnitNo, SalesReceiptNo);

        if OriginalRequestEntryNo <> 0 then begin
          OriginalEftTransactionRequest.Get(OriginalRequestEntryNo);
          OriginalEftTransactionRequest.TestField("Integration Type", EFTTransactionRequest."Integration Type");
          OriginalEftTransactionRequest.TestField("Processing Type", OriginalEftTransactionRequest."Processing Type"::Payment);
          OriginalEftTransactionRequest.TestField(Reversed, false);
          if (not OriginalEftTransactionRequest.Successful) and (OriginalEftTransactionRequest.Recovered) then
            OriginalEftTransactionRequest.Get(OriginalEftTransactionRequest."Recovered by Entry No.");
          OriginalEftTransactionRequest.TestField(Successful, true);
          if (AmountToRefund = 0) then begin
            AmountToRefund := OriginalEftTransactionRequest."Result Amount";
            CurrencyCode := OriginalEftTransactionRequest."Currency Code";
          end;
        end;

        EFTTransactionRequest."Processing Type" := EFTTransactionRequest."Processing Type"::Refund;
        EFTTransactionRequest."Processed Entry No." := OriginalRequestEntryNo;
        EFTTransactionRequest."Amount Input" := AmountToRefund * -1;
        EFTTransactionRequest."Currency Code" := CurrencyCode;
        if EFTTransactionRequest."Currency Code" = '' then begin
          GLSetup.Get;
          EFTTransactionRequest."Currency Code" := GLSetup."LCY Code";
        end;

        EFTInterface.OnCreateRefundRequest(EFTTransactionRequest, Handled);
        CheckHandled(EFTSetup."EFT Integration Type", EFTTransactionRequest, Format(EFTTransactionRequest."Processing Type"::Refund), Handled);
    end;

    procedure CreateVoidRequest(var EFTTransactionRequest: Record "EFT Transaction Request";EFTSetup: Record "EFT Setup";POSUnitNo: Code[10];SalesReceiptNo: Code[20];RequestEntryNoToVoid: Integer;IsManualVoid: Boolean)
    var
        EFTInterface: Codeunit "EFT Interface";
        Handled: Boolean;
        OriginalTransactionRequest: Record "EFT Transaction Request";
    begin
        InitGenericRequest(EFTTransactionRequest, EFTSetup, POSUnitNo, SalesReceiptNo);

        OriginalTransactionRequest.Get(RequestEntryNoToVoid);
        OriginalTransactionRequest.TestField("Integration Type", EFTTransactionRequest."Integration Type");
        if IsManualVoid then
          OriginalTransactionRequest.TestField("Manual Voidable", true)
        else
          OriginalTransactionRequest.TestField("Auto Voidable", true);
        OriginalTransactionRequest.TestField(Reversed, false);
        if not (OriginalTransactionRequest."Processing Type" in [OriginalTransactionRequest."Processing Type"::Payment,
                                                                 OriginalTransactionRequest."Processing Type"::Refund]) then
          OriginalTransactionRequest.FieldError("Processing Type");

        EFTTransactionRequest."Currency Code" := OriginalTransactionRequest."Currency Code";
        EFTTransactionRequest."Amount Input" := OriginalTransactionRequest."Amount Input" * -1;
        EFTTransactionRequest."Processing Type" := EFTTransactionRequest."Processing Type"::Void;
        EFTTransactionRequest."Processed Entry No." := RequestEntryNoToVoid;
        EFTInterface.OnCreateVoidRequest(EFTTransactionRequest, Handled);
        CheckHandled(EFTSetup."EFT Integration Type", EFTTransactionRequest, Format(EFTTransactionRequest."Processing Type"::Void), Handled);
    end;

    procedure CreateVerifySetupRequest(var EFTTransactionRequest: Record "EFT Transaction Request";EFTSetup: Record "EFT Setup";POSUnitNo: Code[10];SalesReceiptNo: Code[20])
    var
        EFTInterface: Codeunit "EFT Interface";
        Handled: Boolean;
    begin
        InitGenericRequest(EFTTransactionRequest, EFTSetup, POSUnitNo, SalesReceiptNo);
        EFTTransactionRequest."Processing Type" := EFTTransactionRequest."Processing Type"::Setup;
        EFTInterface.OnCreateVerifySetupRequest(EFTTransactionRequest, Handled);
        CheckHandled(EFTSetup."EFT Integration Type", EFTTransactionRequest, Format(EFTTransactionRequest."Processing Type"::Setup), Handled);
    end;

    procedure CreateLookupTransactionRequest(var EFTTransactionRequest: Record "EFT Transaction Request";EFTSetup: Record "EFT Setup";POSUnitNo: Code[10];SalesReceiptNo: Code[20];RequestEntryNoToLookup: Integer)
    var
        EFTInterface: Codeunit "EFT Interface";
        Handled: Boolean;
        OriginalTransactionRequest: Record "EFT Transaction Request";
    begin
        InitGenericRequest(EFTTransactionRequest, EFTSetup, POSUnitNo, SalesReceiptNo);
        OriginalTransactionRequest.Get(RequestEntryNoToLookup);
        OriginalTransactionRequest.TestField("Integration Type", EFTTransactionRequest."Integration Type");
        OriginalTransactionRequest.TestField(Recoverable, true);
        OriginalTransactionRequest.TestField(Reversed, false);
        EFTTransactionRequest."Processed Entry No." := RequestEntryNoToLookup;
        EFTTransactionRequest."Processing Type" := EFTTransactionRequest."Processing Type"::Lookup;
        EFTInterface.OnCreateLookupTransactionRequest(EFTTransactionRequest, Handled);
        CheckHandled(EFTSetup."EFT Integration Type", EFTTransactionRequest, Format(EFTTransactionRequest."Processing Type"::Lookup), Handled);
    end;

    procedure CreateAuxRequest(var EFTTransactionRequest: Record "EFT Transaction Request";EFTSetup: Record "EFT Setup";AuxFunction: Integer;POSUnitNo: Code[10];SalesReceiptNo: Code[20])
    var
        EFTInterface: Codeunit "EFT Interface";
        Handled: Boolean;
        tmpEFTAuxOperation: Record "EFT Aux Operation" temporary;
    begin
        InitGenericRequest(EFTTransactionRequest, EFTSetup, POSUnitNo, SalesReceiptNo);

        EFTInterface.OnDiscoverAuxiliaryOperations(tmpEFTAuxOperation);
        tmpEFTAuxOperation.SetRange("Integration Type", EFTTransactionRequest."Integration Type");
        tmpEFTAuxOperation.SetRange("Auxiliary ID", AuxFunction);
        tmpEFTAuxOperation.FindFirst;

        EFTTransactionRequest."Processing Type" := EFTTransactionRequest."Processing Type"::Auxiliary;
        EFTTransactionRequest."Auxiliary Operation ID" := AuxFunction;
        EFTTransactionRequest."Auxiliary Operation Desc." := tmpEFTAuxOperation.Description;
        EFTInterface.OnCreateAuxRequest(EFTTransactionRequest, Handled);
        CheckHandled(EFTSetup."EFT Integration Type", EFTTransactionRequest, Format(EFTTransactionRequest."Processing Type"::Auxiliary), Handled);
    end;

    procedure SendRequest(var EFTTransactionRequest: Record "EFT Transaction Request")
    var
        EFTInterface: Codeunit "EFT Interface";
        Handled: Boolean;
    begin
        EFTInterface.OnSendEftDeviceRequest(EFTTransactionRequest, Handled);
        if not Handled then
          Error('EFT Integration %1 is not subscribing to SendRequest correctly.', EFTTransactionRequest."Integration Type");
    end;

    procedure ConfirmAfterPayment(var EFTTransactionRequest: Record "EFT Transaction Request";var Annul: Boolean)
    var
        EFTInterface: Codeunit "EFT Interface";
        Handled: Boolean;
    begin
        EFTInterface.OnAfterPaymentConfirm(EFTTransactionRequest, Annul);
    end;

    procedure EftIntegrationResponseReceived(var EftTransactionRequest: Record "EFT Transaction Request")
    begin
        EndGenericRequest(EftTransactionRequest);
        OnAfterEftIntegrationResponseReceived(EftTransactionRequest);
    end;

    procedure LookupTransaction(EFTTransactionRequest: Record "EFT Transaction Request")
    var
        POSAction: Record "POS Action";
        POSSession: Codeunit "POS Session";
        POSFrontEnd: Codeunit "POS Front End Management";
        POSSale: Codeunit "POS Sale";
        SalePOS: Record "Sale POS";
    begin
        if not POSSession.IsActiveSession(POSFrontEnd) then
          Error(ERROR_OUTSIDE_POS, Format(EFTTransactionRequest."Processing Type"::Lookup));
        POSFrontEnd.GetSession(POSSession);
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        if SalePOS."Register No." <> EFTTransactionRequest."Register No." then
          Error(ERROR_SAME_POS, Format(EFTTransactionRequest."Processing Type"::Lookup));

        if not POSSession.RetrieveSessionAction('EFT_OPERATION',POSAction) then
          POSAction.Get('EFT_OPERATION');

        POSAction.SetWorkflowInvocationParameter('EftType', EFTTransactionRequest."Integration Type", POSFrontEnd);
        POSAction.SetWorkflowInvocationParameter('OperationType', 8, POSFrontEnd);
        POSAction.SetWorkflowInvocationParameter('EntryNo', EFTTransactionRequest."Entry No.", POSFrontEnd);
        POSAction.SetWorkflowInvocationParameter('PaymentType', EFTTransactionRequest."Original POS Payment Type Code", POSFrontEnd);

        POSFrontEnd.InvokeWorkflow(POSAction);
    end;

    procedure VoidTransaction(EFTTransactionRequest: Record "EFT Transaction Request")
    var
        POSAction: Record "POS Action";
        POSSession: Codeunit "POS Session";
        POSFrontEnd: Codeunit "POS Front End Management";
        POSSale: Codeunit "POS Sale";
        SalePOS: Record "Sale POS";
    begin
        if not POSSession.IsActiveSession(POSFrontEnd) then
          Error(ERROR_OUTSIDE_POS, Format(EFTTransactionRequest."Processing Type"::Void));
        POSFrontEnd.GetSession(POSSession);
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        if SalePOS."Register No." <> EFTTransactionRequest."Register No." then
          Error(ERROR_SAME_POS, Format(EFTTransactionRequest."Processing Type"::Void));

        if not POSSession.RetrieveSessionAction('EFT_OPERATION',POSAction) then
          POSAction.Get('EFT_OPERATION');

        POSAction.SetWorkflowInvocationParameter('EftType', EFTTransactionRequest."Integration Type", POSFrontEnd);
        POSAction.SetWorkflowInvocationParameter('OperationType', 9, POSFrontEnd);
        POSAction.SetWorkflowInvocationParameter('EntryNo', EFTTransactionRequest."Entry No.", POSFrontEnd);
        POSAction.SetWorkflowInvocationParameter('PaymentType', EFTTransactionRequest."Original POS Payment Type Code", POSFrontEnd);

        POSFrontEnd.InvokeWorkflow(POSAction);
    end;

    procedure RefundTransaction(EFTTransactionRequest: Record "EFT Transaction Request")
    var
        POSAction: Record "POS Action";
        POSSession: Codeunit "POS Session";
        POSFrontEnd: Codeunit "POS Front End Management";
        POSSale: Codeunit "POS Sale";
        SalePOS: Record "Sale POS";
    begin
        if not POSSession.IsActiveSession(POSFrontEnd) then
          Error(ERROR_OUTSIDE_POS, Format(EFTTransactionRequest."Processing Type"::Refund));
        POSFrontEnd.GetSession(POSSession);
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        if SalePOS."Register No." <> EFTTransactionRequest."Register No." then
          Error(ERROR_SAME_POS, Format(EFTTransactionRequest."Processing Type"::Refund));

        if not POSSession.RetrieveSessionAction('EFT_OPERATION',POSAction) then
          POSAction.Get('EFT_OPERATION');

        POSAction.SetWorkflowInvocationParameter('EftType', EFTTransactionRequest."Integration Type", POSFrontEnd);
        POSAction.SetWorkflowInvocationParameter('OperationType', 10, POSFrontEnd);
        POSAction.SetWorkflowInvocationParameter('EntryNo', EFTTransactionRequest."Entry No.", POSFrontEnd);
        POSAction.SetWorkflowInvocationParameter('PaymentType', EFTTransactionRequest."Original POS Payment Type Code", POSFrontEnd);

        POSFrontEnd.InvokeWorkflow(POSAction);
    end;

    procedure DownloadTransactionLogs(EFTTransactionRequest: Record "EFT Transaction Request")
    var
        InStream: InStream;
        FileName: Text;
    begin
        if not EFTTransactionRequest.Logs.HasValue then
          exit;
        EFTTransactionRequest.CalcFields(Logs);
        EFTTransactionRequest.Logs.CreateInStream(InStream);
        FileName := StrSubstNo('EFT_Log_%1_%2', EFTTransactionRequest."Integration Type", EFTTransactionRequest."Entry No.");
        //-NPR5.49 [347476]
        //DOWNLOADFROMSTREAM(InStream, 'Log Download', '', 'ZIP File (*.zip)|*.zip', FileName);
        DownloadFromStream(InStream, 'Log Download', '', 'All Files (*.*)|*.*', FileName);
        //+NPR5.49 [347476]
    end;

    procedure DisplayReceipt(EFTTransactionRequest: Record "EFT Transaction Request";ReceiptNo: Integer)
    var
        EFTInterface: Codeunit "EFT Interface";
        Handled: Boolean;
        StreamIn: InStream;
        TextLine: Text[1024];
        TextWhole: Text;
    begin
        EFTInterface.OnDisplayReceipt(EFTTransactionRequest, ReceiptNo, Handled);
        if Handled then
          exit;

        case ReceiptNo of
        1 :
          begin
            EFTTransactionRequest.CalcFields("Receipt 1");
            if not EFTTransactionRequest."Receipt 1".HasValue then
                exit;
            EFTTransactionRequest."Receipt 1".CreateInStream(StreamIn);
          end;
        2:
          begin
            EFTTransactionRequest.CalcFields("Receipt 2");
            if not EFTTransactionRequest."Receipt 2".HasValue then
                exit;
            EFTTransactionRequest."Receipt 2".CreateInStream(StreamIn);
          end;
        end;

        while (not StreamIn.EOS) do begin
          StreamIn.Read(TextLine);
          if TextWhole = '' then
            TextWhole := TextLine
          else
            TextWhole += Format('\') + TextLine
        end;

        Message(TextWhole);
    end;

    local procedure "// Aux"()
    begin
    end;

    local procedure InitGenericRequest(var EFTTransactionRequest: Record "EFT Transaction Request";EFTSetup: Record "EFT Setup";POSUnitNo: Code[10];SalesReceiptNo: Code[10])
    begin
        EFTSetup.TestField("EFT Integration Type");
        EFTSetup.TestField("Payment Type POS");

        EFTTransactionRequest."Integration Type" := EFTSetup."EFT Integration Type";
        EFTTransactionRequest."POS Payment Type Code" := EFTSetup."Payment Type POS"; //This one might be switched later depending on transaction context, ie. card type.
        EFTTransactionRequest."Original POS Payment Type Code" := EFTSetup."Payment Type POS"; //This one will keep pointing to EFTSetup value.
        EFTTransactionRequest."Register No." := POSUnitNo;
        EFTTransactionRequest."Sales Ticket No." := SalesReceiptNo;
        EFTTransactionRequest."User ID" := UserId;
        EFTTransactionRequest.Started := CurrentDateTime;
        EFTTransactionRequest.Token := CreateGuid();
    end;

    local procedure EndGenericRequest(var EFTTransactionRequest: Record "EFT Transaction Request")
    begin
        EFTTransactionRequest.Finished := CurrentDateTime;
        EFTTransactionRequest.Modify;
    end;

    local procedure CheckHandled(IntegrationType: Text;EFTTransactionRequest: Record "EFT Transaction Request";OperationType: Text;Handled: Boolean)
    begin
        if Handled then
          if EFTTransactionRequest.Find then
            exit;

        Error(ERROR_REQUEST_HANDLE, IntegrationType, OperationType);
    end;

    local procedure CalculateCashback(EFTTransactionRequest: Record "EFT Transaction Request"): Decimal
    var
        POSSession: Codeunit "POS Session";
        POSFrontEnd: Codeunit "POS Front End Management";
        POSPaymentLine: Codeunit "POS Payment Line";
        POSSetup: Codeunit "POS Setup";
        Register: Record Register;
        SaleAmount: Decimal;
        PaidAmount: Decimal;
        ReturnAmount: Decimal;
        SubTotal: Decimal;
        RoundedBalance: Decimal;
        ReturnPaymentTypePOS: Record "Payment Type POS";
    begin
        if not POSSession.IsActiveSession(POSFrontEnd) then
          Error(ERROR_SESSION);
        POSFrontEnd.GetSession(POSSession);
        POSSession.GetSetup(POSSetup);
        POSSetup.GetRegisterRecord(Register);
        POSSession.GetPaymentLine(POSPaymentLine);

        POSPaymentLine.CalculateBalance(SaleAmount, PaidAmount, ReturnAmount, SubTotal);
        PaidAmount += EFTTransactionRequest."Amount Input";

        if SaleAmount > PaidAmount then
          exit(0);

        POSPaymentLine.GetPaymentType(ReturnPaymentTypePOS, Register."Return Payment Type", Register."Register No.");
        RoundedBalance := POSPaymentLine.RoundAmount(ReturnPaymentTypePOS, PaidAmount - SaleAmount);
        exit(RoundedBalance + POSPaymentLine.RoundAmount(ReturnPaymentTypePOS, PaidAmount - SaleAmount - RoundedBalance));
    end;

    local procedure "// Event Publishers"()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterEftIntegrationResponseReceived(EftTransactionRequest: Record "EFT Transaction Request")
    begin
    end;
}

