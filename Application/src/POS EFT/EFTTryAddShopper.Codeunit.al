codeunit 6184508 "NPR EFT Try Add Shopper"
{
    // NPR5.49/MMV /20190401 CASE 345188 Created object

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

        case "Entity Type" of
            "Entity Type"::Contact:
                SalePOS.Validate("Customer Type", SalePOS."Customer Type"::Cash);
            "Entity Type"::Customer:
                SalePOS.Validate("Customer Type", SalePOS."Customer Type"::Ord);
        end;
        SalePOS.Validate("Customer No.", "Entity Key");

        SalePOS.Modify(true);
        POSSale.Refresh(SalePOS);
    end;
}

