codeunit 6014668 "NPR EFT Rec. Match/Score Mgt."
{

    trigger OnRun()
    begin
    end;

    var
        MatchSetupDescriptionTxt: label 'Processes enabled Matching Setups for Provider';
        NoMatchingSetupErr: label 'No valid Lines found on %1 %2 %3.';


    procedure TestFilterLine(var EFTReconMatchScoreLine: Record "NPR EFT Rec. Match/Score Line")
    var
        TempEFTTransactionRequest: Record "NPR EFT Transaction Request" temporary;
        TempEFTReconLine: Record "NPR EFT Recon. Line" temporary;
    begin
        if EFTReconMatchScoreLine.LineType <> EFTReconMatchScoreLine.Linetype::Filter then
            exit;
        TempEFTReconLine.Init();
        TempEFTReconLine."Transaction Date" := Today;
        ApplyFilter(TempEFTTransactionRequest, TempEFTReconLine, EFTReconMatchScoreLine);
    end;


    procedure FindBestScore(EFTReconciliation: Record "NPR EFT Reconciliation"; EFTReconLine: Record "NPR EFT Recon. Line"; TransactionDatefilter: Text; var TempEFTTransactionRequest: Record "NPR EFT Transaction Request" temporary)
    var
        EFTReconMatchScore: Record "NPR EFT Recon. Match/Score";
        AddScoreLine: Record "NPR EFT Rec. Match/Score Line";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        TempEFTTransactionRequest.DeleteAll();
        EFTReconMatchScore.SetRange(Type, EFTReconMatchScore.Type::Score);
        EFTReconMatchScore.SetRange("Provider Code", EFTReconciliation."Provider Code");
        EFTReconMatchScore.SetRange(Enabled, true);
        if not EFTReconMatchScore.FindSet() then
            exit;
        repeat
            EFTTransactionRequest.Reset();
            if TransactionDatefilter <> '' then
                EFTTransactionRequest.SetFilter("Transaction Date", TransactionDatefilter);
            EFTTransactionRequest.SetRange("Matched in Reconciliation", false);
            ApplyFilters(EFTTransactionRequest, EFTReconLine, EFTReconMatchScore);
            if EFTTransactionRequest.FindSet() then
                repeat
                    AddToScore(TempEFTTransactionRequest, EFTTransactionRequest, EFTReconMatchScore.Score);
                    AddScoreLine.SetRange(Type, EFTReconMatchScore.Type);
                    AddScoreLine.SetRange("Provider Code", EFTReconMatchScore."Provider Code");
                    AddScoreLine.SetRange(ID, EFTReconMatchScore.ID);
                    AddScoreLine.SetRange(LineType, AddScoreLine.Linetype::AdditionalScore);
                    if AddScoreLine.FindSet() then
                        repeat
                            if FitsAdditionalScoreFilter(EFTTransactionRequest, EFTReconLine, AddScoreLine) then
                                AddToScore(TempEFTTransactionRequest, EFTTransactionRequest, AddScoreLine."Additional Score");
                        until AddScoreLine.Next() = 0;
                until EFTTransactionRequest.Next() = 0;
        until EFTReconMatchScore.Next() = 0;
    end;

    local procedure AddToScore(var TempEFTTransactionRequest: Record "NPR EFT Transaction Request" temporary; EFTTransactionRequest: Record "NPR EFT Transaction Request"; Score: Decimal)
    begin
        if not TempEFTTransactionRequest.Get(EFTTransactionRequest."Entry No.") then begin
            TempEFTTransactionRequest := EFTTransactionRequest;
            TempEFTTransactionRequest."DCC Amount" := 0;
            TempEFTTransactionRequest.Insert(false);
        end;
        TempEFTTransactionRequest."DCC Amount" += Score;
        TempEFTTransactionRequest.Modify(false);
    end;

    local procedure FitsAdditionalScoreFilter(EFTTransactionRequest: Record "NPR EFT Transaction Request"; EFTReconLine: Record "NPR EFT Recon. Line"; EFTReconMatchScoreLine: Record "NPR EFT Rec. Match/Score Line"): Boolean
    begin
        EFTTransactionRequest.FilterGroup(50);
        EFTTransactionRequest.SetRecfilter();
        EFTTransactionRequest.FilterGroup(51);
        ApplyFilter(EFTTransactionRequest, EFTReconLine, EFTReconMatchScoreLine);
        exit(not EFTTransactionRequest.IsEmpty);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Reconciliation Mgt.", 'OnMatchReconciliation', '', false, false)]
    local procedure HandleMatchSetup(var EFTReconciliation: Record "NPR EFT Reconciliation"; EFTReconSubscriber: Record "NPR EFT Recon. Subscriber")
    var
        EFTReconMatchScore: Record "NPR EFT Recon. Match/Score";
    begin
        if not ((EFTReconSubscriber."Subscriber Codeunit ID" = Codeunit::"NPR EFT Rec. Match/Score Mgt.") and (EFTReconSubscriber."Subscriber Function" = 'HandleMatchSetup')) then
            exit;
        EFTReconciliation.CheckUnpostedStatus();

        EFTReconMatchScore.SetRange(Type, EFTReconMatchScore.Type::Match);
        EFTReconMatchScore.SetRange("Provider Code", EFTReconciliation."Provider Code");
        EFTReconMatchScore.SetRange(Enabled, true);
        EFTReconMatchScore.SetCurrentkey(Type, "Provider Code", Enabled, "Sequence No.");
        if EFTReconMatchScore.FindSet() then
            repeat
                ProcessMatch(EFTReconciliation, EFTReconMatchScore);
            until EFTReconMatchScore.Next() = 0;
    end;

    local procedure ProcessMatch(EFTReconciliation: Record "NPR EFT Reconciliation"; EFTReconMatchScore: Record "NPR EFT Recon. Match/Score")
    var
        EFTReconLine: Record "NPR EFT Recon. Line";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        NoOfRecords: Integer;
        Counter: Integer;
        UpdateStep: Integer;
        Window: Dialog;
    begin
        EFTReconLine.SetRange("Reconciliation No.", EFTReconciliation."No.");
        EFTReconLine.SetRange("Applied Entry No.", 0);
        if EFTReconLine.FindSet() then begin
            if GuiAllowed then begin
                NoOfRecords := EFTReconLine.Count;
                UpdateStep := ROUND(NoOfRecords / 100, 1, '<');
                if UpdateStep < 1 then
                    UpdateStep := 1;
                Window.Open(EFTReconMatchScore.Description + '\@1@@@@@@@@@@');
            end;
            repeat
                Counter += 1;
                if GuiAllowed then
                    if (Counter MOD UpdateStep) = 0 then
                        Window.Update(1, ROUND(Counter / NoOfRecords * 10000, 1));
                EFTTransactionRequest.SetRange("Matched in Reconciliation", false);
                ApplyFilters(EFTTransactionRequest, EFTReconLine, EFTReconMatchScore);
                if EFTTransactionRequest.FindFirst() then
                    EFTReconLine.ApplyTransaction(EFTTransactionRequest);
            until EFTReconLine.Next() = 0;
        end;
    end;

    local procedure ApplyFilters(var EFTTransactionRequest: Record "NPR EFT Transaction Request"; EFTReconLine: Record "NPR EFT Recon. Line"; EFTReconMatchScore: Record "NPR EFT Recon. Match/Score")
    var
        EFTReconMatchScoreLine: Record "NPR EFT Rec. Match/Score Line";
        FilterApplied: Boolean;
    begin
        EFTReconMatchScoreLine.SetRange(Type, EFTReconMatchScore.Type);
        EFTReconMatchScoreLine.SetRange("Provider Code", EFTReconMatchScore."Provider Code");
        EFTReconMatchScoreLine.SetRange(ID, EFTReconMatchScore.ID);
        EFTReconMatchScoreLine.SetRange(LineType, EFTReconMatchScoreLine.Linetype::Filter);
        if EFTReconMatchScoreLine.FindSet() then
            repeat
                FilterApplied := FilterApplied or ApplyFilter(EFTTransactionRequest, EFTReconLine, EFTReconMatchScoreLine);
            until EFTReconMatchScoreLine.Next() = 0;
        if not FilterApplied then
            Error(NoMatchingSetupErr, EFTReconMatchScore.TableCaption, EFTReconMatchScore.Type, EFTReconMatchScore."Provider Code");
    end;

    local procedure ApplyFilter(var EFTTransactionRequest: Record "NPR EFT Transaction Request"; EFTReconLine: Record "NPR EFT Recon. Line"; EFTReconMatchScoreLine: Record "NPR EFT Rec. Match/Score Line"): Boolean
    var
        TransRecRef: RecordRef;
        TransFldRef: FieldRef;
        LineRecRef: RecordRef;
        LineFldRef: FieldRef;
        FilterString: Text;
        FilterApplied: Boolean;
    begin
        OnApplyMatchingFilter(EFTTransactionRequest, EFTReconLine, EFTReconMatchScoreLine, FilterApplied);
        if FilterApplied then
            exit(true);

        if EFTReconMatchScoreLine."Transaction Field No." = 0 then
            exit(false);
        TransRecRef.GetTable(EFTTransactionRequest);
        TransFldRef := TransRecRef.Field(EFTReconMatchScoreLine."Transaction Field No.");
        case EFTReconMatchScoreLine."Filter Type" of
            EFTReconMatchScoreLine."filter type"::Field:
                begin
                    if EFTReconMatchScoreLine."Field No." = 0 then
                        exit(false);
                    LineRecRef.GetTable(EFTReconLine);
                    LineFldRef := LineRecRef.Field(EFTReconMatchScoreLine."Field No.");
                    TransFldRef.SetRange(LineFldRef.Value);
                end;
            EFTReconMatchScoreLine."filter type"::Const:
                begin
                    if EFTReconMatchScoreLine."Filter Value" = '' then
                        exit(false);
                    TransFldRef.SetRange(EFTReconMatchScoreLine."Filter Value");
                end;
            EFTReconMatchScoreLine."filter type"::Filter:
                begin
                    if (StrPos(EFTReconMatchScoreLine."Filter Value", '%1') > 0) and (EFTReconMatchScoreLine."Field No." > 0) then begin
                        LineRecRef.GetTable(EFTReconLine);
                        LineFldRef := LineRecRef.Field(EFTReconMatchScoreLine."Field No.");
                        FilterString := StrSubstNo(EFTReconMatchScoreLine."Filter Value", LineFldRef.Value);
                    end else
                        FilterString := EFTReconMatchScoreLine."Filter Value";
                    TransFldRef.SetFilter(FilterString);
                end;
        end;
        TransRecRef.SetTable(EFTTransactionRequest);
        exit(true);
    end;


    procedure CopyLines(var EFTReconMatchScore: Record "NPR EFT Recon. Match/Score")
    var
        CopyFromHeader: Record "NPR EFT Recon. Match/Score";
        EFTReconMatchScoreLine: Record "NPR EFT Rec. Match/Score Line";
        CopyFromLine: Record "NPR EFT Rec. Match/Score Line";
    begin
        CopyFromHeader.SetRange(Type, EFTReconMatchScore.Type);
        if Page.RunModal(0, CopyFromHeader) = Action::LookupOK then begin
            CopyFromLine.SetRange(Type, CopyFromHeader.Type);
            CopyFromLine.SetRange("Provider Code", CopyFromHeader."Provider Code");
            CopyFromLine.SetRange(ID, CopyFromHeader.ID);
            if CopyFromLine.FindSet() then begin
                EFTReconMatchScoreLine.SetRange(Type, EFTReconMatchScore.Type);
                EFTReconMatchScoreLine.SetRange("Provider Code", EFTReconMatchScore."Provider Code");
                EFTReconMatchScoreLine.SetRange(ID, EFTReconMatchScore.ID);
                EFTReconMatchScoreLine.DeleteAll(true);
                repeat
                    EFTReconMatchScoreLine := CopyFromLine;
                    EFTReconMatchScoreLine."Provider Code" := EFTReconMatchScore."Provider Code";
                    EFTReconMatchScoreLine.ID := EFTReconMatchScore.ID;
                    EFTReconMatchScoreLine.Insert(true);
                until CopyFromLine.Next() = 0;
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR EFT Recon. Subscriber", 'UpdateDescription', '', false, false)]
    local procedure OnUpdateDescription(var Sender: Record "NPR EFT Recon. Subscriber")
    begin
        if Sender."Subscriber Codeunit ID" <> Codeunit::"NPR EFT Rec. Match/Score Mgt." then
            exit;
        case Sender."Subscriber Function" of
            'HandleMatchSetup':
                Sender.Description := MatchSetupDescriptionTxt;
            'Match2':
                Sender.Description := 'Match 2';
            'Match3':
                Sender.Description := 'Match 3';
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnApplyMatchingFilter(var EFTTransactionRequest: Record "NPR EFT Transaction Request"; EFTReconLine: Record "NPR EFT Recon. Line"; EFTReconMatchLine: Record "NPR EFT Rec. Match/Score Line"; var FilterApplied: Boolean)
    begin
    end;
}

