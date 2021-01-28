report 6014458 "NPR Audit Roll Details"
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Audit Roll Details.rdlc';
    Caption = 'Audit Roll Details';
    PreviewMode = PrintLayout;
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;

    dataset
    {
        dataitem("Audit Roll"; "NPR Audit Roll")
        {
            DataItemTableView = SORTING("Sale Date", "Sales Ticket No.", "Sale Type", "Line No.") WHERE(Type = FILTER(<> Cancelled));
            RequestFilterFields = "Sales Ticket No.", "Register No.", "Sale Date";
            column(AuditRoll_GetFilters; Filters)
            {
            }
            column(RegisterNo_AuditRoll; "Audit Roll"."Register No.")
            {
            }
            column(SalesTicketNo_AuditRoll; "Audit Roll"."Sales Ticket No.")
            {
            }
            column(SalespersonCode_AuditRoll; "Audit Roll"."Salesperson Code")
            {
            }
            column(PostingDate_AuditRoll; "Audit Roll"."Posting Date")
            {
            }
            column(CustomerNo_AuditRoll; "Audit Roll"."Customer No.")
            {
            }
            column(Type_AuditRoll; "Audit Roll".Type)
            {
            }
            column(No_AuditRoll; "Audit Roll"."No.")
            {
            }
            column(Description_AuditRoll; "Audit Roll".Description)
            {
            }
            column(Posted_AuditRoll; "Audit Roll".Posted)
            {
            }
            column(ItemEntryPosted_AuditRoll; "Audit Roll"."Item Entry Posted")
            {
            }
            column(AmountIncludingVAT_AuditRoll; "Audit Roll"."Amount Including VAT")
            {
            }
            column(Amount_AuditRoll; "Audit Roll".Amount)
            {
            }
            column(LineDiscountAmount_AuditRoll; "Audit Roll"."Line Discount Amount")
            {
            }
            column(VatAmount_AuditRoll; VatAmount)
            {
            }
            column(SaleDate_AuditRoll; Format("Audit Roll"."Sale Date", 0, 1))
            {
            }
            column(COMPANYNAME; CompanyName)
            {
            }
            column(CompanyInformation_Picture; CompanyInformation.Picture)
            {
            }

            trigger OnAfterGetRecord()
            begin
                VatAmount := "Audit Roll"."Amount Including VAT" - "Audit Roll"."Line Discount Amount" - "Audit Roll".Amount;
            end;

            trigger OnPreDataItem()
            begin
                Filters := '';
                Filters := "Audit Roll".GetFilters;
            end;
        }
    }

    labels
    {
        Register_cap = 'Register No.';
        SalesTicket_cap = 'Sales Ticket No.';
        Salesperson_cap = 'Salesperson Code';
        PostingDate_cap = 'Posting Date';
        CustomerNo_cap = 'Customer No.';
        Type_cap = 'Type';
        No_cap = 'No.';
        Description_cap = 'Description';
        Posted_cap = 'Posted';
        ItemEntryPosted_cap = 'Item Entry Posted';
        AmountIncl_cap = 'Amount Including Vat';
        Amount_cap = 'Amount';
        LineDiscountAmount_cap = 'Line Discount Amount';
        VatAmount_cap = 'Vat Amount';
        Report_cap = 'Audit Roll Details';
    }

    trigger OnInitReport()
    begin
        CompanyInformation.Get();
        CompanyInformation.CalcFields(Picture);
    end;

    var
        CompanyInformation: Record "Company Information";
        VatAmount: Decimal;
        Filters: Text;
}

