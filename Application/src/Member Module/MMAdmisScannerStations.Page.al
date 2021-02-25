page 6060069 "NPR MM Admis. Scanner Stations"
{

    Caption = 'MM Admission Scanner Stations';
    PageType = ListPart;
    CardPageId = "NPR Admis. Scanner Stat. Card";
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR MM Admis. Scanner Stations";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Scanner Station Id"; Rec."Scanner Station Id")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Scanner Station Id field';
                }
                field("Guest Avatar"; Rec."Guest Avatar Image")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Guest Avatar field';
                }
                field("Turnstile Default Image"; Rec."Default Turnstile Image")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Turnstile Default Image field';
                }
                field("Turnstile Error Image"; Rec."Error Image of Turnstile")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Turnstile Error Image field';
                }
                field("Admission Code"; Rec."Admission Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Admission Code field';
                }
                field(Activated; Rec.Activated)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Activated field';
                }
            }
        }
    }

}

