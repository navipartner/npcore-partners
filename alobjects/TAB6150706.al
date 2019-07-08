table 6150706 "POS Action Workflow"
{
    Caption = 'POS Action Workflow';

    fields
    {
        field(1;"POS Action Code";Code[20])
        {
            Caption = 'POS Action Code';
        }
        field(2;"Line No.";Integer)
        {
            Caption = 'Line No.';
        }
        field(3;Type;Option)
        {
            Caption = 'Type';
            OptionCaption = 'Action,Execute';
            OptionMembers = "Action",Execute;
        }
        field(4;"Action Code";Code[20])
        {
            Caption = 'Action Code';
            TableRelation = "POS Action" WHERE (Blocked=CONST(false));
        }
        field(5;"Condition Type";Option)
        {
            Caption = 'Condition Type';
            OptionCaption = 'Unconditional,Condition,Event';
            OptionMembers = Unconditional,Condition,"Event";
        }
    }

    keys
    {
        key(Key1;"POS Action Code","Line No.")
        {
        }
    }

    fieldgroups
    {
    }
}

