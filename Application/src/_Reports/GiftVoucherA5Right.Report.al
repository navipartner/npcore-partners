report 6014438 "NPR Gift Voucher A5 Right"
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Gift Voucher A5 Right.rdlc';

    Caption = 'Gift Voucher A5';

    dataset
    {
        dataitem("Integer"; "Integer")
        {
            dataitem("Gift Voucher"; "NPR Gift Voucher")
            {
                MaxIteration = 1;
                column(No_GiftVoucher; "Gift Voucher"."No.")
                {
                }
                column(RegisterNo_Register; Register."Register No.")
                {
                }
                column(Name_Register; POSStore.Name)
                {
                }
                column(CopyText; CopyText)
                {
                }
                column(Address_Register; POSStore.Address)
                {
                }
                column(PostCodeCity_Register; POSStore."Post Code" + ' ' + POSStore.City)
                {
                }
                column(Telephone_Register; Format(POSStore."Phone No."))
                {
                }
                column(FaxText; FaxText)
                {
                }
                column(VAT_Register; Format(Register."VAT No."))
                {
                }
                column(Email_Register; POSStore."E-mail")
                {
                }
                column(wwwaddress_Register; POSStore."Home Page")
                {
                }
                column(Name_GiftVoucher; "Gift Voucher".Name)
                {
                }
                column(Amount_GiftVoucher; "Gift Voucher".Amount)
                {
                }
                column(Address_GiftVoucher; "Gift Voucher".Address)
                {
                }
                column(ZIPCode_GiftVoucher; "Gift Voucher"."ZIP Code")
                {
                }
                column(City_GiftVoucher; "Gift Voucher".City)
                {
                }
                column(Blob_TempBlob; BlobBuffer."Buffer 1")
                {
                }
                column(IssueDate_GiftVoucher; StrSubstNo('%1', "Gift Voucher"."Issue Date") + TextRegister + StrSubstNo('%1', "Register No.") + TextSalesTicket + "Gift Voucher"."Sales Ticket No." + ' - ' + "Gift Voucher"."No." + ' - ' + Format(Time))
                {
                }
                column(SalepersonText; SalepersonText)
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
                    "Gift Voucher"."No. Printed" += 1;
                    "Gift Voucher".Modify();

                    if ("Gift Voucher"."No. Printed" > 1) and (RetailSetup."Copy No. on Sales Ticket") then
                        CopyText := TextCopy;

                    BarcodeLib.GenerateBarcode("Gift Voucher"."No.", TempBlob);
                    BlobBuffer.GetFromTempBlob(TempBlob, 1);

                    if Register.Get("Register No.") then;

                    ShowBody1 := RetailSetup."Name on Sales Ticket";

                    if (StrLen(Format(POSStore."Fax No.")) > 0) then
                        FaxText := TextFax + Format(POSStore."Fax No.");

                    ShowEmail := POSStore."E-mail" <> '';
                    ShowWebAdd := POSStore."Home Page" <> '';
                    ShowNameBody := POSStore.Name <> '';

                    if RetailSetup."Bar Code on Sales Ticket Print" then
                        Barcode := "No."
                    else
                        Barcode := '';

                    if SalespersonPurchaser.Get("Gift Voucher"."Salesperson Code") then;


                    if RetailSetup."Salesperson on Sales Ticket" then
                        SalepersonText := TextSalesperson + ' ' + Format(SalespersonPurchaser.Name)
                    else
                        SalepersonText := '';
                end;
            }

            trigger OnAfterGetRecord()
            begin
                if LoopCounter > 0 then
                    CurrReport.Break;
                LoopCounter += 1;
            end;

            trigger OnPreDataItem()
            begin
                Register.Get(RetailFormCode.FetchRegisterNumber);
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
        Telephone_Caption = 'Telephone No.:';
        Fax_Caption = 'Fax No.:';
        VAT_Caption = 'VAT:';
        GiftVoucher_Caption = 'Gift Voucher:';
        Register_Caption = ' , Register';
        SalesTicket_Caption = ' - Sales Ticket';
        Signature_Caption = 'Stamp and Signature';
        Valid5Yr_Caption = 'Valid for 5 years';
        Invalid_Caption = 'Invalid without company stamp and signature.';
        IssuedFor_Caption = 'Issued for';
        Amount_Caption = 'Amount';
        Footer1_Caption = 'THE GIFTCARD IS A SECURITY; AND MUST';
        Footer2_Caption = 'BE SHOWN AT PURCHASE SITE. WE ARE NOT RESPONSIBLE';
        Footer3_Caption = 'FOR ANY LOSSES';
    }

    trigger OnInitReport()
    begin
        CompanyInfo.Get;
    end;

    trigger OnPreReport()
    begin
        RetailSetup.Get;
        LoopCounter := 0;
    end;

    var
        CompanyInfo: Record "Company Information";
        RetailSetup: Record "NPR Retail Setup";
        Register: Record "NPR Register";
        Barcode: Code[20];
        LoopCounter: Integer;
        CopyText: Text[30];
        SalepersonText: Text[80];
        FaxText: Text[50];
        TempBlob: Codeunit "Temp Blob";
        TextFax: Label 'Fax No.:';
        TextCopy: Label 'COPY';
        RetailFormCode: Codeunit "NPR Retail Form Code";
        BarcodeLib: Codeunit "NPR Barcode Library";
        ShowBody1: Boolean;
        ShowEmail: Boolean;
        ShowWebAdd: Boolean;
        ShowNameBody: Boolean;
        TextSalesperson: Label 'Salesperson';
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        TextRegister: Label ' , Register';
        TextSalesTicket: Label ' - Sales Ticket';
        BlobBuffer: Record "NPR BLOB buffer" temporary;
        POSStore: Record "NPR POS Store";
}

