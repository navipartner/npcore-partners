codeunit 6184521 "EFT Adyen Backgnd. Trx Req."
{
    // NPR5.48/MMV /20190124 CASE 341237 Created object
    // NPR5.49/MMV /20190219 CASE 345188 Added AcquireCard support
    // NPR5.49/MMV /20190409 CASE 351678 Renamed object
    // NPR5.50/MMV /20190515 CASE 355433 Added modify
    // NPR5.53/MMV /20191120 CASE 377533 Rewrote background session handling

    TableNo = "EFT Transaction Async Request";

    trigger OnRun()
    begin
        //-NPR5.53 [377533]
        case CodeunitExecutionMode of
          CodeunitExecutionMode::INIT_SESSION : InitializeSession(Rec);
          CodeunitExecutionMode::START_TRX : StartTransaction(Rec);
        end;
        //+NPR5.53 [377533]
    end;

    var
        ERR_UNSUPPORTED_TYPE: Label 'Unsupported %1: %2';
        CodeunitExecutionMode: Option INIT_SESSION,START_TRX;

    procedure SetExecutionMode(CodeunitExecutionModeIn: Integer)
    begin
        //-NPR5.53 [377533]
        CodeunitExecutionMode := CodeunitExecutionModeIn;
        //+NPR5.53 [377533]
    end;

    local procedure InitializeSession(EFTTransactionAsyncRequest: Record "EFT Transaction Async Request")
    var
        EFTAdyenBackgndTrxReq: Codeunit "EFT Adyen Backgnd. Trx Req.";
        EFTTransactionLoggingMgt: Codeunit "EFT Transaction Logging Mgt.";
    begin
        //-NPR5.53 [377533]
        EFTAdyenBackgndTrxReq.SetExecutionMode(CodeunitExecutionMode::START_TRX);
        if not EFTAdyenBackgndTrxReq.Run(EFTTransactionAsyncRequest) then begin
          EFTTransactionLoggingMgt.WriteLogEntry(EFTTransactionAsyncRequest."Request Entry No", StrSubstNo('Background trx CODEUNIT.RUN error: %1', GetLastErrorText), '');
        end;
        //+NPR5.53 [377533]
    end;

    local procedure StartTransaction(EFTTransactionAsyncRequest: Record "EFT Transaction Async Request")
    var
        EFTTransactionRequest: Record "EFT Transaction Request";
        EFTTransactionLoggingMgt: Codeunit "EFT Transaction Logging Mgt.";
        EFTTrxBackgroundSessionMgt: Codeunit "EFT Trx Background Session Mgt";
        EFTSetup: Record "EFT Setup";
        Response: Text;
        Success: Boolean;
        EFTAdyenCloudProtocol: Codeunit "EFT Adyen Cloud Protocol";
    begin
        //-NPR5.53 [377533]
        EFTTransactionAsyncRequest.TestField("Request Entry No");

        if (EFTTrxBackgroundSessionMgt.IsRequestAbortAttempted(EFTTransactionAsyncRequest."Request Entry No", true)) then begin
          EFTTransactionLoggingMgt.WriteLogEntry(EFTTransactionAsyncRequest."Request Entry No", 'Trx abort already requested. Skipping start on background session', '');
          exit;
        end;

        EFTTransactionLoggingMgt.WriteLogEntry(EFTTransactionAsyncRequest."Request Entry No", 'Starting trx background session', '');
        Commit; //Log

        EFTTransactionRequest.Get(EFTTransactionAsyncRequest."Request Entry No");
        EFTSetup.FindSetup(EFTTransactionRequest."Register No.", EFTTransactionRequest."Original POS Payment Type Code");

        Success := SendRequest(EFTTransactionRequest, EFTSetup, Response, EFTAdyenCloudProtocol);

        LogTrxRequest(EFTTransactionAsyncRequest."Request Entry No", EFTSetup, EFTAdyenCloudProtocol, Success);
        Commit; //Log

        //This function takes a LOCK on the request record, which acts a synchronization mechanism between the racing background sessions.
        //It is kept until after writing response record.
        if EFTTrxBackgroundSessionMgt.IsRequestDone(EFTTransactionAsyncRequest."Request Entry No", true) then begin
          EFTTransactionLoggingMgt.WriteLogEntry(EFTTransactionAsyncRequest."Request Entry No", 'Trx already marked as done. Skipping trx response insert', '');
          exit;
        end;

        InsertTrxResponse(EFTTransactionAsyncRequest."Request Entry No", Success, Response);
        EFTTrxBackgroundSessionMgt.MarkRequestAsDone(EFTTransactionAsyncRequest."Request Entry No");
        Commit; //Response
        //+NPR5.53 [377533]
    end;

    local procedure SendRequest(EFTTransactionRequest: Record "EFT Transaction Request";EFTSetup: Record "EFT Setup";var Response: Text;var EFTAdyenCloudProtocol: Codeunit "EFT Adyen Cloud Protocol"): Boolean
    var
        Success: Boolean;
    begin
        //-NPR5.53 [377533]
        with EFTTransactionRequest do begin
          case "Processing Type" of
            "Processing Type"::PAYMENT : Success := EFTAdyenCloudProtocol.InvokePayment(EFTTransactionRequest, EFTSetup, Response);
            "Processing Type"::REFUND : Success := EFTAdyenCloudProtocol.InvokeRefund(EFTTransactionRequest, EFTSetup, Response);
            "Processing Type"::AUXILIARY :
              case "Auxiliary Operation ID" of
                2,4,5 : Success := EFTAdyenCloudProtocol.InvokeAcquireCard(EFTTransactionRequest, EFTSetup, Response);
                else
                  Error(ERR_UNSUPPORTED_TYPE, EFTTransactionRequest.FieldCaption("Processing Type"), "Processing Type");
              end;
            else
              Error(ERR_UNSUPPORTED_TYPE, EFTTransactionRequest.FieldCaption("Processing Type"), "Processing Type");
          end;
        end;

        exit(Success);
        //+NPR5.53 [377533]
    end;

    local procedure LogTrxRequest(TrxEntryNo: Integer;EFTSetup: Record "EFT Setup";EFTAdyenCloudProtocol: Codeunit "EFT Adyen Cloud Protocol";Success: Boolean)
    var
        EFTAdyenPaymentTypeSetup: Record "EFT Adyen Payment Type Setup";
        LogLevel: Integer;
        EFTAdyenCloudIntegration: Codeunit "EFT Adyen Cloud Integration";
        RequestResponseBuffer: Text;
        EFTTransactionLoggingMgt: Codeunit "EFT Transaction Logging Mgt.";
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

    local procedure InsertTrxResponse(TrxEntryNo: Integer;Success: Boolean;Response: Text)
    var
        OutStream: OutStream;
        EFTTransactionAsyncResponse: Record "EFT Transaction Async Response";
    begin
        //-NPR5.53 [377533]
        EFTTransactionAsyncResponse.Init;
        EFTTransactionAsyncResponse."Request Entry No" := TrxEntryNo;

        if Success then begin
          EFTTransactionAsyncResponse.Response.CreateOutStream(OutStream, TEXTENCODING::UTF8);
          OutStream.WriteText(Response);
        end else begin
          EFTTransactionAsyncResponse.Error := true;
          EFTTransactionAsyncResponse."Error Text" := CopyStr(GetLastErrorText, 1, MaxStrLen(EFTTransactionAsyncResponse."Error Text"));
        end;

        EFTTransactionAsyncResponse.Insert;
        //+NPR5.53 [377533]
    end;
}

