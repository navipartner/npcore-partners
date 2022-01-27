table 6059960 "NPR MCS Webcam Arg. Table"
{
    Access = Internal;

    Caption = 'MCS Webcam Argument Table';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Key"; RecordID)
        {
            Caption = 'Key';
            DataClassification = CustomerContent;
        }
        field(2; Name; Text[250])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
        }
        field(3; Picture; BLOB)
        {
            Caption = 'Picture';
            DataClassification = CustomerContent;
        }
        field(4; "Person Group Id"; Text[50])
        {
            Caption = 'Person Group Id';
            DataClassification = CustomerContent;
        }
        field(5; "Person Id"; Text[50])
        {
            Caption = 'Person Id';
            DataClassification = CustomerContent;
        }
        field(6; "Allow Saving On Identifyed"; Boolean)
        {
            Caption = 'Allow Saving On Identifyed';
            DataClassification = CustomerContent;
        }
        field(7; "Action"; Enum "NPR MCS Faces Action")
        {
            Caption = 'Action';
            DataClassification = CustomerContent;
        }
        field(8; "API Key 1"; Text[50])
        {
            Caption = 'API Key 1';
            DataClassification = CustomerContent;
        }
        field(9; "API Key 2"; Text[50])
        {
            Caption = 'API Key 2';
            DataClassification = CustomerContent;
        }
        field(11; "Is Identified"; Boolean)
        {
            Caption = 'Is Identified';
            DataClassification = CustomerContent;
        }
        field(12; "Table Id"; Integer)
        {
            Caption = 'Table Id';
            DataClassification = CustomerContent;
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Table));
        }
        field(13; "Image Orientation"; enum "NPR MCS API Setup Img Orien.")
        {
            Caption = 'Image Orientation';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Key")
        {
        }
    }
}

