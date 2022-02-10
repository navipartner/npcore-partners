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

    var
        PurchaseHeader: Record "Purchase Header";
        LineNo: Integer;

    trigger OnPreXmlPort()
    begin
        LineNo := GetInitialLineNo();
    end;

    procedure SelectTable(Pheader: Record "Purchase Header")
    begin
        PurchaseHeader := Pheader;
    end;

    local procedure ImportPurchaseLine(PurchHeader: Record "Purchase Header")
    var
        PurchaseLine: Record "Purchase Line";
        ScannerImportMgt: Codeunit "NPR Scanner Import Mgt.";
    begin
        PurchaseLine.Init();
        PurchaseLine."Document Type" := PurchHeader."Document Type";
        PurchaseLine."Document No." := PurchHeader."No.";
        PurchaseLine."Line No." := LineNo;
        PurchaseLine.Insert();

        PurchaseLine.Type := PurchaseLine.Type::Item;
        PurchaseLine.Validate("No.", ScannerImportMgt.GetItemNoFromScannedCode(scanned_item_code));
        Evaluate(PurchaseLine.Quantity, quantity);
        PurchaseLine.Validate(Quantity);
        PurchaseLine.Modify();

        LineNo += 10000;
    end;

    local procedure GetInitialLineNo() InitialLineNo: Integer
    var
        PurchaseLine: Record "Purchase Line";
    begin
        InitialLineNo := 10000;

        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
        if PurchaseLine.FindLast() then
            InitialLineNo += PurchaseLine."Line No.";

        exit(InitialLineNo);
    end;
}