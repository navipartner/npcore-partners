page 6150737 "NPR Available POS Keybinds"
{
    Caption = 'Available POS Keybinds';
    Editable = false;
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR Available POS Keybind";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Key Name"; Rec."Key Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Key Name field';
                }
            }
        }
    }
}
