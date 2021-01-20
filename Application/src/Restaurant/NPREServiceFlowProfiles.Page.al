page 6150694 "NPR NPRE Service Flow Profiles"
{
    Caption = 'Rest. Service Flow Profiles';
    CardPageID = "NPR NPRE Serv. Flow Prof. Card";
    Editable = false;
    PageType = List;
    SourceTable = "NPR NPRE Serv.Flow Profile";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
            }
        }
        area(factboxes)
        {
            systempart(Control6014405; Notes)
            {
                Visible = false;
                ApplicationArea = All;
            }
            systempart(Control6014406; Links)
            {
                Visible = false;
                ApplicationArea = All;
            }
        }
    }
}