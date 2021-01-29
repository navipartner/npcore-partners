report 6060131 "NPR MM Membership Points Det."
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/MM Membership Points Detail.rdlc';
    Caption = 'Membership Points Detail';
    PreviewMode = PrintLayout;
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    dataset
    {
        dataitem("MM Membership"; "NPR MM Membership")
        {
            column(GetFilters; GetFilters)
            {
            }
            column(EntryNo_MMMembership; "Entry No.")
            {
            }
            column(CustomerNo_MMMembership; "Customer No.")
            {
                IncludeCaption = true;
            }
            column(MembershipCode_MMMembership; "Membership Code")
            {
            }
            column(PageCaption; PageCaption)
            {
            }
            column(BalanceBefore; BalanceBefore)
            {
            }
            column(Name_Customer; CustomerName)
            {
            }
            column(Name_CustomerCaption; CustomerNameCaption)
            {
            }
            column(ExtMembershipNo; "External Membership No.")
            {
            }
            column(MembershipNoCaption; MembershipNoCaption)
            {
            }
            column(BalanceBeforeCaption; BalanceBeforeCaption)
            {
            }
            column(BalanceAfterCaption; BalanceAfterCaption)
            {
            }
            dataitem("MM Membership Points Entry"; "NPR MM Members. Points Entry")
            {
                DataItemLink = "Membership Entry No." = FIELD("Entry No."), "Posting Date" = FIELD("Date Filter");
                DataItemTableView = SORTING("Entry No.");
                column(MembershipEntryNo_MMMembershipPointsEntry; "Membership Entry No.")
                {
                }
                column(AmountLCY_MMMembershipPointsEntry; "Amount (LCY)")
                {
                    IncludeCaption = true;
                }
                column(AwardedAmountLCY_MMMembershipPointsEntry; "Awarded Amount (LCY)")
                {
                    IncludeCaption = true;
                }
                column(AwardedPoints_MMMembershipPointsEntry; "Awarded Points")
                {
                    IncludeCaption = true;
                }
                column(RedeemedPoints_MMMembershipPointsEntry; "Redeemed Points")
                {
                    IncludeCaption = true;
                }
                column(Points_MMMembershipPointsEntry; Points)
                {
                    IncludeCaption = true;
                }
                column(ItemNo_MMMembershipPointsEntry; "Item No.")
                {
                    IncludeCaption = true;
                }
                column(VariantCode_MMMembershipPointsEntry; "Variant Code")
                {
                    IncludeCaption = true;
                }
                column(Quantity_MMMembershipPointsEntry; Quantity)
                {
                    IncludeCaption = true;
                }
                column(PostingDate_MMMembershipPointsEntry; Format("Posting Date", 0, 1))
                {
                }
                column(DocumentNo_MMMembershipPointsEntry; "Document No.")
                {
                    IncludeCaption = true;
                }
                column(PointConstraint_MMMembershipPointsEntry; "Point Constraint")
                {
                    IncludeCaption = true;
                }
                column(EntryType_MMMembershipPointsEntry; "Entry Type")
                {
                    IncludeCaption = true;
                }
                column(PostingDateCaption; PostingDateCaption)
                {
                }
            }

            trigger OnAfterGetRecord()
            var
                MMMembershipPointsEntry: Record "NPR MM Members. Points Entry";
                MMMembership: Record "NPR MM Membership";
            begin
                BalanceBefore := 0;

                MMMembershipPointsEntry.SetRange("Membership Entry No.", "Entry No.");
                MMMembershipPointsEntry.SetFilter("Posting Date", GetFilter("Date Filter"));
                if not MMMembershipPointsEntry.FindFirst() then
                    CurrReport.Skip();

                MMMembership.SetRange("Entry No.", "Entry No.");
                MMMembership.SetFilter("Date Filter", '..%1', "MM Membership".GetRangeMin("Date Filter"));
                if MMMembership.FindFirst then begin
                    MMMembership.CalcFields("Remaining Points");
                    BalanceBefore := MMMembership."Remaining Points";
                end;

                Clear(CustomerName);
                if Customer.Get("Customer No.") then
                    CustomerName := Customer.Name;
            end;
        }
    }

    labels
    {
        ReportLbl = 'Membership Points Detail';
    }

    var
        Customer: Record Customer;
        BalanceBefore: Decimal;
        BalanceAfterCaption: Label 'Balance After';
        BalanceBeforeCaption: Label 'Balance Before';
        CustomerNameCaption: Label 'Customer Name';
        MembershipNoCaption: Label 'Membership';
        PageCaption: Label 'Page %1 of %2';
        PostingDateCaption: Label 'Posting Date';
        CustomerName: Text;
}

