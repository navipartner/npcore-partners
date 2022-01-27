report 6014458 "NPR POS Entry Details"
{

    Caption = 'POS Entry Details';
    PreviewMode = PrintLayout;
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = NPRRetail;
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/POSEntryDetails.rdlc';
    DataAccessIntent = ReadOnly;

    dataset
    {

        DataItem("NPR POS Entry"; "NPR POS Entry")
        {

            DataItemTableView = SORTING("Posting Date", "Document No.")
                WHERE("Entry Type" = FILTER(<> "Cancelled Sale"),
                      "Entry Type" = FILTER(<> "Comment"),
                      "System Entry" = filter(false));

            RequestFilterFields = "Document No.", "POS Unit No.", "Posting Date", "Entry Type";

            column(RegisterNo_NPR_POS_Entry; "POS Unit No.")
            {
                IncludeCaption = true;
            }
            column(SalesTicketNo_NPR_POS_Entry; "Document No.")
            {
                IncludeCaption = true;
            }
            column(SalespersonCode_NPR_POS_Entry; "Salesperson Code")
            {
                IncludeCaption = true;
            }
            column(EntryDate_NPR_POS_Entry; "Entry Date")
            {
                IncludeCaption = true;
            }
            column(CustomerNo_NPR_POS_Entry; "Customer No.")
            {
                IncludeCaption = true;
            }
            column(Type_NPR_POS_Entry; "Entry Type")
            {
                IncludeCaption = true;
            }
            column(No_NPR_POS_Entry; "Entry No.")
            {
                IncludeCaption = true;
            }
            column(Description_NPR_POS_Entry; Description)
            {
                IncludeCaption = true;
            }
            column(Posted_NPR_POS_Entry; Format("NPR POS Entry"."Post Entry Status"))
            {
            }
            column(PostItemEntryStatus_POSEntryStauts; Format("NPR POS Entry"."Post Item Entry Status"))
            {
            }

            column(DiscountAmount_NPR_POS_Entry; "NPR POS Entry"."Discount Amount")
            {
                IncludeCaption = true;
            }

            column(RoundingAmountLCY_NPR_POS_Entry; "NPR POS Entry"."Rounding Amount (LCY)")
            {
                IncludeCaption = true;
            }
            column(AmountIncTaxRound_NPR_POS_Entry; "NPR POS Entry"."Amount Incl. Tax & Round")
            {
                IncludeCaption = true;
            }

            column(AmountIncludingVAT_NPR_POS_Entry_Sales_Line; POSEntrySalesLine."Amount Incl. VAT")
            {

            }
            column(Amount_NPR_POS_Entry_Sale_Line; POSEntrySalesLine."Amount Excl. VAT")
            {
            }
            column(LineDiscountAmount_NPR_POS_Entry_Sale_Line; POSEntrySalesLine."Line Discount Amount Incl. VAT")
            {
            }
            column(POSEntryTaxLine_TaxAmount; POSEntryTaxLine."Tax Amount")
            {
            }
            column(Filters; Filters)
            {
            }
            column(CompanyName; CompanyInfo.Name)
            {
            }


            trigger OnPreDataItem()
            begin
                CompanyInfo.get();
                if not IsEntryTypeFilterValid() then
                    CurrReport.Break();
            end;

            trigger OnAfterGetRecord()
            begin
                Clear(POSEntrySalesLine);
                Clear(POSEntryTaxLine);

                POSEntrySalesLine.SetRange("POS Entry No.", "NPR POS Entry"."Entry No.");
                if POSEntrySalesLine.findset() then begin
                    POSEntrySalesLine.CalcSums("Amount Incl. VAT", "Amount Excl. VAT", "Line Discount Amount Incl. VAT");
                end;

                POSEntryTaxLine.setrange("POS Entry No.", "NPR POS Entry"."Entry No.");
                if POSEntryTaxLine.FindSet() then begin
                    POSEntryTaxLine.CalcSums("Tax Amount");
                end;


            end;
        }
    }
    requestpage
    {
        SaveValues = true;
        layout
        {
        }

        actions
        {
        }
    }

    labels
    {
        Report_cap = 'POS Entry Details';
        AmountIncl_cap = 'Amount Incl.Tax';
        AmountExcl_cap = 'Amount Excl.Tax';
        Amount_cap = 'Amount';
        LineDiscountAmount_cap = 'Discount Amount';
        TaxAmount_cap = 'Tax Amount';
        Post_Item_Entry_Status_cap = 'Post Item Entry Status';
        Post_Entry_Status_cap = 'Post Entry Status';
        SalesExclTax_cap = 'Sales Excl. Tax';
        Filter_cap = 'Filter:';


    }

    var
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        POSEntryTaxLine: Record "NPR POS Entry Tax Line";
        Filters: Text;
        CompanyInfo: Record "Company Information";


    local procedure IsEntryTypeFilterValid() Result: boolean
    var
        NPRPOSEntry: Record "NPR POS Entry";
    begin
        NPRPOSEntry.FilterGroup(50);
        NPRPOSEntry.SetFilter("Entry Type", NPRPOSEntry.GetFilter("Entry Type"));
        NPRPOSEntry.FilterGroup(51);
        NPRPOSEntry.SetFilter("Entry Type", '<>%1 & <>%2', NPRPOSEntry."Entry Type"::"Cancelled Sale", NPRPOSEntry."Entry Type"::"Comment");
        Result := NPRPOSEntry.count() <> 0;
    end;
}
