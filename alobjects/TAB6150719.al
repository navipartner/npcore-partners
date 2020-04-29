table 6150719 "POS Keyboard Binding Setup"
{
    // NPR5.48/JAVA/20190205  CASE 323835 Transport NPR5.48 - 5 February 2019

    Caption = 'POS Keyboard Binding Setup';

    fields
    {
        field(1;"Action Code";Code[20])
        {
            Caption = 'Action Code';
        }
        field(10;Description;Text[250])
        {
            Caption = 'Description';
        }
        field(15;"Key Bind";Text[30])
        {
            Caption = 'Key Bind';

            trigger OnLookup()
            var
                AvailablePOSKeybinds: Page "Available POS Keybinds";
                AvailablePOSKeybind: Record "Available POS Keybind";
            begin
                AvailablePOSKeybinds.LookupMode := true;
                AvailablePOSKeybinds.Editable := false;
                AvailablePOSKeybind.SetRange(Supported,true);
                AvailablePOSKeybinds.SetTableView(AvailablePOSKeybind);
                if AvailablePOSKeybinds.RunModal = ACTION::LookupOK then begin
                  AvailablePOSKeybinds.GetRecord(AvailablePOSKeybind);
                  Validate("Key Bind",AvailablePOSKeybind."Key Name");
                end;
            end;

            trigger OnValidate()
            begin
                if "Key Bind" <> xRec."Key Bind" then
                  Enabled := false;
            end;
        }
        field(20;Enabled;Boolean)
        {
            Caption = 'Enabled';

            trigger OnValidate()
            begin
                POSKeyboardBindingMgt.CheckKeyBind(Rec,false);
            end;
        }
        field(30;"Default Key Bind";Text[30])
        {
            Caption = 'Default Key Bind';
        }
    }

    keys
    {
        key(Key1;"Action Code")
        {
        }
    }

    fieldgroups
    {
    }

    var
        POSKeyboardBindingMgt: Codeunit "POS Keyboard Binding Mgt.";
}

