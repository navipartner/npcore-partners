table 6151310 "NPR NpEc Document"
{
    Access = Public;
    Caption = 'E-Commerce Document';
    DataClassification = CustomerContent;
    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(10; "Store Code"; Code[20])
        {
            Caption = 'Store Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR NpEc Store";
        }
        field(20; "Reference No."; Code[50])
        {
            Caption = 'Reference No.';
            DataClassification = CustomerContent;
        }
        field(30; "Document Type"; Option)
        {
            Caption = 'Document Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Sales Quote,Sales Order,Sales Invoice,Sales Credit Memo,Sales Blanket Order,Sales Return Order,Posted Sales Invoice,Posted Sales Credit Memo,Posted Sales Shipment,Posted Sales Return Receipt,Purchase Quote,Purchase Order,Purchase Invoice,Purchase Credit Memo,Purchase Blanket Order,Purchase Return Order,Posted Purchase Invoice,Posted Purchase Credit Memo,Posted Purchase Receipt,Posted Purchase Return Shipment';
            OptionMembers = "Sales Quote","Sales Order","Sales Invoice","Sales Credit Memo","Sales Blanket Order","Sales Return Order","Posted Sales Invoice","Posted Sales Credit Memo","Posted Sales Shipment","Posted Sales Return Receipt","Purchase Quote","Purchase Order","Purchase Invoice","Purchase Credit Memo","Purchase Blanket Order","Purchase Return Order","Posted Purchase Invoice","Posted Purchase Credit Memo","Posted Purchase Receipt","Posted Purchase Return Shipment";

            trigger OnValidate()
            begin
                SetDocTableNo();
            end;
        }
        field(40; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = CustomerContent;
            TableRelation = IF ("Document Type" = CONST("Sales Quote")) "Sales Header"."No." WHERE("Document Type" = CONST(Quote))
            ELSE
            IF ("Document Type" = CONST("Sales Order")) "Sales Header"."No." WHERE("Document Type" = CONST(Order))
            ELSE
            IF ("Document Type" = CONST("Sales Invoice")) "Sales Header"."No." WHERE("Document Type" = CONST(Invoice))
            ELSE
            IF ("Document Type" = CONST("Sales Credit Memo")) "Sales Header"."No." WHERE("Document Type" = CONST("Credit Memo"))
            ELSE
            IF ("Document Type" = CONST("Sales Blanket Order")) "Sales Header"."No." WHERE("Document Type" = CONST("Blanket Order"))
            ELSE
            IF ("Document Type" = CONST("Sales Return Order")) "Sales Header"."No." WHERE("Document Type" = CONST("Return Order"))
            ELSE
            IF ("Document Type" = CONST("Posted Sales Invoice")) "Sales Invoice Header"."No."
            ELSE
            IF ("Document Type" = CONST("Posted Sales Credit Memo")) "Sales Cr.Memo Header"."No."
            ELSE
            IF ("Document Type" = CONST("Posted Sales Shipment")) "Sales Shipment Header"."No."
            ELSE
            IF ("Document Type" = CONST("Posted Sales Return Receipt")) "Return Receipt Header"."No."
            ELSE
            IF ("Document Type" = CONST("Purchase Quote")) "Purchase Header"."No." WHERE("Document Type" = CONST(Quote))
            ELSE
            IF ("Document Type" = CONST("Purchase Order")) "Purchase Header"."No." WHERE("Document Type" = CONST(Order))
            ELSE
            IF ("Document Type" = CONST("Purchase Invoice")) "Purchase Header"."No." WHERE("Document Type" = CONST(Invoice))
            ELSE
            IF ("Document Type" = CONST("Purchase Credit Memo")) "Purchase Header"."No." WHERE("Document Type" = CONST("Credit Memo"))
            ELSE
            IF ("Document Type" = CONST("Purchase Blanket Order")) "Purchase Header"."No." WHERE("Document Type" = CONST("Blanket Order"))
            ELSE
            IF ("Document Type" = CONST("Purchase Return Order")) "Purchase Header"."No." WHERE("Document Type" = CONST("Return Order"))
            ELSE
            IF ("Document Type" = CONST("Posted Purchase Invoice")) "Purch. Inv. Header"."No."
            ELSE
            IF ("Document Type" = CONST("Posted Purchase Credit Memo")) "Purch. Cr. Memo Hdr."."No."
            ELSE
            IF ("Document Type" = CONST("Posted Purchase Receipt")) "Purch. Rcpt. Header"."No."
            ELSE
            IF ("Document Type" = CONST("Posted Purchase Return Shipment")) "Return Shipment Header"."No.";
        }
        field(50; "Document Table No."; Integer)
        {
            Caption = 'Document Table No.';
            DataClassification = CustomerContent;
        }
        field(100; "Inserted at"; DateTime)
        {
            Caption = 'Inserted at';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
        key(Key2; "Store Code", "Reference No.", "Document Type", "Document No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        "Inserted at" := CurrentDateTime;
        SetDocTableNo();
    end;

    local procedure SetDocTableNo()
    begin
        case "Document Type" of
            "Document Type"::"Sales Quote", "Document Type"::"Sales Order", "Document Type"::"Sales Invoice", "Document Type"::"Sales Credit Memo",
            "Document Type"::"Sales Blanket Order", "Document Type"::"Sales Return Order":
                begin
                    "Document Table No." := DATABASE::"Sales Header";
                end;
            "Document Type"::"Posted Sales Invoice":
                begin
                    "Document Table No." := DATABASE::"Sales Invoice Header";
                end;
            "Document Type"::"Posted Sales Credit Memo":
                begin
                    "Document Table No." := DATABASE::"Sales Cr.Memo Header";
                end;
            "Document Type"::"Posted Sales Shipment":
                begin
                    "Document Table No." := DATABASE::"Sales Shipment Header";
                end;
            "Document Type"::"Posted Sales Return Receipt":
                begin
                    "Document Table No." := DATABASE::"Return Receipt Header";
                end;
            "Document Type"::"Purchase Quote", "Document Type"::"Purchase Order", "Document Type"::"Purchase Invoice", "Document Type"::"Purchase Credit Memo",
            "Document Type"::"Purchase Blanket Order", "Document Type"::"Purchase Return Order":
                begin
                    "Document Table No." := DATABASE::"Purchase Header";
                end;
            "Document Type"::"Posted Purchase Invoice":
                begin
                    "Document Table No." := DATABASE::"Purch. Inv. Header";
                end;
            "Document Type"::"Posted Purchase Credit Memo":
                begin
                    "Document Table No." := DATABASE::"Purch. Cr. Memo Hdr.";
                end;
            "Document Type"::"Posted Purchase Receipt":
                begin
                    "Document Table No." := DATABASE::"Purch. Rcpt. Header";
                end;
            "Document Type"::"Posted Purchase Return Shipment":
                begin
                    "Document Table No." := DATABASE::"Return Shipment Header";
                end;
        end;
    end;
}

