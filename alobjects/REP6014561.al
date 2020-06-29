report 6014561 "Gift Voucher A5"
{
    // NPR4.16/KN/20151009 CASE 220371   Created report based on report 55251 in Smykkebasen
    // NPR4.18/KN/20160128 CASE 232717   Increased report margins in layout
    // NPR5.38/JLK /20180124  CASE 300892 Corrected AL Error on blank Text Constants Text1002 to Text1006
    // NPR5.38/JLK /20180125  CASE 303595 Added ENU object caption
    // NPR5.40/JLK /20180307  CASE 307438 Removed unused Audit Roll variable
    DefaultLayout = RDLC;
    RDLCLayout = './layouts/Gift Voucher A5.rdlc';

    Caption = 'Gift Voucher A5';

    dataset
    {
        dataitem("Integer"; "Integer")
        {
            dataitem("Gift Voucher"; "Gift Voucher")
            {
                column(CopyText; CopyText)
                {
                }
                column(No_GiftVoucher; "Gift Voucher"."No.")
                {
                }
                column(Amount_GiftVoucher; "Gift Voucher".Amount)
                {
                    DecimalPlaces = 2 : 2;
                    IncludeCaption = true;
                }
                column(Name_GiftVoucher; "Gift Voucher".Name)
                {
                }
                column(Address_GiftVoucher; "Gift Voucher".Address)
                {
                }
                column(IssueDate_GiftVoucher; "Gift Voucher"."Issue Date")
                {
                }
                column(RegisterNo_GiftVoucher; "Gift Voucher"."Register No.")
                {
                }
                column(SalesTicketNo_GiftVoucher; "Gift Voucher"."Sales Ticket No.")
                {
                }
                column(ZipCodeCityText; ZipCodeCityText)
                {
                }
                column(DetailsText; DetailsText)
                {
                }
                column(Barcode; TempBlob.Blob)
                {
                }
                column(SalesPersonText; SalesPersonText)
                {
                }
                dataitem(Register; Register)
                {
                    DataItemLink = "Register No." = FIELD("Register No.");
                    column(Name_Register; Register.Name)
                    {
                    }
                    column(Address_Register; Register.Address)
                    {
                    }
                    column(Email_Register; Register."E-mail")
                    {
                    }
                    column(WebAddress_Register; Register.Website)
                    {
                    }
                    column(RegisterPhoneText; RegisterPhoneText)
                    {
                    }
                    column(RegisterPostCodeAndCityText; RegisterPostCodeAndCityText)
                    {
                    }
                    column(RegisterVatNoText; RegisterVatNoText)
                    {
                    }

                    trigger OnAfterGetRecord()
                    begin
                        RegisterPhoneText := StrSubstNo(Text1002, Register."Phone No.");
                        RegisterPostCodeAndCityText := Register."Post Code" + ' ' + Register.City;
                        RegisterVatNoText := StrSubstNo(Text1003, Register."VAT No.");
                    end;
                }

                trigger OnAfterGetRecord()
                var
                    SalesPerson: Record "Salesperson/Purchaser";
                begin
                    "Gift Voucher"."No. Printed" += 1;
                    "Gift Voucher".Modify(false);

                    if ("Gift Voucher"."No. Printed" > 1) and (RetailSetup."Copy No. on Sales Ticket") then
                        CopyText := Text1001;

                    DetailsText := Format("Issue Date") + ' ' + "Register No." + ' ' + "Sales Ticket No." + ' - ' + "No." + ' - ' + Format(Time);

                    //+NPR5.38
                    ZipCodeCityText := "ZIP Code";
                    if ZipCodeCityText <> '' then
                        ZipCodeCityText += ', ' + City
                    else
                        ZipCodeCityText += City;
                    //-NPR5.38

                    BarcodeLib.GenerateBarcode("Gift Voucher"."No.", TempBlob);

                    if Get("Gift Voucher".Salesperson) then
                        if RetailSetup."Salesperson on Sales Ticket" then
                            SalesPersonText := StrSubstNo('%1 %2', "Gift Voucher".FieldCaption(Salesperson), Name);
                end;
            }

            trigger OnAfterGetRecord()
            begin
                if LoopCounter > 0 then
                    CurrReport.Break;
                LoopCounter += 1;
            end;

            trigger OnPreDataItem()
            var
                RetailFormCode: Codeunit "Retail Form Code";
            begin
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
        Lbl000 = 'Gift voucher';
        Lbl001 = 'Valid for 5 years';
        Lbl002 = 'THIS GIFT VOUCHER IS A SECURITY AND MUST';
        Lbl003 = 'BE PRESENTED UPON PURCHASE. THE ISSUER IS NOT';
        Lbl004 = 'RESPONSIBLE FOR LOSS.';
        // The label 'Lbl005' could not be exported.
        // The label 'Lbl006' could not be exported.
        // The label 'Lbl007' could not be exported.
        // The label 'Lbl008' could not be exported.
    }

    trigger OnInitReport()
    begin
        RetailSetup.Get();
        LoopCounter := 0;
    end;

    var
        LoopCounter: Integer;
        RetailSetup: Record "Retail Setup";
        CopyText: Text;
        Text1001: Label 'COPY';
        TempBlob: Codeunit "Temp Blob";
        DetailsText: Text;
        SalesPersonText: Text;
        RegisterPhoneText: Text;
        RegisterPostCodeAndCityText: Text;
        RegisterVatNoText: Text;
        ZipCodeCityText: Text;
        BarcodeLib: Codeunit "Barcode Library";
        Text1002: Label 'Phone No.: %1';
        Text1003: Label 'VAT No.: %1';
}

