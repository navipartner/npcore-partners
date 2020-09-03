table 6014508 "NPR Accessory Unfold Entry"
{
    // NPR5.40/MHA /20180214  CASE 288039 Object created - unfold Accessory Items

    Caption = 'Accessory Unfold Entry';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Accessory Item No."; Code[20])
        {
            Caption = 'Accessory Item No.';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = Item WHERE("NPR Has Accessories" = CONST(true));
        }
        field(5; "Item Ledger Entry No."; Integer)
        {
            BlankZero = true;
            Caption = 'Item Ledger Entry No.';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = "Item Ledger Entry"."Entry No.";
        }
        field(10; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = "NPR Accessory/Spare Part"."Item No." WHERE(Code = FIELD("Accessory Item No."),
                                                                     Type = CONST(Accessory),
                                                                     "Add Extra Line Automatically" = CONST(false));
        }
        field(15; "Source Type"; Option)
        {
            CalcFormula = Lookup ("Item Ledger Entry"."Source Type" WHERE("Entry No." = FIELD("Item Ledger Entry No.")));
            Caption = 'Source Type';
            Editable = false;
            FieldClass = FlowField;
            OptionCaption = ' ,Customer,Vendor,Item';
            OptionMembers = " ",Customer,Vendor,Item;
        }
        field(20; "Source No."; Code[20])
        {
            CalcFormula = Lookup ("Item Ledger Entry"."Source No." WHERE("Entry No." = FIELD("Item Ledger Entry No.")));
            Caption = 'Source No.';
            Editable = false;
            FieldClass = FlowField;
            TableRelation = IF ("Source Type" = CONST(Customer)) Customer
            ELSE
            IF ("Source Type" = CONST(Vendor)) Vendor
            ELSE
            IF ("Source Type" = CONST(Item)) Item;
        }
        field(25; "Document Type"; Option)
        {
            CalcFormula = Lookup ("Item Ledger Entry"."Document Type" WHERE("Entry No." = FIELD("Item Ledger Entry No.")));
            Caption = 'Document Type';
            Editable = false;
            FieldClass = FlowField;
            OptionCaption = ' ,Sales Shipment,Sales Invoice,Sales Return Receipt,Sales Credit Memo,Purchase Receipt,Purchase Invoice,Purchase Return Shipment,Purchase Credit Memo,Transfer Shipment,Transfer Receipt,Service Shipment,Service Invoice,Service Credit Memo,Posted Assembly';
            OptionMembers = " ","Sales Shipment","Sales Invoice","Sales Return Receipt","Sales Credit Memo","Purchase Receipt","Purchase Invoice","Purchase Return Shipment","Purchase Credit Memo","Transfer Shipment","Transfer Receipt","Service Shipment","Service Invoice","Service Credit Memo","Posted Assembly";
        }
        field(30; "Document No."; Code[20])
        {
            CalcFormula = Lookup ("Item Ledger Entry"."Document No." WHERE("Entry No." = FIELD("Item Ledger Entry No.")));
            Caption = 'Document No.';
            Editable = false;
            FieldClass = FlowField;
        }
        field(35; "Document Line No."; Integer)
        {
            CalcFormula = Lookup ("Item Ledger Entry"."Document Line No." WHERE("Entry No." = FIELD("Item Ledger Entry No.")));
            Caption = 'Document Line No.';
            Editable = false;
            FieldClass = FlowField;
        }
        field(40; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(45; "Location Code"; Code[10])
        {
            CalcFormula = Lookup ("Item Ledger Entry"."Location Code" WHERE("Entry No." = FIELD("Item Ledger Entry No.")));
            Caption = 'Location Code';
            Editable = false;
            FieldClass = FlowField;
            TableRelation = Location;
        }
        field(50; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
        }
        field(55; "Global Dimension 1 Code"; Code[20])
        {
            CalcFormula = Lookup ("Item Ledger Entry"."Global Dimension 1 Code" WHERE("Entry No." = FIELD("Item Ledger Entry No.")));
            CaptionClass = '1,1,1';
            Caption = 'Global Dimension 1 Code';
            Editable = false;
            FieldClass = FlowField;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));
        }
        field(60; "Global Dimension 2 Code"; Code[20])
        {
            CalcFormula = Lookup ("Item Ledger Entry"."Global Dimension 2 Code" WHERE("Entry No." = FIELD("Item Ledger Entry No.")));
            CaptionClass = '1,1,2';
            Caption = 'Global Dimension 2 Code';
            Editable = false;
            FieldClass = FlowField;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));
        }
        field(65; "Cash Register No."; Code[20])
        {
            CalcFormula = Lookup ("Item Ledger Entry"."NPR Register Number" WHERE("Entry No." = FIELD("Item Ledger Entry No.")));
            Caption = 'Cash Register No.';
            Editable = false;
            FieldClass = FlowField;
        }
        field(70; "Salesperson Code"; Code[20])
        {
            CalcFormula = Lookup ("Item Ledger Entry"."NPR Salesperson Code" WHERE("Entry No." = FIELD("Item Ledger Entry No.")));
            Caption = 'Salesperson Code';
            Editable = false;
            FieldClass = FlowField;
        }
        field(75; "Document Time"; Time)
        {
            CalcFormula = Lookup ("Item Ledger Entry"."NPR Document Time" WHERE("Entry No." = FIELD("Item Ledger Entry No.")));
            Caption = 'Document Time';
            Editable = false;
            FieldClass = FlowField;
        }
        field(80; "Unit Price"; Decimal)
        {
            Caption = 'Unit Price';
            DataClassification = CustomerContent;
        }
        field(85; "Posting Date"; Date)
        {
            CalcFormula = Lookup ("Item Ledger Entry"."Posting Date" WHERE("Entry No." = FIELD("Item Ledger Entry No.")));
            Caption = 'Posting Date';
            Editable = false;
            FieldClass = FlowField;
        }
        field(90; "Unfold Item Ledger Entry No."; Integer)
        {
            Caption = 'Unfold Item Ledger Entry No.';
            DataClassification = CustomerContent;
            TableRelation = "Item Ledger Entry";
        }
    }

    keys
    {
        key(Key1; "Accessory Item No.", "Item Ledger Entry No.", "Item No.")
        {
        }
    }

    fieldgroups
    {
    }
}

