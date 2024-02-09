page 6151540 "NPR TM DeferredCuePart"
{
    Extensible = False;
    Caption = 'Ticket Defer Revenue Insight';
    PageType = CardPart;
    RefreshOnActivate = true;
    SourceTable = "NPR TM DeferralCue";
    UsageCategory = None;
    layout
    {
        area(content)
        {
            CueGroup(TicketRevenue)
            {
                Caption = 'Deferral Status';
                field(UnresolvedCount; AsInteger(Format(Rec.FieldNo(UnresolvedCount))))
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Number of tickets that have exceeded its check for the related posted document.';
                    Caption = 'Failed Deferral Count';
                    AutoFormatType = 11;
                    AutoFormatExpression = '<Precision,0:0><Standard Format,0>';

                    trigger OnDrillDown()
                    var
                        TicketDeferralList: Page "NPR TM RevenueRecognition";
                        DeferredRevenue: Record "NPR TM DeferRevenueRequest";
                    begin
                        DeferredRevenue.SetFilter(Status, '=%1', DeferredRevenue.Status::UNRESOLVED);
                        TicketDeferralList.SetTableView(DeferredRevenue);
                        TicketDeferralList.Run();
                    end;
                }

                field(PendingDeferralCount; AsInteger(Format(Rec.FieldNo(PendingDeferralCount))))
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Number of tickets that are pending deferral (Registered, Waiting, Pending Deferral).';
                    Caption = 'Pending Deferral Count';
                    AutoFormatType = 11;
                    AutoFormatExpression = '<Precision,0:0><Standard Format,0>';

                    trigger OnDrillDown()
                    var
                        TicketDeferralList: Page "NPR TM RevenueRecognition";
                        DeferredRevenue: Record "NPR TM DeferRevenueRequest";
                    begin
                        DeferredRevenue.SetFilter(Status, '=%1|=%2|=%3', DeferredRevenue.Status::WAITING, DeferredRevenue.Status::REGISTERED, DeferredRevenue.Status::PENDING_DEFERRAL);
                        TicketDeferralList.SetTableView(DeferredRevenue);
                        TicketDeferralList.Run();
                    end;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.Insert();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        CurrPage.EnqueueBackgroundTask(_TaskId, Codeunit::"NPR TM DeferCueTaskWorker");
    end;

    trigger OnPageBackgroundTaskCompleted(TaskId: Integer; Results: Dictionary of [Text, Text])
    var
        ResultSetKey: Text;
    begin
        if (not (TaskId = _TaskId)) then
            exit;

        Clear(_TaskResults);
        foreach ResultSetKey in Results.Keys() do
            _TaskResults.Add(ResultSetKey, Results.Get(ResultSetKey));

    end;

    trigger OnPageBackgroundTaskError(TaskId: Integer; ErrorCode: Text; ErrorText: Text; ErrorCallStack: Text; var IsHandled: Boolean)
    var
        TaskError: Label 'Page %1: background task ended with an error.\Error code: %2.\Error: %3', Comment = '%1 = called from page caption, %2 = error code, %3 = error text';
    begin
        if (TaskId = _TaskId) then
            Error(TaskError, CurrPage.Caption(), ErrorCode, ErrorText);
    end;

    local procedure AsInteger(FieldNo: Text) Integer: Decimal
    begin
        if (_TaskResults.ContainsKey(FieldNo)) then
            if (not Evaluate(Integer, _TaskResults.Get(FieldNo), 9)) then
                Integer := 0;
    end;

    var
        _TaskResults: Dictionary of [Text, Text];
        _TaskId: Integer;


}