codeunit 6184508 "NPR EFT Try Add Shopper"
{
    Access = Internal;
    TableNo = "NPR EFT Shopper Recognition";

    trigger OnRun()
    var
        POSSession: Codeunit "NPR POS Session";
        POSSale: Codeunit "NPR POS Sale";
        SalePOS: Record "NPR POS Sale";
    begin
        POSSession.GetSession(POSSession, true);
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        case Rec."Entity Type" of
            Rec."Entity Type"::Contact:
                SalePOS.Validate("Customer Type", SalePOS."Customer Type"::Cash);
            Rec."Entity Type"::Customer:
                SalePOS.Validate("Customer Type", SalePOS."Customer Type"::Ord);
        end;
        SalePOS.Validate("Customer No.", Rec."Entity Key");

        SalePOS.Modify(true);
        POSSale.Refresh(SalePOS);
    end;
}

