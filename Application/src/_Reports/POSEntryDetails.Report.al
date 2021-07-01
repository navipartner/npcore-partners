report 6014458 "NPR POS Entry Details"
{

    Caption = 'POS Entry Details';
    PreviewMode = PrintLayout;
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = all;
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/POSEntryDetails.rdlc';


    dataset
    {

        DataItem("NPR POS Entry"; "NPR POS Entry")
        {

            DataItemTableView = SORTING("Posting Date", "Document No.")
                                     WHERE("Entry Type" = FILTER(<> "Cancelled Sale"), "Entry Type" = FILTER(<> "Comment"));

            RequestFilterFields = "Document No.", "POS Unit No.", "Posting Date";

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

            trigger OnPreDataItem()
            begin
                Filters := '';

                Filters := "NPR POS Entry".GETFILTERS;
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

        DataItem(CompanyInformation; "Company Information")
        {
            column(COMPANYNAME; COMPANYNAME)
            {
            }
            column(CompanyInformation_Picture; CompanyInformation.Picture)
            {
            }
            column(Filters; Filters)
            {
            }
            trigger OnAfterGetRecord()
            begin
                CalcFields(Picture);
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
    }

    labels
    {
        Report_cap = 'POS Entry Details';
        AmountIncl_cap = 'Amount Including Vat';
        Amount_cap = 'Amount';
        LineDiscountAmount_cap = 'Line Discount Amount';
        VatAmount_cap = 'Vat Amount';
    }

    var
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        POSEntryTaxLine: Record "NPR POS Entry Tax Line";
        Filters: Text;
}