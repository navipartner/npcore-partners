#if BC17
report 6151015 "NPR NpRv Voucher 3"
{
    RDLCLayout = './src/_Reports/layouts/NpRv Voucher 3.rdlc';
    WordLayout = './src/_Reports/layouts/NpRv Voucher 3.docx';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = NPRRetail;
    Caption = 'NpRv Voucher';
    DefaultLayout = Word;
    DataAccessIntent = ReadOnly;

    dataset
    {
        dataitem("NpRv Voucher"; "NPR NpRv Voucher")
        {
            column(No_NpRvVoucher; "NpRv Voucher"."No.")
            {
            }
            column(VoucherType_NpRvVoucher; "NpRv Voucher"."Voucher Type")
            {
            }
            column(Description_NpRvVoucher; "NpRv Voucher".Description)
            {
            }
            column(ReferenceNo_NpRvVoucher; "NpRv Voucher"."Reference No.")
            {
            }
            column(StartingDate_NpRvVoucher; "NpRv Voucher"."Starting Date")
            {
            }
            column(EndingDate_NpRvVoucher; "NpRv Voucher"."Ending Date")
            {
            }
            column(NoSeries_NpRvVoucher; "NpRv Voucher"."No. Series")
            {
            }
            column(ArchNoSeries_NpRvVoucher; "NpRv Voucher"."Arch. No. Series")
            {
            }
            column(ArchNo_NpRvVoucher; "NpRv Voucher"."Arch. No.")
            {
            }
            column(AccountNo_NpRvVoucher; "NpRv Voucher"."Account No.")
            {
            }
            column(ProvisionAccountNo_NpRvVoucher; "NpRv Voucher"."Provision Account No.")
            {
            }
            column(PrintTemplateCode_NpRvVoucher; "NpRv Voucher"."Print Template Code")
            {
            }
            column(Open_NpRvVoucher; "NpRv Voucher".Open)
            {
            }
            column(Amount_NpRvVoucher; "NpRv Voucher".Amount)
            {
            }
            column(InitialAmount_NpRvVoucher; "NpRv Voucher"."Initial Amount")
            {
            }
            column(InuseQuantity_NpRvVoucher; "NpRv Voucher"."In-use Quantity")
            {
            }
            column(EmailTemplateCode_NpRvVoucher; "NpRv Voucher"."E-mail Template Code")
            {
            }
            column(SMSTemplateCode_NpRvVoucher; "NpRv Voucher"."SMS Template Code")
            {
            }
            column(SendVoucherModule_NpRvVoucher; "NpRv Voucher"."Send Voucher Module")
            {
            }
            column(SendviaPrint_NpRvVoucher; "NpRv Voucher"."Send via Print")
            {
            }
            column(SendviaEmail_NpRvVoucher; "NpRv Voucher"."Send via E-mail")
            {
            }
            column(SendviaSMS_NpRvVoucher; "NpRv Voucher"."Send via SMS")
            {
            }
            column(ValidateVoucherModule_NpRvVoucher; "NpRv Voucher"."Validate Voucher Module")
            {
            }
            column(ApplyPaymentModule_NpRvVoucher; "NpRv Voucher"."Apply Payment Module")
            {
            }
            column(CustomerNo_NpRvVoucher; "NpRv Voucher"."Customer No.")
            {
            }
            column(ContactNo_NpRvVoucher; "NpRv Voucher"."Contact No.")
            {
            }
            column(Name_NpRvVoucher; "NpRv Voucher".Name)
            {
            }
            column(Name2_NpRvVoucher; "NpRv Voucher"."Name 2")
            {
            }
            column(Address_NpRvVoucher; "NpRv Voucher".Address)
            {
            }
            column(Address2_NpRvVoucher; "NpRv Voucher"."Address 2")
            {
            }
            column(PostCode_NpRvVoucher; "NpRv Voucher"."Post Code")
            {
            }
            column(City_NpRvVoucher; "NpRv Voucher".City)
            {
            }
            column(County_NpRvVoucher; "NpRv Voucher".County)
            {
            }
            column(CountryRegionCode_NpRvVoucher; "NpRv Voucher"."Country/Region Code")
            {
            }
            column(Email_NpRvVoucher; "NpRv Voucher"."E-mail")
            {
            }
            column(PhoneNo_NpRvVoucher; "NpRv Voucher"."Phone No.")
            {
            }
            column(VoucherMessage_NpRvVoucher; "NpRv Voucher"."Voucher Message")
            {
            }
            column(Barcode_NpRvVoucher; TempBlobBuffer."Buffer 1")
            {
            }
            column(IssueDate_NpRvVoucher; "NpRv Voucher"."Issue Date")
            {
            }
            column(IssueRegisterNo_NpRvVoucher; "NpRv Voucher"."Issue Register No.")
            {
            }
            column(IssueDocumentType_NpRvVoucher; "NpRv Voucher"."Issue Document Type")
            {
            }
            column(IssueDocumentNo_NpRvVoucher; "NpRv Voucher"."Issue Document No.")
            {
            }
            column(IssueExternalDocumentNo_NpRvVoucher; "NpRv Voucher"."Issue External Document No.")
            {
            }
            column(IssueUserID_NpRvVoucher; "NpRv Voucher"."Issue User ID")
            {
            }
            column(StartingDate_DateFormat; StartingDate)
            {
            }
            column(EndingDate_DateFormat; EndingDate)
            {
            }
            column(IssuedDate_DateFormat; IssuedDate)
            {
            }

            trigger OnAfterGetRecord()
            var
                Language: Codeunit Language;
            begin
                BarcodeLib.GenerateBarcode("NpRv Voucher"."Reference No.", TempBlobCol1);
                TempBlobBuffer.GetFromTempBlob(TempBlobCol1, 1);

                CurrReport.Language := Language.GetLanguageIdOrDefault("Language Code");
                Evaluate(StartingDate, Format(DT2Date("NpRv Voucher"."Starting Date")));
                Evaluate(EndingDate, Format(DT2Date("NpRv Voucher"."Ending Date")));
                Evaluate(IssuedDate, Format("NpRv Voucher"."Issue Date"));
            end;
        }
    }

    var
        EndingDate: Text;
        IssuedDate: Text;
        StartingDate: Text;
        TempBlobBuffer: Record "NPR BLOB buffer" temporary;
        BarcodeLib: Codeunit "NPR Barcode Image Library";
        TempBlobCol1: Codeunit "Temp Blob";
}
#endif