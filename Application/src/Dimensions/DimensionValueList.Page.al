page 6150845 "NPR Dimension Value List"
{
    Extensible = false;
    Caption = 'Dimension Value List';
    UsageCategory = None;
    Editable = false;
    PageType = List;
    SourceTable = "Dimension Value";
    SourceTableView = where(Blocked = const(false));

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Code"; Rec.Code)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the code for the dimension value.';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies a descriptive name for the dimension value.';
                }
            }
        }
    }
}
