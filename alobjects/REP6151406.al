report 6151406 "Magento Gift Voucher"
{
    // NC/20160427  NaviConnect
    // MAG2.00/MHA/20160525  CASE 242557 Magento Integration
    // MAG2.17/JDH /20181112 CASE 334163 Added Caption to Object
    DefaultLayout = RDLC;
    RDLCLayout = './layouts/Magento Gift Voucher.rdlc';

    Caption = 'Magento Gift Voucher';
    PreviewMode = PrintLayout;

    dataset
    {
        dataitem("Gift Voucher";"Gift Voucher")
        {
            column(GiftVoucher;GiftVoucher)
            {
            }

            trigger OnAfterGetRecord()
            var
                TempBlob: Record TempBlob temporary;
                Convert: DotNet npNetConvert;
                MemoryStream: DotNet npNetMemoryStream;
                InStream: InStream;
            begin
                GiftVoucherMgt.GiftVoucherToTempBlob("Gift Voucher",TempBlob);
                TempBlob.Blob.CreateInStream(InStream);
                MemoryStream := MemoryStream.MemoryStream;
                CopyStream(MemoryStream,InStream);
                GiftVoucher := Convert.ToBase64String(MemoryStream.ToArray);
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
        GiftVoucherMgt: Codeunit "Magento Gift Voucher Mgt.";
        GiftVoucher: Text;
}

