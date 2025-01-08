page 6184897 "NPR SG AllowedNumbersListLine"
{
    Extensible = false;

    PageType = ListPart;
    UsageCategory = None;
    SourceTable = "NPR SG NumberWhiteListLine";
    Caption = 'Speedgate Allowed Numbers';
    DelayedInsert = true;

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
                    Visible = false;
                }
                field(Type; Rec."Type")
                {
                    ToolTip = 'Specifies the value of the Type field.', Comment = '%';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the value of the Description field.', Comment = '%';
                    ApplicationArea = NPRRetail;
                }
                field(Rule; Rec.RuleType)
                {
                    ToolTip = 'Specifies the value of the Rule field.', Comment = '%';
                    ApplicationArea = NPRRetail;
                }
                field(Prefix; Rec.Prefix)
                {
                    ToolTip = 'Specifies the value of the Prefix field.', Comment = '%';
                    ApplicationArea = NPRRetail;
                    NotBlank = true;
                }
                field(Length; Rec.NumberLength)
                {
                    ToolTip = 'Specifies the value of the Length field.', Comment = '%';
                    ApplicationArea = NPRRetail;
                    BlankZero = true;
                }
            }
        }

    }

}