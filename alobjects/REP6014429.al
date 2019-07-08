report 6014429 "Posting Overview Audit"
{
    // NPR70.00.00.00/LS/20150126  CASE 202874 : Convert Report to 7.1
    // NPR5.27/JLK /20161005 CASE 252134 Added TotalAuditRoll Including VAT
    // NPR5.39/TJ  /20180206 CASE 302634 Change OptionString property of global variable LastSalesType to english version
    // NPR5.39/JLK /20180219  CASE 300892 Removed warning/error from AL
    DefaultLayout = RDLC;
    RDLCLayout = './Posting Overview Audit.rdlc';

    Caption = 'Posting Overview Audit';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem("Audit Roll";"Audit Roll")
        {
            DataItemTableView = SORTING("Register No.","Sales Ticket No.","Sale Type","Line No.","No.","Sale Date");
            RequestFilterFields = "Register No.","Sale Date","No.";
            column(COMPANYNAME;CompanyName)
            {
            }
            column(CompanyInfoPicture;CompanyInformation.Picture)
            {
            }
            column(RegisterFilter;RegisterFilter)
            {
            }
            column(DateFilter;DateFilter)
            {
            }
            column(NoFilter;NoFilter)
            {
            }
            column(RegisterNo_AuditRoll;"Audit Roll"."Register No.")
            {
            }
            column(SalesTicketNo_AuditRoll;"Audit Roll"."Sales Ticket No.")
            {
            }
            column(SalespersonCode_AuditRoll;"Audit Roll"."Salesperson Code")
            {
            }
            column(DepartmentCode_AuditRoll;"Audit Roll"."Department Code")
            {
            }
            column(SaleDate_AuditRoll;"Audit Roll"."Sale Date")
            {
            }
            column(AuditRollNo;AuditRollNo)
            {
            }
            column(Description_AuditRoll;"Audit Roll".Description)
            {
            }
            column(AmountIncludingVAT_AuditRoll;"Audit Roll"."Amount Including VAT")
            {
            }
            column(Color_AuditRoll;"Audit Roll".Color)
            {
            }
            column(Size_AuditRoll;"Audit Roll".Size)
            {
            }
            column(VariantCode_AuditRoll;"Audit Roll"."Variant Code")
            {
            }
            column(SaleType_AuditRoll;"Audit Roll"."Sale Type")
            {
            }
            column(LineNo_AuditRoll;"Audit Roll"."Line No.")
            {
            }
            column(No_AuditRoll;"Audit Roll"."No.")
            {
            }
            column(PrintDankort;PrintDankort)
            {
            }
            column(IncludeDankort;IncludeDankort)
            {
            }
            column(AuditRollTotalInclVAT;AuditRollTotalInclVAT)
            {
            }
            dataitem("Credit Card Transaction";"Credit Card Transaction")
            {
                DataItemLink = "Register No."=FIELD("Register No."),"Sales Ticket No."=FIELD("Sales Ticket No."),Date=FIELD("Sale Date");
                DataItemTableView = SORTING("Register No.","Sales Ticket No.",Date) WHERE(Type=FILTER(<>1));
                column(TransactionTime_CreditCardTransaction;"Credit Card Transaction"."Transaction Time")
                {
                }
                column(EntryNo_CreditCardTransaction;"Credit Card Transaction"."Entry No.")
                {
                }
                column(Type_CreditCardTransaction;"Credit Card Transaction".Type)
                {
                }
                column(Text_CreditCardTransaction;"Credit Card Transaction".Text)
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

                //-NPR5.27
                if "Audit Roll".Quantity <> 0 then
                  AuditRollTotalInclVAT += "Amount Including VAT";
                //+NPR5.27
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
                field(IncludeDankort;IncludeDankort)
                {
                    Caption = 'Include Dankort';
                }
            }
        }

        actions
        {
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

        //-NPR5.39
        // Object.SETRANGE(ID, 6014429);
        // Object.SETRANGE(Type, 3);
        // Object.FIND('-');
        //+NPR5.39
    end;

    var
        CompanyInformation: Record "Company Information";
        RegisterFilter: Code[250];
        DateFilter: Code[250];
        NoFilter: Code[250];
        AuditRoll1: Record "Audit Roll";
        RetailSetup: Record "Retail Setup";
        IncludeDankort: Boolean;
        QtyLine: Integer;
        PrintDankort: Boolean;
        LastRegisterNo: Code[10];
        LastTicketNo: Code[20];
        LastSalesType: Option Sale,Payment,"Debit Sale","Gift Voucher","Credit Voucher",Deposit,"Out payment",Comment,,"Open/Close";
        LastLineNo: Integer;
        LastNo: Code[20];
        LastSalesDate: Date;
        AuditRollNo: Code[20];
        Item: Record Item;
        AuditRollTotalInclVAT: Decimal;
}

