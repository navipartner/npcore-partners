#if not BC17
table 6151175 "NPR Spfy Related Document"
{
    Access = Internal;
    Caption = 'Related Document';
    DataClassification = CustomerContent;
    TableType = Temporary;
    LookupPageId = "NPR Spfy Related Documents";
    DrillDownPageId = "NPR Spfy Related Documents";

    fields
    {
        field(1; "Document Type"; Enum "NPR Spfy Document Type")
        {
            Caption = 'Document Type';
            DataClassification = CustomerContent;
        }
        field(2; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Document Type", "Document No.")
        {
            Clustered = true;
        }
    }

    procedure ShowDocument()
    var
        ReturnReceiptHeader: Record "Return Receipt Header";
        SalesHeader: Record "Sales Header";
        SalesCreditMemoHeader: Record "Sales Cr.Memo Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesShipmentHeader: Record "Sales Shipment Header";
        PageManagement: Codeunit "Page Management";
        SalesDocType: Enum "Sales Document Type";
        RecRef: RecordRef;
        NotSupportedErr: Label 'Document type %1 is not supported.', Comment = '%1 - Document type.';
    begin
        TestField("Document Type");
        TestField("Document No.");
        case "Document Type" of
            "Document Type"::"Sales Order",
            "Document Type"::"Sales Invoice",
            "Document Type"::"Sales Return Order",
            "Document Type"::"Sales Credit Memo":
                begin
                    case "Document Type" of
                        "Document Type"::"Sales Order":
                            SalesDocType := SalesDocType::Order;
                        "Document Type"::"Sales Invoice":
                            SalesDocType := SalesDocType::Invoice;
                        "Document Type"::"Sales Return Order":
                            SalesDocType := SalesDocType::"Return Order";
                        "Document Type"::"Sales Credit Memo":
                            SalesDocType := SalesDocType::"Credit Memo";
                    end;
                    SalesHeader.Get(SalesDocType, "Document No.");
                    RecRef.GetTable(SalesHeader);
                end;
            "Document Type"::"Posted Sales Shipment":
                begin
                    SalesShipmentHeader.Get("Document No.");
                    RecRef.GetTable(SalesShipmentHeader);
                end;
            "Document Type"::"Posted Return Receipt":
                begin
                    ReturnReceiptHeader.Get("Document No.");
                    RecRef.GetTable(ReturnReceiptHeader);
                end;
            "Document Type"::"Posted Sales Invoice":
                begin
                    SalesInvoiceHeader.Get("Document No.");
                    RecRef.GetTable(SalesInvoiceHeader);
                end;
            "Document Type"::"Posted Sales Credit Memo":
                begin
                    SalesCreditMemoHeader.Get("Document No.");
                    RecRef.GetTable(SalesCreditMemoHeader);
                end;
            else
                Error(NotSupportedErr, "Document Type");
        end;
        PageManagement.PageRun(RecRef);
    end;

    procedure AddSalesHeader(SalesHeader: Record "Sales Header")
    begin
        case SalesHeader."Document Type" of
            SalesHeader."Document Type"::Order:
                "Document Type" := "Document Type"::"Sales Order";
            SalesHeader."Document Type"::Invoice:
                "Document Type" := "Document Type"::"Sales Invoice";
            SalesHeader."Document Type"::"Return Order":
                "Document Type" := "Document Type"::"Sales Return Order";
            SalesHeader."Document Type"::"Credit Memo":
                "Document Type" := "Document Type"::"Sales Credit Memo";
            else
                exit;
        end;
        "Document No." := SalesHeader."No.";
        if not Find() then
            Insert();
    end;
}
#endif