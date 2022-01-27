table 6014697 "NPR Embedded Video Buffer"
{
    Access = Internal;
    Caption = 'Embedded Video Buffer';
    DataClassification = CustomerContent;
    ObsoleteState = Removed;
    ObsoleteReason = 'Not used';
    fields
    {
        field(1; "Module Code"; Code[20])
        {
            Caption = 'Module Code';
            NotBlank = true;
            DataClassification = CustomerContent;
        }
        field(5; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(10; "Module Name"; Text[50])
        {
            Caption = 'Module Name';
            DataClassification = CustomerContent;
        }
        field(15; Columns; Integer)
        {
            Caption = 'Columns';
            InitValue = 1;
            MinValue = 1;
            DataClassification = CustomerContent;
        }
        field(50; "Video Html"; Text[250])
        {
            Caption = 'Video Html';
            DataClassification = CustomerContent;
        }
        field(55; "Width (px)"; Integer)
        {
            Caption = 'Width (px)';
            DataClassification = CustomerContent;
        }
        field(60; "Height (px)"; Integer)
        {
            Caption = 'Height (px)';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Module Code", "Line No.")
        {
        }
    }

    fieldgroups
    {
    }
}

