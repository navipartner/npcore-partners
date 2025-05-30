﻿report 6060112 "NPR Check Duplicate Contacts"
{
    #IF NOT BC17 
    Extensible = False; 
    #ENDIF
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Check Duplicate Contacts.rdlc';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = NPRRetail;
    Caption = 'Check Duplicate Contacts';
    DataAccessIntent = ReadOnly;

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
                    column(Temp_Contact_No; TempCont."No.")
                    {
                        IncludeCaption = true;
                    }
                    column(Temp_Contact_Name; TempCont.Name)
                    {
                        IncludeCaption = true;
                    }
                    column(Temp_Contact_Address; TempCont.Address)
                    {
                        IncludeCaption = true;
                    }
                    column(Temp_Contact_Phone_No; TempCont."Phone No.")
                    {
                        IncludeCaption = true;
                    }

                    trigger OnAfterGetRecord()
                    begin
                        if Number = 1 then begin
                            if not TempCont.FindFirst() then
                                CurrReport.Break()
                        end else
                            if TempCont.Next() = 0 then
                                CurrReport.Break();
                    end;
                }

                trigger OnAfterGetRecord()
                begin
                    TempCont.DeleteAll();
                    Cont2.Reset();
                    Cont2.SetFilter("No.", '<>%1', "No.");

                    if CheckName then
                        Cont2.SetRange(Name, Name);
                    if CheckAddr then
                        Cont2.SetRange(Address, Address);
                    if CheckPhone then
                        Cont2.SetRange("Phone No.", "Phone No.");

                    if Cont2.FindSet() then
                        repeat
                            TempCont.Init();
                            TempCont.TransferFields(Cont2);
                            TempCont.Insert();
                        until Cont2.Next() = 0
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
        SaveValues = true;
        layout
        {
            area(content)
            {
                field("Check Name"; CheckName)
                {
                    Caption = 'Name';

                    ToolTip = 'Specifies the value of the Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Check Addr"; CheckAddr)
                {
                    Caption = 'Address';

                    ToolTip = 'Specifies the value of the Address field';
                    ApplicationArea = NPRRetail;
                }
                field("Check Phone"; CheckPhone)
                {
                    Caption = 'Phone No.';

                    ToolTip = 'Specifies the value of the Phone No. field';
                    ApplicationArea = NPRRetail;
                }
            }
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
        Cont2: Record Contact;
        TempCont: Record Contact temporary;
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

