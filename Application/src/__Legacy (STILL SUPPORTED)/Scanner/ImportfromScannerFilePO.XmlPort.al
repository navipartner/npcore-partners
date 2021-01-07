xmlport 6014414 "NPR Import from ScannerFilePO"
{
    Caption = 'Import from Scanner File PO';
    Direction = Import;
    FieldDelimiter = '"';
    FieldSeparator = '|';
    Format = VariableText;
    UseRequestPage = false;

    schema
    {
        textelement(Root)
        {
            tableelement(tmppurchaseheader; "Purchase Header")
            {
                AutoSave = false;
                XmlName = 'tmpPurchaseHeader';
                UseTemporary = true;
                textelement(shelf)
                {
                    XmlName = 'shelf';
                }
                textelement(scanned_item_code)
                {
                }
                textelement(quantity)
                {
                }

                trigger OnBeforeInsertRecord()
                var
                    RecRef: RecordRef;
                begin
                    ImportPurchaseLine(PurchaseHeader);
                end;
            }
        }
    }

    requestpage
    {
        Caption = 'Import StockTake Wrksht. Line';

        layout
        {
        }

        actions
        {
        }
    }

    trigger OnInitXmlPort()
    begin
        SessionName := Format(CurrentDateTime(), 0, 9);
    end;

    var
        SessionName: Text[40];
        PurchaseHeader: Record "Purchase Header";

    procedure SelectTable(Pheader: Record "Purchase Header")
    begin
        PurchaseHeader := Pheader;
    end;

    local procedure ImportPurchaseLine(PurchHeader: Record "Purchase Header")
    var
        PurchaseLine: Record "Purchase Line";
        NextLineNo: Integer;
    begin
        PurchaseLine.SetRange("Document Type", PurchHeader."Document Type");
        PurchaseLine.SetRange("Document No.", PurchHeader."No.");
        if PurchaseLine.FindLast then
            NextLineNo := PurchaseLine."Line No." + 10000
        else
            NextLineNo := 10000;

        PurchaseLine.Init;
        PurchaseLine."Document Type" := PurchHeader."Document Type";
        PurchaseLine."Document No." := PurchHeader."No.";
        PurchaseLine."Line No." := NextLineNo;
        PurchaseLine.Type := PurchaseLine.Type::Item;
        PurchaseLine."No." := '';

        PurchaseLine.Validate("Cross-Reference No.", scanned_item_code);
        Evaluate(PurchaseLine.Quantity, quantity);
        PurchaseLine.Validate(Quantity);
        PurchaseLine.Insert;
    end;
}