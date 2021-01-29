report 6014503 "NPR Repair Guarantee"
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Repair Guarantee.rdlc'; 
    UsageCategory = ReportsAndAnalysis; 
    ApplicationArea = All;
    Caption = 'Repair Guarantee';
    PreviewMode = PrintLayout;
    dataset
    {
        dataitem("Customer Repair"; "NPR Customer Repair")
        {
            RequestFilterFields = "No.";
            column(CompanyInfoPicture; CompanyInformation.Picture)
            {
            }
            column(Adresselinie; AddrLine)
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
            column(RepairNo; Text001 + ' ' + Format("No."))
            {
            }
            column(CompanyInfo; Format(Today, 0, 4))
            {
            }
            column(GlobalDim; GlobalDimension1Desc + ' ' + "Global Dimension 1 Code")
            {
            }
            column(Repair; Text010)
            {
            }
            column(Text011; Text011)
            {
            }
            column(Text012; Text012)
            {
            }
            column(Text013; Text013)
            {
            }
            column(Text014; Text014)
            {
            }
            column(ItemDescription; "Item Description")
            {
            }
            column(PriceIncludingVAT; "Prices Including VAT")
            {
            }
            column(HandedInDate; Format("Handed In Date", 0, 1))
            {
            }
            column(Delivered; Delivered)
            {
            }
            column(Claimed; Claimed)
            {
            }
            column(DefectDescription; Text017)
            {
            }
            column(RepairDescription; Text018)
            {
            }
            column(Thanks; Text009)
            {
            }
            column(ThanksCompanyName; CompanyInformation.Name)
            {
            }
            column(AddressFooter; DotDisplay + AddrLine + DotDisplay + Text005 + CompanyInformation."Phone No." + DotDisplay + Text006 + CompanyInformation."Fax No.")
            {
            }
            column(AddressFooter2; DotDisplay + Text003 + CompanyInformation."E-Mail" + DotDisplay + Text004 + CompanyInformation."VAT Registration No.")
            {
            }
            column(TextWarranty; Text019)
            {
            }
            column(AddrLine; AddrLine)
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
                column(RepairFound; RepairFound)
                {
                }

                trigger OnAfterGetRecord()
                begin

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
                Clear(GlobalDimension1Desc);
                if ("Customer Repair"."Global Dimension 1 Code") <> '' then
                    GlobalDimension1Desc := CaptionClassTranslate('1,1,1,,');
                TelephoneText := '';
                if "Phone No." <> '' then
                    TelephoneText := Text005;

                MobileText := '';
                if "Mobile Phone No." <> '' then
                    MobileText := Text020;

                FormAdr.Company(CompanyAddr, CompanyInformation);
                Clear(CustAddress);
                CustAddress[1] := Name;
                CustAddress[2] := Address;
                CustAddress[3] := "Address 2";
                CustAddress[4] := Format("Post Code") + ' ' + City;
                CustAddress[5] := TelephoneText + ' ' + Format("Phone No.");
                CustAddress[6] := MobileText + ' ' + Format("Mobile Phone No.");
                CompressArray(CustAddress);

                AddrLine := '';
                for AddrLineCounter := 1 to 4 do begin
                    if CompanyAddr[AddrLineCounter] <> '' then begin
                        if StrLen(AddrLine) <> 0 then
                            AddrLine := AddrLine + '  ';
                        AddrLine := AddrLine + CompanyAddr[AddrLineCounter];
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
        DefectFound: Boolean;
        RepairFound: Boolean;
        AddrLineCounter: Integer;
        Text004: Label 'CVR No.: ';
        Text017: Label 'Defect Description';
        Text003: Label 'E-mail: ';
        Text006: Label 'Fax No.: ';
        Text013: Label 'Handed In';
        Text011: Label 'Item';
        Text016: Label 'Item No. %1';
        Text020: Label 'Mobile:';
        Text007: Label 'Phone:';
        Text012: Label 'Price Incl. VAT';
        Text018: Label 'Repair Description';
        Text010: Label 'Repair Guarantee';
        Text002: Label 'Repair no. %1';
        Text001: Label 'Repair No.:';
        Text014: Label 'Returned';
        Text005: Label 'Telephone: ';
        Text019: Label 'We give one year guarantee on all new parts and all adjustments. In case there are any problems we ask you to contact us immediately with presentation of this guarantee card';
        Text009: Label 'Yours sincerely, ';
        DotDisplay: Text;
        MobileText: Text;
        StarDisplay: Text;
        TelephoneText: Text;
        CompanyAddr: array[8] of Text[50];
        CustAddress: array[8] of Text[50];
        GlobalDimension1Desc: Text[80];
        AddrLine: Text[100];
}

