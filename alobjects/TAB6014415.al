table 6014415 "Quantity Discount Line"
{
    // NPR5.31/MHA /20170110  CASE 262904 Renamed Variables and functions to English and deleted unused in OnInsert()

    Caption = 'Multiple Unit Price';

    fields
    {
        field(1; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            TableRelation = Item."No.";
        }
        field(2; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DecimalPlaces = 2 : 2;
            MaxValue = 9.999;
            MinValue = 2;
            NotBlank = true;
        }
        field(3; "Unit Price"; Decimal)
        {
            Caption = 'Unit Price';
            DecimalPlaces = 2 : 2;
            MaxValue = 9999999;
            MinValue = 0;

            trigger OnValidate()
            begin
                ValidateValues;
                Total := "Unit Price" * Quantity;
            end;
        }
        field(4; Total; Decimal)
        {
            Caption = 'Total';
            DecimalPlaces = 2 : 2;
            MaxValue = 9999999;
            MinValue = 0;

            trigger OnValidate()
            begin
                "Unit Price" := Total / Quantity;
                ValidateValues;
            end;
        }
        field(5; "Created Date"; Date)
        {
            Caption = 'Created Date';
            Editable = false;
        }
        field(6; "Last Date Modified"; Date)
        {
            Caption = 'Last Date Modified';
            Editable = false;
        }
        field(7; "Price Includes VAT"; Boolean)
        {
            CalcFormula = Lookup (Item."Price Includes VAT" WHERE("No." = FIELD("Item No.")));
            Caption = 'Price Includes VAT';
            Editable = false;
            FieldClass = FlowField;
        }
        field(8; "Start Date"; Decimal)
        {
            Caption = 'Start Date';
        }
        field(9; "Main no."; Code[20])
        {
            Caption = 'Main no.';
        }
    }

    keys
    {
        key(Key1; "Item No.", "Main no.", Quantity)
        {
        }
        key(Key2; "Last Date Modified")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        RecRef.GetTable(Rec);
        SyncCU.OnDelete(RecRef);
    end;

    trigger OnInsert()
    begin
        "Created Date" := Today;

        RecRef.GetTable(Rec);
        SyncCU.OnInsert(RecRef);
    end;

    trigger OnModify()
    begin
        "Last Date Modified" := Today;

        RecRef.GetTable(Rec);
        SyncCU.OnModify(RecRef);
    end;

    trigger OnRename()
    begin
        "Created Date" := Today;
    end;

    var
        Text1060000: Label 'The sale price is lower at a lower quantity.\\';
        Text1060001: Label 'Identification Fields and -Values.\\';
        Text1060002: Label 'Item Code=%1, Quantity=%2';
        "//-SyncProfiles": Integer;
        SyncCU: Codeunit CompanySyncManagement;
        RecRef: RecordRef;
        "//+SyncProfiles": Integer;

    local procedure ValidateValues()
    var
        QuantityDiscountLine: Record "Quantity Discount Line";
        Vare: Record Item;
    begin
        QuantityDiscountLine.SetRange("Item No.", "Item No.");
        //-NPR5.31 [262904]
        //IF QuantityDiscountLine.FIND('-') THEN
        if QuantityDiscountLine.FindSet then
            //+NPR5.31 [262904]
            repeat
                if ("Unit Price" > QuantityDiscountLine."Unit Price") and (Quantity > QuantityDiscountLine.Quantity) then begin
                    Message(Text1060000 +
                            Text1060001 +
                            Text1060002, QuantityDiscountLine."Item No.", QuantityDiscountLine.Quantity);
                    exit;
                end;
            until QuantityDiscountLine.Next = 0;


        Vare.Get("Item No.");
        if "Unit Price" > Vare."Unit Price" then
            Message(Text1060000 +
                    Text1060001 +
                    Text1060002, QuantityDiscountLine."Item No.", 1);
    end;
}

