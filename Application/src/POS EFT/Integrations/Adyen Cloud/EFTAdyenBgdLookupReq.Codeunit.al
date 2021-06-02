codeunit 6184530 "NPR EFT Adyen Bgd. Lookup Req."
{
    // NPR5.53/MMV /20191120 CASE 377533 Created object
    // NPR5.53/MMV /20200126 CASE 377533 Added timeout param on lookup invoke
    // NPR5.54/MMV /20200218 CASE 387990 Added response status code buffer.
    // NPR5.54/MMV /20200226 CASE 364340 Added check for outdated request.

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
        CodeunitExecutionMode: Option INIT_SESSION,START_TRX;

    procedure SetExecutionMode(CodeunitExecutionModeIn: Integer)
    begin
        CodeunitExecutionMode := CodeunitExecutionModeIn;
    end;

    local procedure InitializeSession(EFTTransactionAsyncRequest: Record "NPR EFT Trx Async Req.")
    var
        EFTAdyenBackgndLookupReq: Codeunit "NPR EFT Adyen Bgd. Lookup Req.";
        EFTTransactionLoggingMgt: Codeunit "NPR EFT Trx Logging Mgt.";
        BackgroundLookupLbl: Label 'Background lookup CODEUNIT.RUN error: %1';
    begin
        EFTAdyenBackgndLookupReq.SetExecutionMode(CodeunitExecutionMode::START_TRX);
        if not EFTAdyenBackgndLookupReq.Run(EFTTransactionAsyncRequest) then begin
            EFTTransactionLoggingMgt.WriteLogEntry(EFTTransactionAsyncRequest."Request Entry No", StrSubstNo(BackgroundLookupLbl, GetLastErrorText), '');
        end;
    end;

    local procedure StartTransaction(EFTTransactionAsyncRequest: Record "NPR EFT Trx Async Req.")
    var
        EFTTransactionLoggingMgt: Codeunit "NPR EFT Trx Logging Mgt.";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTTrxBackgroundSessionMgt: Codeunit "NPR EFT Trx Bgd. Session Mgt";
        EFTSetup: Record "NPR EFT Setup";
        EFTAdyenCloudProtocol: Codeunit "NPR EFT Adyen Cloud Prot.";
        Response: Text;
        LookupEftTrxRequest: Record "NPR EFT Transaction Request";
        LookupAttempt: Integer;
        ConclusiveResponse: Boolean;
        EFTAdyenResponseParser: Codeunit "NPR EFT Adyen Resp. Parser";
        InnerResponse: Text;
    begin
        EFTTransactionAsyncRequest.TestField("Request Entry No");

        EFTTransactionLoggingMgt.WriteLogEntry(EFTTransactionAsyncRequest."Request Entry No", 'Starting lookup background session', '');
        Commit(); //Log

        EFTTransactionRequest.Get(EFTTransactionAsyncRequest."Request Entry No");
        if not (EFTTransactionRequest."Processing Type" in [EFTTransactionRequest."Processing Type"::PAYMENT, EFTTransactionRequest."Processing Type"::REFUND]) then
            EFTTransactionRequest.FieldError("Processing Type");
        EFTSetup.FindSetup(EFTTransactionRequest."Register No.", EFTTransactionRequest."Original POS Payment Type Code");

        while (not ConclusiveResponse) do begin
            Clear(Response);
            LookupAttempt += 1;

            if LookupAttempt = 1 then begin
                Sleep(1000 * 10);
                EFTTransactionLoggingMgt.WriteLogEntry(EFTTransactionAsyncRequest."Request Entry No", 'Lookup buffer period passed, starting to loop lookup requests', '');
                Commit();
                //-NPR5.54 [364340]
            end else
                if LookupAttempt > 60 then begin
                    EFTTransactionLoggingMgt.WriteLogEntry(EFTTransactionAsyncRequest."Request Entry No", 'Stopping lookup background session. (Timeout)', '');
                    exit;
                end else begin
                    Sleep(1000 * 5);
                end;

            if EFTTrxBackgroundSessionMgt.IsRequestOutdated(EFTTransactionAsyncRequest."Request Entry No", EFTTransactionAsyncRequest."Hardware ID") then begin
                EFTTransactionLoggingMgt.WriteLogEntry(EFTTransactionAsyncRequest."Request Entry No", 'Stopping lookup background session. (Found newer request on same hardware)', '');
                exit;
            end;
            //+NPR5.54 [364340]

            if EFTTrxBackgroundSessionMgt.IsRequestDone(EFTTransactionAsyncRequest."Request Entry No", false) then begin
                if EFTTrxBackgroundSessionMgt.IsRequestDone(EFTTransactionAsyncRequest."Request Entry No", true) then begin
                    EFTTransactionLoggingMgt.WriteLogEntry(EFTTransactionAsyncRequest."Request Entry No", 'Stopping lookup background session. (Marked as done)', '');
                    exit;
                end;
                Commit(); //Release lock
            end;

            LookupEftTrxRequest := EFTTransactionRequest; //Is not actually inserted in DB to prevent data spam. Reference no. is increased on top of auto increment.
            LookupEftTrxRequest."Reference Number Input" += ('r' + Format(LookupAttempt));

            EFTAdyenCloudProtocol.ClearRequestResponseBuffer();
            //-NPR5.53 [377533]
            if EFTAdyenCloudProtocol.InvokeLookup(LookupEftTrxRequest, EFTSetup, EFTTransactionRequest, 1000 * 5, Response) then; //5 sec. timeout, repeat on error.
                                                                                                                                  //+NPR5.53 [377533]
            ConclusiveResponse := EFTAdyenResponseParser.IsConclusiveLookupResult(Response, InnerResponse);
        end;

        LogTrxRequest(EFTTransactionAsyncRequest."Request Entry No", EFTSetup, EFTAdyenCloudProtocol, ConclusiveResponse);
        Commit(); //Log

        //This function takes a LOCK on the request record, which acts a synchronization mechanism between the racing background sessions.
        //It is kept until after writing response record.
        if EFTTrxBackgroundSessionMgt.IsRequestDone(EFTTransactionAsyncRequest."Request Entry No", true) then begin
            EFTTransactionLoggingMgt.WriteLogEntry(EFTTransactionAsyncRequest."Request Entry No", 'Trx already marked as done. Skipping lookup response insert', '');
            exit;
        end;

        InsertTrxResponse(EFTTransactionAsyncRequest."Request Entry No", ConclusiveResponse, InnerResponse);
        EFTTrxBackgroundSessionMgt.MarkRequestAsDone(EFTTransactionAsyncRequest."Request Entry No");
        Commit(); //Response
    end;

    local procedure LogTrxRequest(TrxEntryNo: Integer; EFTSetup: Record "NPR EFT Setup"; EFTAdyenCloudProtocol: Codeunit "NPR EFT Adyen Cloud Prot."; Success: Boolean)
    var
        EFTAdyenPaymentTypeSetup: Record "NPR EFT Adyen Paym. Type Setup";
        LogLevel: Integer;
        EFTAdyenCloudIntegration: Codeunit "NPR EFT Adyen Cloud Integ.";
        EFTTransactionLoggingMgt: Codeunit "NPR EFT Trx Logging Mgt.";
    begin
        LogLevel := EFTAdyenCloudIntegration.GetLogLevel(EFTSetup);

        if (LogLevel = EFTAdyenPaymentTypeSetup."Log Level"::FULL)
          or ((LogLevel = EFTAdyenPaymentTypeSetup."Log Level"::ERROR) and (not Success)) then begin
            EFTTransactionLoggingMgt.WriteLogEntry(TrxEntryNo, 'Lookup request done', EFTAdyenCloudProtocol.GetRequestResponseBuffer());
        end else begin
            EFTTransactionLoggingMgt.WriteLogEntry(TrxEntryNo, 'Lookup request done', '');
        end;
    end;

    local procedure InsertTrxResponse(TrxEntryNo: Integer; Success: Boolean; Response: Text)
    var
        OutStream: OutStream;
        EFTTransactionAsyncResponse: Record "NPR EFT Trx Async Resp.";
    begin
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
        EFTTransactionAsyncResponse."Transaction Started" := true;
        //+NPR5.54 [387990]

        EFTTransactionAsyncResponse.Insert();
    end;
}

