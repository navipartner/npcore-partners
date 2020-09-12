report 6014434 "NPR Vendor/Debtor by date"
{
    // NPR70.00.00.00/LS/060514 CASE 183046 : Convert Report to Nav 2013
    // NPR4.14/TS/20150820 CASE 22159 Change Caption of  report
    // NPR5.38/JLK /20180124  CASE 300892 Removed AL Error on obsolite property CurrReport_PAGENO
    // NPR5.39/JLK /20180219  CASE 300892 Removed warning/error from AL
    // NPR5.40/TJ  /20180319  CASE 307717 Replaced hardcoded dates with DMY2DATE structure
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/VendorDebtor by date.rdlc';

    Caption = 'Vendor/Customer by date';

    dataset
    {
        dataitem("Integer"; "Integer")
        {
            MaxIteration = 1;
            column(Number_Integer; Integer.Number)
            {
            }
            column(COMPANYNAME; CompanyName)
            {
            }
            column(Tildato; Tildato)
            {
            }
        }
        dataitem(Vendor; Vendor)
        {
            RequestFilterFields = "No.", "Vendor Posting Group", "Global Dimension 1 Filter";
            column(No_Vendor; Vendor."No.")
            {
            }
            column(Name_Vendor; Vendor.Name)
            {
            }
            column(NetChangeLCY_Vendor; Vendor."Net Change (LCY)")
            {
            }
            column(PrintKreditor; PrintKreditor)
            {
            }
            column(Kunmedsaldo_Vendor; Kunmedsaldo)
            {
            }
            column(ShowCreditor; ShowCreditor)
            {
            }

            trigger OnAfterGetRecord()
            begin
                afdfilter := Vendor.GetFilter(Vendor."Global Dimension 1 Filter");
                Vendor.SetFilter("Global Dimension 1 Filter", afdfilter);
                //-NPR5.40 [307717]
                //Vendor.SETRANGE("Date Filter", 010180D ,Tildato);
                Vendor.SetRange("Date Filter", DMY2Date(1, 1, 1980), Tildato);
                //+NPR5.40 [307717]
                Vendor.CalcFields("Net Change (LCY)");

                //-NPR70.00.00.00
                ShowCreditor := false;
                if (Kunmedsaldo = true) and ("Net Change (LCY)" = 0) then
                    ShowCreditor := false
                else
                    if (Kunmedsaldo = false) and ("Net Change (LCY)" <> 0) then
                        ShowCreditor := true;
                //+NPR70.00.00.00
            end;

            trigger OnPreDataItem()
            begin
                if not PrintKreditor then CurrReport.Break;
                //-NPR5.39
                //CurrReport.CREATETOTALS("Net Change (LCY)");
                //+NPR5.39
            end;
        }
        dataitem(Customer; Customer)
        {
            DataItemTableView = SORTING("No.");
            RequestFilterFields = "No.", "Global Dimension 1 Filter";
            column(NetChangeLCY_Customer; Customer."Net Change (LCY)")
            {
            }
            column(No_Customer; Customer."No.")
            {
            }
            column(Name_Customer; Customer.Name)
            {
            }
            column(PrintDebitor; PrintDebitor)
            {
            }
            column(Kunmedsaldo_Customer; Kunmedsaldo)
            {
            }
            column(ShowCustomer; ShowCustomer)
            {
            }
            column(Tildato_Customer; Tildato)
            {
            }

            trigger OnAfterGetRecord()
            begin
                afdfilter := Customer.GetFilter(Customer."Global Dimension 1 Filter");
                Customer.SetFilter("Global Dimension 1 Filter", afdfilter);
                //-NPR5.40 [307717]
                //Customer.SETRANGE("Date Filter", 010180D ,Tildato);
                Customer.SetRange("Date Filter", DMY2Date(1, 1, 1980), Tildato);
                //+NPR5.40 [307717]
                Customer.CalcFields("Net Change (LCY)");

                //-NPR70.00.00.00
                ShowCustomer := false;
                if (Kunmedsaldo = true) and ("Net Change (LCY)" = 0) then
                    ShowCustomer := false
                else
                    if (Kunmedsaldo = false) and ("Net Change (LCY)" <> 0) then
                        ShowCustomer := true;
                //+NPR70.00.00.00
            end;

            trigger OnPreDataItem()
            begin
                if not PrintDebitor then CurrReport.Break;
                //-NPR5.38
                //CurrReport.PAGENO(1);
                //+NPR5.38
            end;
        }
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                group(Options)
                {
                    field(Tildato; Tildato)
                    {
                        Caption = 'To Date';
                        ApplicationArea = All;
                    }
                    field(Kunmedsaldo; Kunmedsaldo)
                    {
                        Caption = 'Only With Balance';
                        ApplicationArea = All;
                    }
                    field(PrintKreditor; PrintKreditor)
                    {
                        Caption = 'Creditor';
                        ApplicationArea = All;
                    }
                    field(PrintDebitor; PrintDebitor)
                    {
                        Caption = 'Customer';
                        ApplicationArea = All;
                    }
                }
            }
        }

        actions
        {
        }
    }

    labels
    {
        Report_Caption = 'Report Per Date';
        PerDate_Caption = 'Per Date';
        No_Caption = 'No.';
        Name_Caption = 'Name';
        NetChange_Caption = 'Net Change (LCY)';
        Total_Caption = 'Total';
        Creditor_Caption = 'Creditor per Date';
        Customer_Caption = 'Customer per Date';
        Footer_Caption = 'ˆNAVIPARTNER K¢benhavn 2002';
    }

    trigger OnInitReport()
    begin
        Tildato := Today;
        //-NPR70.00.00.00
        Kunmedsaldo := false;
        PrintKreditor := true;
        PrintDebitor := true;
        //+NPR70.00.00.00
    end;

    trigger OnPreReport()
    begin
        Firmaoplysninger.Get();
        Firmaoplysninger.CalcFields(Picture);

        //-NPR5.39
        // objekt.SETRANGE(ID, 6014434);
        // objekt.SETRANGE(Type, 3);
        // objekt.FIND('-');
        //+NPR5.39
    end;

    var
        Firmaoplysninger: Record "Company Information";
        Tildato: Date;
        Kunmedsaldo: Boolean;
        Totalsaldo: Decimal;
        PrintKreditor: Boolean;
        PrintDebitor: Boolean;
        afdfilter: Code[20];
        afddebitor: Code[20];
        ShowCustomer: Boolean;
        ShowCreditor: Boolean;
}

