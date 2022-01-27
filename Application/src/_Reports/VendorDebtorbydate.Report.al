report 6014434 "NPR Vendor/Debtor by date"
{
    #IF NOT BC17 
    Extensible = False; 
    #ENDIF
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/VendorDebtor by date.rdlc';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = NPRRetail;
    Caption = 'Vendor/Customer by date';
    DataAccessIntent = ReadOnly;

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
                DimFilter := Vendor.GetFilter(Vendor."Global Dimension 1 Filter");
                Vendor.SetFilter("Global Dimension 1 Filter", DimFilter);
                Vendor.SetRange("Date Filter", DMY2Date(1, 1, 1980), Tildato);
                Vendor.CalcFields("Net Change (LCY)");

                ShowCreditor := false;
                if (Kunmedsaldo = true) and ("Net Change (LCY)" = 0) then
                    ShowCreditor := false
                else
                    if (Kunmedsaldo = false) and ("Net Change (LCY)" <> 0) then
                        ShowCreditor := true;
            end;

            trigger OnPreDataItem()
            begin
                if not PrintKreditor then
                    CurrReport.Break();
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
                DimFilter := Customer.GetFilter(Customer."Global Dimension 1 Filter");
                Customer.SetFilter("Global Dimension 1 Filter", DimFilter);
                Customer.SetRange("Date Filter", DMY2Date(1, 1, 1980), Tildato);
                Customer.CalcFields("Net Change (LCY)");

                ShowCustomer := false;
                if (Kunmedsaldo = true) and ("Net Change (LCY)" = 0) then
                    ShowCustomer := false
                else
                    if (Kunmedsaldo = false) and ("Net Change (LCY)" <> 0) then
                        ShowCustomer := true;
            end;

            trigger OnPreDataItem()
            begin
                if not PrintDebitor then
                    CurrReport.Break();
            end;
        }
    }

    requestpage
    {
        SaveValues = true;
        layout
        {
            area(content)
            {
                group(Options)
                {
                    field("Til dato"; Tildato)
                    {
                        Caption = 'To Date';

                        ToolTip = 'Specifies the value of the To Date field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Kunmed saldo"; Kunmedsaldo)
                    {
                        Caption = 'Only With Balance';

                        ToolTip = 'Specifies the value of the Only With Balance field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Print Kreditor"; PrintKreditor)
                    {
                        Caption = 'Creditor';

                        ToolTip = 'Specifies the value of the Creditor field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Print Debitor"; PrintDebitor)
                    {
                        Caption = 'Customer';

                        ToolTip = 'Specifies the value of the Customer field';
                        ApplicationArea = NPRRetail;
                    }
                }
            }
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
        Tildato := Today();
        Kunmedsaldo := false;
        PrintKreditor := true;
        PrintDebitor := true;
    end;

    trigger OnPreReport()
    begin
        Firmaoplysninger.Get();
        Firmaoplysninger.CalcFields(Picture);
    end;

    var
        Firmaoplysninger: Record "Company Information";
        Kunmedsaldo: Boolean;
        PrintDebitor: Boolean;
        PrintKreditor: Boolean;
        ShowCreditor: Boolean;
        ShowCustomer: Boolean;
        DimFilter: Text;
        Tildato: Date;
}

