xmlport 6014418 "NPR Import from ScannerFileSO"
{
    Caption = 'Import from Scanner File SO';
    Direction = Import;
    FieldDelimiter = '"';
    FieldSeparator = '|';
    Format = VariableText;
    UseRequestPage = false;

    schema
    {
        textelement(Root)
        {
            tableelement(tmpsalesheader; "Sales Header")
            {
                AutoSave = false;
                XmlName = 'tmpSalesHeader';
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
                    ImportSalesLine(SalesHeader);
                end;
            }
        }
    }

    requestpage
    {
        Caption = 'Import from Scanner File SO';

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
        SalesHeader: Record "Sales Header";

    procedure SelectTable(Sheader: Record "Sales Header")
    begin
        SalesHeader := Sheader;
    end;

    local procedure ImportSalesLine(SalesHeader: Record "Sales Header")
    var
        SalesLine: Record "Sales Line";
        NextLineNo: Integer;
        Qty: Decimal;
        Item: Record Item;
    begin
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        if SalesLine.FindLast then
            NextLineNo := SalesLine."Line No." + 10000
        else
            NextLineNo := 10000;

        SalesLine.Init;
        SalesLine."Document Type" := SalesHeader."Document Type";
        SalesLine."Document No." := SalesHeader."No.";
        SalesLine."Line No." := NextLineNo;
        SalesLine.Type := SalesLine.Type::Item;
        SalesLine.Validate("No.", '');

        if Item.Get(scanned_item_code) then begin
            SalesLine.Validate("No.", Item."No.");
        end else
            SalesLine.Validate("Item Reference No.", scanned_item_code);
        Evaluate(Qty, quantity);
        SalesLine.Validate(Quantity, Qty);

        SalesLine.Insert;
    end;
}