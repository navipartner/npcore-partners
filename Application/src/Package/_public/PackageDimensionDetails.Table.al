table 6059804 "NPR Package Dimension Details"
{
    Access = public;
    Caption = 'Package Dimension Details';
    DataClassification = customercontent;
    DrillDownPageId = "NPR Package Dimension Details";

    fields
    {
        field(1; "Document Type"; enum "NPR ShipProviderDocumentType")
        {
            Caption = 'Document Type';
            DataClassification = CustomerContent;
        }
        field(2; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = CustomerContent;
            TableRelation = if ("Document Type" = const(Order)) "Sales Header"."No." where("Document Type" = const(Order))
            else
            if ("Document Type" = const(Shipment)) "Sales Shipment Header"."No.";
        }
        field(3; "Package Dimension Line No."; Integer)
        {
            Caption = 'Package Dimension Line No.';
            DataClassification = CustomerContent;
        }
        field(9; "Sales Line No."; Integer)
        {
            Caption = 'Sales Line No.';
            DataClassification = CustomerContent;

            TableRelation = if ("Document Type" = const(Order)) "Sales Line"."Line No."
            where(Type = filter(Item), "Document Type" = filter(Order), "Document No." = field("Document No."))
            else
            if ("Document Type" = const(Shipment)) "Sales Shipment Line"."Line No." where(Type = filter(Item), "Document No." = field("Document No."));

            trigger OnValidate()
            var
                SalesLine: record "Sales Line";
                SalesShimentLine: Record "Sales Shipment Line";
            begin
                "Item No." := '';
                if "Document Type" = "Document Type"::Order then begin
                    SalesLine.get(SalesLine."Document Type"::Order, "Document No.", "Sales Line No.");
                    if SalesLine.Type = SalesLine.Type::Item then begin
                        "Item No." := SalesLine."No.";
                        "Variant Code" := SalesLine."Variant Code";
                    end;
                end else
                    if "Document Type" = "Document Type"::shipment then begin
                        SalesShimentLine.get("Document No.", "Sales Line No.");
                        if SalesShimentLine.Type = SalesShimentLine.Type::Item then begin
                            "Item No." := SalesShimentLine."No.";
                            "Variant Code" := SalesShimentLine."Variant Code";
                        end;
                    end;
            end;
        }

        field(10; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(11; "Item Quantity"; Decimal)
        {
            Caption = 'Item Quantity';
            DataClassification = CustomerContent;
        }
        field(12; "Variant Code"; Code[20])
        {
            Caption = 'Variant Code';
            DataClassification = CustomerContent;
        }

    }

    keys
    {
        key(PK; "Document Type", "Document No.", "Package Dimension Line No.", "Sales Line No.")
        {
            Clustered = true;
        }
    }
}