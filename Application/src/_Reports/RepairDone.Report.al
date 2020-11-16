report 6014502 "NPR Repair Done"
{
    // NPR5.27/JLK /20161019  CASE 255004 Corrected rdlc and adjusted layout to requirements
    //                                    Some variables and text constant name changed
    //                                    Removed Register Information
    // NPR5.36/JLK /20170921  CASE 286803 Increased length variable CompanyAddr to [50]
    // TM1.39/THRO/20181126  CASE 334644 Replaced Coudeunit 1 by Wrapper Codeunit
    // NPR5.50/ZESO/201905006 CASE 353382 Remove Reference to Wrapper Codeunit
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Repair Done.rdlc';

    Caption = 'Repair Done';
    PreviewMode = PrintLayout;

    dataset
    {
        dataitem("Customer Repair"; "NPR Customer Repair")
        {
            column(CompanyInfoPicture; CompanyInformation.Picture)
            {
            }
            column(AdresseLinieCaption; StarDisplay)
            {
            }
            column(DebAddress1; DebAddress[1])
            {
            }
            column(DebAddress2; DebAddress[2])
            {
            }
            column(DebAddress3; DebAddress[3])
            {
            }
            column(DebAddress4; DebAddress[4])
            {
            }
            column(DebAddress5; DebAddress[5])
            {
            }
            column(DebAddress6; DebAddress[6])
            {
            }
            column(DebAddress7; DebAddress[7])
            {
            }
            column(DebAddress8; DebAddress[8])
            {
            }
            column(RepairNo; Text002 + Format("No."))
            {
            }
            column(CompanyInformation; Format(Today, 0, 4))
            {
            }
            column(GlobalDimension; GlobDim1Desc + ' ' + "Global Dimension 1 Code")
            {
            }
            column(Repair; Repair_Cap)
            {
            }
            column(Name; StrSubstNo(Text003, Name))
            {
            }
            column(RepairDescription; StrSubstNo(Text004, "Item Description"))
            {
            }
            column(PriceIncludingVAT; Text006 + Format("Prices Including VAT") + ',-')
            {
            }
            column(ThanksCompanyName; CompanyInformation.Name)
            {
            }
            column(AddressFooter; DotDisplay + AdresseLine + DotDisplay + Text007 + CompanyInformation."Phone No." + DotDisplay + Text008 + CompanyInformation."Fax No." + DotDisplay)
            {
            }
            column(AddressFooter2; DotDisplay + Text009 + CompanyInformation."E-Mail" + DotDisplay + Text010 + CompanyInformation."VAT Registration No." + DotDisplay)
            {
            }
            column(RepairNotice2; StrSubstNo(Text005, CompanyInformation."Phone No.", CompanyInformation."E-Mail"))
            {
            }
            column(Thanks; Text011)
            {
            }
            column(RepairNotice1; Text012)
            {
            }
            column(RepairLbl; Text013)
            {
            }
            column(DefectLbl; Text014)
            {
            }
            dataitem(ErrorCustomerRepairJournal; "NPR Customer Repair Journal")
            {
                DataItemLink = "Customer Repair No." = FIELD("No.");
                DataItemTableView = SORTING("Customer Repair No.", Type, "Line No.") WHERE(Type = CONST(Fejlbeskrivelse));
                column(CustomerRepairlNo_ErrorCustomerRepairJournal; "Customer Repair No.")
                {
                }
                column(Text_ErrorCustomerRepairJournal; Text)
                {
                }
                column(LineNo_ErrorCustomerRepairJournal; "Line No.")
                {
                }
                column(DefectFound; DefectFound)
                {
                }

                trigger OnAfterGetRecord()
                begin
                    if (Text <> '') then
                        DefectFound := true;
                end;

                trigger OnPreDataItem()
                begin
                    DefectFound := false;
                end;
            }
            dataitem(RepairCustomerRepairJournal; "NPR Customer Repair Journal")
            {
                DataItemLink = "Customer Repair No." = FIELD("No.");
                DataItemTableView = SORTING("Customer Repair No.", Type, "Line No.") WHERE(Type = CONST(Reparationsbeskrivelse));
                column(CustomerRepairNo_RepairCustomerRepairJournal; "Customer Repair No.")
                {
                }
                column(LineNo_RepairCustomerRepairJournal; "Line No.")
                {
                }
                column(Text_RepairCustomerRepairJournal; Text)
                {
                }
                column(ItemPartNo_RepairCustomerRepairJournal; "Item Part No.")
                {
                }
                column(Description_Item; Item.Description)
                {
                }
                column(RepairFound; RepairFound)
                {
                }

                trigger OnAfterGetRecord()
                begin
                    if Item.Get("Item Part No.") then;

                    if (Text <> '') then
                        RepairFound := true;
                end;

                trigger OnPreDataItem()
                begin
                    RepairFound := false;
                end;
            }

            trigger OnAfterGetRecord()
            begin
                Clear(GlobDim1Desc);
                if ("Customer Repair"."Global Dimension 1 Code") <> '' then
                    //-#[353382] [353382]
                    //-TM1.39 [334644]
                    //GlobDim1Desc := SystemEventWrapper.CaptionClassTranslate(CurrReport.LANGUAGE,'1,1,1,,');
                    //+TM1.39 [334644]
                    GlobDim1Desc := CaptionClassTranslate('1,1,1,,');
                //+#[353382] [353382]
                FormAdr.Company(CompanyAddr, CompanyInformation);

                TelephoneText := '';
                if "Phone No." <> '' then
                    TelephoneText := Text007;

                MobileText := '';
                if "Mobile Phone No." <> '' then
                    MobileText := Text015;

                Clear(DebAddress);
                DebAddress[1] := Name;
                DebAddress[2] := Address;
                DebAddress[3] := "Address 2";
                DebAddress[4] := Format("Post Code") + ' ' + City;
                DebAddress[5] := TelephoneText + ' ' + Format("Phone No.");
                DebAddress[6] := MobileText + ' ' + Format("Mobile Phone No.");
                CompressArray(DebAddress);

                AdresseLine := '';
                for AdresseLineCounter := 1 to 4 do begin
                    if CompanyAddr[AdresseLineCounter] <> '' then begin
                        if StrLen(AdresseLine) <> 0 then
                            AdresseLine := AdresseLine + '  ';
                        AdresseLine := AdresseLine + CompanyAddr[AdresseLineCounter];
                    end;
                end;

                if "Price when Not Accepted" <> 0 then
                    PriceNotAccepted := Text001 + Format("Price when Not Accepted");
            end;

            trigger OnPreDataItem()
            begin
                CompanyInformation.Get;
                CompanyInformation.CalcFields(Picture);
            end;
        }
    }

    requestpage
    {

        layout
        {
        }

        actions
        {
        }
    }

    labels
    {
        ItemNo = 'Item No.';
    }

    trigger OnPreReport()
    begin
        DotDisplay := '  ';
        StarDisplay := '*';
    end;

    var
        CompanyInformation: Record "Company Information";
        FormAdr: Codeunit "Format Address";
        DebAddress: array[8] of Text[50];
        PriceNotAccepted: Text[100];
        AdresseLine: Text[100];
        AdresseLineCounter: Integer;
        CompanyAddr: array[8] of Text[50];
        GlobDim1Desc: Text[80];
        Repair_Cap: Label 'Notice of Repair Done ';
        Text001: Label 'For not-accepted repair offers we invoice LCY  ';
        Text002: Label 'Repair No.: ';
        Text003: Label 'Dear %1';
        Text004: Label 'Your %1 is ready for pickup';
        Text005: Label 'For questions regarding your repair you can contact us on %1 or E-mail %2';
        Text006: Label 'The repair costs amount to LCY incl. VAT: ';
        Text007: Label 'Telephone: ';
        Text008: Label 'Fax No.: ';
        Text009: Label 'E-mail: ';
        Text010: Label 'CVR No.: ';
        Text011: Label 'Yours sincerely, ';
        Text012: Label 'Finished repairs are stored 6 months from arrival';
        Text013: Label 'Repair Description';
        Text014: Label 'Defect Description';
        DotDisplay: Text;
        StarDisplay: Text;
        Item: Record Item;
        DefectFound: Boolean;
        RepairFound: Boolean;
        TelephoneText: Text;
        MobileText: Text;
        Text015: Label 'Mobile: ';
}

