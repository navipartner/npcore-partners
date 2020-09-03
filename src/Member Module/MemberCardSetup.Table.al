table 6059772 "NPR Member Card Setup"
{
    // NPR5.31/JLK /20170331  CASE 268274 Changed ENU Caption

    Caption = 'Point Card Properties';

    fields
    {
        field(1; "Card Code"; Code[10])
        {
            Caption = 'Card Code';
            TableRelation = "NPR Member Card Types";
        }
        field(2; Type; Option)
        {
            Caption = 'Type';
            OptionCaption = 'Item,Item Group,Gift Voucher';
            OptionMembers = Item,"Item Group","Gift Voucher";
        }
        field(3; "No."; Code[20])
        {
            Caption = 'Code';
            TableRelation = IF (Type = CONST(Item)) Item."No."
            ELSE
            IF (Type = CONST("Item Group")) "NPR Item Group"."No."
            ELSE
            IF (Type = CONST("Gift Voucher")) "NPR Payment Type POS"."No." WHERE("Processing Type" = CONST("Gift Voucher"));
            ValidateTableRelation = false;
        }
        field(5; "Units Per Point"; Decimal)
        {
            Caption = 'Units Per Point';
        }
        field(6; Points; Decimal)
        {
            Caption = 'Points';
        }
        field(7; "Customer Group"; Code[10])
        {
            Caption = 'Customer Group';
            TableRelation = "Customer Posting Group";
        }
        field(9; "Base Calculation On"; Option)
        {
            Caption = 'Base Calculation On';
            OptionCaption = 'Amounts,Quantity';
            OptionMembers = Amounts,Quantity;
        }
        field(10; "Starting Date"; Date)
        {
            Caption = 'Starting Date';
        }
        field(11; "Ending Date"; Date)
        {
            Caption = 'Ending Date';
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

