report 6060111 "NPR Check Duplicate Cust."
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Check Duplicate Customers.rdlc'; 
    UsageCategory = ReportsAndAnalysis; 
    ApplicationArea = All;
    Caption = 'Check Duplicate Customers';

    dataset
    {
        dataitem(IntegerComp; "Integer")
        {
            DataItemTableView = WHERE(Number = CONST(1));
            column(Company_Name; Company.Name)
            {
                IncludeCaption = true;
            }
            column(Company_Picture; Company.Picture)
            {
            }
            column(SearchFilterValue; SearchFilter)
            {
            }
            dataitem(Customer; Customer)
            {
                column(No_Customer; Customer."No.")
                {
                    IncludeCaption = true;
                }
                column(Name_Customer; Customer.Name)
                {
                    IncludeCaption = true;
                }
                column(Address_Customer; Customer.Address)
                {
                    IncludeCaption = true;
                }
                column(PhoneNo_Customer; Customer."Phone No.")
                {
                    IncludeCaption = true;
                }
                dataitem("Integer"; "Integer")
                {
                    DataItemTableView = SORTING(Number) WHERE(Number = FILTER(1 ..));
                    column(Temp_Customer_No; TMPCust."No.")
                    {
                        IncludeCaption = true;
                    }
                    column(Temp_Customer_Name; TMPCust.Name)
                    {
                        IncludeCaption = true;
                    }
                    column(Temp_Customer_Address; TMPCust.Address)
                    {
                        IncludeCaption = true;
                    }
                    column(Temp_Customer_Phone_No; TMPCust."Phone No.")
                    {
                        IncludeCaption = true;
                    }

                    trigger OnAfterGetRecord()
                    begin
                        if Number = 1 then begin
                            if not TMPCust.FindFirst() then
                                CurrReport.Break();
                        end else
                            if TMPCust.Next() = 0 then
                                CurrReport.Break();
                    end;
                }

                trigger OnAfterGetRecord()
                var
                    Cust2: Record Customer;
                begin
                    TMPCust.DeleteAll();
                    Cust2.Reset();

                    Cust2.SetFilter("No.", '<>%1', Customer."No.");
                    if CheckName then
                        Cust2.SetRange(Name, Name);
                    if CheckAddr then
                        Cust2.SetRange(Address, Address);
                    if CheckPhone then
                        Cust2.SetRange("Phone No.", "Phone No.");

                    if Cust2.FindSet() then
                        repeat
                            TMPCust.Init();
                            TMPCust.TransferFields(Cust2);
                            TMPCust.Insert();
                        until Cust2.Next() = 0
                    else
                        CurrReport.Skip();
                end;
            }

            trigger OnPreDataItem()
            begin
                Company.Get();
                Company.CalcFields(Picture);
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
                    field(CheckName; CheckName)
                    {
                        Caption = 'Name';
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Name field';
                    }
                    field(CheckAddr; CheckAddr)
                    {
                        Caption = 'Address';
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Address field';
                    }
                    field(CheckPhone; CheckPhone)
                    {
                        Caption = 'Phone No.';
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Phone No. field';
                    }
                }
            }
        }

    }

    labels
    {
        Original = 'Customer';
        Duplicate = 'Matching Customers';
        ComName = 'Company Name';
    }

    trigger OnPreReport()
    begin
        if (not CheckName) and (not CheckAddr) and (not CheckPhone) then
            Error(CheckboxErr);

        if CheckName then begin
            SearchFilter += NameLbl;
        end;
        if CheckAddr then begin
            if SearchFilter <> '' then
                SearchFilter += AndAddressLbl
            else
                SearchFilter += AddressLbl;
        end;
        if CheckPhone then begin
            if SearchFilter <> '' then
                SearchFilter += PhoneLbl
            else
                SearchFilter += Phone2Lbl;
        end;

        SearchFilter := SearchFilterLbl + SearchFilter;
    end;

    var
        Company: Record "Company Information";
        TMPCust: Record Customer temporary;
        CheckAddr: Boolean;
        CheckName: Boolean;
        CheckPhone: Boolean;
        AddressLbl: Label 'Address';
        AndAddressLbl: Label ' and Address';
        PhoneLbl: Label ' and Phone No.';
        NameLbl: Label 'Name';
        Phone2Lbl: Label 'Phone No.';
        SearchFilterLbl: Label 'Search based on: ';
        CheckboxErr: Label 'Tick one of the check boxes';
        SearchFilter: Text;
}

