codeunit 6185084 "NPR EFT Adyen Subs Conf Task" implements "NPR POS Background Task"
{
    Access = Internal;

    procedure ExecuteBackgroundTask(TaskId: Integer; Parameters: Dictionary of [Text, Text]; var Result: Dictionary of [Text, Text]);
    var
        EntryNo: Integer;
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTSetup: Record "NPR EFT Setup";
        GLSetup: Record "General Ledger Setup";
        SalePOS: Record "NPR POS Sale";
        EFTAdyenCloudProtocol: Codeunit "NPR EFT Adyen Cloud Protocol";
        EFTAdyenCloudIntegrat: Codeunit "NPR EFT Adyen Cloud Integrat.";
        EFTAdyenConfInputReq: Codeunit "NPR EFT Adyen ConfInput Req";
        MMMembershipMgtInternal: Codeunit "NPR MM MembershipMgtInternal";
        EFTAdyenTaskEvents: Codeunit "NPR EFT Adyen Task Events";
        Request: Text;
        Response: Text;
        URL: Text;
        Logs: Text;
        ConfirmationDialogText: Text;
        ConfirmationDialogTitleLbl: Label 'Subscription';
        ConfirmationDialogTextLbl: Label 'Start subscription %1 %2/year on card?';
        AutoRenewYesInternalConfirmationDialogTextLbl: Label 'Do you want to add the following card as the primary payment method?';
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

        EFTAdyenTaskEvents.OnBeforeEFTAdyenSubsConfirmationDialogTextSet(ConfirmationDialogText, SubscriptionAmountIncludingVAT, GLSetup."LCY Code");

        EFTAdyenConfInputReq.SetTitle(ConfirmationDialogTitleLbl);
        SalePOS.Get(EFTTransactionRequest."Register No.", EFTTransactionRequest."Sales Ticket No.");
        if MMMembershipMgtInternal.CheckMembershipAutoRenewStatusYesInternal(SalePOS."Customer No.") then
            EFTAdyenConfInputReq.SetTextQst(AutoRenewYesInternalConfirmationDialogTextLbl)
        else
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
        TempRenewalPrice: Decimal;
    begin
        MemberInfoCapture.Reset();
        MemberInfoCapture.SetCurrentKey("Receipt No.", "Line No.");
        MemberInfoCapture.SetRange("Receipt No.", EFTTransactionRequest."Sales Ticket No.");
        if not MemberInfoCapture.FindSet() then
            // If we were asked to start a subscription, but don't have any member info capture,
            // it's likely somebody starting subscription on an existing membership.
            exit(CalcSubscriptionRenewalPriceOnSubsStart(EFTTransactionRequest."Sales ID"));

        repeat
            if (CalcSubscriptionRenewalPrice(MemberInfoCapture, TempRenewalPrice)) then begin
                SubscriptionAmountIncludingVAT += TempRenewalPrice;
            end else begin
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
            end;
        until MemberInfoCapture.Next() = 0;
    end;

    local procedure CalcSubscriptionRenewalPriceOnSubsStart(SaleId: Guid): Decimal
    var
        POSSale: Record "NPR POS Sale";
        Membership: Record "NPR MM Membership";
        MembershipEntry: Record "NPR MM Membership Entry";
        MembershipAlterationSetup: Record "NPR MM Members. Alter. Setup";
        MembershipMgt: Codeunit "NPR MM MembershipMgtInternal";
        RenewWithItemNo: Code[20];
        AlterationSystemId: Guid;
        ReasonText: Text;
    begin
        POSSale.SetLoadFields("Customer No.");
        if (not POSSale.GetBySystemId(SaleId)) then
            exit;
        if (POSSale."Customer No." = '') then
            exit;

        Membership.SetLoadFields("Entry No.", "External Membership No.");
        Membership.SetCurrentKey("Customer No.");
        Membership.SetRange("Customer No.", POSSale."Customer No.");
        if (not Membership.FindFirst()) then
            exit;

        MembershipEntry.SetRange("Membership Entry No.", Membership."Entry No.");
        MembershipEntry.SetRange(Blocked, false);
        MembershipEntry.SetFilter(Context, '<>%1', MembershipEntry.Context::REGRET);
        if (not MembershipEntry.FindLast()) then
            exit;

        if (not MembershipMgt.SelectAutoRenewRule(MembershipEntry, RenewWithItemNo, AlterationSystemId, ReasonText)) then
            exit;

        if (not MembershipAlterationSetup.GetBySystemId(AlterationSystemId)) then
            exit;

        exit(CalculateAutoRenewPrice(Membership."Entry No.", Membership."External Membership No.", MembershipAlterationSetup, MembershipEntry));
    end;

    local procedure CalcSubscriptionRenewalPrice(MemberInfoCapture: Record "NPR MM Member Info Capture"; var RenewalPrice: Decimal): Boolean
    var
        TempMembershipEntry: Record "NPR MM Membership Entry" temporary;
        MembershipAlterationSetup: Record "NPR MM Members. Alter. Setup";
        MembershipMgt: Codeunit "NPR MM MembershipMgtInternal";
        RenewWithItemNo: Code[20];
        AlterationSystemId: Guid;
        ReasonText: Text;
        OutStartDate, OutEndDate : Date;
        TempPrice: Decimal;
    begin
        TempMembershipEntry.Init();

        TempMembershipEntry."Membership Entry No." := MemberInfoCapture."Membership Entry No.";
        TempMembershipEntry."Membership Code" := MemberInfoCapture."Membership Code";
        TempMembershipEntry."Item No." := MemberInfoCapture."Item No.";

        case MemberInfoCapture."Information Context" of
            MemberInfoCapture."Information Context"::NEW:
                begin
                    TempMembershipEntry.Context := TempMembershipEntry.Context::NEW;
                    TempMembershipEntry."Valid Until Date" := MemberInfoCapture."Valid Until";
                end;
            MemberInfoCapture."Information Context"::UPGRADE:
                begin
                    if (not MembershipMgt.UpgradeMembership(MemberInfoCapture, false, false, OutStartDate, OutEndDate, TempPrice)) then
                        exit(false);

                    TempMembershipEntry.Context := TempMembershipEntry.Context::UPGRADE;
                    TempMembershipEntry."Valid From Date" := OutStartDate;
                    TempMembershipEntry."Valid Until Date" := OutEndDate;
                end;
            MemberInfoCapture."Information Context"::RENEW:
                begin
                    if (not MembershipMgt.RenewMembership(MemberInfoCapture, false, false, OutStartDate, OutEndDate, TempPrice)) then
                        exit(false);

                    TempMembershipEntry.Context := TempMembershipEntry.Context::RENEW;
                    TempMembershipEntry."Valid From Date" := OutStartDate;
                    TempMembershipEntry."Valid Until Date" := OutEndDate;
                end;
            MemberInfoCapture."Information Context"::EXTEND:
                begin
                    if (not MembershipMgt.ExtendMembership(MemberInfoCapture, false, false, OutStartDate, OutEndDate, TempPrice)) then
                        exit(false);

                    TempMembershipEntry.Context := TempMembershipEntry.Context::EXTEND;
                    TempMembershipEntry."Valid From Date" := OutStartDate;
                    TempMembershipEntry."Valid Until Date" := OutEndDate;
                end;
            else
                exit(false);
        end;

        if (not MembershipMgt.SelectAutoRenewRule(TempMembershipEntry, RenewWithItemNo, AlterationSystemId, ReasonText)) then
            exit(false);

        if (not MembershipAlterationSetup.GetBySystemId(AlterationSystemId)) then
            exit(false);

        RenewalPrice := CalculateAutoRenewPrice(MemberInfoCapture."Membership Entry No.", MemberInfoCapture."External Membership No.", MembershipAlterationSetup, TempMembershipEntry);
        exit(true);
    end;

    local procedure CalculateAutoRenewPrice(MembershipEntryNo: Integer; ExternalMembershipNo: Code[20]; MembershipAlterationSetup: Record "NPR MM Members. Alter. Setup"; MembershipEntry: Record "NPR MM Membership Entry") RenewalPrice: Decimal
    var
        MembershipMgt: Codeunit "NPR MM MembershipMgtInternal";
        TempAutoRenewInfoCapture: Record "NPR MM Member Info Capture" temporary;
    begin
        TempAutoRenewInfoCapture.Init();
        TempAutoRenewInfoCapture."Entry No." := 0;

        TempAutoRenewInfoCapture."Membership Entry No." := MembershipEntryNo;
        TempAutoRenewInfoCapture."Membership Code" := MembershipAlterationSetup."From Membership Code";
        TempAutoRenewInfoCapture."External Membership No." := ExternalMembershipNo;
        if (MembershipAlterationSetup."From Membership Code" = MembershipAlterationSetup."To Membership Code") and (MembershipAlterationSetup."Auto-Renew To" <> '') then
            TempAutoRenewInfoCapture."Item No." := MembershipAlterationSetup."Auto-Renew To" // if we are activating subscription on existing membership
        else
            TempAutoRenewInfoCapture."Item No." := MembershipAlterationSetup."Sales Item No.";
        TempAutoRenewInfoCapture."Information Context" := TempAutoRenewInfoCapture."Information Context"::AUTORENEW;
        TempAutoRenewInfoCapture."Document Date" := Today(); // Active
        TempAutoRenewInfoCapture.Description := MembershipAlterationSetup.Description;

        RenewalPrice := MembershipMgt.CalculateAutoRenewPrice(TempAutoRenewInfoCapture."Membership Entry No.", MembershipAlterationSetup, TempAutoRenewInfoCapture, MembershipEntry);
    end;
}