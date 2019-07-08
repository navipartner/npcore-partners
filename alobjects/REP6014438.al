report 6014438 "Gift Voucher A5 Right"
{
    // NPR4.15/LS/20150904  CASE 217672 Create A5 Gift Voucher Report
    // NPR5.40/JLK /20180307  CASE 307438 Removed unused Audit Roll variable
    // NPR5.43/JDH /20180604 CASE 317971 Changed captions to ENU
    DefaultLayout = RDLC;
    RDLCLayout = './Gift Voucher A5 Right.rdlc';

    Caption = 'Gift Voucher A5';

    dataset
    {
        dataitem("Integer";"Integer")
        {
            dataitem("Gift Voucher";"Gift Voucher")
            {
                MaxIteration = 1;
                column(No_GiftVoucher;"Gift Voucher"."No.")
                {
                }
                column(RegisterNo_Register;Register."Register No.")
                {
                }
                column(Name_Register;Register.Name)
                {
                }
                column(CopyText;CopyText)
                {
                }
                column(Address_Register;Register.Address)
                {
                }
                column(PostCodeCity_Register;Register."Post Code" + ' ' + Register.City)
                {
                }
                column(Telephone_Register;Format(Register."Phone No."))
                {
                }
                column(FaxText;FaxText)
                {
                }
                column(VAT_Register;Format(Register."VAT No."))
                {
                }
                column(Email_Register;Register."E-mail")
                {
                }
                column(wwwaddress_Register;Register.Website)
                {
                }
                column(Name_GiftVoucher;"Gift Voucher".Name)
                {
                }
                column(Amount_GiftVoucher;"Gift Voucher".Amount)
                {
                }
                column(Address_GiftVoucher;"Gift Voucher".Address)
                {
                }
                column(ZIPCode_GiftVoucher;"Gift Voucher"."ZIP Code")
                {
                }
                column(City_GiftVoucher;"Gift Voucher".City)
                {
                }
                column(Blob_TempBlob;TempBlob.Blob)
                {
                }
                column(IssueDate_GiftVoucher;StrSubstNo('%1',"Gift Voucher"."Issue Date")+ TextRegister + StrSubstNo('%1',"Register No.") + TextSalesTicket + "Gift Voucher"."Sales Ticket No." +' - ' + "Gift Voucher"."No."+' - ' +Format(Time))
                {
                }
                column(SalepersonText;SalepersonText)
                {
                }

                trigger OnAfterGetRecord()
                begin
                    "Gift Voucher"."No. Printed" += 1;
                    "Gift Voucher".Modify();

                    if ("Gift Voucher"."No. Printed" > 1 ) and (RetailSetup."Copy No. on Sales Ticket" ) then
                      CopyText := TextCopy;

                    BarcodeLib.GenerateBarcode("Gift Voucher"."No.",TempBlob);

                    if Register.Get("Register No.") then;

                    ShowBody1 := RetailSetup."Name on Sales Ticket";

                    if(StrLen(Format(Register."Fax No.")) > 0) then
                      FaxText := TextFax + Format(Register."Fax No.");

                    ShowEmail := Register."E-mail" <> '';
                    ShowWebAdd := Register.Website <> '';
                    ShowNameBody := Register.Name <> '';

                    if RetailSetup."Bar Code on Sales Ticket Print" then
                      Barcode := "No."
                    else
                      Barcode := '';

                    if SalespersonPurchaser.Get("Gift Voucher".Salesperson) then;


                    if RetailSetup."Salesperson on Sales Ticket" then
                      SalepersonText := TextSalesperson + ' ' + Format(SalespersonPurchaser.Name)
                    else
                      SalepersonText := '';
                end;
            }

            trigger OnAfterGetRecord()
            begin
                //-NPR5.40
                //AuditRoll.SETRANGE("Register No.","Gift Voucher"."Register No.");
                //AuditRoll.SETRANGE("Sales Ticket No.","Gift Voucher"."Sales Ticket No.");
                //+NPR5.40

                if LoopCounter >0 then
                  CurrReport.Break;
                LoopCounter += 1;
            end;

            trigger OnPreDataItem()
            begin
                Register.Get(RetailFormCode.FetchRegisterNumber );
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
        RetailSetup: Record "Retail Setup";
        Register: Record Register;
        Barcode: Code[20];
        LoopCounter: Integer;
        CopyText: Text[30];
        SalepersonText: Text[80];
        FaxText: Text[50];
        TempBlob: Record TempBlob;
        TextFax: Label 'Fax No.:';
        TextCopy: Label 'COPY';
        RetailFormCode: Codeunit "Retail Form Code";
        BarcodeLib: Codeunit "Barcode Library";
        ShowBody1: Boolean;
        ShowEmail: Boolean;
        ShowWebAdd: Boolean;
        ShowNameBody: Boolean;
        TextSalesperson: Label 'Salesperson';
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        TextRegister: Label ' , Register';
        TextSalesTicket: Label ' - Sales Ticket';
}

