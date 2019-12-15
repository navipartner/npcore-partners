xmlport 6014418 "Import from Scanner File SO"
{
    // NPR5.23/TS/20160609 CASE 243592 XmlPort Created
    // NPR5.26/JC/20160811  CASE 248302 Check item no. first
    // NPR5.49/BHR /20190227 CASE 346899 Correction to Import all document types

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
            tableelement(tmpsalesheader;"Sales Header")
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
        SessionName := Format (CurrentDateTime(), 0, 9);
    end;

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
        SalesLine.SetRange("Document Type",SalesHeader."Document Type");
        SalesLine.SetRange("Document No.",SalesHeader."No.");
        if SalesLine.FindLast then
          NextLineNo := SalesLine."Line No." + 10000
        else
          NextLineNo := 10000;

        SalesLine.Init;
        //-NPR5.49 [346899]
        //SalesLine."Document Type" := SalesLine."Document Type"::Order;
        SalesLine."Document Type" := SalesHeader."Document Type";
        //+NPR5.49 [346899]
        SalesLine."Document No." := SalesHeader."No.";
        SalesLine."Line No." := NextLineNo;
        SalesLine.Type := SalesLine.Type::Item;
        SalesLine.Validate("No." ,'');

        //-NPR5.26 [248302]
        if Item.Get(scanned_item_code) then begin
          SalesLine.Validate("No.", Item."No.");
        end else
        //+NPR5.26 [248302]
        SalesLine.Validate("Cross-Reference No.",scanned_item_code);
        Evaluate(Qty,quantity);
        SalesLine.Validate(Quantity,Qty);

        SalesLine.Insert;
    end;
}

