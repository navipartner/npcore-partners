report 6060129 "NPR MM Membersh. Points Summ."
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/MM Membership Points Summary.rdlc';
    Caption = 'Membership Points Summary';
    PreviewMode = PrintLayout;
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = NPRRetail;
    DataAccessIntent = ReadOnly;

    dataset
    {
        dataitem("MM Membership"; "NPR MM Membership")
        {
            column(MembershipCode_MMMembership; "Membership Code")
            {
                IncludeCaption = true;
            }
            column(CustomerNo_MMMembership; "Customer No.")
            {
                IncludeCaption = true;
            }
            column(Name_Customer; Customer.Name)
            {
            }
            column(Name_CustomerCaption; CustomerNameCaption)
            {
            }
            column(AwardedPointsSale_MMMembership; "Awarded Points (Sale)")
            {
                IncludeCaption = true;
            }
            column(AwardedPointsRefund_MMMembership; "Awarded Points (Refund)")
            {
                IncludeCaption = true;
            }
            column(RedeemedPointsWithdrawl_MMMembership; "Redeemed Points (Withdrawl)")
            {
                IncludeCaption = true;
            }
            column(RedeemedPointsDeposit_MMMembership; "Redeemed Points (Deposit)")
            {
                IncludeCaption = true;
            }
            column(ExpiredPoints_MMMembership; "Expired Points")
            {
                IncludeCaption = true;
            }
            column(RemainingPoints_MMMembership; "Remaining Points")
            {
                IncludeCaption = true;
            }
            column(PageCaption; PageCaption)
            {
            }
            column(GetFilters; GetFilters)
            {
            }
            column(ExtMembershipNo_MMMembership; "External Membership No.")
            {
            }
            column(MembershipNoCaption; MembershipNoCaption)
            {
            }

            trigger OnAfterGetRecord()
            begin
                CalcFields("Awarded Points (Sale)", "Awarded Points (Refund)", "Redeemed Points (Withdrawl)", "Redeemed Points (Deposit)", "Expired Points", "Remaining Points");
                Clear(CustomerName);
                if Customer.Get("Customer No.") then
                    CustomerName := Customer.Name;
            end;
        }
    }

    requestpage
    {
        SaveValues = true;
        trigger OnOpenPage()
        begin
            "MM Membership".SetFilter("Date Filter", '..%2', ToDate);
        end;
    }

    labels
    {
        ReportLbl = 'Membership Points Summary';
    }

    var
        Customer: Record Customer;
        ToDate: Date;
        CustomerNameCaption: Label 'Customer Name';
        MembershipNoCaption: Label 'Membership';
        PageCaption: Label 'Page %1 of %2';
        CustomerName: Text;
}

