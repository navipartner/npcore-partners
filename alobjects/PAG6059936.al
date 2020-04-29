page 6059936 "Hotkey Listener"
{
    // NPR4.10/HP/20150529  CASE210673    The change makes the control add-in invisible.
    // NPR5.22.02/JDH/20160708 CASE 241848 Removed Reference to DLL, that is not used any more

    Caption = 'Hotkey Listener';
    PageType = Worksheet;

    layout
    {
        area(content)
        {
        }
    }

    actions
    {
    }

    var
        HotkeyManagement: Codeunit "Hotkey Management";

    procedure InitializeHotkeys()
    var
        Hotkey: Record Hotkey;
    begin
    end;

    procedure Stop()
    begin
        CurrPage.Close;
    end;
}

