page 6150737 "NPR Available POS Keybinds"
{
    Caption = 'Available POS Keybinds';
    Editable = false;
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR Available POS Keybind";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Key Name"; Rec."Key Name")
                {

                    ToolTip = 'Specifies the value of the Key Name field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}
