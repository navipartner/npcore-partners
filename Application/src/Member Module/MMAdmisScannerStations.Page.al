page 6060069 "NPR MM Admis. Scanner Stations"
{
    Extensible = False;

    Caption = 'MM Admission Scanner Stations';
    PageType = ListPart;
    CardPageId = "NPR Admis. Scanner Stat. Card";
    UsageCategory = Administration;

    SourceTable = "NPR MM Admis. Scanner Stations";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Scanner Station Id"; Rec."Scanner Station Id")
                {

                    ToolTip = 'Specifies the value of the Scanner Station Id field';
                    ApplicationArea = NPRRetail;
                }
                field("Guest Avatar"; Rec."Guest Avatar Image")
                {

                    ToolTip = 'Specifies the value of the Guest Avatar field';
                    ApplicationArea = NPRRetail;
                }
                field("Turnstile Default Image"; Rec."Default Turnstile Image")
                {

                    ToolTip = 'Specifies the value of the Turnstile Default Image field';
                    ApplicationArea = NPRRetail;
                }
                field("Turnstile Error Image"; Rec."Error Image of Turnstile")
                {

                    ToolTip = 'Specifies the value of the Turnstile Error Image field';
                    ApplicationArea = NPRRetail;
                }
                field("Admission Code"; Rec."Admission Code")
                {

                    ToolTip = 'Specifies the value of the Admission Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Activated; Rec.Activated)
                {

                    ToolTip = 'Specifies the value of the Activated field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

}

