codeunit 6184653 "NPR MM Loy. Assignment On Sale"
{
    TableNo = "NPR POS Sale";

    trigger OnRun()
    var
        MMLoyaltyPointMgt: Codeunit "NPR MM Loyalty Point Mgt.";
    begin
        MMLoyaltyPointMgt.LoyPointAssignmentOnSale(Rec);
    end;
}