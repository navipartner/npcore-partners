report 6060129 "MM Membership Points Summary"
{
    // MM1.17/JLK /20170123  CASE 243075 Object created
    DefaultLayout = RDLC;
    RDLCLayout = './layouts/MM Membership Points Summary.rdlc';

    Caption = 'Membership Points Summary';
    PreviewMode = PrintLayout;

    dataset
    {
        dataitem("MM Membership";"MM Membership")
        {
            column(MembershipCode_MMMembership;"Membership Code")
            {
                IncludeCaption = true;
            }
            column(CustomerNo_MMMembership;"Customer No.")
            {
                IncludeCaption = true;
            }
            column(Name_Customer;Customer.Name)
            {
            }
            column(Name_CustomerCaption;CustomerNameCaption)
            {
            }
            column(AwardedPointsSale_MMMembership;"Awarded Points (Sale)")
            {
                IncludeCaption = true;
            }
            column(AwardedPointsRefund_MMMembership;"Awarded Points (Refund)")
            {
                IncludeCaption = true;
            }
            column(RedeemedPointsWithdrawl_MMMembership;"Redeemed Points (Withdrawl)")
            {
                IncludeCaption = true;
            }
            column(RedeemedPointsDeposit_MMMembership;"Redeemed Points (Deposit)")
            {
                IncludeCaption = true;
            }
            column(ExpiredPoints_MMMembership;"Expired Points")
            {
                IncludeCaption = true;
            }
            column(RemainingPoints_MMMembership;"Remaining Points")
            {
                IncludeCaption = true;
            }
            column(PageCaption;PageCaption)
            {
            }
            column(GetFilters;GetFilters)
            {
            }
            column(ExtMembershipNo_MMMembership;"External Membership No.")
            {
            }
            column(MembershipNoCaption;MembershipNoCaption)
            {
            }

            trigger OnAfterGetRecord()
            begin

                CalcFields("Awarded Points (Sale)","Awarded Points (Refund)","Redeemed Points (Withdrawl)","Redeemed Points (Deposit)","Expired Points","Remaining Points");

                Clear(CustomerName);
                if Customer.Get("Customer No.") then
                  CustomerName := Customer.Name;
            end;
        }
    }

    requestpage
    {

        layout
        {
        }

        actions
        {
        }

        trigger OnOpenPage()
        begin
            "MM Membership".SetFilter("Date Filter",'..%2',ToDate);
        end;
    }

    labels
    {
        ReportLbl = 'Membership Points Summary';
    }

    var
        Customer: Record Customer;
        CustomerName: Text;
        ToDate: Date;
        PageCaption: Label 'Page %1 of %2';
        MembershipNoCaption: Label 'Membership';
        CustomerNameCaption: Label 'Customer Name';
}

