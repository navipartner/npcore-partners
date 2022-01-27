page 6014584 "NPR Variety Input Barcode"
{
    Extensible = False;
    Caption = 'Input Barcode';
    PageType = StandardDialog;
    UsageCategory = None;

    layout
    {
        area(content)
        {
            field(Barcode; Barcode)
            {
                Caption = 'Barcode';
                ToolTip = 'Enter valid barcode value';
                ApplicationArea = NPRRetail;
            }
        }
    }

    var
        Barcode: Code[50];

    procedure GetBarcode(): Code[50]
    begin
        Exit(Barcode);
    end;
}

