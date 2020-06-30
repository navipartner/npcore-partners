report 6014423 "Rent Overview"
{
    DefaultLayout = RDLC;
    RDLCLayout = './layouts/Rent Overview.rdlc';
    Caption = 'Rent Overview';

    dataset
    {
        dataitem("Payment Terms"; "Payment Terms")
        {
            column(TempBlob1; BlobBuffer."Buffer 1")
            {
            }
            column(TempBlob2; BlobBuffer."Buffer 2")
            {
            }
            column(TempBlob3; BlobBuffer."Buffer 3")
            {
            }
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
    begin
        test.Rotate(10);
        test.SetDpiY(1000);
        test.SetDpiX(1000);
        test.SetSizeX(0.6);
        test.SetBarcodeType('EAN13');
        test.GenerateBarcode('2712', TempBlob1);
        //test.Init('2712345546111',TempBlob1);
        //test.GenerateBarcode('2712345546111',TempBlob1);

        BlobBuffer.GetFromTempBlob(TempBlob1, 1);
        BlobBuffer.GetFromTempBlob(TempBlob2, 2);
        BlobBuffer.GetFromTempBlob(TempBlob3, 3);
    end;

    var
        BlobBuffer: Record "BLOB buffer" temporary;
        TempBlob1: Codeunit "Temp Blob";
        TempBlob2: Codeunit "Temp Blob";
        TempBlob3: Codeunit "Temp Blob";
        test: Codeunit "Barcode Library";
}

