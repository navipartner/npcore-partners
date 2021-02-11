report 6014505 "NPR Delivery Note"
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Delivery Note.rdlc'; 
    UsageCategory = ReportsAndAnalysis; 
    ApplicationArea = All;
    Caption = 'Delivery Note';
    PreviewMode = PrintLayout;
    dataset
    {
        dataitem("Customer Repair"; "NPR Customer Repair")
        {
            column(COMPANYNAME; CompanyName)
            {
            }
            column(CustAddress1; CustAddress[1])
            {
            }
            column(CustAddress2; CustAddress[2])
            {
            }
            column(CustAddress3; CustAddress[3])
            {
            }
            column(CustAddress4; CustAddress[4])
            {
            }
            column(CustAddress5; CustAddress[5])
            {
            }
            column(CustAddress6; CustAddress[6])
            {
            }
            column(CustAddress7; CustAddress[7])
            {
            }
            column(CustAddress8; CustAddress[8])
            {
            }
            column(CompanyInformationCity; CompanyInformation.City)
            {
            }
            column(CompanyInformationName; CompanyInformation.Name)
            {
            }
            column(CompanyInformationPicture; CompanyInformation.Picture)
            {
            }
            column(CompanyInformationPhoneNo; CompanyInformation."Phone No.")
            {
            }
            column(CustRepairGlobalDim1; GlobalDimension1Desc + '  ' + "Global Dimension 1 Code")
            {
            }
            column(AddrLine; AddressLine)
            {
            }
            column(CustomerRepairStatus; "Customer Repair".Status)
            {
            }
            column(AddressFooter; DotDisplay + AddressLine + DotDisplay + Text006 + CompanyInformation."Phone No." + DotDisplay + Text007 + CompanyInformation."Fax No." + DotDisplay)
            {
            }
            column(AddressFooter2; DotDisplay + Text004 + CompanyInformation."E-Mail" + DotDisplay + Text005 + CompanyInformation."VAT Registration No." + DotDisplay)
            {
            }
            column(RepairNo; Text003 + ' ' + Format("No."))
            {
            }
            column(Today; Format(Today, 0, 4))
            {
            }
            column(NameCaption; Text008)
            {
            }
            column(Name; Name)
            {
            }
            column(HandedInCaption; Text009)
            {
            }
            column(HandedIn; Format("Handed In Date", 0, 1))
            {
            }
            column(GuaranteeCaption; Text010)
            {
            }
            column(Guarantee; Format(Worranty, 0))
            {
            }
            column(EquipmentCaption; Text011)
            {
            }
            column(ItemDescription; "Item Description")
            {
            }
            column(SerialNoCaption; Text012)
            {
            }
            column(SerialNo; "Serial No.")
            {
            }
            column(AccessoriesCaption; Text013)
            {
            }
            column(Accessories; Accessories)
            {
            }
            column(Accessories1; "Accessories 1")
            {
            }
            column(DefectDescCaption; Text014)
            {
            }
            column(RepairDescription; Text017)
            {
            }
            column(Thanks; Text015)
            {
            }
            column(PictureDocumentation1; "Picture Documentation1")
            {
            }
            column(PictureDocumentation2; "Picture Documentation2")
            {
            }
            column(Table_Cap; Text016)
            {
            }
            column(LetterText1; LetterText[1])
            {
            }
            column(LetterText2; LetterText[2])
            {
            }
            column(LetterText3; LetterText[3])
            {
            }
            column(LetterText4; LetterText[4])
            {
            }
            column(LetterText5; LetterText[5])
            {
            }
            column(CompanyAddr1; CompanyAddr[1])
            {
            }
            column(CompanyAddr2; CompanyAddr[2])
            {
            }
            column(CompanyAddr3; CompanyAddr[3])
            {
            }
            column(CompanyAddr4; CompanyAddr[4])
            {
            }
            column(CompanyAddr5; CompanyAddr[5])
            {
            }
            column(CompanyAddr6; CompanyAddr[6])
            {
            }
            column(CompanyAddr7; CompanyAddr[7])
            {
            }
            column(CompanyAddr8; CompanyAddr[8])
            {
            }
            dataitem(CustomerRepairJournalDefect; "NPR Customer Repair Journal")
            {
                DataItemLink = "Customer Repair No." = FIELD("No.");
                DataItemTableView = SORTING("Customer Repair No.", Type, "Line No.") WHERE(Type = CONST(Fejlbeskrivelse));
                column(DefectLineNo; "Line No.")
                {
                }
                column(DefectText; Text)
                {
                }
                column(DefectFound; DefectFound)
                {
                }

                trigger OnAfterGetRecord()
                begin

                    if Text <> '' then
                        DefectFound := true;
                end;

                trigger OnPreDataItem()
                begin
                    DefectFound := false;
                end;
            }

            trigger OnAfterGetRecord()
            begin
                "Customer Repair".CalcFields("Picture Documentation1", "Picture Documentation2");
                Clear(GlobalDimension1Desc);
                if ("Customer Repair"."Global Dimension 1 Code") <> '' then
                    GlobalDimension1Desc := CaptionClassTranslate('1,1,1,,');
                TelephoneText := '';
                if "Phone No." <> '' then
                    TelephoneText := Text006;

                MobileText := '';
                if "Mobile Phone No." <> '' then
                    MobileText := Text018;

                TelephoneCompText := '';
                if CompanyInformation."Phone No." <> '' then
                    TelephoneCompText := Text006;

                CompanyAddr[1] := CompanyInformation.Name;
                CompanyAddr[2] := CompanyInformation.Address;
                CompanyAddr[3] := CompanyInformation."Address 2";
                CompanyAddr[4] := Format(CompanyInformation."Post Code") + ' ' + CompanyInformation.City;
                CompanyAddr[5] := TelephoneCompText + ' ' + Format(CompanyInformation."Phone No.");
                CompressArray(CompanyAddr);

                Clear(CustAddress);
                CustAddress[1] := Name;
                CustAddress[2] := Address;
                CustAddress[3] := "Address 2";
                CustAddress[4] := Format("Post Code") + ' ' + City;
                CustAddress[5] := TelephoneText + ' ' + Format("Phone No.");
                CustAddress[6] := MobileText + ' ' + Format("Mobile Phone No.");
                CompressArray(CustAddress);

                AddressLine := '';
                for AddressLineCounter := 1 to 4 do begin
                    if CompanyAddr[AddressLineCounter] <> '' then begin
                        if StrLen(AddressLine) <> 0 then
                            AddressLine := AddressLine + '  ';
                        AddressLine := AddressLine + CompanyAddr[AddressLineCounter];
                    end;
                end;
            end;

            trigger OnPreDataItem()
            begin
                CompanyInformation.Get();
                CompanyInformation.CalcFields(Picture);
            end;
        }
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                group("Letter Text")
                {
                    Caption = 'Letter Text';
                    field("LetterText[1]"; LetterText[1])
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the LetterText[1] field';
                    }
                    field("LetterText[2]"; LetterText[2])
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the LetterText[2] field';
                    }
                    field("LetterText[3]"; LetterText[3])
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the LetterText[3] field';
                    }
                    field("LetterText[4]"; LetterText[4])
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the LetterText[4] field';
                    }
                    field("LetterText[5]"; LetterText[5])
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the LetterText[5] field';
                    }
                }
            }
        }

    }

    trigger OnPreReport()
    begin
        DotDisplay := '  ';
        StarDisplay := '*';
    end;

    var
        CompanyInformation: Record "Company Information";
        FormatAddr: Codeunit "Format Address";
        DefectFound: Boolean;
        AddressLineCounter: Integer;
        Text013: Label 'Accessories';
        Text005: Label 'CVR No.: ';
        Text014: Label 'Defect Description';
        Text016: Label 'Delivery Note';
        Text004: Label 'E-mail: ';
        Text011: Label 'Equipment';
        Text007: Label 'Fax No.: ';
        Text010: Label 'Guarantee';
        Text009: Label 'Handed In';
        Text002: Label 'LCY Incl. VAT.';
        Text018: Label 'Mobile: ';
        Text008: Label 'Name';
        Text001: Label 'Price at not-accepted estimate';
        Text017: Label 'Repair Description';
        Text003: Label 'Repair No.:';
        Text012: Label 'Serial No.';
        Text006: Label 'Telephone: ';
        Text015: Label 'Yours sincerely,';
        DotDisplay: Text;
        MobileText: Text;
        StarDisplay: Text;
        TelephoneCompText: Text;
        TelephoneText: Text;
        CompanyAddr: array[8] of Text[100];
        CustAddress: array[8] of Text[100];
        LetterText: array[5] of Text[50];
        GlobalDimension1Desc: Text[80];
        AddressLine: Text[100];
}

