page 6150737 "NPR Available POS Keybinds"
{
    // NPR5.48/TJ  /20181204 CASE 323835 New object

    Caption = 'Available POS Keybinds';
    Editable = false;
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR Available POS Keybind";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Key Name"; "Key Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Key Name field';
                }
            }
        }
    }

    actions
    {
    }
}

