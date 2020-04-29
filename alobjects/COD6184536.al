codeunit 6184536 "EFT NETSCloud Bg. Trx. Req."
{
    // NPR5.54/JAKUBV/20200408  CASE 364340 Transport NPR5.54 - 8 April 2020

    TableNo = "EFT Transaction Async Request";

    trigger OnRun()
    begin
        case CodeunitExecutionMode of
          CodeunitExecutionMode::INIT_SESSION : InitializeSession(Rec);
          CodeunitExecutionMode::START_TRX : StartTransaction(Rec);
        end;
    end;

    var
        ERR_UNSUPPORTED_TYPE: Label 'Unsupported %1: %2';
        CodeunitExecutionMode: Option INIT_SESSION,START_TRX;

    procedure SetExecutionMode(CodeunitExecutionModeIn: Integer)
    begin
        CodeunitExecutionMode := CodeunitExecutionModeIn;
    end;

    local procedure InitializeSession(EFTTransactionAsyncRequest: Record "EFT Transaction Async Request")
    var
        EFTNETSBackgndTrxReq: Codeunit "EFT NETSCloud Bg. Trx. Req.";
        EFTTransactionLoggingMgt: Codeunit "EFT Transaction Logging Mgt.";
    begin
        EFTNETSBackgndTrxReq.SetExecutionMode(CodeunitExecutionMode::START_TRX);
        if not EFTNETSBackgndTrxReq.Run(EFTTransactionAsyncRequest) then begin
          EFTTransactionLoggingMgt.WriteLogEntry(EFTTransactionAsyncRequest."Request Entry No", StrSubstNo('Background trx CODEUNIT.RUN error: %1', GetLastErrorText), '');
        end;
    end;

    local procedure StartTransaction(EFTTransactionAsyncRequest: Record "EFT Transaction Async Request")
    var
        EFTTransactionRequest: Record "EFT Transaction Request";
        EFTTransactionLoggingMgt: Codeunit "EFT Transaction Logging Mgt.";
        EFTTrxBackgroundSessionMgt: Codeunit "EFT Trx Background Session Mgt";
        EFTSetup: Record "EFT Setup";
        TrxResponse: Text;
        TrxResult: Boolean;
        EFTNETSCloudProtocol: Codeunit "EFT NETSCloud Protocol";
        LookupResponse: Text;
        LookupResult: Boolean;
        LookupAttempt: Integer;
        ErrorText: Text;
        EFTNETSCloudToken: Codeunit "EFT NETSCloud Token";
        TokenText: Text;
        TransactionStarted: Boolean;
    begin
        if (EFTTrxBackgroundSessionMgt.IsRequestAbortAttempted(EFTTransactionAsyncRequest."Request Entry No", true)) then begin
          EFTTransactionLoggingMgt.WriteLogEntry(EFTTransactionAsyncRequest."Request Entry No", 'Trx abort already requested. Skipping start on background session', '');
          exit;
        end;

        EFTTransactionLoggingMgt.WriteLogEntry(EFTTransactionAsyncRequest."Request Entry No", 'Starting trx background session', '');
        Commit; //Log

        EFTTransactionRequest.Get(EFTTransactionAsyncRequest."Request Entry No");
        EFTSetup.FindSetup(EFTTransactionRequest."Register No.", EFTTransactionRequest."Original POS Payment Type Code");

        TrxResult := SendRequest(EFTTransactionRequest, EFTSetup, TrxResponse, EFTNETSCloudProtocol);
        TransactionStarted := TrxResult or (EFTNETSCloudProtocol.GetResponseStatusCodeBuffer in [0,200,201,400]);
        LogTrxRequest(EFTTransactionAsyncRequest."Request Entry No", EFTSetup, EFTNETSCloudProtocol, TrxResult);
        Commit; //Log

        if not TrxResult then begin
          ErrorText := GetLastErrorText;

          while ((not LookupResult) and (LookupAttempt < 2)) do begin //Lookup requests abort active transactions so we cannot have a high amount of retries since it risks overlapping with new trx attempts.
            LookupAttempt += 1;

            if EFTTrxBackgroundSessionMgt.IsRequestOutdated(EFTTransactionAsyncRequest."Request Entry No", EFTTransactionAsyncRequest."Hardware ID") then begin
              EFTTransactionLoggingMgt.WriteLogEntry(EFTTransactionAsyncRequest."Request Entry No", 'Stopping auto lookup. (Found newer request on same hardware)', '');
              exit;
            end;

            if EFTTrxBackgroundSessionMgt.IsRequestDone(EFTTransactionAsyncRequest."Request Entry No", false) then begin
              if EFTTrxBackgroundSessionMgt.IsRequestDone(EFTTransactionAsyncRequest."Request Entry No", true) then begin
                EFTTransactionLoggingMgt.WriteLogEntry(EFTTransactionAsyncRequest."Request Entry No", 'Stopping auto lookup. (Marked as done)', '');
                exit;
              end;
              Commit;
            end;

            LookupResult := LookupTrx(LookupAttempt, EFTTransactionRequest, EFTSetup, EFTNETSCloudProtocol, 1000 * 5, LookupResponse);

            if not LookupResult then begin
              Sleep(1000 * 5);
            end;
          end;

          if LookupResult then begin
            TrxResult := LookupResult;
            TrxResponse := LookupResponse;
          end;
        end;

        //This function takes a LOCK on the request record, which acts a synchronization mechanism.
        //It is kept until after writing response record.
        if EFTTrxBackgroundSessionMgt.IsRequestDone(EFTTransactionAsyncRequest."Request Entry No", true) then begin
          EFTTransactionLoggingMgt.WriteLogEntry(EFTTransactionAsyncRequest."Request Entry No", 'Trx already marked as done. Skipping trx response insert', '');
          exit;
        end;

        InsertTrxResponse(EFTTransactionAsyncRequest."Request Entry No", TrxResult, TrxResponse, ErrorText);
        EFTTrxBackgroundSessionMgt.MarkRequestAsDone(EFTTransactionAsyncRequest."Request Entry No");
        Commit; //Response
    end;

    local procedure SendRequest(EFTTransactionRequest: Record "EFT Transaction Request";EFTSetup: Record "EFT Setup";var Response: Text;var EFTNETSCloudProtocol: Codeunit "EFT NETSCloud Protocol"): Boolean
    var
        Success: Boolean;
    begin
        with EFTTransactionRequest do begin
          case "Processing Type" of
            "Processing Type"::PAYMENT : Success := EFTNETSCloudProtocol.InvokePayment(EFTTransactionRequest, EFTSetup, Response);
            "Processing Type"::REFUND : Success := EFTNETSCloudProtocol.InvokeRefund(EFTTransactionRequest, EFTSetup, Response);
            "Processing Type"::AUXILIARY :
              case "Auxiliary Operation ID" of
                1 : ;
                else
                  Error(ERR_UNSUPPORTED_TYPE, EFTTransactionRequest.FieldCaption("Processing Type"), "Processing Type");
              end;
            else
              Error(ERR_UNSUPPORTED_TYPE, EFTTransactionRequest.FieldCaption("Processing Type"), "Processing Type");
          end;
        end;

        exit(Success);
    end;

    local procedure LogTrxRequest(TrxEntryNo: Integer;EFTSetup: Record "EFT Setup";EFTNETSCloudProtocol: Codeunit "EFT NETSCloud Protocol";Success: Boolean)
    var
        EFTNETSCloudPaymentSetup: Record "EFT NETS Cloud Payment Setup";
        LogLevel: Integer;
        EFTNETSCloudIntegration: Codeunit "EFT NETSCloud Integration";
        RequestResponseBuffer: Text;
        EFTTransactionLoggingMgt: Codeunit "EFT Transaction Logging Mgt.";
    begin
        LogLevel := EFTNETSCloudIntegration.GetLogLevel(EFTSetup);

        if (LogLevel = EFTNETSCloudPaymentSetup."Log Level"::FULL)
          or ((LogLevel = EFTNETSCloudPaymentSetup."Log Level"::ERROR) and (not Success)) then begin
          RequestResponseBuffer := EFTNETSCloudProtocol.GetRequestResponseBuffer();
          EFTTransactionLoggingMgt.WriteLogEntry(TrxEntryNo, 'Trx request done', RequestResponseBuffer);
        end else begin
          EFTTransactionLoggingMgt.WriteLogEntry(TrxEntryNo, 'Trx request done', '');
        end;
    end;

    local procedure InsertTrxResponse(TrxEntryNo: Integer;Success: Boolean;Response: Text;ErrorText: Text)
    var
        OutStream: OutStream;
        EFTTransactionAsyncResponse: Record "EFT Transaction Async Response";
    begin
        EFTTransactionAsyncResponse.Init;
        EFTTransactionAsyncResponse."Request Entry No" := TrxEntryNo;

        if Success then begin
          EFTTransactionAsyncResponse.Response.CreateOutStream(OutStream, TEXTENCODING::UTF8);
          OutStream.WriteText(Response);
        end else begin
          EFTTransactionAsyncResponse.Error := true;
          EFTTransactionAsyncResponse."Error Text" := CopyStr(ErrorText, 1, MaxStrLen(EFTTransactionAsyncResponse."Error Text"));
        end;

        EFTTransactionAsyncResponse.Insert;
    end;

    local procedure LookupTrx(LookupAttempt: Integer;EFTTransactionRequest: Record "EFT Transaction Request";EFTSetup: Record "EFT Setup";EFTNETSCloudProtocol: Codeunit "EFT NETSCloud Protocol";TimeoutMs: Integer;var LookupResponse: Text): Boolean
    var
        LookupResult: Boolean;
        EFTTransactionLoggingMgt: Codeunit "EFT Transaction Logging Mgt.";
        EFTNETSCloudResponseParser: Codeunit "EFT NETSCloud Response Parser";
    begin
        LookupResult := EFTNETSCloudProtocol.InvokeLookupLastTransaction(EFTTransactionRequest, EFTSetup, EFTTransactionRequest, TimeoutMs, LookupResponse);

        if LookupResult then begin
          LookupResult := EFTNETSCloudResponseParser.IsLookupResponseRelatedToTransaction(LookupResponse, EFTTransactionRequest);
        end;

        if LookupResult then begin
          EFTTransactionLoggingMgt.WriteLogEntry(
            EFTTransactionRequest."Entry No.",
            StrSubstNo('Auto lookup attempt %1, Success', LookupAttempt),
            EFTNETSCloudProtocol.GetRequestResponseBuffer());
        end else begin
          EFTTransactionLoggingMgt.WriteLogEntry(
            EFTTransactionRequest."Entry No.",
            StrSubstNo('Auto lookup attempt %1, Failure', LookupAttempt),
            EFTNETSCloudProtocol.GetRequestResponseBuffer());
        end;

        exit(LookupResult);
    end;
}

