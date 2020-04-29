codeunit 6184508 "EFT Try Add Shopper"
{
    // NPR5.49/MMV /20190401 CASE 345188 Created object

    TableNo = "EFT Shopper Recognition";

    trigger OnRun()
    var
        POSSession: Codeunit "POS Session";
        POSSale: Codeunit "POS Sale";
        SalePOS: Record "Sale POS";
    begin
        POSSession.GetSession(POSSession, true);
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        case "Entity Type" of
          "Entity Type"::Contact : SalePOS.Validate("Customer Type", SalePOS."Customer Type"::Cash);
          "Entity Type"::Customer : SalePOS.Validate("Customer Type", SalePOS."Customer Type"::Ord);
        end;
        SalePOS.Validate("Customer No.", "Entity Key");

        SalePOS.Modify(true);
        POSSale.Refresh(SalePOS);
    end;
}

