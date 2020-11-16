report 6014505 "NPR Delivery Note"
{
    // NPR5.25/JLK /20160803 CASE 247902 Report Upgraded from NAV 6.2
    // NPR5.27/JLK /20161024 CASE 256226 Changes in rdlc layout required
    //                                    Changes in Text constents to make use of variables for static information
    //                                    Changes in report to adapt to similar layout in all repair reports
    // NPR5.29/JLK /20161205 CASE 253270 Replaced Company Information Address in Header instead of Customer Information Address
    // NPR5.36/JLK /20170921  CASE 286803 Increased length variable CompanyAddr to [50]
    // NPR5.38/JLK /20180124  CASE 300892 Removed AL Error on ControlContainer Caption in Request Page
    // TM1.39/THRO/20181126  CASE 334644 Replaced Coudeunit 1 by Wrapper Codeunit
    // NPR5.50/ZESO/201905006 CASE 353382 Remove Reference to Wrapper Codeunit
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Delivery Note.rdlc';

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
                    //-#[353382] [353382]
                    //-TM1.39 [334644]
                    //GlobalDimension1Desc := SystemEventWrapper.CaptionClassTranslate(CurrReport.LANGUAGE,'1,1,1,,');
                    //+TM1.39 [334644]
                    GlobalDimension1Desc := CaptionClassTranslate('1,1,1,,');
                //-#[353382] [353382]
                TelephoneText := '';
                if "Phone No." <> '' then
                    TelephoneText := Text006;

                MobileText := '';
                if "Mobile Phone No." <> '' then
                    MobileText := Text018;

                //-NPR5.29
                //FormatAddr.Company(CompanyAddr,CompanyInformation);
                TelephoneCompText := '';
                if CompanyInformation."Phone No." <> '' then
                    TelephoneCompText := Text006;

                CompanyAddr[1] := CompanyInformation.Name;
                CompanyAddr[2] := CompanyInformation.Address;
                CompanyAddr[3] := CompanyInformation."Address 2";
                CompanyAddr[4] := Format(CompanyInformation."Post Code") + ' ' + CompanyInformation.City;
                CompanyAddr[5] := TelephoneCompText + ' ' + Format(CompanyInformation."Phone No.");
                CompressArray(CompanyAddr);
                //+NPR5.29

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
                    }
                    field("LetterText[2]"; LetterText[2])
                    {
                        ApplicationArea = All;
                    }
                    field("LetterText[3]"; LetterText[3])
                    {
                        ApplicationArea = All;
                    }
                    field("LetterText[4]"; LetterText[4])
                    {
                        ApplicationArea = All;
                    }
                    field("LetterText[5]"; LetterText[5])
                    {
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
    }

    trigger OnPreReport()
    begin
        DotDisplay := '  ';
        StarDisplay := '*';
    end;

    var
        CompanyInformation: Record "Company Information";
        FormatAddr: Codeunit "Format Address";
        CustAddress: array[8] of Text[50];
        AddressLine: Text[100];
        AddressLineCounter: Integer;
        CompanyAddr: array[8] of Text[50];
        GlobalDimension1Desc: Text[80];
        Text001: Label 'Price at not-accepted estimate';
        Text002: Label 'LCY Incl. VAT.';
        Text003: Label 'Repair No.:';
        Text004: Label 'E-mail: ';
        Text005: Label 'CVR No.: ';
        Text006: Label 'Telephone: ';
        Text007: Label 'Fax No.: ';
        Text008: Label 'Name';
        Text009: Label 'Handed In';
        Text010: Label 'Guarantee';
        Text011: Label 'Equipment';
        Text012: Label 'Serial No.';
        Text013: Label 'Accessories';
        Text014: Label 'Defect Description';
        Text015: Label 'Yours sincerely,';
        Text016: Label 'Delivery Note';
        Text017: Label 'Repair Description';
        LetterText: array[5] of Text[50];
        TelephoneText: Text;
        MobileText: Text;
        StarDisplay: Text;
        DotDisplay: Text;
        Text018: Label 'Mobile: ';
        DefectFound: Boolean;
        TelephoneCompText: Text;
}

