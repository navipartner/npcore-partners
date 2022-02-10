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
                    ImportTransferLine(TransferOrderHeader."No.");
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
        LineNo: Integer;

    trigger OnPreXmlPort()
    begin
        LineNo := GetInitialLineNo();
    end;

    procedure SelectTable(Theader: Record "Transfer Header")
    begin
        TransferOrderHeader := Theader;
    end;

    local procedure ImportTransferLine(DocumentNo: Code[20])
    var
        TransferLine: Record "Transfer Line";
        ScannerImportMgt: Codeunit "NPR Scanner Import Mgt.";
    begin
        TransferLine.Init();
        TransferLine."Document No." := DocumentNo;
        TransferLine."Line No." := LineNo;
        TransferLine.Insert();

        TransferLine.Validate("Item No.", ScannerImportMgt.GetItemNoFromScannedCode(scanned_item_code));
        Evaluate(TransferLine.Quantity, quantity);
        TransferLine.Validate(Quantity);
        TransferLine.Modify();

        LineNo += 10000;
    end;

    local procedure GetInitialLineNo() InitialLineNo: Integer
    var
        TransferLine: Record "Transfer Line";
    begin
        InitialLineNo := 10000;

        TransferLine.SetRange("Document No.", TransferOrderHeader."No.");
        if TransferLine.FindLast() then
            InitialLineNo += TransferLine."Line No.";

        exit(InitialLineNo);
    end;
}