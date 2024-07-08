page 6151159 "NPR Feature Flags"
{
    PageType = List;
    UsageCategory = None;
    SourceTable = "NPR Feature Flag";
    Caption = 'Feature Flags';
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    Editable = false;
    Extensible = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(Name; Rec.Name)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Name field.';
                }
                field(Value; Rec.Value)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Value field.';
                }

                field("Variation ID"; Rec."Variation ID")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Variation ID field.';
                }
            }
        }
    }
}