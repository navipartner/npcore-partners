report 6014561 "NPR Gift Voucher A5"
{
    UsageCategory = None;
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Gift Voucher A5.rdlc';

    Caption = 'Gift Voucher A5';

    dataset
    {
        dataitem("Integer"; "Integer")
        {
            dataitem("Gift Voucher"; "NPR Gift Voucher")
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
                column(External_Reference_No_; "Gift Voucher"."External Reference No.")
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
                column(SalesPersonText; SalesPersonText)
                {
                }
                dataitem(Register; "NPR Register")
                {
                    DataItemLink = "Register No." = FIELD("Register No.");
                    column(Name_Register; POSStore.Name)
                    {
                    }
                    column(Address_Register; POSStore.Address)
                    {
                    }
                    column(Email_Register; POSStore."E-mail")
                    {
                    }
                    column(WebAddress_Register; POSStore."Home Page")
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
                    var
                        POSUnit: Record "NPR POS Unit";
                        POSSession: Codeunit "NPR POS Session";
                        POSFrontEnd: Codeunit "NPR POS Front End Management";
                        POSSetup: Codeunit "NPR POS Setup";
                    begin
                        clear(POSStore);
                        if POSSession.IsActiveSession(POSFrontEnd) then begin
                            POSFrontEnd.GetSession(POSSession);
                            POSSession.GetSetup(POSSetup);
                            POSSetup.GetPOSStore(POSStore);
                        end else begin
                            if POSUnit.get(Register."Register No.") then
                                POSStore.get(POSUnit."POS Store Code");
                        end;
                        RegisterPhoneText := StrSubstNo(Text1002, POSStore."Phone No.");
                        RegisterPostCodeAndCityText := POSStore."Post Code" + ' ' + POSStore.City;
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

                    ZipCodeCityText := "ZIP Code";
                    if ZipCodeCityText <> '' then
                        ZipCodeCityText += ', ' + City
                    else
                        ZipCodeCityText += City;

                    BarcodeLib.GenerateBarcode("Gift Voucher"."No.", TempBlob);
                    BlobBuffer.GetFromTempBlob(TempBlob, 1);

                    if Get("Gift Voucher"."Salesperson Code") then
                        if RetailSetup."Salesperson on Sales Ticket" then
                            SalesPersonText := StrSubstNo('%1 %2', "Gift Voucher".FieldCaption("Salesperson Code"), Name);
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
                RetailFormCode: Codeunit "NPR Retail Form Code";
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
    }

    trigger OnInitReport()
    begin
        RetailSetup.Get();
        LoopCounter := 0;
    end;

    var
        LoopCounter: Integer;
        RetailSetup: Record "NPR Retail Setup";
        CopyText: Text;
        Text1001: Label 'COPY';
        TempBlob: Codeunit "Temp Blob";
        DetailsText: Text;
        SalesPersonText: Text;
        RegisterPhoneText: Text;
        RegisterPostCodeAndCityText: Text;
        RegisterVatNoText: Text;
        ZipCodeCityText: Text;
        BarcodeLib: Codeunit "NPR Barcode Library";
        Text1002: Label 'Phone No.: %1';
        Text1003: Label 'VAT No.: %1';
        BlobBuffer: Record "NPR BLOB buffer" temporary;
        POSStore: Record "NPR POS Store";
}

