report 6151405 "Magento Credit Voucher"
{
    // MAG1.06/TS/20150225  CASE 201682 Object Created
    // MAG1.12/TS/20150410  CASE 210753 Added code to pick up Report Language
    // MAG1.17/TR/20150618 CASE 210183 Gift Voucher Blob is sent to Layout as Base64String.
    //                                    Handling of image data moved from Layout to Navision.
    // MAG2.00/MHA/20160525  CASE 242557 Magento Integration
    DefaultLayout = RDLC;
    RDLCLayout = './Magento Credit Voucher.rdlc';

    Caption = 'Magento - Credit Voucher';
    PreviewMode = PrintLayout;

    dataset
    {
        dataitem("Credit Voucher";"Credit Voucher")
        {
            column(CreditVoucher;CreditVoucher)
            {
            }

            trigger OnAfterGetRecord()
            var
                TempBlob: Record TempBlob temporary;
                Convert: DotNet Convert;
                MemoryStream: DotNet MemoryStream;
                InStream: InStream;
            begin
                //-MAG1.17
                MagentoGiftVoucherMgt.CreditVoucherToTempBlob("Credit Voucher",TempBlob);
                TempBlob.Blob.CreateInStream(InStream);
                MemoryStream := MemoryStream.MemoryStream;
                CopyStream(MemoryStream,InStream);
                CreditVoucher := Convert.ToBase64String(MemoryStream.ToArray);
                //+MAG1.17
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
        MagentoGiftVoucherMgt: Codeunit "Magento Gift Voucher Mgt.";
        CreditVoucher: Text;
}

