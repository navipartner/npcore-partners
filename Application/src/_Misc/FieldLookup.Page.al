page 6014547 "NPR Field Lookup"
{
    Caption = 'Field Lookup';
    Editable = false;
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "Field";

    layout
    {
        area(content)
        {
            repeater(Control6150613)
            {
                ShowCaption = false;
                field("No."; "No.")
                {
                    ApplicationArea = All;
                    Caption = 'No.';
                    ToolTip = 'Specifies the value of the No. field';
                }
                field("Field Caption"; "Field Caption")
                {
                    ApplicationArea = All;
                    Caption = 'Field Caption';
                    ToolTip = 'Specifies the value of the Field Caption field';
                }
            }
        }
    }

    actions
    {
    }
}

