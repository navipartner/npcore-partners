table 6151374 "NPR CS UI Line"
{
    Access = Internal;

    Caption = 'CS UI Line';
    DataClassification = CustomerContent;
    ObsoleteState = Removed;
    ObsoleteReason = 'Object moved to NP Warehouse App.';

    fields
    {
        field(1; "UI Code"; Code[20])
        {
            Caption = 'Miniform Code';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(11; "Area"; Option)
        {
            Caption = 'Area';
            DataClassification = CustomerContent;
            OptionCaption = 'Header,Body,Footer', Locked = true;
            OptionMembers = Header,Body,Footer;
        }
        field(12; "Field Type"; Option)
        {
            Caption = 'Field Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Text,Input,Output,Asterisk,Default', Locked = true;
            OptionMembers = Text,Input,Output,Asterisk,Default;

        }
        field(13; "Table No."; Integer)
        {
            Caption = 'Table No.';
            DataClassification = CustomerContent;

        }
        field(14; "Field No."; Integer)
        {
            Caption = 'Field No.';
            DataClassification = CustomerContent;

        }
        field(15; "Text"; Text[30])
        {
            Caption = 'Text';
            DataClassification = CustomerContent;
        }
        field(16; "Field Length"; Integer)
        {
            Caption = 'Field Length';
            DataClassification = CustomerContent;
        }
        field(21; "Call UI"; Code[20])
        {
            Caption = 'Call UI';
            DataClassification = CustomerContent;
        }
        field(22; "Field Data Type"; Text[30])
        {
            Caption = 'Field Data Type';
            DataClassification = CustomerContent;
        }
        field(23; "First Responder"; Option)
        {
            Caption = 'First Responder';
            DataClassification = CustomerContent;
            OptionCaption = 'Keyboard,Keyboard(Active),Barcode Reader,Rfid Reader';
            OptionMembers = Keyboard,"Keyboard(Active)","Barcode Reader","Rfid Reader";
        }
        field(24; Placeholder; Text[30])
        {
            Caption = 'Placeholder';
            DataClassification = CustomerContent;
        }
        field(25; "Default Value"; Text[30])
        {
            Caption = 'Default Value';
            DataClassification = CustomerContent;
        }
        field(26; "Format Value"; Boolean)
        {
            Caption = 'Format Value';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "UI Code", "Line No.")
        {
        }
        key(Key2; "Area")
        {
        }
    }

    fieldgroups
    {
    }


}

