report 6014501 "NPR Repair Offer"
{
    // NPR5.25/JLK /20160622  CASE 244140 Report copied from 6.2ver
    // NPR5.27/JLK /20131025  CASE 256163 Report rdlc layout changed and accomodated to other repair reports
    //                                     Some variables and text constants renamed to more descriptive ENU words
    // NPR5.36/JLK /20170921  CASE 286803 Increased length variable CompanyAddr to [50]
    // TM1.39/THRO/20181126  CASE 334644 Replaced Coudeunit 1 by Wrapper Codeunit
    // NPR5.50/ZESO/201905006 CASE 353382 Remove Reference to Wrapper Codeunit
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Repair Offer.rdlc';

    Caption = 'Repair Offer';
    PreviewMode = PrintLayout;

    dataset
    {
        dataitem("Customer Repair"; "NPR Customer Repair")
        {
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
            column(CustomerRepairNoCaption; Text003)
            {
            }
            column(CustomerRepairNo; "No.")
            {
            }
            column(CustomerRepairNameCaption; Text004)
            {
            }
            column(TodayDate; Format(Today, 0, 4))
            {
            }
            column(CustomerRepairName; "Customer Repair".Name)
            {
            }
            column(CustomerRepairItemCaption; Text006)
            {
            }
            column(CustomerRepairItem; "Customer Repair"."Item Description")
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
            column(GlobalDimension1CodeCaption; GlobalDimension1Desc)
            {
            }
            column(GlobalDimension1Code; "Customer Repair"."Global Dimension 1 Code")
            {
            }
            column(RepairPriceAmount; Text005 + ' ' + Format("Prices Including VAT") + ',-')
            {
            }
            column(NotAcceptNotice; NotAccept)
            {
            }
            column(ContactText; Text007 + ' ' + CompanyInformation."Phone No.")
            {
            }
            column(EstDeliveryText; Text008 + ' ' + Text013 + ' ' + Format(EstDelivery) + ' ' + Text014)
            {
            }
            column(RepairEstText; Text018)
            {
            }
            column(RepairStatusReturnText; Text019)
            {
            }
            column(RepairEstNotice; Text020)
            {
            }
            column(ConfirmText; Text021)
            {
            }
            column(FooterText; Text022)
            {
            }
            column(PSText; Text023)
            {
            }
            column(AddrLine; AddrLine)
            {
            }
            column(CustomerRepairStatus; "Customer Repair".Status)
            {
            }
            column(ReturnNoRepair; ReturnNoRepair)
            {
            }
            column(AddressFooter; DotDisplay + AddrLine + DotDisplay + Text009 + CompanyInformation."Phone No." + DotDisplay + Text010 + CompanyInformation."Fax No." + DotDisplay)
            {
            }
            column(AddressFooter2; DotDisplay + Text011 + CompanyInformation."E-Mail" + DotDisplay + Text012 + CompanyInformation."VAT Registration No." + DotDisplay)
            {
            }
            dataitem("Customer Repair Journal"; "NPR Customer Repair Journal")
            {
                DataItemLink = "Customer Repair No." = FIELD("No.");
                DataItemTableView = SORTING("Customer Repair No.", Type, "Line No.") WHERE(Type = CONST(Reparationsbeskrivelse));
                column(Text_CustomerRepairJournal; "Customer Repair Journal".Text)
                {
                }
                column(TextCaption_CustomerRepairJournal; Text025)
                {
                }
                column(RepairCount; RepairCount)
                {
                }

                trigger OnAfterGetRecord()
                begin
                    if ReturnNoRepair then
                        CurrReport.Break;

                    RepairCount := RepairCount + 1;
                end;

                trigger OnPreDataItem()
                begin
                    RepairCount := 0;
                end;
            }

            trigger OnAfterGetRecord()
            begin

                if "Customer Repair".Status = "Customer Repair".Status::"Return No Repair" then
                    ReturnNoRepair := true;

                Clear(GlobalDimension1Desc);
                if ("Customer Repair"."Global Dimension 1 Code") <> '' then
                    //-#[353382] [353382]
                    //-TM1.39 [334644]
                    //GlobalDimension1Desc := SystemEventWrapper.CaptionClassTranslate(CurrReport.LANGUAGE,'1,1,1,,');
                    //+TM1.39 [334644]
                    GlobalDimension1Desc := CaptionClassTranslate('1,1,1,,');
                //+#[353382] [353382]
                CompanyInformation.Get;
                CompanyInformation.CalcFields(Picture);

                FormatAddr.Company(CompanyAddr, CompanyInformation);

                TelephoneText := '';
                if "Phone No." <> '' then
                    TelephoneText := Text009;

                MobileText := '';
                if "Mobile Phone No." <> '' then
                    MobileText := Text024;

                Clear(CustAddress);
                CustAddress[1] := Name;
                CustAddress[2] := Address;
                CustAddress[3] := "Address 2";
                CustAddress[4] := Format("Post Code") + ' ' + City;
                CustAddress[5] := TelephoneText + ' ' + Format("Phone No.");
                CustAddress[6] := MobileText + ' ' + Format("Mobile Phone No.");
                CompressArray(CustAddress);

                AddrLine := '';
                for AddrLineCount := 1 to 4 do begin
                    if CompanyAddr[AddrLineCount] <> '' then begin
                        if StrLen(AddrLine) <> 0 then
                            AddrLine := AddrLine + '  ';
                        AddrLine := AddrLine + CompanyAddr[AddrLineCount];
                    end;
                end;


                if "Price when Not Accepted" <> 0 then
                    NotAccept := Text001 + ' ' + Text002 + ' ' + Format("Price when Not Accepted") + ',-'
                else
                    NotAccept := '';

                if "Expected Completion Date" <> 0D then
                    EstDelivery := Format("Expected Completion Date" - "Handed In Date" + 2) + Text016
                else
                    EstDelivery := Text017;

                "Customer Repair Journal".SetFilter("Customer Repair Journal"."Customer Repair No.", "Customer Repair"."No.");
                "Customer Repair Journal".SetRange("Customer Repair Journal".Type, "Customer Repair Journal".Type::Reparationsbeskrivelse);
                RepDescription := "Customer Repair Journal".Text;
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
        NotAccept: Text[150];
        AddrLine: Text[100];
        AddrLineCount: Integer;
        CompanyAddr: array[8] of Text[50];
        Customer: Record Customer;
        EstDelivery: Text[30];
        GlobalDimension1Desc: Text[80];
        RepDescription: Text[100];
        Text001: Label 'For not-accepted repair offers we invoice';
        Text002: Label 'LCY Incl. VAT';
        Text003: Label 'Repair No.:';
        Text004: Label 'Dear ';
        Text005: Label 'The Repair Costs will amount to LCY ';
        Text006: Label 'We have today received an answer from our repairer concerning your repair of ';
        Text007: Label 'If you need more information, please contact us on Tel. No.: ';
        Text008: Label 'If you';
        Text009: Label 'Telephone: ';
        Text010: Label 'Fax No.: ';
        Text011: Label 'E-mail: ';
        Text012: Label 'CVR No.: ';
        Text013: Label 'want execution of the submitted repair, the delivery will be approximately';
        Text014: Label 'from receipt of your';
        Text016: Label ' days';
        Text017: Label '2-4 weeks';
        Text018: Label 'Repair Offer';
        Text019: Label 'The repair could not be carried out, but the product can be found in our shop';
        Text020: Label 'The repair estimate is incl. VAT. In case of hidden defects, the price may be changed.';
        Text021: Label 'confirmation.';
        Text022: Label 'Yours sincerely,';
        Text023: Label 'In accordance with existing law, completed repairs are kept for up to 6 months and are then sold at the market price.';
        ReturnNoRepair: Boolean;
        RepairCount: Integer;
        TelephoneText: Text;
        MobileText: Text;
        Text024: Label 'Mobile: ';
        DotDisplay: Text;
        StarDisplay: Text;
        Text025: Label 'Repair Description';
}

