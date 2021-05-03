table 6150719 "NPR POS Keyboard Bind. Setup"
{
    Caption = 'POS Keyboard Binding Setup';
    DataClassification = CustomerContent;

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

            trigger OnLookup()
            var
                AvailablePOSKeybinds: Page "NPR Available POS Keybinds";
                AvailablePOSKeybind: Record "NPR Available POS Keybind";
            begin
                AvailablePOSKeybinds.LookupMode := true;
                AvailablePOSKeybinds.Editable := false;
                AvailablePOSKeybind.SetRange(Supported, true);
                AvailablePOSKeybinds.SetTableView(AvailablePOSKeybind);
                if AvailablePOSKeybinds.RunModal() = ACTION::LookupOK then begin
                    AvailablePOSKeybinds.GetRecord(AvailablePOSKeybind);
                    Validate("Key Bind", AvailablePOSKeybind."Key Name");
                end;
            end;

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

            trigger OnValidate()
            begin
                POSKeyboardBindingMgt.CheckKeyBind(Rec, false);
            end;
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

    var
        POSKeyboardBindingMgt: Codeunit "NPR POS Keyboard Binding Mgt.";
}
