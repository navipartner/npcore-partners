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

    var
        SalesHeader: Record "Sales Header";
        LineNo: Integer;

    trigger OnPreXmlPort()
    begin
        LineNo := GetInitialLineNo();
    end;

    procedure SelectTable(Sheader: Record "Sales Header")
    begin
        SalesHeader := Sheader;
    end;

    local procedure ImportSalesLine(SalesHeader: Record "Sales Header")
    var
        SalesLine: Record "Sales Line";
        ScannerImportMgt: Codeunit "NPR Scanner Import Mgt.";
    begin
        SalesLine.Init();
        SalesLine."Document Type" := SalesHeader."Document Type";
        SalesLine."Document No." := SalesHeader."No.";
        SalesLine."Line No." := LineNo;
        SalesLine.Insert();

        SalesLine.Type := SalesLine.Type::Item;
        SalesLine.Validate("No.", ScannerImportMgt.GetItemNoFromScannedCode(scanned_item_code));
        Evaluate(SalesLine.Quantity, quantity);
        SalesLine.Validate(Quantity);
        SalesLine.Modify();

        LineNo += 10000;
    end;

    local procedure GetInitialLineNo() InitialLineNo: Integer
    var
        SalesLine: Record "Sales Line";
    begin
        InitialLineNo := 10000;

        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        if SalesLine.FindLast() then
            InitialLineNo += SalesLine."Line No.";

        exit(InitialLineNo);
    end;
}