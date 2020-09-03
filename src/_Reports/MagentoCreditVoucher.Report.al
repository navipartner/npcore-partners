report 6151405 "NPR Magento Credit Voucher"
{
    // MAG1.06/TS/20150225  CASE 201682 Object Created
    // MAG1.12/TS/20150410  CASE 210753 Added code to pick up Report Language
    // MAG1.17/TR/20150618 CASE 210183 Gift Voucher Blob is sent to Layout as Base64String.
    //                                    Handling of image data moved from Layout to Navision.
    // MAG2.00/MHA/20160525  CASE 242557 Magento Integration
    // MAG2.22/MHA /20190619  CASE 357825 Added Data Items to be used with Word Layout
    // MAG14.00.2.22/MHA/20190717  CASE 362262 Removed DotNet Print functionality

    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Magento Credit Voucher.rdlc';

    Caption = 'Magento - Credit Voucher';
    PreviewMode = PrintLayout;

    dataset
    {
        dataitem("Credit Voucher"; "NPR Credit Voucher")
        {
            column(No_CreditVoucher; "Credit Voucher"."No.")
            {
            }
            column(RegisterNo_CreditVoucher; "Credit Voucher"."Register No.")
            {
            }
            column(SalesTicketNo_CreditVoucher; "Credit Voucher"."Sales Ticket No.")
            {
            }
            column(IssueDate_CreditVoucher; Format("Credit Voucher"."Issue Date"))
            {
            }
            column(Salesperson_CreditVoucher; "Credit Voucher".Salesperson)
            {
            }
            column(ShortcutDimension1Code_CreditVoucher; "Credit Voucher"."Shortcut Dimension 1 Code")
            {
            }
            column(LocationCode_CreditVoucher; "Credit Voucher"."Location Code")
            {
            }
            column(Status_CreditVoucher; "Credit Voucher".Status)
            {
            }
            column(Amount_CreditVoucher; "Credit Voucher".Amount)
            {
            }
            column(Name_CreditVoucher; "Credit Voucher".Name)
            {
            }
            column(Address_CreditVoucher; "Credit Voucher".Address)
            {
            }
            column(PostCode_CreditVoucher; "Credit Voucher"."Post Code")
            {
            }
            column(City_CreditVoucher; "Credit Voucher".City)
            {
            }
            column(CashedonRegisterNo_CreditVoucher; "Credit Voucher"."Cashed on Register No.")
            {
            }
            column(CashedonSalesTicketNo_CreditVoucher; "Credit Voucher"."Cashed on Sales Ticket No.")
            {
            }
            column(CashedDate_CreditVoucher; Format("Credit Voucher"."Cashed Date"))
            {
            }
            column(CashedSalesperson_CreditVoucher; "Credit Voucher"."Cashed Salesperson")
            {
            }
            column(CashedinGlobalDim1Code_CreditVoucher; "Credit Voucher"."Cashed in Global Dim 1 Code")
            {
            }
            column(CashedinLocationCode_CreditVoucher; "Credit Voucher"."Cashed in Location Code")
            {
            }
            column(CashedExternal_CreditVoucher; "Credit Voucher"."Cashed External")
            {
            }
            column(Blocked_CreditVoucher; "Credit Voucher".Blocked)
            {
            }
            column(LastDateModified_CreditVoucher; Format("Credit Voucher"."Last Date Modified"))
            {
            }
            column(Reference_CreditVoucher; "Credit Voucher".Reference)
            {
            }
            column(Nummerserie_CreditVoucher; "Credit Voucher".Nummerserie)
            {
            }
            column(CustomerNo_CreditVoucher; "Credit Voucher"."Customer No")
            {
            }
            column(Invoiced_CreditVoucher; "Credit Voucher".Invoiced)
            {
            }
            column(Invoicedonenclosure_CreditVoucher; "Credit Voucher"."Invoiced on enclosure")
            {
            }
            column(Invoicedonenclosureno_CreditVoucher; "Credit Voucher"."Invoiced on enclosure no.")
            {
            }
            column(Checkedexternalviaenclosure_CreditVoucher; "Credit Voucher"."Checked external via enclosure")
            {
            }
            column(IssuedonDrawerNo_CreditVoucher; "Credit Voucher"."Issued on Drawer No")
            {
            }
            column(IssuedonTicketNo_CreditVoucher; "Credit Voucher"."Issued on Ticket No")
            {
            }
            column(IssuedAuditRollType_CreditVoucher; "Credit Voucher"."Issued Audit Roll Type")
            {
            }
            column(IssuedAuditRollLine_CreditVoucher; "Credit Voucher"."Issued Audit Roll Line")
            {
            }
            column(CheckedAudit_CreditVoucher; "Credit Voucher"."Checked Audit")
            {
            }
            column(CheckAuditRollLine_CreditVoucher; "Credit Voucher"."Check Audit Roll Line")
            {
            }
            column(ExternalCreditVoucher_CreditVoucher; "Credit Voucher"."External Credit Voucher")
            {
            }
            column(Statusmanuallychangedon_CreditVoucher; "Credit Voucher"."Status manually changed on")
            {
            }
            column(Statusmanuallychangedby_CreditVoucher; "Credit Voucher"."Status manually changed by")
            {
            }
            column(CustomerType_CreditVoucher; "Credit Voucher"."Customer Type")
            {
            }
            column(Cashedinstore_CreditVoucher; "Credit Voucher"."Cashed in store")
            {
            }
            column(Externalno_CreditVoucher; "Credit Voucher"."External no")
            {
            }
            column(Cancelledbysalesperson_CreditVoucher; "Credit Voucher"."Cancelled by salesperson")
            {
            }
            column(CreatedinCompany_CreditVoucher; "Credit Voucher"."Created in Company")
            {
            }
            column(OfflineNo_CreditVoucher; "Credit Voucher"."Offline - No.")
            {
            }
            column(PrimaryKeyLength_CreditVoucher; "Credit Voucher"."Primary Key Length")
            {
            }
            column(Offline_CreditVoucher; "Credit Voucher".Offline)
            {
            }
            column(ShortcutDimension2Code_CreditVoucher; "Credit Voucher"."Shortcut Dimension 2 Code")
            {
            }
            column(CashedinGlobalDim2Code_CreditVoucher; "Credit Voucher"."Cashed in Global Dim 2 Code")
            {
            }
            column(PaymentTypeNo_CreditVoucher; "Credit Voucher"."Payment Type No.")
            {
            }
            column(Exporteddate_CreditVoucher; "Credit Voucher"."Exported date")
            {
            }
            column(CashedPOSEntryNo_CreditVoucher; "Credit Voucher"."Cashed POS Entry No.")
            {
            }
            column(CashedPOSPaymentLineNo_CreditVoucher; "Credit Voucher"."Cashed POS Payment Line No.")
            {
            }
            column(CashedPOSUnitNo_CreditVoucher; "Credit Voucher"."Cashed POS Unit No.")
            {
            }
            column(IssuingPOSEntryNo_CreditVoucher; "Credit Voucher"."Issuing POS Entry No")
            {
            }
            column(IssuingPOSSaleLineNo_CreditVoucher; "Credit Voucher"."Issuing POS Sale Line No.")
            {
            }
            column(IssuingPOSUnitNo_CreditVoucher; "Credit Voucher"."Issuing POS Unit No.")
            {
            }
            column(NoPrinted_CreditVoucher; "Credit Voucher"."No. Printed")
            {
            }
            column(Comment_CreditVoucher; "Credit Voucher".Comment)
            {
            }
            column(VoucherNo_CreditVoucher; "Credit Voucher"."Voucher No.")
            {
            }
            column(ExternalCreditVoucherNo_CreditVoucher; "Credit Voucher"."External Credit Voucher No.")
            {
            }
            column(ExternalReferenceNo_CreditVoucher; "Credit Voucher"."External Reference No.")
            {
            }
            column(ExpireDate_CreditVoucher; Format("Credit Voucher"."Expire Date"))
            {
            }
            column(CurrencyCode_CreditVoucher; "Credit Voucher"."Currency Code")
            {
            }
            column(SalesOrderNo_CreditVoucher; "Credit Voucher"."Sales Order No.")
            {
            }
            column(Barcode_CreditVoucher; BlobBuffer."Buffer 1")
            {
            }

            trigger OnAfterGetRecord()
            var
                MagentoBarcodeLibrary: Codeunit "NPR Magento Barcode Library";
            begin
                //-MAG2.22 [357825]
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
        BlobBuffer: Record "NPR BLOB buffer" temporary;
}

