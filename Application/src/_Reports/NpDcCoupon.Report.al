report 6014444 "NPR NpDc Coupon"
{
#if not BC17
    Extensible = False;
    UsageCategory = None;
#else
    RDLCLayout = './src/_Reports/layouts/NpDc Coupon.rdlc';
    WordLayout = './src/_Reports/layouts/NpDc Coupon.docx';
    ApplicationArea = NPRRetail;
    Caption = 'NpDc Coupon';
    DefaultLayout = Word;
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(NpDcCoupon; "NPR NpDc Coupon")
        {
            column(No; "No.")
            {
            }
            column(ApplyDiscountModule; "Apply Discount Module")
            {
            }
            column(ArchNo; "Arch. No.")
            {
            }
            column(CouponType; "Coupon Type")
            {
            }
            column(CustomerNo; "Customer No.")
            {
            }
            column(Description; Description)
            {
            }
            column(DiscountAmountTxt; DiscountAmt)
            {
            }
            column(DiscountAmount; "Discount Amount")
            {
            }
            column(DiscountType; "Discount Type")
            {
            }
            column(InuseQuantity; "In-use Quantity")
            {
            }
            column(InuseQuantityExternal; "In-use Quantity (External)")
            {
            }
            column(IssueCouponModule; "Issue Coupon Module")
            {
            }
            column(MaxUseperSale; "Max Use per Sale")
            {
            }
            column(MaxDiscountAmount; "Max. Discount Amount")
            {
            }
            column(NoSeries; "No. Series")
            {
            }
            column(Open; Open)
            {
            }
            column(POSStoreGroup; "POS Store Group")
            {
            }
            column(PrintTemplateCode; "Print Template Code")
            {
            }
            column(ReferenceNo; "Reference No.")
            {
            }
            column(RemainingQuantity; "Remaining Quantity")
            {
            }
            column(ValidateCouponModule; "Validate Coupon Module")
            {
            }
            column(StartingDate_DateFormat; StartingDate)
            {
            }
            column(Issued_DateFormat; IssuedDate)
            {
            }
            column(EndingDate_DateFormat; EndingDate)
            {
            }
            column(Barcode_NpDcCoupon; TempBlobBuffer."Buffer 1")
            {
            }
            dataitem("Coupon Type"; "NPR NpDc Coupon Type")
            {
                DataItemLink = Code = field("Coupon Type");
                column(CouponTypeDescription; Description)
                {
                }
            }

            trigger OnAfterGetRecord()
            begin

                BarcodeLib.GenerateBarcode(NpDcCoupon."Reference No.", TempBlobCol1);
                TempBlobBuffer.GetFromTempBlob(TempBlobCol1, 1);
                CurrReport.Language := GlobalLanguage();
                NpDcCoupon.CalcFields("Issue Date");

                if "Discount Type" = "Discount Type"::"Discount %" then
                    DiscountAmt := StrSubstNo(DiscountLbl, "Discount %", '%')
                else
                    DiscountAmt := StrSubstNo(DiscountLbl, "Discount Amount", 'DKK');

                Evaluate(EndingDate, Format(DT2Date(NpDcCoupon."Ending Date")));
                Evaluate(IssuedDate, Format(NpDcCoupon."Issue Date"));

            end;
        }
    }
    requestpage
    {
        SaveValues = true;
    }

    var
        TempBlobBuffer: Record "NPR BLOB buffer" temporary;
        BarcodeLib: Codeunit "NPR Barcode Image Library";
        TempBlobCol1: Codeunit "Temp Blob";


        EndingDate: Text;
        IssuedDate: Text;
        StartingDate: Text;
        DiscountLbl: Label '%1%2', Comment = '%1 is amount, %2 is either DKK or % depending on Discount Type';
        DiscountAmt: Text[100];
#endif
}