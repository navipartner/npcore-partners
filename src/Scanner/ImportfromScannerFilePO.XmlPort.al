xmlport 6014414 "NPR Import from ScannerFilePO"
{
    // CASE222241/TS/20151109  CASE 222241 Created
    // NPR5.38/TS  /20171128 CASE 296801 Removed Document Type Filter
    // NPR5.48/BHR /20181119 CASE 336496 Validate Quantity

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

    trigger OnPostXmlPort()
    var
        StockTakeWorksheetLine: Record "NPR Stock-Take Worksheet Line";
    begin
    end;

    trigger OnPreXmlPort()
    var
        StockTakeWorksheetLine: Record "NPR Stock-Take Worksheet Line";
    begin
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
        //-NPR5.38 [296801]
        //PurchaseLine."Document Type" := PurchHeader."Document Type"::"Credit Memo";
        PurchaseLine."Document Type" := PurchHeader."Document Type";
        //+NPR5.38 [296801]
        PurchaseLine."Document No." := PurchHeader."No.";
        PurchaseLine."Line No." := NextLineNo;
        PurchaseLine.Type := PurchaseLine.Type::Item;
        PurchaseLine."No." := '';

        PurchaseLine.Validate("Cross-Reference No.", scanned_item_code);
        Evaluate(PurchaseLine.Quantity, quantity);
        //-NPR5.48 [336496]
        PurchaseLine.Validate(Quantity);
        //+NPR5.48 [336496]
        PurchaseLine.Insert;
    end;
}

