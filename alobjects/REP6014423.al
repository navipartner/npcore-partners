report 6014423 "Rent Overview"
{
    DefaultLayout = RDLC;
    RDLCLayout = './layouts/Rent Overview.rdlc';
    Caption = 'Rent Overview';

    dataset
    {
        dataitem("Payment Terms"; "Payment Terms")
        {
            column(TempBlob1; TempBlob1.Blob)
            {
            }
            column(TempBlob2; TempBlob2.Blob)
            {
            }
            column(TempBlob3; TempBlob3.Blob)
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
    end;

    var
        TempBlob1: Codeunit "Temp Blob";
        TempBlob2: Codeunit "Temp Blob";
        TempBlob3: Codeunit "Temp Blob";
        test: Codeunit "Barcode Library";
}

