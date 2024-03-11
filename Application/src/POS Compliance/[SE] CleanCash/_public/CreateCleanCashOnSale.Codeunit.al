codeunit 6184648 "NPR Create Clean Cash On Sale"
{
    TableNo = "NPR POS Sale";

    trigger OnRun()
    var
        CleanCashWrapper: Codeunit "NPR CleanCash Wrapper";
    begin
        CleanCashWrapper.CreateCleanCashOnPOSSale(Rec);
    end;
}