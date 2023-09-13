page 6151157 "NPR Feature Flags Setup Sub"
{
    PageType = ListPart;
    UsageCategory = None;
    SourceTable = "NPR Feature Flag";
    Caption = 'NPR Feature Flags Setup Subpage';
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