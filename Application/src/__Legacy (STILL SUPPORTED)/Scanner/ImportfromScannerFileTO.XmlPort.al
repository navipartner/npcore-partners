xmlport 6014413 "NPR ImportFromScannerFile TO"
{
    Caption = 'Import from Scanner File TO';
    Direction = Import;
    FieldDelimiter = '"';
    FieldSeparator = '|';
    Format = VariableText;
    UseRequestPage = false;

    schema
    {
        textelement(Root)
        {
            tableelement("Transfer Header"; "Transfer Header")
            {
                AutoSave = false;
                XmlName = 'tmpTransferHeader';
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
                    ImportTransferLine(TransferOrderHeader);
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
        TransferOrderHeader: Record "Transfer Header";

    procedure SelectTable(Theader: Record "Transfer Header")
    begin
        TransferOrderHeader := Theader;
    end;

    local procedure ImportTransferLine(TransferHeader: Record "Transfer Header")
    var
        TransferLine: Record "Transfer Line";
        Item: Record Item;
        LineNo: Integer;
    begin
        TransferLine.SetRange("Document No.", TransferHeader."No.");
        if TransferLine.FindLast() then
            LineNo := TransferLine."Line No." + 10000
        else
            LineNo := 10000;

        TransferLine.Init();
        TransferLine."Document No." := TransferHeader."No.";
        TransferLine."Line No." := LineNo;
        TransferLine."Item No." := '';
        Evaluate(TransferLine.Quantity, quantity);
        if Item.Get(scanned_item_code) then
            TransferLine.Validate("Item No.", Item."No.")
        else
            TransferLine.Validate("NPR Cross-Reference No.", scanned_item_code);
        TransferLine.Insert();
    end;
}