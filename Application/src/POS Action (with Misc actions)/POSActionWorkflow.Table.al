table 6150706 "NPR POS Action Workflow"
{
    Access = Internal;
    Caption = 'POS Action Workflow';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "POS Action Code"; Code[20])
        {
            Caption = 'POS Action Code';
            DataClassification = CustomerContent;
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(3; Type; Option)
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Action,Execute';
            OptionMembers = "Action",Execute;
        }
        field(4; "Action Code"; Code[20])
        {
            Caption = 'Action Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Action" WHERE(Blocked = CONST(false));
        }
        field(5; "Condition Type"; Option)
        {
            Caption = 'Condition Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Unconditional,Condition,Event';
            OptionMembers = Unconditional,Condition,"Event";
        }
    }

    keys
    {
        key(Key1; "POS Action Code", "Line No.")
        {
        }
    }
}

