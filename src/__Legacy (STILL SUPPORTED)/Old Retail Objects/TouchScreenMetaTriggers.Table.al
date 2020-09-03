table 6014443 "NPR Touch Screen: MetaTriggers"
{

    Caption = 'Touch Screen - MetaTriggers';
    ObsoleteState = Removed;

    fields
    {
        field(1; "On function call"; Code[50])
        {
            Caption = 'On function call';
        }
        field(2; Sequence; Integer)
        {
            Caption = 'Sequence';
        }
        field(3; "Register No."; Code[10])
        {
            Caption = 'Cash Register No.';
            TableRelation = "NPR Register";
        }
        field(4; ID; Integer)
        {
            Caption = 'ID';
        }
        field(5; "Line Type"; Option)
        {
            Caption = 'Line Type';
            OptionCaption = 'Report,Form,Internal,Codeunit,Page';
            OptionMembers = "Report",Form,Internal,"Codeunit","Page";
        }
        field(6; "Var Parameter"; Option)
        {
            Caption = 'Var Parameter';
            OptionCaption = ' ,Sale,Sales Line';
            OptionMembers = " ",Sale,SalesLine;
        }
        field(7; "Var Record Param"; Text[250])
        {
            Caption = 'Var Record Param';
        }
        field(8; When; Option)
        {
            Caption = 'When';
            OptionCaption = 'Before,After';
            OptionMembers = Before,After;
        }
    }

    keys
    {
        key(Key1; "On function call", Sequence)
        {
        }
        key(Key2; When, Sequence, "Register No.")
        {
        }
    }

    fieldgroups
    {
    }

    var
        RapportValg2: Record "NPR Report Selection Retail";
        printerID: Record "NPR Period Line";
}

