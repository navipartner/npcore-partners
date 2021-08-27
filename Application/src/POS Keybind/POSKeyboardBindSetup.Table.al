table 6150719 "NPR POS Keyboard Bind. Setup"
{
    Caption = 'POS Keyboard Binding Setup';
    DataClassification = CustomerContent;
    ObsoleteState = Removed;
    ObsoleteReason = 'Almost zero usage since the module was introduced, but caused significant performance issues';

    fields
    {
        field(1; "Action Code"; Code[20])
        {
            Caption = 'Action Code';
            DataClassification = CustomerContent;
        }
        field(10; Description; Text[250])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(15; "Key Bind"; Text[30])
        {
            Caption = 'Key Bind';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Key Bind" <> xRec."Key Bind" then
                    Enabled := false;
            end;
        }
        field(20; Enabled; Boolean)
        {
            Caption = 'Enabled';
            DataClassification = CustomerContent;
        }
        field(30; "Default Key Bind"; Text[30])
        {
            Caption = 'Default Key Bind';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Action Code")
        {
        }
    }
}
