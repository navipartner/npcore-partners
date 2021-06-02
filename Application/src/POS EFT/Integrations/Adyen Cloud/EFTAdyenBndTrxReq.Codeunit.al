codeunit 6184521 "NPR EFT Adyen Bnd. Trx Req."
{
    TableNo = "NPR EFT Trx Async Req.";

    trigger OnRun()
    begin
        case CodeunitExecutionMode of
            CodeunitExecutionMode::INIT_SESSION:
                InitializeSession(Rec);
            CodeunitExecutionMode::START_TRX:
                StartTransaction(Rec);
        end;
    end;

    var
        ERR_UNSUPPORTED_TYPE: Label 'Unsupported %1: %2';
        CodeunitExecutionMode: Option INIT_SESSION,START_TRX;

    procedure SetExecutionMode(CodeunitExecutionModeIn: Integer)
    begin
        CodeunitExecutionMode := CodeunitExecutionModeIn;
    end;

    local procedure InitializeSession(EFTTransactionAsyncRequest: Record "NPR EFT Trx Async Req.")
    var
        EFTAdyenBackgndTrxReq: Codeunit "NPR EFT Adyen Bnd. Trx Req.";
        EFTTransactionLoggingMgt: Codeunit "NPR EFT Trx Logging Mgt.";
        BackgroundTrxLbl: Label 'Background trx CODEUNIT.RUN error: %1';
    begin
        EFTAdyenBackgndTrxReq.SetExecutionMode(CodeunitExecutionMode::START_TRX);
        if not EFTAdyenBackgndTrxReq.Run(EFTTransactionAsyncRequest) then begin
            EFTTransactionLoggingMgt.WriteLogEntry(EFTTransactionAsyncRequest."Request Entry No", StrSubstNo(BackgroundTrxLbl, GetLastErrorText), '');
        end;
    end;

    local procedure StartTransaction(EFTTransactionAsyncRequest: Record "NPR EFT Trx Async Req.")
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTTransactionLoggingMgt: Codeunit "NPR EFT Trx Logging Mgt.";
        EFTTrxBackgroundSessionMgt: Codeunit "NPR EFT Trx Bgd. Session Mgt";
        EFTSetup: Record "NPR EFT Setup";
        Response: Text;
        Success: Boolean;
        EFTAdyenCloudProtocol: Codeunit "NPR EFT Adyen Cloud Prot.";
        TransactionStarted: Boolean;
    begin
        //-NPR5.53 [377533]
        EFTTransactionAsyncRequest.TestField("Request Entry No");

        if (EFTTrxBackgroundSessionMgt.IsRequestAbortAttempted(EFTTransactionAsyncRequest."Request Entry No", true)) then begin
            EFTTransactionLoggingMgt.WriteLogEntry(EFTTransactionAsyncRequest."Request Entry No", 'Trx abort already requested. Skipping start on background session', '');
            exit;
        end;

        EFTTransactionLoggingMgt.WriteLogEntry(EFTTransactionAsyncRequest."Request Entry No", 'Starting trx background session', '');
        Commit(); //Log

        EFTTransactionRequest.Get(EFTTransactionAsyncRequest."Request Entry No");
        EFTSetup.FindSetup(EFTTransactionRequest."Register No.", EFTTransactionRequest."Original POS Payment Type Code");

        Success := SendRequest(EFTTransactionRequest, EFTSetup, Response, EFTAdyenCloudProtocol);
        //-NPR5.54 [387990]
        TransactionStarted := (Success or (EFTAdyenCloudProtocol.GetResponseStatusCodeBuffer() in [0, 200])); //Unknown or success
        //+NPR5.54 [387990]

        LogTrxRequest(EFTTransactionAsyncRequest."Request Entry No", EFTSetup, EFTAdyenCloudProtocol, Success);
        Commit(); //Log

        //This function takes a LOCK on the request record, which acts a synchronization mechanism between the racing background sessions.
        //It is kept until after writing response record.
        if EFTTrxBackgroundSessionMgt.IsRequestDone(EFTTransactionAsyncRequest."Request Entry No", true) then begin
            EFTTransactionLoggingMgt.WriteLogEntry(EFTTransactionAsyncRequest."Request Entry No", 'Trx already marked as done. Skipping trx response insert', '');
            exit;
        end;

        //-NPR5.54 [387990]
        //InsertTrxResponse(EFTTransactionAsyncRequest."Request Entry No", Success, Response);
        InsertTrxResponse(EFTTransactionAsyncRequest."Request Entry No", Success, Response, TransactionStarted);
        //+NPR5.54 [387990]
        EFTTrxBackgroundSessionMgt.MarkRequestAsDone(EFTTransactionAsyncRequest."Request Entry No");
        Commit(); //Response
        //+NPR5.53 [377533]
    end;

    local procedure SendRequest(EFTTransactionRequest: Record "NPR EFT Transaction Request"; EFTSetup: Record "NPR EFT Setup"; var Response: Text; var EFTAdyenCloudProtocol: Codeunit "NPR EFT Adyen Cloud Prot."): Boolean
    var
        Success: Boolean;
    begin
        //-NPR5.53 [377533]
        case EFTTransactionRequest."Processing Type" of
            EFTTransactionRequest."Processing Type"::PAYMENT:
                Success := EFTAdyenCloudProtocol.InvokePayment(EFTTransactionRequest, EFTSetup, Response);
            EFTTransactionRequest."Processing Type"::REFUND:
                Success := EFTAdyenCloudProtocol.InvokeRefund(EFTTransactionRequest, EFTSetup, Response);
            EFTTransactionRequest."Processing Type"::AUXILIARY:
                case EFTTransactionRequest."Auxiliary Operation ID" of
                    2, 4, 5:
                        Success := EFTAdyenCloudProtocol.InvokeAcquireCard(EFTTransactionRequest, EFTSetup, Response);
                    else
                        Error(ERR_UNSUPPORTED_TYPE, EFTTransactionRequest.FieldCaption("Processing Type"), EFTTransactionRequest."Processing Type");
                end;
            else
                Error(ERR_UNSUPPORTED_TYPE, EFTTransactionRequest.FieldCaption("Processing Type"), EFTTransactionRequest."Processing Type");
        end;

        exit(Success);
        //+NPR5.53 [377533]
    end;

    local procedure LogTrxRequest(TrxEntryNo: Integer; EFTSetup: Record "NPR EFT Setup"; EFTAdyenCloudProtocol: Codeunit "NPR EFT Adyen Cloud Prot."; Success: Boolean)
    var
        EFTAdyenPaymentTypeSetup: Record "NPR EFT Adyen Paym. Type Setup";
        LogLevel: Integer;
        EFTAdyenCloudIntegration: Codeunit "NPR EFT Adyen Cloud Integ.";
        RequestResponseBuffer: Text;
        EFTTransactionLoggingMgt: Codeunit "NPR EFT Trx Logging Mgt.";
    begin
        //-NPR5.53 [377533]
        LogLevel := EFTAdyenCloudIntegration.GetLogLevel(EFTSetup);

        if (LogLevel = EFTAdyenPaymentTypeSetup."Log Level"::FULL)
          or ((LogLevel = EFTAdyenPaymentTypeSetup."Log Level"::ERROR) and (not Success)) then begin
            RequestResponseBuffer := EFTAdyenCloudProtocol.GetRequestResponseBuffer();
            EFTTransactionLoggingMgt.WriteLogEntry(TrxEntryNo, 'Trx request done', RequestResponseBuffer);
        end else begin
            EFTTransactionLoggingMgt.WriteLogEntry(TrxEntryNo, 'Trx request done', '');
        end;
        //+NPR5.53 [377533]
    end;

    local procedure InsertTrxResponse(TrxEntryNo: Integer; Success: Boolean; Response: Text; TransactionStarted: Boolean)
    var
        OutStream: OutStream;
        EFTTransactionAsyncResponse: Record "NPR EFT Trx Async Resp.";
    begin
        //-NPR5.53 [377533]
        EFTTransactionAsyncResponse.Init();
        EFTTransactionAsyncResponse."Request Entry No" := TrxEntryNo;

        if Success then begin
            EFTTransactionAsyncResponse.Response.CreateOutStream(OutStream, TEXTENCODING::UTF8);
            OutStream.WriteText(Response);
        end else begin
            EFTTransactionAsyncResponse.Error := true;
            EFTTransactionAsyncResponse."Error Text" := CopyStr(GetLastErrorText, 1, MaxStrLen(EFTTransactionAsyncResponse."Error Text"));
        end;

        //-NPR5.54 [387990]
        EFTTransactionAsyncResponse."Transaction Started" := TransactionStarted;
        //+NPR5.54 [387990]

        EFTTransactionAsyncResponse.Insert();
        //+NPR5.53 [377533]
    end;
}

