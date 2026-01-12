codeunit 6184509 "NPR EFT Try Print Receipt"
{
    Access = Internal;
    TableNo = "NPR EFT Transaction Request";

    trigger OnRun()
    var
        Sentry: Codeunit "NPR Sentry";
        Span: Codeunit "NPR Sentry Span";
    begin
        Sentry.StartSpan(Span, 'bc.pos.eft.print');
        Rec.PrintReceipts(false);
        Span.Finish();
    end;
}

