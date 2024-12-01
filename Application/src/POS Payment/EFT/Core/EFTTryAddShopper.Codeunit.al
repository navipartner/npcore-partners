codeunit 6184508 "NPR EFT Try Add Shopper"
{
    Access = Internal;
    TableNo = "NPR EFT Shopper Recognition";

    trigger OnRun()
    var
        POSSession: Codeunit "NPR POS Session";
        POSSale: Codeunit "NPR POS Sale";
        MembershipMgtInternal: Codeunit "NPR MM MembershipMgtInternal";
        SalePOS: Record "NPR POS Sale";
        MembershipEntryNo: Integer;
        CustomerNo: Code[20];
    begin
        POSSession.GetSession(POSSession, true);
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        case Rec."Entity Type" of
            Rec."Entity Type"::Customer:
                SalePOS.Validate("Customer No.", Rec."Entity Key");
            Rec."Entity Type"::Membership:
                begin
                    Evaluate(MembershipEntryNo, Rec."Entity Key");
                    CustomerNo := MembershipMgtInternal.GetCustomerNoFromMembershipEntryNo(MembershipEntryNo);
                    SalePOS.Validate("Customer No.", CustomerNo);
                end;
        end;
        SalePOS.Modify(true);
        POSSale.Refresh(SalePOS);
    end;
}

