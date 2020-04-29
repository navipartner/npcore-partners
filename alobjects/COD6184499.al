codeunit 6184499 "EFT Framework Mgt."
{
    // Internal for EFT framework, use "EFT Transaction Mgt." or "EFT Hardware Mgt." instead from outside the module
    // 
    // NPR5.36/TSA /20170927 CASE 282251 Changed the implementation for OnBeforeBalanceRegisterEvent
    // NPR5.46/MMV /20180831 CASE 290734 Refactored
    // NPR5.49/MMV /20190410 CASE 347476 Removed hardcoded .zip from download logs function
    // NPR5.51/MMV /20190603 CASE 355433 Moved implicit behaviour from events to function invocations
    // NPR5.51/MMV /20190626 CASE 359385 Added support for gift cards
    // NPR5.51/MMV /20190716 CASE 355433 Limit cashback amount logged to 100% of trx amount.
    // NPR5.53/MMV /20191216 CASE 377533 Added IsFromMostRecentSaleOnPOSUnit()
    // NPR5.54/MMV /20200226 CASE 364340 Added "Result Processed" field.
    //                                   Unified lookup mgt. between giftcard load & payment/refund.
    //                                   Added pause/resume methods for code reuse.


    trigger OnRun()
    begin
    end;

    var
        ERROR_SESSION: Label 'Critical Error: Session object could not be retrieved by EFT Framework';
        ERROR_AMOUNT: Label 'Invalid amount for %1 operation';
        ERROR_REQUEST_HANDLE: Label 'Integration type %1 does not handle %2 operations';
        ERROR_OUTSIDE_POS: Label 'Can only attempt transaction %1 from the POS';
        ERROR_SAME_POS: Label 'Can only attempt transaction %1 from the same register as the request originated';
        CAPTION_OUTPUT: Label 'Electronic Funds Transfer Receipt';

    procedure CreateBeginWorkshiftRequest(var EFTTransactionRequest: Record "EFT Transaction Request";EFTSetup: Record "EFT Setup";POSUnitNo: Code[10];SalesReceiptNo: Code[20])
    var
        EFTInterface: Codeunit "EFT Interface";
        Handled: Boolean;
    begin
        InitGenericRequest(EFTTransactionRequest, EFTSetup, POSUnitNo, SalesReceiptNo);
        EFTTransactionRequest."Processing Type" := EFTTransactionRequest."Processing Type"::OPEN;
        EFTInterface.OnCreateBeginWorkshiftRequest(EFTTransactionRequest, Handled);
        CheckHandled(EFTSetup."EFT Integration Type", EFTTransactionRequest, Format(EFTTransactionRequest."Processing Type"::OPEN), Handled);
    end;

    procedure CreateEndWorkshiftRequest(var EFTTransactionRequest: Record "EFT Transaction Request";EFTSetup: Record "EFT Setup";POSUnitNo: Code[10];SalesReceiptNo: Code[20])
    var
        EFTInterface: Codeunit "EFT Interface";
        Handled: Boolean;
    begin
        InitGenericRequest(EFTTransactionRequest, EFTSetup, POSUnitNo, SalesReceiptNo);
        EFTTransactionRequest."Processing Type" := EFTTransactionRequest."Processing Type"::CLOSE;
        EFTInterface.OnCreateEndWorkshiftRequest(EFTTransactionRequest, Handled);
        CheckHandled(EFTSetup."EFT Integration Type", EFTTransactionRequest, Format(EFTTransactionRequest."Processing Type"::CLOSE), Handled);
    end;

    procedure CreatePaymentOfGoodsRequest(var EFTTransactionRequest: Record "EFT Transaction Request";EFTSetup: Record "EFT Setup";POSUnitNo: Code[10];SalesReceiptNo: Code[20];CurrencyCode: Code[10];AmountToCapture: Decimal)
    var
        GLSetup: Record "General Ledger Setup";
        EFTInterface: Codeunit "EFT Interface";
        Handled: Boolean;
    begin
        if AmountToCapture < 0 then
          Error(ERROR_AMOUNT, Format(EFTTransactionRequest."Processing Type"::PAYMENT));

        InitGenericRequest(EFTTransactionRequest, EFTSetup, POSUnitNo, SalesReceiptNo);

        EFTTransactionRequest."Processing Type" := EFTTransactionRequest."Processing Type"::PAYMENT;
        EFTTransactionRequest."Amount Input" := AmountToCapture;
        EFTTransactionRequest."Currency Code" := CurrencyCode;
        if EFTTransactionRequest."Currency Code" = '' then begin
          GLSetup.Get;
          EFTTransactionRequest."Currency Code" := GLSetup."LCY Code";
        end;
        EFTTransactionRequest."Cashback Amount" := CalculateCashback(EFTTransactionRequest);

        EFTInterface.OnCreatePaymentOfGoodsRequest(EFTTransactionRequest, Handled);
        CheckHandled(EFTSetup."EFT Integration Type", EFTTransactionRequest, Format(EFTTransactionRequest."Processing Type"::PAYMENT), Handled);
    end;

    procedure CreateRefundRequest(var EFTTransactionRequest: Record "EFT Transaction Request";EFTSetup: Record "EFT Setup";POSUnitNo: Code[10];SalesReceiptNo: Code[20];CurrencyCode: Code[10];AmountToRefund: Decimal;OriginalRequestEntryNo: Integer)
    var
        GLSetup: Record "General Ledger Setup";
        EFTInterface: Codeunit "EFT Interface";
        Handled: Boolean;
        OriginalEftTransactionRequest: Record "EFT Transaction Request";
    begin
        if AmountToRefund < 0 then
          Error(ERROR_AMOUNT, Format(EFTTransactionRequest."Processing Type"::REFUND));

        InitGenericRequest(EFTTransactionRequest, EFTSetup, POSUnitNo, SalesReceiptNo);

        if OriginalRequestEntryNo <> 0 then begin
          OriginalEftTransactionRequest.Get(OriginalRequestEntryNo);
          //-NPR5.54 [364340]
          if OriginalEftTransactionRequest."Processing Type" = OriginalEftTransactionRequest."Processing Type"::LOOK_UP then begin
            OriginalEftTransactionRequest.Get(OriginalEftTransactionRequest."Processed Entry No.");
            OriginalRequestEntryNo := OriginalEftTransactionRequest."Entry No.";
          end;
          //+NPR5.54 [364340]
          OriginalEftTransactionRequest.TestField("Integration Type", EFTTransactionRequest."Integration Type");
          OriginalEftTransactionRequest.TestField("Processing Type", OriginalEftTransactionRequest."Processing Type"::PAYMENT);
          OriginalEftTransactionRequest.TestField(Reversed, false);
          if (not OriginalEftTransactionRequest.Successful) and (OriginalEftTransactionRequest.Recovered) then
            OriginalEftTransactionRequest.Get(OriginalEftTransactionRequest."Recovered by Entry No.");
          OriginalEftTransactionRequest.TestField(Successful, true);
        //-NPR5.54 [364340]
          OriginalEftTransactionRequest.TestField(Finished);
          OriginalEftTransactionRequest.TestField("External Result Known", true);
        //+NPR5.54 [364340]
          if (AmountToRefund = 0) then begin
            AmountToRefund := OriginalEftTransactionRequest."Result Amount";
            CurrencyCode := OriginalEftTransactionRequest."Currency Code";
          end;
        end;

        EFTTransactionRequest."Processing Type" := EFTTransactionRequest."Processing Type"::REFUND;
        //-NPR5.54 [364340]
        EFTTransactionRequest."Processed Entry No." := OriginalRequestEntryNo;
        //+NPR5.54 [364340]
        EFTTransactionRequest."Amount Input" := AmountToRefund * -1;
        EFTTransactionRequest."Currency Code" := CurrencyCode;
        if EFTTransactionRequest."Currency Code" = '' then begin
          GLSetup.Get;
          EFTTransactionRequest."Currency Code" := GLSetup."LCY Code";
        end;

        EFTInterface.OnCreateRefundRequest(EFTTransactionRequest, Handled);
        CheckHandled(EFTSetup."EFT Integration Type", EFTTransactionRequest, Format(EFTTransactionRequest."Processing Type"::REFUND), Handled);
    end;

    procedure CreateVoidRequest(var EFTTransactionRequest: Record "EFT Transaction Request";EFTSetup: Record "EFT Setup";POSUnitNo: Code[10];SalesReceiptNo: Code[20];RequestEntryNoToVoid: Integer;IsManualVoid: Boolean)
    var
        EFTInterface: Codeunit "EFT Interface";
        Handled: Boolean;
        OriginalTransactionRequest: Record "EFT Transaction Request";
    begin
        InitGenericRequest(EFTTransactionRequest, EFTSetup, POSUnitNo, SalesReceiptNo);

        OriginalTransactionRequest.Get(RequestEntryNoToVoid);
        //-NPR5.54 [364340]
        if OriginalTransactionRequest."Processing Type" = OriginalTransactionRequest."Processing Type"::LOOK_UP then begin
          OriginalTransactionRequest.Get(OriginalTransactionRequest."Processed Entry No.");
          RequestEntryNoToVoid := OriginalTransactionRequest."Entry No.";
        end;
        //+NPR5.54 [364340]
        OriginalTransactionRequest.TestField("Integration Type", EFTTransactionRequest."Integration Type");
        if IsManualVoid then
          OriginalTransactionRequest.TestField("Manual Voidable", true)
        else
          OriginalTransactionRequest.TestField("Auto Voidable", true);
        OriginalTransactionRequest.TestField(Reversed, false);

        if not (OriginalTransactionRequest."Processing Type" in [OriginalTransactionRequest."Processing Type"::PAYMENT,
                                                                 OriginalTransactionRequest."Processing Type"::REFUND,
                                                                 OriginalTransactionRequest."Processing Type"::GIFTCARD_LOAD]) then
          OriginalTransactionRequest.FieldError("Processing Type");

        //-NPR5.54 [364340]
        if (not OriginalTransactionRequest.Successful) and (OriginalTransactionRequest.Recovered) then begin
          OriginalTransactionRequest.Get(OriginalTransactionRequest."Recovered by Entry No.");
        end;
        OriginalTransactionRequest.TestField(Successful, true);
        OriginalTransactionRequest.TestField(Finished);
        OriginalTransactionRequest.TestField("External Result Known", true);
        //+NPR5.54 [364340]

        EFTTransactionRequest."Currency Code" := OriginalTransactionRequest."Currency Code";
        //-NPR5.54 [364340]
        //EFTTransactionRequest."Amount Input" := OriginalTransactionRequest."Amount Input" * -1;
        EFTTransactionRequest."Amount Input" := OriginalTransactionRequest."Result Amount" * -1;
        //+NPR5.54 [364340]
        EFTTransactionRequest."Processing Type" := EFTTransactionRequest."Processing Type"::VOID;
        //-NPR5.54 [364340]
        EFTTransactionRequest."Processed Entry No." := RequestEntryNoToVoid;
        //+NPR5.54 [364340]
        EFTInterface.OnCreateVoidRequest(EFTTransactionRequest, Handled);
        CheckHandled(EFTSetup."EFT Integration Type", EFTTransactionRequest, Format(EFTTransactionRequest."Processing Type"::VOID), Handled);
    end;

    procedure CreateVerifySetupRequest(var EFTTransactionRequest: Record "EFT Transaction Request";EFTSetup: Record "EFT Setup";POSUnitNo: Code[10];SalesReceiptNo: Code[20])
    var
        EFTInterface: Codeunit "EFT Interface";
        Handled: Boolean;
    begin
        InitGenericRequest(EFTTransactionRequest, EFTSetup, POSUnitNo, SalesReceiptNo);
        EFTTransactionRequest."Processing Type" := EFTTransactionRequest."Processing Type"::SETUP;
        EFTInterface.OnCreateVerifySetupRequest(EFTTransactionRequest, Handled);
        CheckHandled(EFTSetup."EFT Integration Type", EFTTransactionRequest, Format(EFTTransactionRequest."Processing Type"::SETUP), Handled);
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
        //-NPR5.54 [364340]
        OriginalTransactionRequest.TestField(Recovered, false);
        if OriginalTransactionRequest."Processing Type" = OriginalTransactionRequest."Processing Type"::LOOK_UP then
          OriginalTransactionRequest.FieldError("Processing Type");
        //+NPR5.54 [364340]
        EFTTransactionRequest."Processed Entry No." := RequestEntryNoToLookup;
        EFTTransactionRequest."Processing Type" := EFTTransactionRequest."Processing Type"::LOOK_UP;
        EFTInterface.OnCreateLookupTransactionRequest(EFTTransactionRequest, Handled);
        CheckHandled(EFTSetup."EFT Integration Type", EFTTransactionRequest, Format(EFTTransactionRequest."Processing Type"::LOOK_UP), Handled);
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

        EFTTransactionRequest."Processing Type" := EFTTransactionRequest."Processing Type"::AUXILIARY;
        EFTTransactionRequest."Auxiliary Operation ID" := AuxFunction;
        EFTTransactionRequest."Auxiliary Operation Desc." := tmpEFTAuxOperation.Description;
        EFTInterface.OnCreateAuxRequest(EFTTransactionRequest, Handled);
        CheckHandled(EFTSetup."EFT Integration Type", EFTTransactionRequest, Format(EFTTransactionRequest."Processing Type"::AUXILIARY), Handled);
    end;

    procedure CreateGiftcardLoadRequest(var EFTTransactionRequest: Record "EFT Transaction Request";EFTSetup: Record "EFT Setup";POSUnitNo: Code[10];SalesReceiptNo: Code[20];CurrencyCode: Code[10];AmountToLoad: Decimal)
    var
        GLSetup: Record "General Ledger Setup";
        EFTInterface: Codeunit "EFT Interface";
        Handled: Boolean;
    begin
        //-NPR5.51 [359385]
        if AmountToLoad < 0 then
          Error(ERROR_AMOUNT, Format(EFTTransactionRequest."Processing Type"::GIFTCARD_LOAD));

        InitGenericRequest(EFTTransactionRequest, EFTSetup, POSUnitNo, SalesReceiptNo);

        EFTTransactionRequest."Processing Type" := EFTTransactionRequest."Processing Type"::GIFTCARD_LOAD;
        EFTTransactionRequest."Amount Input" := AmountToLoad * -1;
        EFTTransactionRequest."Currency Code" := CurrencyCode;
        if EFTTransactionRequest."Currency Code" = '' then begin
          GLSetup.Get;
          EFTTransactionRequest."Currency Code" := GLSetup."LCY Code";
        end;

        EFTInterface.OnCreateGiftCardLoadRequest(EFTTransactionRequest, Handled);
        CheckHandled(EFTSetup."EFT Integration Type", EFTTransactionRequest, Format(EFTTransactionRequest."Processing Type"::GIFTCARD_LOAD), Handled);
        //+NPR5.51 [359385]
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
    var
        EFTPaymentMgt: Codeunit "EFT Transaction Mgt.";
        OriginalEFTTransactionRequest: Record "EFT Transaction Request";
        ProcessingType: Integer;
    begin
        EndGenericRequest(EftTransactionRequest);

        //-NPR5.51 [355433]
        with EftTransactionRequest do begin
          if ("Processing Type" in ["Processing Type"::VOID, "Processing Type"::LOOK_UP]) then begin
            OriginalEFTTransactionRequest.Get("Processed Entry No.");
            if (OriginalEFTTransactionRequest."Processing Type" = "Processing Type"::VOID) then
              OriginalEFTTransactionRequest.Get(OriginalEFTTransactionRequest."Processed Entry No.");
            ProcessingType := OriginalEFTTransactionRequest."Processing Type";
          end else begin
            ProcessingType := EftTransactionRequest."Processing Type";
          end;

          case ProcessingType of
        //-NPR5.54 [364340]
            "Processing Type"::GIFTCARD_LOAD,
        //+NPR5.54 [364340]
            "Processing Type"::PAYMENT,
            "Processing Type"::REFUND :
              EFTPaymentMgt.HandleIntegrationResponse(EftTransactionRequest);

        //-NPR5.54 [364340]
        //    "Processing Type"::GIFTCARD_LOAD :
        //      EFTGiftCardMgt.HandleIntegrationResponse(EftTransactionRequest);
        //+NPR5.54 [364340]

            else
              HandleOtherIntegrationResponse(EftTransactionRequest);
          end;
        end;
        //+NPR5.51 [355433]

        OnAfterEftIntegrationResponseReceived(EftTransactionRequest);
    end;

    local procedure HandleOtherIntegrationResponse(EftTransactionRequest: Record "EFT Transaction Request")
    var
        POSFrontEnd: Codeunit "POS Front End Management";
        POSSession: Codeunit "POS Session";
        EFTInterface: Codeunit "EFT Interface";
        Skip: Boolean;
    begin
        //-NPR5.51 [355433]
        with EftTransactionRequest do begin
          if not ("Processing Type" in ["Processing Type"::AUXILIARY, "Processing Type"::OPEN, "Processing Type"::CLOSE, "Processing Type"::OTHER, "Processing Type"::SETUP]) then
            FieldError("Processing Type");
        end;

        POSSession.GetSession(POSSession, true);
        POSSession.GetFrontEnd(POSFrontEnd, true);
        POSSession.RequestRefreshData();

        //-NPR5.54 [364340]
        ResumeFrontEndAfterEFTRequest(EftTransactionRequest, POSFrontEnd);
        //+NPR5.54 [364340]
        //+NPR5.51 [355433]
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
          Error(ERROR_OUTSIDE_POS, Format(EFTTransactionRequest."Processing Type"::LOOK_UP));
        POSFrontEnd.GetSession(POSSession);
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        if SalePOS."Register No." <> EFTTransactionRequest."Register No." then
          Error(ERROR_SAME_POS, Format(EFTTransactionRequest."Processing Type"::LOOK_UP));

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
          Error(ERROR_OUTSIDE_POS, Format(EFTTransactionRequest."Processing Type"::VOID));
        POSFrontEnd.GetSession(POSSession);
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        if SalePOS."Register No." <> EFTTransactionRequest."Register No." then
          Error(ERROR_SAME_POS, Format(EFTTransactionRequest."Processing Type"::VOID));

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
          Error(ERROR_OUTSIDE_POS, Format(EFTTransactionRequest."Processing Type"::REFUND));
        POSFrontEnd.GetSession(POSSession);
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        if SalePOS."Register No." <> EFTTransactionRequest."Register No." then
          Error(ERROR_SAME_POS, Format(EFTTransactionRequest."Processing Type"::REFUND));

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
        DownloadFromStream(InStream, 'Log Download', '', 'All Files (*.*)|*.*', FileName);
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

    local procedure InitGenericRequest(var EFTTransactionRequest: Record "EFT Transaction Request";EFTSetup: Record "EFT Setup";POSUnitNo: Text;SalesReceiptNo: Text)
    var
        SalePOS: Record "Sale POS";
    begin
        EFTSetup.TestField("EFT Integration Type");
        EFTSetup.TestField("Payment Type POS");
        //-NPR5.54 [364340]
        SalePOS.Get(POSUnitNo, SalesReceiptNo);
        //+NPR5.54 [364340]

        EFTTransactionRequest."Integration Type" := EFTSetup."EFT Integration Type";
        EFTTransactionRequest."POS Payment Type Code" := EFTSetup."Payment Type POS"; //This one might be switched later depending on transaction context, ie. card type.
        EFTTransactionRequest."Original POS Payment Type Code" := EFTSetup."Payment Type POS"; //This one will keep pointing to EFTSetup value.
        EFTTransactionRequest."Register No." := POSUnitNo;
        EFTTransactionRequest."Sales Ticket No." := SalesReceiptNo;
        EFTTransactionRequest."User ID" := UserId;
        EFTTransactionRequest.Started := CurrentDateTime;
        EFTTransactionRequest.Token := CreateGuid();
        //-NPR5.54 [364340]
        EFTTransactionRequest."Sales ID" := SalePOS."Retail ID";
        //+NPR5.54 [364340]
    end;

    local procedure EndGenericRequest(var EFTTransactionRequest: Record "EFT Transaction Request")
    begin
        EFTTransactionRequest.Finished := CurrentDateTime;
        //-NPR5.54 [364340]
        EFTTransactionRequest."Result Processed" := true; //If this value is false later, we never acted on the result in the POS.
        //+NPR5.54 [364340]
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
        Cashback: Decimal;
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
        //-NPR5.51 [355433]
        Cashback := RoundedBalance + POSPaymentLine.RoundAmount(ReturnPaymentTypePOS, PaidAmount - SaleAmount - RoundedBalance);
        if Cashback > EFTTransactionRequest."Amount Input" then
          Cashback := EFTTransactionRequest."Amount Input";
        exit(Cashback);
        //+NPR5.51 [355433]
    end;

    procedure IsFromMostRecentSaleOnPOSUnit(EFTTransactionRequest: Record "EFT Transaction Request"): Boolean
    var
        POSEntry: Record "POS Entry";
        SalePOS: Record "Sale POS";
    begin
        //-NPR5.53 [377533]
        with EFTTransactionRequest do begin
          if "Sales Ticket No." = '' then
            exit(false);
          if "Register No." = '' then
            exit(false);

          SalePOS.SetRange("Register No.", "Register No.");
          SalePOS.SetRange(Date, DT2Date(Started));
          SalePOS.SetFilter("Start Time", '>%1', DT2Time(Started));
          if not SalePOS.IsEmpty then
            exit(false);

          POSEntry.SetRange("POS Unit No.", "Register No.");
          POSEntry.SetFilter("Entry Type", '%1|%2', POSEntry."Entry Type"::"Direct Sale", POSEntry."Entry Type"::"Credit Sale");
          if not POSEntry.FindLast then
            exit(true);

          if POSEntry."Document Date" > DT2Date(Started) then
            exit(false);
          if (POSEntry."Document Date" = DT2Date(Started)) and (POSEntry."Starting Time" > DT2Time(Started)) then
            exit(false);

          exit(true);
        end;
        //+NPR5.53 [377533]
    end;

    procedure PauseFrontEndBeforeEFTRequest(EFTTransactionRequest: Record "EFT Transaction Request";POSFrontEnd: Codeunit "POS Front End Management")
    var
        EFTInterface: Codeunit "EFT Interface";
        Skip: Boolean;
    begin
        //-NPR5.54 [364340]
        if POSFrontEnd.IsPaused() then
          exit;

        EFTInterface.OnBeforePauseFrontEnd(EFTTransactionRequest, Skip);
        if not Skip then begin
          POSFrontEnd.PauseWorkflow();
        end;
        //+NPR5.54 [364340]
    end;

    procedure ResumeFrontEndAfterEFTRequest(EFTTransactionRequest: Record "EFT Transaction Request";POSFrontEnd: Codeunit "POS Front End Management")
    var
        Skip: Boolean;
        EFTInterface: Codeunit "EFT Interface";
    begin
        //-NPR5.54 [364340]
        EFTInterface.OnBeforeResumeFrontEnd(EFTTransactionRequest, Skip);
        if not Skip then begin
          POSFrontEnd.ResumeWorkflow();
        end;
        //+NPR5.54 [364340]
    end;

    local procedure "// Event Publishers"()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterEftIntegrationResponseReceived(EftTransactionRequest: Record "EFT Transaction Request")
    begin
    end;
}

