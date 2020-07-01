report 6014564 "Credit Voucher A5"
{
    // NPR4.16/KN/20151009 CASE 220371   Created report based on report 55254 in Smykkebasen
    // NPR4.16/KN/20151112 CASE 225533   Removed line duplicate in layout
    // NPR4.18/KN/20160128 CASE 232717   Increased report margins in layout
    // NPR5.38/NPKNAV/20180126  CASE 300892 Transport NPR5.38 - 26 January 2018
    // NPR5.48/TS  /20190130  CASE 337257  Added Comment
    DefaultLayout = RDLC;
    RDLCLayout = './layouts/Credit Voucher A5.rdlc';

    Caption = 'Credit Voucher A5';

    dataset
    {
        dataitem(Loop; "Integer")
        {
            dataitem("Credit Voucher"; "Credit Voucher")
            {
                column(CopyText; CopyText)
                {
                }
                column(No_CreditVoucher; "Credit Voucher"."No.")
                {
                }
                column(Amount_CreditVoucher; "Credit Voucher".Amount)
                {
                    IncludeCaption = true;
                }
                column(Name_CreditVoucher; "Credit Voucher".Name)
                {
                }
                column(Address_CreditVoucher; "Credit Voucher".Address)
                {
                }
                column(IssueDate_CreditVoucher; "Credit Voucher"."Issue Date")
                {
                }
                column(RegisterNo_CreditVoucher; "Credit Voucher"."Register No.")
                {
                }
                column(SalesTicketNo_CreditVoucher; "Credit Voucher"."Sales Ticket No.")
                {
                }
                column(ZipCodeCityText; ZipCodeCityText)
                {
                }
                column(DetailsText; DetailsText)
                {
                }
                column(Barcode; BlobBuffer."Buffer 1")
                {
                }
                column(SalesPersonText; SalespersonText)
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
                    column(Wwwaddress_Register; Register.Website)
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
                    dataitem(Period; Period)
                    {
                        DataItemLink = "Register No." = FIELD("Register No.");
                        column(Comment_Period; Period.Comment)
                        {
                        }
                    }

                    trigger OnAfterGetRecord()
                    begin
                        RegisterPhoneText := StrSubstNo(Text1002, Register."Phone No.");
                        RegisterPostCodeAndCityText := Register."Post Code" + ' ' + Register.City;
                        RegisterVatNoText := StrSubstNo(Text1003, Register."VAT No.");
                    end;
                }

                trigger OnAfterGetRecord()
                begin
                    "Credit Voucher"."No. Printed" += 1;
                    "Credit Voucher".Modify(false);

                    if ("Credit Voucher"."No. Printed" > 1) and (RetailSetup."Copy No. on Sales Ticket") then
                        CopyText := Text1001;

                    DetailsText := Format("Issue Date") + ' ' + "Register No." + ' ' + "Sales Ticket No." + ' - ' + "No." + ' - ' + Format(Time);
                    //+NPR5.38
                    ZipCodeCityText := "Post Code";
                    if ZipCodeCityText <> '' then
                        ZipCodeCityText += ', ' + City
                    else
                        ZipCodeCityText += City;
                    //-NPR5.38

                    BarcodeLib.GenerateBarcode("Credit Voucher"."No.", TempBlob);
                    BlobBuffer.GetFromTempBlob(TempBlob, 1);

                    if Get("Credit Voucher".Salesperson) then
                        if RetailSetup."Salesperson on Sales Ticket" then
                            SalespersonText := StrSubstNo('%1 %2', "Credit Voucher".FieldCaption(Salesperson), Name);
                end;
            }

            trigger OnAfterGetRecord()
            begin
                if LoopCounter > 0 then
                    CurrReport.Break;
                LoopCounter += 1;
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
        Lbl000 = 'Credit Voucher';
        Lbl001 = 'Issued for';
        Lbl002 = 'Invalid without company stamp and signature.';
        Lbl003 = 'NOTE: THE CREDIT VOUCHER MUST';
        Lbl004 = 'BE SHOWN AT PURCHASE SITE. WE ARE NOT RESPONSIBLE';
        Lbl005 = 'ANY LOSSES';
    }

    trigger OnInitReport()
    begin
        RetailSetup.Get();
        LoopCounter := 0;
    end;

    var
        RetailSetup: Record "Retail Setup";
        LoopCounter: Integer;
        BarcodeLib: Codeunit "Barcode Library";
        CopyText: Text;
        DetailsText: Text;
        Text1001: Label 'COPY';
        Text1002: Label 'Phone No.: %1';
        Text1003: Label 'VAT No.: %1';
        SalespersonText: Text;
        RegisterPhoneText: Text;
        RegisterPostCodeAndCityText: Text;
        RegisterVatNoText: Text;
        ZipCodeCityText: Text;
        TempBlob: Codeunit "Temp Blob";
        BlobBuffer: Record "BLOB Buffer" temporary;
}

