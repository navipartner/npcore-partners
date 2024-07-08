codeunit 6184656 "NPR MM Member Print On Sale"
{
    TableNo = "NPR POS Sale";

    trigger OnRun()
    var
        MMMemberRetailIntegr: Codeunit "NPR MM Member Retail Integr.";
    begin
        MMMemberRetailIntegr.PrintMemberships(Rec);
    end;
}