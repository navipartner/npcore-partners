table 6059772 "NPR Member Card Setup"
{

    Caption = 'Point Card Properties';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Card Code"; Code[10])
        {
            Caption = 'Card Code';
            TableRelation = "NPR Member Card Types";
            DataClassification = CustomerContent;
        }
        field(2; Type; Option)
        {
            Caption = 'Type';
            OptionCaption = 'Item,Item Group,Gift Voucher';
            OptionMembers = Item,"Item Group","Gift Voucher";
            DataClassification = CustomerContent;
        }
        field(3; "No."; Code[20])
        {
            Caption = 'Code';
            TableRelation = IF (Type = CONST(Item)) Item."No."
            ELSE
            IF (Type = CONST("Item Group")) "NPR Item Group"."No.";
            ValidateTableRelation = false;
            DataClassification = CustomerContent;
        }
        field(5; "Units Per Point"; Decimal)
        {
            Caption = 'Units Per Point';
            DataClassification = CustomerContent;
        }
        field(6; Points; Decimal)
        {
            Caption = 'Points';
            DataClassification = CustomerContent;
        }
        field(7; "Customer Group"; Code[10])
        {
            Caption = 'Customer Group';
            TableRelation = "Customer Posting Group";
            DataClassification = CustomerContent;
        }
        field(9; "Base Calculation On"; Option)
        {
            Caption = 'Base Calculation On';
            OptionCaption = 'Amounts,Quantity';
            OptionMembers = Amounts,Quantity;
            DataClassification = CustomerContent;
        }
        field(10; "Starting Date"; Date)
        {
            Caption = 'Starting Date';
            DataClassification = CustomerContent;
        }
        field(11; "Ending Date"; Date)
        {
            Caption = 'Ending Date';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Card Code", Type, "No.", Points)
        {
        }
        key(Key2; Points)
        {
        }
    }

    fieldgroups
    {
    }
}

