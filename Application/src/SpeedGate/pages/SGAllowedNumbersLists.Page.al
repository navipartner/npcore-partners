page 6184899 "NPR SG AllowedNumbersLists"
{
    Extensible = false;

    PageType = List;
    UsageCategory = None;
    SourceTable = "NPR SG AllowedNumbersList";
    Editable = false;
    CardPageId = "NPR SG AllowedNumbersList";
    Caption = 'Speedgate Allowed Numbers';

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Code"; Rec."Code")
                {
                    ToolTip = 'Specifies the value of the Code field.', Comment = '%';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the value of the Description field.', Comment = '%';
                    ApplicationArea = NPRRetail;
                }
                field(ValidateMode; Rec.ValidateMode)
                {
                    ToolTip = 'Strict mode implies that the list is an exhaustive list of numbers permitted by the gate while flexible mode implies that specific prefixes may be denied but failure to match number with a prefix will check actual entities in a predefined order.', Comment = '%';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}