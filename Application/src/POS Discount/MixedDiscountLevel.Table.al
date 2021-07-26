table 6014427 "NPR Mixed Discount Level"
{
    // NPR5.55/ALPO/20200714 CASE 412946 Mixed Discount enhancement: support for multiple discount amount levels

    Caption = 'Mixed Discount Level';
    DrillDownPageID = "NPR Mixed Discount Levels";
    LookupPageID = "NPR Mixed Discount Levels";
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Mixed Discount Code"; Code[20])
        {
            Caption = 'Mixed Discount Code';
            TableRelation = "NPR Mixed Discount";
            DataClassification = CustomerContent;
        }
        field(10; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DecimalPlaces = 0 : 5;
            MinValue = 0;
            DataClassification = CustomerContent;
        }
        field(15; "Multiple Of"; Boolean)
        {
            Caption = 'Multiple Of';
            DataClassification = CustomerContent;
        }
        field(20; "Discount Amount"; Decimal)
        {
            AutoFormatType = 2;
            BlankZero = true;
            CaptionClass = GetCaptionClass(FieldNo("Discount Amount"));
            Caption = 'Discount Amount';
            MinValue = 0;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Discount Amount" <> 0 then
                    "Discount %" := 0;
            end;
        }
        field(30; "Discount %"; Decimal)
        {
            BlankZero = true;
            Caption = 'Discount %';
            DecimalPlaces = 0 : 5;
            MaxValue = 100;
            MinValue = 0;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Discount %" <> 0 then
                    "Discount Amount" := 0;
            end;
        }

        field(6151479; "Replication Counter"; BigInteger)
        {
            Caption = 'Replication Counter';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Mixed Discount Code", Quantity)
        {
        }

        key(Key2; "Replication Counter")
        {
        }
    }

    fieldgroups
    {
    }

    local procedure GetFieldCaption(FieldNumber: Integer): Text[100]
    var
        "Field": Record "Field";
    begin
        Field.Get(DATABASE::"NPR Mixed Discount Level", FieldNumber);
        exit(Field."Field Caption");
    end;

    local procedure GetCaptionClass(FieldNumber: Integer): Text[80]
    var
        MixedDiscount: Record "NPR Mixed Discount";
    begin
        if not MixedDiscount.Get("Mixed Discount Code") then
            MixedDiscount.Init();

        if not MixedDiscount."Total Amount Excl. VAT" then
            exit('2,1,' + GetFieldCaption(FieldNumber))
        else
            exit('2,0,' + GetFieldCaption(FieldNumber));
    end;
}

