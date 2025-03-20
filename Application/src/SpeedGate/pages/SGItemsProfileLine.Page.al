page 6185032 "NPR SG ItemsProfileLine"
{
    Extensible = false;
    PageType = ListPart;
    UsageCategory = None;
    DelayedInsert = true;
    Caption = 'Speedgate Items Card Profile';
    SourceTable = "NPR SG ItemsProfileLine";

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Code"; Rec."Code")
                {
                    ToolTip = 'Specifies the value of the Code field.', Comment = '%';
                    Visible = false;
                    ApplicationArea = NPRRetail;
                    NotBlank = true;
                }
                field(LineNo; Rec.LineNo)
                {
                    Visible = false;
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Line No. field.', Comment = '%';
                }
                field(ItemNo; Rec.ItemNo)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Item No. field.', Comment = '%';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Description field.', Comment = '%';
                }
                field(Description2; Rec.Description2)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Description 2 field.', Comment = '%';
                }
                field(PresentationOrder; Rec.PresentationOrder)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Presentation Order field.', Comment = '%';
                }
            }
        }
    }

}