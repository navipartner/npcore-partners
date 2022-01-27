table 6060082 "NPR MCS Rec. Bus. Rule"
{
    Access = Internal;
    ObsoleteState = Pending;
    ObsoleteReason = 'On February 15, 2018, “Recommendations API is no longer under active development”';
    Caption = 'MCS Rec. Business Rule';
    DataClassification = CustomerContent;

    fields
    {
        field(10; "Model No."; Code[10])
        {
            Caption = 'Model No.';
            DataClassification = CustomerContent;
        }
        field(20; "Rule No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Rule No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(30; Active; Boolean)
        {
            Caption = 'Active';
            DataClassification = CustomerContent;
        }
        field(40; "Rule Type"; Option)
        {
            Caption = 'Rule Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Block,WhiteList,Upsale';
            OptionMembers = Block,WhiteList,Upsale;
        }
        field(50; Type; Option)
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Item,Attribute';
            OptionMembers = Item,Attribute;
        }
        field(60; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
            TableRelation = IF (Type = CONST(Item)) Item."No."
            ELSE
            IF (Type = CONST(Attribute)) "NPR Attribute".Code;
        }
        field(70; "Block Seed Item No."; Code[20])
        {
            Caption = 'Block Seed Item No.';
            DataClassification = CustomerContent;
            TableRelation = Item."No.";
        }
        field(100; "Last Sent Date Time"; DateTime)
        {
            Caption = 'Last Sent Date Time';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }

    keys
    {
        key(Key1; "Model No.", "Rule No.")
        {
        }
    }
}

