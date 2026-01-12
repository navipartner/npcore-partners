codeunit 6248502 "NPR Sentry Session Example"
{

    TableNo = "NPR Sentry Session Rec Example";

    trigger OnRun()
    var
        Sentry: Codeunit "NPR Sentry";
        Span: Codeunit "NPR Sentry Span";
    begin
        if IsNullGuid(Rec.SystemId) then begin
            Rec.GetBySystemId(Page.GetBackgroundParameters().Get('SentrySessionExampleSystemId'));
        end;

        Sentry.InitScopeAndTransaction('BC Background Session Example',
                                       'background_session.bc:sentry_example',
                                       Rec."Sentry Parent Trace Id",
                                       Rec."Sentry Parent Span Id",
                                       Rec."Sentry Parent Sampled");

        Sentry.StartSpan(Span, 'Custom span with a sleep');
        Sleep(5000);
        Span.Finish();

        Sentry.FinalizeScope();
    end;
}
