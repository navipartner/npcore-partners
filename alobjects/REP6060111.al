report 6060111 "Check Duplicate Customers"
{
    // NPR4.18\JLK\20151119 CASE 227394 - Report to find matching customers based on Name, Address and Phone No.
    // NPR5.38/JLK /20180124  CASE 300892 Removed AL Error on ControlContainer Caption in Request Page
    // NPR5.38/JLK /20180125  CASE 303595 Added ENU object caption
    DefaultLayout = RDLC;
    RDLCLayout = './Check Duplicate Customers.rdlc';

    Caption = 'Check Duplicate Customers';

    dataset
    {
        dataitem(IntegerComp;"Integer")
        {
            DataItemTableView = WHERE(Number=CONST(1));
            column(Company_Name;Company.Name)
            {
                IncludeCaption = true;
            }
            column(Company_Picture;Company.Picture)
            {
            }
            column(SearchFilterValue;SearchFilter)
            {
            }
            dataitem(Customer;Customer)
            {
                column(No_Customer;Customer."No.")
                {
                    IncludeCaption = true;
                }
                column(Name_Customer;Customer.Name)
                {
                    IncludeCaption = true;
                }
                column(Address_Customer;Customer.Address)
                {
                    IncludeCaption = true;
                }
                column(PhoneNo_Customer;Customer."Phone No.")
                {
                    IncludeCaption = true;
                }
                dataitem("Integer";"Integer")
                {
                    DataItemTableView = SORTING(Number) WHERE(Number=FILTER(1..));
                    column(Temp_Customer_No;TMPCust."No.")
                    {
                        IncludeCaption = true;
                    }
                    column(Temp_Customer_Name;TMPCust.Name)
                    {
                        IncludeCaption = true;
                    }
                    column(Temp_Customer_Address;TMPCust.Address)
                    {
                        IncludeCaption = true;
                    }
                    column(Temp_Customer_Phone_No;TMPCust."Phone No.")
                    {
                        IncludeCaption = true;
                    }

                    trigger OnAfterGetRecord()
                    begin
                        if Number = 1 then begin
                          if not TMPCust.FindFirst then
                            CurrReport.Break;
                        end else
                          if TMPCust.Next = 0 then
                            CurrReport.Break;
                    end;
                }

                trigger OnAfterGetRecord()
                var
                    Cust2: Record Customer;
                begin
                    TMPCust.DeleteAll;
                    Cust2.Reset;

                    Cust2.SetFilter("No.",'<>%1',Customer."No.");
                    if CheckName then
                      Cust2.SetRange(Name,Name);
                    if CheckAddr then
                      Cust2.SetRange(Address,Address);
                    if CheckPhone then
                      Cust2.SetRange("Phone No.","Phone No.");

                    if Cust2.FindSet then
                      repeat
                        TMPCust.Init;
                        TMPCust.TransferFields(Cust2);
                        TMPCust.Insert;
                      until Cust2.Next = 0
                    else
                      CurrReport.Skip;
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
                    field(CheckName;CheckName)
                    {
                        Caption = 'Name';
                    }
                    field(CheckAddr;CheckAddr)
                    {
                        Caption = 'Address';
                    }
                    field(CheckPhone;CheckPhone)
                    {
                        Caption = 'Phone No.';
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
        Original = 'Customer';
        Duplicate = 'Matching Customers';
        ComName = 'Company Name';
    }

    trigger OnPreReport()
    begin
        if (not CheckName) and (not CheckAddr) and (not CheckPhone) then
          Error(Text001);

        if CheckName then begin
          SearchFilter += Text003;
        end;
        if CheckAddr then begin
          if SearchFilter <> '' then
            SearchFilter += Text005
          else
            SearchFilter += Text004;
        end;
        if CheckPhone then begin
          if SearchFilter <> '' then
            SearchFilter += Text007
          else
            SearchFilter += Text006;
        end;

        SearchFilter := Text002 + SearchFilter;
    end;

    var
        CheckAddr: Boolean;
        CheckPhone: Boolean;
        CheckName: Boolean;
        TMPCust: Record Customer temporary;
        Company: Record "Company Information";
        SearchFilter: Text;
        Text001: Label 'Tick one of the check boxes';
        Text002: Label 'Search based on: ';
        Text003: Label 'Name';
        Text004: Label 'Address';
        Text005: Label ' and Address';
        Text006: Label 'Phone No.';
        Text007: Label ' and Phone No.';
}

