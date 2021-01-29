report 6014564 "NPR Credit Voucher A5"
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Credit Voucher A5.rdlc'; 
    UsageCategory = ReportsAndAnalysis; 
    ApplicationArea = All;
    Caption = 'Credit Voucher A5';

    dataset
    {
        dataitem(Loop; "Integer")
        {
            dataitem("Credit Voucher"; "NPR Credit Voucher")
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
                    column(Wwwaddress_Register; POSStore."Home Page")
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
                    dataitem(Period; "NPR Period")
                    {
                        DataItemLink = "Register No." = FIELD("Register No.");
                        column(Comment_Period; Period.Comment)
                        {
                        }
                    }

                    trigger OnAfterGetRecord()
                    var
                        POSUnit: Record "NPR POS Unit";
                        POSFrontEnd: Codeunit "NPR POS Front End Management";
                        POSSession: Codeunit "NPR POS Session";
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
                        RegisterPhoneText := StrSubstNo(PhoneNoLbl, POSStore."Phone No.");
                        RegisterPostCodeAndCityText := POSStore."Post Code" + ' ' + POSStore.City;
                    end;
                }

                trigger OnAfterGetRecord()
                begin
                    "Credit Voucher"."No. Printed" += 1;
                    "Credit Voucher".Modify(false);

                    if ("Credit Voucher"."No. Printed" > 1) and (RetailSetup."Copy No. on Sales Ticket") then
                        CopyText := CopyLbl;

                    DetailsText := Format("Issue Date") + ' ' + "Register No." + ' ' + "Sales Ticket No." + ' - ' + "No." + ' - ' + Format(Time);

                    ZipCodeCityText := "Post Code";
                    if ZipCodeCityText <> '' then
                        ZipCodeCityText += ', ' + City
                    else
                        ZipCodeCityText += City;

                    BarcodeLib.GenerateBarcode("Credit Voucher"."No.", TempBlob);
                    BlobBuffer.GetFromTempBlob(TempBlob, 1);

                    if Get("Credit Voucher"."Salesperson Code") then
                        if RetailSetup."Salesperson on Sales Ticket" then
                            SalespersonText := StrSubstNo('%1 %2', "Credit Voucher".FieldCaption("Salesperson Code"), Name);
                end;
            }

            trigger OnAfterGetRecord()
            begin
                if LoopCounter > 0 then
                    CurrReport.Break();
                LoopCounter += 1;
            end;
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
        BlobBuffer: Record "NPR BLOB buffer" temporary;
        POSStore: Record "NPR POS Store";
        RetailSetup: Record "NPR Retail Setup";
        BarcodeLib: Codeunit "NPR Barcode Library";
        TempBlob: Codeunit "Temp Blob";
        LoopCounter: Integer;
        CopyLbl: Label 'COPY';
        PhoneNoLbl: Label 'Phone No.: %1', Comment = '%1 = Phone No.';
        VatNoLbl: Label 'VAT No.: %1', Comment = '%1 = VAT No.';
        CopyText: Text;
        DetailsText: Text;
        RegisterPhoneText: Text;
        RegisterPostCodeAndCityText: Text;
        RegisterVatNoText: Text;
        SalespersonText: Text;
        ZipCodeCityText: Text;
}

