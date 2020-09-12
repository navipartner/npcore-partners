report 6060112 "NPR Check Duplicate Contacts"
{
    // NPR4.18\JLK\20151119 CASE 227394 - Report to find matching contacts based on Name, Address and Phone No.
    // NPR5.38/JLK /20180124  CASE 300892 Removed AL Error on ControlContainer Caption in Request Page
    // NPR5.38/JLK /20180125  CASE 303595 Added ENU object caption
    // NPR5.39/JLK /20180219  CASE 300892 Removed warning/error from AL
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Check Duplicate Contacts.rdlc';

    Caption = 'Check Duplicate Contacts';

    dataset
    {
        dataitem(IntegerComp; "Integer")
        {
            DataItemTableView = WHERE(Number = CONST(1));
            column(Company_Name; Company.Name)
            {
            }
            column(Company_Picture; Company.Picture)
            {
            }
            column(SearchFilterValue; SearchFilter)
            {
            }
            dataitem(Contact; Contact)
            {
                column(No_Contact; Contact."No.")
                {
                    IncludeCaption = true;
                }
                column(Name_Contact; Contact.Name)
                {
                    IncludeCaption = true;
                }
                column(Address_Contact; Contact.Address)
                {
                    IncludeCaption = true;
                }
                column(PhoneNo_Contact; Contact."Phone No.")
                {
                    IncludeCaption = true;
                }
                dataitem("Integer"; "Integer")
                {
                    DataItemTableView = SORTING(Number) WHERE(Number = FILTER(1 ..));
                    column(Temp_Contact_No; TMPCont."No.")
                    {
                        IncludeCaption = true;
                    }
                    column(Temp_Contact_Name; TMPCont.Name)
                    {
                        IncludeCaption = true;
                    }
                    column(Temp_Contact_Address; TMPCont.Address)
                    {
                        IncludeCaption = true;
                    }
                    column(Temp_Contact_Phone_No; TMPCont."Phone No.")
                    {
                        IncludeCaption = true;
                    }

                    trigger OnAfterGetRecord()
                    begin
                        if Number = 1 then begin
                            if not TMPCont.FindFirst then
                                CurrReport.Break
                        end else
                            if TMPCont.Next = 0 then
                                CurrReport.Break;
                    end;
                }

                trigger OnAfterGetRecord()
                begin
                    TMPCont.DeleteAll;
                    Cont2.Reset;
                    Cont2.SetFilter("No.", '<>%1', "No.");

                    if CheckName then
                        Cont2.SetRange(Name, Name);
                    if CheckAddr then
                        Cont2.SetRange(Address, Address);
                    if CheckPhone then
                        Cont2.SetRange("Phone No.", "Phone No.");

                    if Cont2.FindSet then
                        repeat
                            TMPCont.Init;
                            TMPCont.TransferFields(Cont2);
                            TMPCont.Insert;
                        until Cont2.Next = 0
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
                field(CheckName; CheckName)
                {
                    Caption = 'Name';
                    ApplicationArea = All;
                }
                field(CheckAddr; CheckAddr)
                {
                    Caption = 'Address';
                    ApplicationArea = All;
                }
                field(CheckPhone; CheckPhone)
                {
                    Caption = 'Phone No.';
                    ApplicationArea = All;
                }
            }
        }

        actions
        {
        }
    }

    labels
    {
        Original = 'Contact';
        Duplicate = 'Matching Contacts';
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
        CheckName: Boolean;
        CheckAddr: Boolean;
        CheckPhone: Boolean;
        Cont2: Record Contact;
        TMPCont: Record Contact temporary;
        SearchFilter: Text;
        Company: Record "Company Information";
        Text001: Label 'Tick one of the check boxes';
        Text002: Label 'Search based on: ';
        Text003: Label 'Name';
        Text004: Label 'Address';
        Text005: Label ' and Address';
        Text006: Label 'Phone No.';
        Text007: Label ' and Phone No.';
}

