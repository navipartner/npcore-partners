report 6014504 "Customer Note"
{
    // NPR4.14/TR/20150811  CASE 183284 Output modifications made on report.
    // NPR5.27/JLK /20161019  CASE 255020 Changes made in rdlc layout and variables changed to be descriptive in ENU
    // NPR5.36/JLK /20170921  CASE 286803 Increased length variable CompanyAddr to [50]
    // TM1.39/THRO/20181126  CASE 334644 Replaced Coudeunit 1 by Wrapper Codeunit
    // NPR5.50/ZESO/201905006 CASE 353382 Remove Reference to Wrapper Codeunit
    DefaultLayout = RDLC;
    RDLCLayout = './layouts/Customer Note.rdlc';

    Caption = 'Customer Note';
    PreviewMode = PrintLayout;

    dataset
    {
        dataitem("Customer Repair";"Customer Repair")
        {
            RequestFilterFields = "No.","Customer No.";
            column(CompanyInfoPicture;CompanyInformation.Picture)
            {
            }
            column(Report_Cap;ReportCap)
            {
            }
            column(AdresseLinieCaption;StarDisplay)
            {
            }
            column(DebAddress1;DebAddress[1])
            {
            }
            column(DebAddress2;DebAddress[2])
            {
            }
            column(DebAddress3;DebAddress[3])
            {
            }
            column(DebAddress4;DebAddress[4])
            {
            }
            column(DebAddress5;DebAddress[5])
            {
            }
            column(DebAddress6;DebAddress[6])
            {
            }
            column(DebAddress7;DebAddress[7])
            {
            }
            column(DebAddress8;DebAddress[8])
            {
            }
            column(RepairNo;StrSubstNo(Text001,"No."))
            {
            }
            column(ItemDescription;"Item Description")
            {
            }
            column(SerialNo;"Serial No.")
            {
            }
            column(Accessories;Accessories + ' ' +"Accessories 1")
            {
            }
            column(Warranty;Format(Worranty))
            {
            }
            column(EstimatedPrice;PriceText)
            {
            }
            column(HandedInDate;Format("Handed In Date",0,1))
            {
            }
            column(ExpedtedCompletionDate;Format("Expected Completion Date",0,1))
            {
            }
            column(PrinceIncVAT;"Prices Including VAT")
            {
            }
            column(SalesName;SalesPerson.Name)
            {
            }
            column(PriceNotAccepted;PriceNotAccepted)
            {
            }
            column(ThanksCompanyName;CompanyInformation.Name)
            {
            }
            column(AddressFooter;DotDisplay + ' ' + AdresseLine + DotDisplay + Text004 + CompanyInformation."Phone No." + DotDisplay + Text005 + CompanyInformation."Fax No." + ' ' + DotDisplay)
            {
            }
            column(AddressFooter2;DotDisplay + Text002 + CompanyInformation."E-Mail" + DotDisplay + Text003 + CompanyInformation."VAT Registration No." + ' ' + DotDisplay)
            {
            }
            column(CompanyInfoHeader;Format(Today,0,4))
            {
            }
            column(GlobalDimensionDescription;GlobalDimension1Desc + ' ' + "Global Dimension 1 Code")
            {
            }
            column(HandledIn;Text008)
            {
            }
            column(EstCompletion;Text009)
            {
            }
            column(Salesperson;Text010)
            {
            }
            column(Thanks;Text007)
            {
            }
            column(Notice1;Text012)
            {
            }
            column(Notice2;Text013)
            {
            }
            column(Notice3;Text014)
            {
            }
            column(Notice4;StrSubstNo(Text015,CompanyInformation."Phone No.",CompanyInformation."E-Mail"))
            {
            }

            trigger OnAfterGetRecord()
            begin
                Clear(GlobalDimension1Desc);
                if("Customer Repair"."Global Dimension 1 Code") <> '' then
                  //-#[353382] [353382]
                  //-TM1.39 [334644]
                  //GlobalDimension1Desc := SystemEventWrapper.CaptionClassTranslate(CurrReport.LANGUAGE,'1,1,1,,');
                  //+TM1.39 [334644]
                  GlobalDimension1Desc := CaptionClassTranslate('1,1,1,,');
                  //+#[353382] [353382]

                TelephoneText := '';
                if "Phone No." <> '' then
                  TelephoneText := Text004;

                MobileText := '';
                if "Mobile Phone No." <> '' then
                  MobileText := Text016;

                Clear(PriceText);
                Clear(DebAddress);

                if "Prices Including VAT" <> 0 then
                  PriceText := Text006;

                if SalesPerson.Get("Salesperson Code") then;

                FormAdr.Company(CompanyAddr,CompanyInformation);

                DebAddress[1]:=Name;
                DebAddress[2]:=Address;
                DebAddress[3]:="Address 2";
                DebAddress[4]:=Format("Post Code")+' '+City;
                DebAddress[5]:=TelephoneText + ' ' + Format("Phone No.");
                DebAddress[6]:=MobileText + ' ' + Format("Mobile Phone No.");
                CompressArray(DebAddress);

                AdresseLine:='';
                for AdresseLineCounter := 1 to 4 do begin
                  if CompanyAddr[AdresseLineCounter] <> '' then begin
                    if StrLen(AdresseLine) <> 0 then
                      AdresseLine := AdresseLine + '  ';
                    AdresseLine := AdresseLine+CompanyAddr[AdresseLineCounter];
                  end;
                end;
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
        SerieNoLbl = 'Serial No.:';
        VareLbl = 'Item:';
        AccessoriesLbl = 'Accessory:';
        WarantyLbl = 'Guarantee:';
    }

    trigger OnPreReport()
    begin
        DotDisplay := '  ';
        StarDisplay := '*';
    end;

    var
        ReportCap: Label 'Customer Note';
        Text001: Label 'Repair No.: %1';
        Text002: Label 'E-mail: ';
        Text003: Label 'CVR No.: ';
        Text004: Label 'Telephone: ';
        Text005: Label 'Fax No.: ';
        Text006: Label 'Price Incl. VAT';
        Text007: Label 'Yours sincerely, ';
        Text008: Label 'Handed In:';
        Text009: Label 'Est. Completion:';
        Text010: Label 'Sales Person';
        CompanyInformation: Record "Company Information";
        FormAdr: Codeunit "Format Address";
        DebAddress: array [8] of Text[50];
        AdresseLine: Text[100];
        AdresseLineCounter: Integer;
        CompanyAddr: array [8] of Text[50];
        PriceNotAccepted: Text[100];
        SalesPerson: Record "Salesperson/Purchaser";
        PriceText: Text[30];
        GlobalDimension1Desc: Text[80];
        DotDisplay: Text;
        StarDisplay: Text;
        Text012: Label 'For complaints regarding your product, it will be sent for examination by a specialist workshop. Errors will be corrected at no cost for you unless the product shows signs of abuse, shock, moisture damage or excessive wear. You will be notified if any of the above is found.';
        Text013: Label 'In case of faults/damage caused by misuse or shock/moisture you will be presented with an offer for repair. If you do not want the product repaired, you must pay the cost of the price estimate.';
        Text014: Label 'Finished repairs are stored 6 months from arrival';
        Text015: Label 'For questions regarding your repair you can contact us on %1 or E-mail %2';
        TelephoneText: Text;
        Text016: Label 'Mobile:';
        MobileText: Text;
}

