report 6151406 "NPR Magento Gift Voucher"
{
    // NC/20160427  NaviConnect
    // MAG2.00/MHA/20160525  CASE 242557 Magento Integration
    // MAG2.17/JDH /20181112 CASE 334163 Added Caption to Object
    // MAG2.22/MHA /20190619  CASE 357825 Added Data Items to be used with Word Layout
    // MAG14.00.2.22/MHA/20190717  CASE 362262 Removed DotNet Print functionality
    // MAG2.23/ZESO/20190911  CASE 365692 Display special danish characters correctly.

    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Magento Gift Voucher.rdlc';

    Caption = 'Magento Gift Voucher';
    PreviewMode = PrintLayout;

    dataset
    {
        dataitem("Gift Voucher"; "NPR Gift Voucher")
        {
            column(No_GiftVoucher; "Gift Voucher"."No.")
            {
            }
            column(RegisterNo_GiftVoucher; "Gift Voucher"."Register No.")
            {
            }
            column(SalesTicketNo_GiftVoucher; "Gift Voucher"."Sales Ticket No.")
            {
            }
            column(IssueDate_GiftVoucher; Format("Gift Voucher"."Issue Date"))
            {
            }
            column(Salesperson_GiftVoucher; "Gift Voucher"."Salesperson Code")
            {
            }
            column(ShortcutDimension1Code_GiftVoucher; "Gift Voucher"."Shortcut Dimension 1 Code")
            {
            }
            column(LocationCode_GiftVoucher; "Gift Voucher"."Location Code")
            {
            }
            column(Status_GiftVoucher; "Gift Voucher".Status)
            {
            }
            column(Amount_GiftVoucher; "Gift Voucher".Amount)
            {
            }
            column(Name_GiftVoucher; "Gift Voucher".Name)
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
            column(CashedonRegisterNo_GiftVoucher; "Gift Voucher"."Cashed on Register No.")
            {
            }
            column(CashedonSalesTicketNo_GiftVoucher; "Gift Voucher"."Cashed on Sales Ticket No.")
            {
            }
            column(CashedDate_GiftVoucher; "Gift Voucher"."Cashed Date")
            {
            }
            column(CashedSalesperson_GiftVoucher; "Gift Voucher"."Cashed Salesperson")
            {
            }
            column(CashedinGlobalDim1Code_GiftVoucher; "Gift Voucher"."Cashed in Global Dim 1 Code")
            {
            }
            column(CashedinLocationCode_GiftVoucher; "Gift Voucher"."Cashed in Location Code")
            {
            }
            column(CashedExternal_GiftVoucher; "Gift Voucher"."Cashed External")
            {
            }
            column(NoSeries_GiftVoucher; "Gift Voucher"."No. Series")
            {
            }
            column(Blocked_GiftVoucher; "Gift Voucher".Blocked)
            {
            }
            column(LastDateModified_GiftVoucher; Format("Gift Voucher"."Last Date Modified"))
            {
            }
            column(Reference_GiftVoucher; "Gift Voucher".Reference)
            {
            }
            column(CustomerNo_GiftVoucher; "Gift Voucher"."Customer No.")
            {
            }
            column(Invoiced_GiftVoucher; "Gift Voucher".Invoiced)
            {
            }
            column(InvoicedbyDocumentType_GiftVoucher; "Gift Voucher"."Invoiced by Document Type")
            {
            }
            column(InvoicedbyDocumentNo_GiftVoucher; "Gift Voucher"."Invoiced by Document No.")
            {
            }
            column(CashedExternalyonDocNo_GiftVoucher; "Gift Voucher"."Cashed Externaly on Doc. No.")
            {
            }
            column(CashedAuditRollType_GiftVoucher; "Gift Voucher"."Cashed Audit Roll Type")
            {
            }
            column(CashedAuditRollLine_GiftVoucher; "Gift Voucher"."Cashed Audit Roll Line")
            {
            }
            column(IssuingRegisterNo_GiftVoucher; "Gift Voucher"."Issuing Register No.")
            {
            }
            column(IssuingSalesTicketNo_GiftVoucher; "Gift Voucher"."Issuing Sales Ticket No.")
            {
            }
            column(IssuingAuditRollType_GiftVoucher; "Gift Voucher"."Issuing Audit Roll Type")
            {
            }
            column(IssuingAuditRollLine_GiftVoucher; "Gift Voucher"."Issuing Audit Roll Line")
            {
            }
            column(ExternalGiftVoucher_GiftVoucher; "Gift Voucher"."External Gift Voucher")
            {
            }
            column(ManChangeofStatusDate_GiftVoucher; "Gift Voucher"."Man. Change of Status Date")
            {
            }
            column(StatusChangedManby_GiftVoucher; "Gift Voucher"."Status Changed Man. by")
            {
            }
            column(CustomerType_GiftVoucher; "Gift Voucher"."Customer Type")
            {
            }
            column(CashedinStore_GiftVoucher; "Gift Voucher"."Cashed in Store")
            {
            }
            column(ExternalNo_GiftVoucher; "Gift Voucher"."External No.")
            {
            }
            column(CancelingSalesperson_GiftVoucher; "Gift Voucher"."Canceling Salesperson")
            {
            }
            column(CreatedinCompany_GiftVoucher; "Gift Voucher"."Created in Company")
            {
            }
            column(OfflineNo_GiftVoucher; "Gift Voucher"."Offline - No.")
            {
            }
            column(PrimaryKeyLength_GiftVoucher; "Gift Voucher"."Primary Key Length")
            {
            }
            column(Offline_GiftVoucher; "Gift Voucher".Offline)
            {
            }
            column(ShortcutDimension2Code_GiftVoucher; "Gift Voucher"."Shortcut Dimension 2 Code")
            {
            }
            column(CashedinGlobalDim2Code_GiftVoucher; "Gift Voucher"."Cashed in Global Dim 2 Code")
            {
            }
            column(PaymentTypeNo_GiftVoucher; "Gift Voucher"."Payment Type No.")
            {
            }
            column(Exporteddate_GiftVoucher; Format("Gift Voucher"."Exported date"))
            {
            }
            column(SecretCode_GiftVoucher; "Gift Voucher"."Secret Code")
            {
            }
            column(CashedPOSEntryNo_GiftVoucher; "Gift Voucher"."Cashed POS Entry No.")
            {
            }
            column(CashedPOSPaymentLineNo_GiftVoucher; "Gift Voucher"."Cashed POS Payment Line No.")
            {
            }
            column(CashedPOSUnitNo_GiftVoucher; "Gift Voucher"."Cashed POS Unit No.")
            {
            }
            column(IssuingPOSEntryNo_GiftVoucher; "Gift Voucher"."Issuing POS Entry No")
            {
            }
            column(IssuingPOSSaleLineNo_GiftVoucher; "Gift Voucher"."Issuing POS Sale Line No.")
            {
            }
            column(IssuingPOSUnitNo_GiftVoucher; "Gift Voucher"."Issuing POS Unit No.")
            {
            }
            column(NoPrinted_GiftVoucher; "Gift Voucher"."No. Printed")
            {
            }
            column(Comment_GiftVoucher; "Gift Voucher".Comment)
            {
            }
            column(VoucherNo_GiftVoucher; "Gift Voucher"."Voucher No.")
            {
            }
            column(ExternalGiftVoucherNo_GiftVoucher; "Gift Voucher"."External Gift Voucher No.")
            {
            }
            column(ExternalReferenceNo_GiftVoucher; "Gift Voucher"."External Reference No.")
            {
            }
            column(ExpireDate_GiftVoucher; Format("Gift Voucher"."Expire Date"))
            {
            }
            column(CurrencyCode_GiftVoucher; "Gift Voucher"."Currency Code")
            {
            }
            column(SalesOrderNo_GiftVoucher; "Gift Voucher"."Sales Order No.")
            {
            }
            column(Message_GiftVoucher; GiftVoucherMessage)
            {
            }
            column(Barcode_GiftVoucher; BlobBuffer."Buffer 1")
            {
            }

            trigger OnAfterGetRecord()
            var
                InStream: InStream;
                StreamReader: DotNet NPRNetStreamReader;
                MagentoBarcodeLibrary: Codeunit "NPR Magento Barcode Library";
                NulChr: Char;
            begin
                //-MAG2.22 [357825]
                GiftVoucherMessage := '';
                if "Gift Voucher Message".HasValue then begin
                    CalcFields("Gift Voucher Message");
                    "Gift Voucher Message".CreateInStream(InStream);
                    //-MAG2.23 [365692]
                    //StreamReader := StreamReader.StreamReader(InStream);
                    //GiftVoucherMessage := StreamReader.ReadToEnd();
                    InStream.ReadText(GiftVoucherMessage);
                    //+MAG2.23 [365692]
                    NulChr := 0;
                    GiftVoucherMessage := DelChr(GiftVoucherMessage, '=', Format(NulChr));
                end;

                MagentoBarcodeLibrary.SetDpiX(600);
                MagentoBarcodeLibrary.SetDpiY(600);
                MagentoBarcodeLibrary.GenerateBarcode("No.", TempBlobBarcode);
                BlobBuffer.GetFromTempBlob(TempBlobBarcode, 1);
                //+MAG2.22 [357825]
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
    var
        Language: Record Language;
    begin
    end;

    var
        TempBlobBarcode: Codeunit "Temp Blob";
        GiftVoucherMessage: Text;
        BlobBuffer: Record "NPR BLOB buffer" temporary;
}

