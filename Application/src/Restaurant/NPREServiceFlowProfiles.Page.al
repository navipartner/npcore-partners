page 6150694 "NPR NPRE Service Flow Profiles"
{
    Extensible = False;
    Caption = 'Rest. Service Flow Profiles';
    CardPageID = "NPR NPRE Serv. Flow Prof. Card";
    Editable = false;
    PageType = List;
    SourceTable = "NPR NPRE Serv.Flow Profile";
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {
                    ToolTip = 'Specifies a code to identify this restaurant service flow profile.';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies a text that describes the restaurant service flow profile.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
        area(factboxes)
        {
            systempart(Control6014405; Notes)
            {
                Visible = false;
                ApplicationArea = NPRRetail;
            }
            systempart(Control6014406; Links)
            {
                Visible = false;
                ApplicationArea = NPRRetail;
            }
        }
    }
}
