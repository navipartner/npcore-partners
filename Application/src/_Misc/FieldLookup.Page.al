page 6014547 "NPR Field Lookup"
{
    Caption = 'Field Lookup';
    Editable = false;
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "Field";

    layout
    {
        area(content)
        {
            repeater(Control6150613)
            {
                ShowCaption = false;
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    Caption = 'No.';
                    ToolTip = 'Specifies the value of the No. field';
                }
                field("Field Caption"; Rec."Field Caption")
                {
                    ApplicationArea = All;
                    Caption = 'Field Caption';
                    ToolTip = 'Specifies the value of the Field Caption field';
                }
            }
        }
    }
}

