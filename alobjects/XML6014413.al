xmlport 6014413 "Import from Scanner File TO"
{
    // NPR5.33/TS  /20151109  CASE 222241 Created
    // NPR5.33/JLK /20170906  CASE 279955 Added first get to Item

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
            tableelement("Transfer Header";"Transfer Header")
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
                var
                    RecRef: RecordRef;
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

    trigger OnPostXmlPort()
    var
        StockTakeWorksheetLine: Record "Stock-Take Worksheet Line";
    begin
    end;

    trigger OnPreXmlPort()
    var
        StockTakeWorksheetLine: Record "Stock-Take Worksheet Line";
    begin
    end;

    var
        TransferOrderHeader: Record "Transfer Header";

    procedure SelectTable(Theader: Record "Transfer Header")
    var
        TransferLine: Integer;
    begin
        TransferOrderHeader := Theader;
    end;

    local procedure ImportTransferLine(TransferHeader: Record "Transfer Header")
    var
        TransferLine: Record "Transfer Line";
        LineNo: Integer;
        Item: Record Item;
    begin
        TransferLine.SetRange("Document No.",TransferHeader."No.");
        if TransferLine.FindLast then
          LineNo := TransferLine."Line No." +10000
        else
          LineNo := 10000;

        TransferLine.Init;
        TransferLine."Document No." := TransferHeader."No." ;
        TransferLine."Line No." := LineNo;
        TransferLine."Item No." := '';
        Evaluate(TransferLine.Quantity,quantity);
        //-NPR5.33
        if Item.Get(scanned_item_code) then
          TransferLine.Validate("Item No.",Item."No.")
        else
        //+NPR5.33
          TransferLine.Validate("Cross-Reference No.",scanned_item_code) ;
        TransferLine.Insert;
    end;
}

