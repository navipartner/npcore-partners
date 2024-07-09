table 6150726 "NPR POS Action Sequence"
{
    Access = Internal;
    Caption = 'POS Action Sequence';
    DataClassification = CustomerContent;
    ObsoleteState = Removed;
    ObsoleteTag = '2023-06-28';
    ObsoleteReason = '0 references. And done much simpler by maintaining separate actions with extra code at the start/end or by making an action extensible';

    fields
    {
        field(1; "Reference Type"; Option)
        {
            Caption = 'Reference Type';
            DataClassification = CustomerContent;
            Description = 'DO NOT TRANSLATE OptionCaption';
            OptionCaption = 'Before,After';
            OptionMembers = Before,After;
        }
        field(2; "Reference POS Action Code"; Code[20])
        {
            Caption = 'Reference POS Action Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Action" WHERE("Workflow Engine Version" = FILTER(>= '2.0'));
            ValidateTableRelation = false;
        }
        field(3; "POS Action Code"; Code[20])
        {
            Caption = 'POS Action Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Action" WHERE("Workflow Engine Version" = FILTER(>= '2.0'));
            ValidateTableRelation = false;
        }
        field(4; "Sequence No."; Integer)
        {
            Caption = 'Sequence No.';
            DataClassification = CustomerContent;
        }
        field(5; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(6; "Source Type"; Option)
        {
            Caption = 'Source Type';
            DataClassification = CustomerContent;
            Description = 'DO NOT TRANSLATE OptionCaption';
            Editable = false;
            OptionMembers = Manual,Discovery;
        }
    }

    keys
    {
        key(Key1; "Reference Type", "Reference POS Action Code", "POS Action Code")
        {
        }
    }
}

