table 6014507 "NPR Accessory Unfold Worksheet"
{
    // NPR5.40/MHA /20180214  CASE 288039 Object created - unfold Accessory Items

    Caption = 'Accessory Unfold Worksheet';
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
            TableRelation = "Item Ledger Entry"."Entry No." WHERE("Item No." = FIELD("Accessory Item No."),
                                                                   "Entry Type" = CONST(Sale));
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;

            trigger OnValidate()
            var
                ItemLedgEntry: Record "Item Ledger Entry";
            begin
                TestUnfoldEntry();
                UpdateQty();
            end;
        }
        field(10; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR Accessory/Spare Part"."Item No." WHERE(Code = FIELD("Accessory Item No."),
                                                                     Type = CONST(Accessory),
                                                                     "Unfold in Worksheet" = CONST(true));

            trigger OnValidate()
            var
                AccessorySparePart: Record "NPR Accessory/Spare Part";
                ItemLedgEntry: Record "Item Ledger Entry";
            begin
                UpdateQty();
            end;
        }
        field(12; "Entry Type"; Option)
        {
            CalcFormula = Lookup ("Item Ledger Entry"."Entry Type" WHERE("Entry No." = FIELD("Item Ledger Entry No.")));
            Caption = 'Entry Type';
            Editable = false;
            FieldClass = FlowField;
            OptionCaption = 'Purchase,Sale,Positive Adjmt.,Negative Adjmt.,Transfer,Consumption,Output, ,Assembly Consumption,Assembly Output';
            OptionMembers = Purchase,Sale,"Positive Adjmt.","Negative Adjmt.",Transfer,Consumption,Output," ","Assembly Consumption","Assembly Output";
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

    var
        Text000: Label 'Item Ledger Entry No. %1 has already been unfolded.';
        Text001: Label 'Item Ledger Entry No. %1 is an unfold entry.';

    local procedure TestUnfoldEntry()
    var
        AccessoryUnfoldEntry: Record "NPR Accessory Unfold Entry";
        ItemLedgEntry: Record "Item Ledger Entry";
    begin
        if "Item Ledger Entry No." = 0 then
            exit;

        ItemLedgEntry.Get("Item Ledger Entry No.");
        ItemLedgEntry.TestField("Entry Type", ItemLedgEntry."Entry Type"::Sale);

        AccessoryUnfoldEntry.SetRange("Item Ledger Entry No.", "Item Ledger Entry No.");
        if AccessoryUnfoldEntry.FindFirst then
            Error(Text000, "Item Ledger Entry No.");

        AccessoryUnfoldEntry.Reset;
        AccessoryUnfoldEntry.SetRange("Unfold Item Ledger Entry No.", "Item Ledger Entry No.");
        if AccessoryUnfoldEntry.FindFirst then
            Error(Text001, "Item Ledger Entry No.");
    end;

    local procedure UpdateQty()
    var
        AccessorySparePart: Record "NPR Accessory/Spare Part";
        ItemLedgEntry: Record "Item Ledger Entry";
        AmountPct: Decimal;
    begin
        if "Item Ledger Entry No." = 0 then
            exit;

        ItemLedgEntry.Get("Item Ledger Entry No.");
        if ItemLedgEntry.Quantity = 0 then
            exit;
        ItemLedgEntry.CalcFields("Sales Amount (Actual)");

        if "Item No." = '' then begin
            Quantity := ItemLedgEntry.Quantity;
            "Unit Price" := Abs(ItemLedgEntry."Sales Amount (Actual)" / ItemLedgEntry.Quantity);

            exit;
        end;

        AccessorySparePart.Get(AccessorySparePart.Type::Accessory, "Accessory Item No.", "Item No.");
        AccessorySparePart.CalcFields(Description);
        if AccessorySparePart.Quantity = 0 then begin
            "Unit Price" := 0;
            Quantity := 0;
            exit;
        end;
        Description := AccessorySparePart.Description;

        AmountPct := CalcAmountPct(AccessorySparePart);
        "Unit Price" := ItemLedgEntry."Sales Amount (Actual)" * AmountPct / ItemLedgEntry.Quantity;
        Quantity := -ItemLedgEntry.Quantity * AccessorySparePart.Quantity;
    end;

    local procedure CalcAmountPct(AccessorySparePart: Record "NPR Accessory/Spare Part"): Decimal
    var
        AccessorySparePart2: Record "NPR Accessory/Spare Part";
        SalesAmount: Decimal;
        SalesAmountTotal: Decimal;
    begin
        if AccessorySparePart."Use Alt. Price" then
            SalesAmount := AccessorySparePart."Alt. Price" * AccessorySparePart.Quantity
        else begin
            AccessorySparePart.CalcFields("Unit Price");
            SalesAmount := AccessorySparePart."Unit Price" * AccessorySparePart.Quantity;
        end;

        AccessorySparePart2.SetRange(Code, AccessorySparePart.Code);
        AccessorySparePart2.FindSet;
        repeat
            if AccessorySparePart2."Use Alt. Price" then
                SalesAmountTotal += AccessorySparePart2."Alt. Price" * AccessorySparePart2.Quantity
            else begin
                AccessorySparePart2.CalcFields("Unit Price");
                SalesAmountTotal += AccessorySparePart2."Unit Price" * AccessorySparePart2.Quantity;
            end;
        until AccessorySparePart2.Next = 0;

        if SalesAmountTotal <> 0 then
            exit(SalesAmount / SalesAmountTotal);

        AccessorySparePart2.CalcSums(Quantity);
        if AccessorySparePart2.Quantity <> 0 then
            exit(AccessorySparePart.Quantity / AccessorySparePart2.Quantity);

        exit(1 / AccessorySparePart2.Count);
    end;
}

