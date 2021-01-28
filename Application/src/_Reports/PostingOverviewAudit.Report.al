report 6014429 "NPR Posting Overview Audit"
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Posting Overview Audit.rdlc';
    Caption = 'Posting Overview Audit';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    dataset
    {
        dataitem("Audit Roll"; "NPR Audit Roll")
        {
            DataItemTableView = SORTING("Register No.", "Sales Ticket No.", "Sale Type", "Line No.", "No.", "Sale Date");
            RequestFilterFields = "Register No.", "Sale Date", "No.";
            column(COMPANYNAME; CompanyName)
            {
            }
            column(CompanyInfoPicture; CompanyInformation.Picture)
            {
            }
            column(RegisterFilter; RegisterFilter)
            {
            }
            column(DateFilter; DateFilter)
            {
            }
            column(NoFilter; NoFilter)
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
            column(DepartmentCode_AuditRoll; "Audit Roll"."Department Code")
            {
            }
            column(SaleDate_AuditRoll; "Audit Roll"."Sale Date")
            {
            }
            column(AuditRollNo; AuditRollNo)
            {
            }
            column(Description_AuditRoll; "Audit Roll".Description)
            {
            }
            column(AmountIncludingVAT_AuditRoll; "Audit Roll"."Amount Including VAT")
            {
            }
            column(Color_AuditRoll; "Audit Roll".Color)
            {
            }
            column(Size_AuditRoll; "Audit Roll".Size)
            {
            }
            column(VariantCode_AuditRoll; "Audit Roll"."Variant Code")
            {
            }
            column(SaleType_AuditRoll; "Audit Roll"."Sale Type")
            {
            }
            column(LineNo_AuditRoll; "Audit Roll"."Line No.")
            {
            }
            column(No_AuditRoll; "Audit Roll"."No.")
            {
            }
            column(PrintDankort; PrintDankort)
            {
            }
            column(IncludeDankort; IncludeDankort)
            {
            }
            column(AuditRollTotalInclVAT; AuditRollTotalInclVAT)
            {
            }
            dataitem("EFT Receipt"; "NPR EFT Receipt")
            {
                DataItemLink = "Register No." = FIELD("Register No."), "Sales Ticket No." = FIELD("Sales Ticket No."), Date = FIELD("Sale Date");
                DataItemTableView = SORTING("Register No.", "Sales Ticket No.", Date) WHERE(Type = FILTER(<> 1));
                column(TransactionTime_CreditCardTransaction; "EFT Receipt"."Transaction Time")
                {
                }
                column(EntryNo_CreditCardTransaction; "EFT Receipt"."Entry No.")
                {
                }
                column(Type_CreditCardTransaction; "EFT Receipt".Type)
                {
                }
                column(Text_CreditCardTransaction; "EFT Receipt".Text)
                {
                }

                trigger OnPreDataItem()
                begin
                    RetailSetup.Get();

                    if not IncludeDankort then
                        CurrReport.Break();
                end;
            }

            trigger OnAfterGetRecord()
            begin
                AuditRoll1.SetRange("Register No.", "Register No.");
                AuditRoll1.SetRange("Sales Ticket No.", "Sales Ticket No.");
                AuditRoll1.Find('+');

                LastRegisterNo := AuditRoll1."Register No.";
                LastTicketNo := AuditRoll1."Sales Ticket No.";
                LastSalesType := AuditRoll1."Sale Type";
                LastLineNo := AuditRoll1."Line No.";
                LastNo := AuditRoll1."No.";
                LastSalesDate := AuditRoll1."Sale Date";

                AuditRollNo := "No.";

                if Type = Type::Item then begin
                    if Item.Get("No.") then
                        AuditRollNo := Item."Vendor Item No.";
                end;

                PrintDankort := false;

                if ("Register No." = LastRegisterNo) and ("Sales Ticket No." = LastTicketNo) and ("Sale Type" = LastSalesType) and
                 ("Line No." = LastLineNo) and ("No." = LastNo) and ("Sale Date" = LastSalesDate) then
                    PrintDankort := true;

                if "Audit Roll".Quantity <> 0 then
                    AuditRollTotalInclVAT += "Amount Including VAT";
            end;

            trigger OnPreDataItem()
            begin
                RegisterFilter := "Audit Roll".GetFilter("Register No.");
                DateFilter := "Audit Roll".GetFilter("Sale Date");
                NoFilter := "Audit Roll".GetFilter("No.");

                Clear(AuditRollTotalInclVAT);
            end;
        }
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                field(IncludeDankort; IncludeDankort)
                {
                    Caption = 'Include Dankort';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Include Dankort field';
                }
            }
        }
    }

    labels
    {
        Report_Caption = 'Entry Overview';
        AuditRoll_Caption = 'Audit Roll';
        RegisterFilter_Caption = 'Register Filter';
        DateFilter_Caption = 'Date Filter';
        NoFilter_Caption = 'No. Filter';
        RegisterNo_Caption = 'Register No.';
        SalesTicketNo_Caption = 'Sales Ticket No.';
        SalesPersonCode_Caption = 'Sales Person Code';
        DeptCode_Caption = 'Department Code';
        SalesDate_Caption = 'Sale Date';
        Code_Caption = 'Code';
        Description_Caption = 'Description';
        AmtInclVAT_Caption = 'Amount Including VAT';
        Color_Caption = 'Color :';
        Size_Caption = 'Size :';
        VariantCode_Caption = 'Variant Code';
        EntryNo_Caption = 'Entry No.';
        Type_Caption = 'Type';
        Text_Caption = 'Text';
        TransactionTime_Caption = 'Transaction Time';
        Page_Caption = 'Page';
        Total_Caption = 'Total';
    }

    trigger OnPreReport()
    begin
        CompanyInformation.Get();
        CompanyInformation.CalcFields(Picture);
    end;

    var
        CompanyInformation: Record "Company Information";
        Item: Record Item;
        AuditRoll1: Record "NPR Audit Roll";
        RetailSetup: Record "NPR Retail Setup";
        IncludeDankort: Boolean;
        PrintDankort: Boolean;
        LastRegisterNo: Code[10];
        AuditRollNo: Code[20];
        LastNo: Code[20];
        LastTicketNo: Code[20];
        DateFilter: Code[250];
        NoFilter: Code[250];
        RegisterFilter: Code[250];
        LastSalesDate: Date;
        AuditRollTotalInclVAT: Decimal;
        LastLineNo: Integer;
        QtyLine: Integer;
        LastSalesType: Option Sale,Payment,"Debit Sale","Gift Voucher","Credit Voucher",Deposit,"Out payment",Comment,,"Open/Close";
}

