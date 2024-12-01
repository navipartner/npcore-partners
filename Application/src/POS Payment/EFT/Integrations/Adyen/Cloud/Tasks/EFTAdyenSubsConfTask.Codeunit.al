codeunit 6185084 "NPR EFT Adyen Subs Conf Task" implements "NPR POS Background Task"
{
    Access = Internal;

    procedure ExecuteBackgroundTask(TaskId: Integer; Parameters: Dictionary of [Text, Text]; var Result: Dictionary of [Text, Text]);
    var
        EntryNo: Integer;
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTSetup: Record "NPR EFT Setup";
        GLSetup: Record "General Ledger Setup";
        EFTAdyenCloudProtocol: Codeunit "NPR EFT Adyen Cloud Protocol";
        EFTAdyenCloudIntegrat: Codeunit "NPR EFT Adyen Cloud Integrat.";
        EFTAdyenConfInputReq: Codeunit "NPR EFT Adyen ConfInput Req";
        Request: Text;
        Response: Text;
        URL: Text;
        Logs: Text;
        ConfirmationDialogText: Text;
        ConfirmationDialogTitleLbl: Label 'Subscription';
        ConfirmationDialogTextLbl: Label 'Start subscription %1 %2/year on card?';
        SubscriptionAmountIncludingVAT: Decimal;
        StatusCode: Integer;
        Started: Boolean;
        Completed: Boolean;
    begin
        Evaluate(EntryNo, Parameters.Get('EntryNo'));
        EFTTransactionRequest.Get(EntryNo);
        EFTSetup.FindSetup(EFTTransactionRequest."Register No.", EFTTransactionRequest."Original POS Payment Type Code");

        if not GLSetup.Get() then
            Clear(GLSetup);

        SubscriptionAmountIncludingVAT := CalcSubscriptionAmountIncludingVAT(EFTTransactionRequest);
        ConfirmationDialogText := StrSubstNo(ConfirmationDialogTextLbl, SubscriptionAmountIncludingVAT, GLSetup."LCY Code");

        EFTAdyenConfInputReq.SetTitle(ConfirmationDialogTitleLbl);
        EFTAdyenConfInputReq.SetTextQst(ConfirmationDialogText);
        Request := EFTAdyenConfInputReq.GetRequestJson(EFTTransactionRequest, EFTSetup);
        URL := EFTAdyenCloudProtocol.GetTerminalURL(EFTTransactionRequest);

        Completed := EFTAdyenCloudProtocol.InvokeAPI(Request, EFTAdyenCloudIntegrat.GetAPIKey(EFTSetup), URL, 1000 * 60 * 5, Response, StatusCode);
        Started := StatusCode in [0, 200]; //if we got 403 or other 4xx transaction didn't even start 
        Logs := EFTAdyenCloudProtocol.GetLogBuffer();

        Result.Add('Started', Format(Started, 0, 9));
        Result.Add('Completed', Format(Completed, 0, 9));
        Result.Add('Response', Response);
        Result.Add('Logs', Logs);
        if not (Completed) then begin
            Result.Add('Error', GetLastErrorText());
            Result.Add('ErrorCallstack', GetLastErrorCallStack());
        end;
    end;

    procedure BackgroundTaskSuccessContinuation(TaskId: Integer; Parameters: Dictionary of [Text, Text]; Results: Dictionary of [Text, Text]);
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        Completed: Boolean;
        Response: Text;
        Error: Text;
        ErrorCallstack: Text;
        EntryNo: Integer;
        Logs: Text;
        POSActionEFTAdyenCloud: Codeunit "NPR POS Action EFT Adyen Cloud";
        EFTAdyenIntegration: Codeunit "NPR EFT Adyen Integration";
    begin
        //Trx done, either complete (success/failure) or handled error 
        Evaluate(EntryNo, Parameters.Get('EntryNo'));
        EFTTransactionRequest.Get(EntryNo);
        Evaluate(Completed, Results.Get('Completed'), 9);

        if Completed then begin
            Response := Results.Get('Response');
            Logs := Results.Get('Logs');
            EFTAdyenIntegration.WriteLogEntry(EFTTransactionRequest, false, 'TaskSubsConfirmDone (Complete)', Logs);
            Commit();

            POSActionEFTAdyenCloud.SetTrxResponse(EFTTransactionRequest."Entry No.", Response, true, true, '');
            POSActionEFTAdyenCloud.SetTrxStatus(EFTTransactionRequest."Entry No.", Enum::"NPR EFT Adyen Task Status"::SubscriptionConfirmationResponseReceived);
        end else begin
            Error := Results.Get('Error');
            ErrorCallstack := Results.Get('ErrorCallstack');
            EFTAdyenIntegration.WriteLogEntry(EFTTransactionRequest, false, 'TaskSubsConfirmDone (Error)', StrSubstNo('Error: %1 \\Callstack: %2', Error, ErrorCallStack));
            POSActionEFTAdyenCloud.SetTrxResponse(EFTTransactionRequest."Entry No.", Response, false, true, StrSubstNo('Error: %1 \\Callstack: %2', Error, ErrorCallStack));
            POSActionEFTAdyenCloud.SetTrxStatus(EFTTransactionRequest."Entry No.", Enum::"NPR EFT Adyen Task Status"::SubscriptionConfirmationResponseReceived);
        end;
    end;

    procedure BackgroundTaskErrorContinuation(TaskId: Integer; Parameters: Dictionary of [Text, Text]; ErrorCode: Text; ErrorText: Text; ErrorCallStack: Text);
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        EntryNo: Integer;
        POSActionEFTAdyenCloud: Codeunit "NPR POS Action EFT Adyen Cloud";
        EFTAdyenIntegration: Codeunit "NPR EFT Adyen Integration";
    begin
        //Trx result unknown - log error and start lookup        
        Evaluate(EntryNo, Parameters.Get('EntryNo'));
        EFTTransactionRequest.Get(EntryNo);
        EFTAdyenIntegration.WriteLogEntry(EFTTransactionRequest, false, 'TaskSubsConfirmError', '');
        POSActionEFTAdyenCloud.SetTrxResponse(EFTTransactionRequest."Entry No.", '', false, true, StrSubstNo('Error: %1 \\Callstack: %2', ErrorText, ErrorCallStack));
        POSActionEFTAdyenCloud.SetTrxStatus(EFTTransactionRequest."Entry No.", Enum::"NPR EFT Adyen Task Status"::SubscriptionConfirmationResponseReceived);
    end;

    procedure BackgroundTaskCancelled(TaskId: Integer; Parameters: Dictionary of [Text, Text]);
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        EntryNo: Integer;
        POSActionEFTAdyenCloud: Codeunit "NPR POS Action EFT Adyen Cloud";
        EFTAdyenIntegration: Codeunit "NPR EFT Adyen Integration";
    begin
        //Trx result unknown - log error and start lookup        
        Evaluate(EntryNo, Parameters.Get('EntryNo'));
        EFTTransactionRequest.Get(EntryNo);
        EFTAdyenIntegration.WriteLogEntry(EFTTransactionRequest, false, 'TaskSubsConfirmCancelled', '');
        POSActionEFTAdyenCloud.SetTrxResponse(EFTTransactionRequest."Entry No.", '', false, true, StrSubstNo('Error: %1 \\Callstack: %2'));
        POSActionEFTAdyenCloud.SetTrxStatus(EFTTransactionRequest."Entry No.", Enum::"NPR EFT Adyen Task Status"::SubscriptionConfirmationResponseReceived);
    end;

    local procedure CalcSubscriptionAmountIncludingVAT(EFTTransactionRequest: Record "NPR EFT Transaction Request") SubscriptionAmountIncludingVAT: Decimal;
    var
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        TempProcessedLineBuffer: Record "NPR MM Member Info Capture" temporary;
        SalesLinePOS: Record "NPR POS Sale Line";
    begin
        MemberInfoCapture.Reset();
        MemberInfoCapture.SetCurrentKey("Receipt No.", "Line No.");
        MemberInfoCapture.SetRange("Receipt No.", EFTTransactionRequest."Sales Ticket No.");
        MemberInfoCapture.SetLoadFields("Entry No.", "Receipt No.", "Line No.");
        if not MemberInfoCapture.FindSet() then
            exit;

        repeat
            TempProcessedLineBuffer.Reset();
            TempProcessedLineBuffer.SetRange("Receipt No.", MemberInfoCapture."Receipt No.");
            TempProcessedLineBuffer.SetRange("Line No.", MemberInfoCapture."Line No.");
            if TempProcessedLineBuffer.IsEmpty then begin
                SalesLinePOS.Reset();
                SalesLinePOS.SetRange("Register No.", EFTTransactionRequest."Register No.");
                SalesLinePOS.SetRange("Sales Ticket No.", EFTTransactionRequest."Sales Ticket No.");
                SalesLinePOS.SetRange("Line No.", MemberInfoCapture."Line No.");
                SalesLinePOS.CalcSums("Amount Including VAT");
                SubscriptionAmountIncludingVAT += SalesLinePOS."Amount Including VAT";

                TempProcessedLineBuffer.Init();
                TempProcessedLineBuffer := MemberInfoCapture;
                TempProcessedLineBuffer.Insert();
            end;
        until MemberInfoCapture.Next() = 0;
    end;
}