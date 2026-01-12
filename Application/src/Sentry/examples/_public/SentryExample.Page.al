page 6185086 "NPR Sentry Example"
{
    PageType = Card;
    ApplicationArea = NPRRetail;
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            group(GroupName)
            {
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ActionName)
            {
                ApplicationArea = NPRRetail;
                Caption = 'Sentry Example Action';
                ToolTip = 'Run Sentry example action';
                Image = Action;

                trigger OnAction()
                var
                    Sentry: Codeunit "NPR Sentry";

                begin
                    Sentry.InitScopeAndTransaction('Example Page ActionName', 'ui.bc.page.action:action_name');

                    DoSomeWork();

                    Sentry.FinalizeScope();
                end;
            }

            action(ActionName2)
            {
                ApplicationArea = NPRRetail;
                Caption = 'Sentry Error Example';
                ToolTip = 'Run Sentry Error Example';
                Image = Absence;

                trigger OnAction()
                var
                    Sentry: Codeunit "NPR Sentry";
                    SentrySpan: Codeunit "NPR Sentry Span";
                begin
                    Sentry.InitScopeAndTransaction('Sentry Error Example', 'ui.bc.page.action:error_example');

                    Sentry.StartSpan(SentrySpan, 'bc.error_example');
                    if not TryDivideByZero() then
                        Sentry.AddLastErrorInEnglish();
                    SentrySpan.Finish();

                    Sentry.FinalizeScope();
                end;
            }
        }
    }


    local procedure DoSomeWork()
    var
        Sentry: Codeunit "NPR Sentry";
        POSEntry: Record "NPR POS Entry";
        SentrySessionRecExample: Record "NPR Sentry Session Rec Example";
        SessionId: Integer;
        TaskId: Integer;
        Parameters: Dictionary of [Text, Text];
    begin
        POSEntry.SetRange("Post Entry Status", POSEntry."Post Entry Status"::Unposted);
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
        POSEntry.ReadIsolation := IsolationLevel::UpdLock;
#endif
        if Sentry.FindSet(POSEntry, true, true) then begin
            // do something with the records
        end;

        SentrySessionRecExample.Init();
        SentrySessionRecExample.MyField := Random(100000);
        SentrySessionRecExample."Sentry Parent Trace Id" := CopyStr(Sentry.GetCurrentTraceId(), 1, 100);
        SentrySessionRecExample."Sentry Parent Span Id" := CopyStr(Sentry.GetCurrentSpanId(), 1, 100);
        SentrySessionRecExample."Sentry Parent Sampled" := Sentry.IsCurrentTransactionSampled();
        SentrySessionRecExample.Insert();
        Commit();

        TaskScheduler.CreateTask(Codeunit::"NPR Sentry Session Example", 0, true, CompanyName(), CurrentDateTime(), SentrySessionRecExample.RecordId);

        StartSession(SessionId, Codeunit::"NPR Sentry Session Example", CompanyName(), SentrySessionRecExample);

        Parameters.Add('SentrySessionExampleSystemId', SentrySessionRecExample.SystemId);
        CurrPage.EnqueueBackgroundTask(TaskId, Codeunit::"NPR Sentry Session Example", Parameters);
    end;

    [TryFunction]
    local procedure TryDivideByZero()
    var
        x: Integer;
        y: Integer;
    begin
        x := 1;
        y := 0;
        x := x div y; // This will cause a DivideByZero error
    end;
}
