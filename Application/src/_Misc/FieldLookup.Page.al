page 6014547 "NPR Field Lookup"
{
    Extensible = False;
    Caption = 'Field Lookup';
    Editable = false;
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "Field";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Control6150613)
            {
                ShowCaption = false;
                field("No."; Rec."No.")
                {

                    Caption = 'No.';
                    ToolTip = 'Specifies the value of the No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Field Caption"; Rec."Field Caption")
                {

                    Caption = 'Field Caption';
                    ToolTip = 'Specifies the value of the Field Caption field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}

