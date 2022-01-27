table 6014443 "NPR Touch Screen: MetaTriggers"
{
    Access = Internal;

    Caption = 'Touch Screen - MetaTriggers';
    ObsoleteState = Removed;
    ObsoleteReason = 'Not used';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "On function call"; Code[50])
        {
            Caption = 'On function call';
            DataClassification = CustomerContent;
        }
        field(2; Sequence; Integer)
        {
            Caption = 'Sequence';
            DataClassification = CustomerContent;
        }
        field(3; "Register No."; Code[10])
        {
            Caption = 'Cash Register No.';
            DataClassification = CustomerContent;
        }
        field(4; ID; Integer)
        {
            Caption = 'ID';
            DataClassification = CustomerContent;
        }
        field(5; "Line Type"; Option)
        {
            Caption = 'Line Type';
            OptionCaption = 'Report,Form,Internal,Codeunit,Page';
            OptionMembers = "Report",Form,Internal,"Codeunit","Page";
            DataClassification = CustomerContent;
        }
        field(6; "Var Parameter"; Option)
        {
            Caption = 'Var Parameter';
            OptionCaption = ' ,Sale,Sales Line';
            OptionMembers = " ",Sale,SalesLine;
            DataClassification = CustomerContent;
        }
        field(7; "Var Record Param"; Text[250])
        {
            Caption = 'Var Record Param';
            DataClassification = CustomerContent;
        }
        field(8; When; Option)
        {
            Caption = 'When';
            OptionCaption = 'Before,After';
            OptionMembers = Before,After;
            DataClassification = CustomerContent;
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

}

