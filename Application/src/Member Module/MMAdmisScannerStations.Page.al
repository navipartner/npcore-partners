page 6060069 "NPR MM Admis. Scanner Stations"
{

    Caption = 'MM Admission Scanner Stations';
    PageType = ListPart;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR MM Admis. Scanner Stations";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Scanner Station Id"; "Scanner Station Id")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Scanner Station Id field';
                }
                field("Guest Avatar"; "Guest Avatar")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Guest Avatar field';
                }
                field("Turnstile Default Image"; "Turnstile Default Image")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Turnstile Default Image field';
                }
                field("Turnstile Error Image"; "Turnstile Error Image")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Turnstile Error Image field';
                }
                field("Admission Code"; "Admission Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Admission Code field';
                }
                field(Activated; Activated)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Activated field';
                }
            }
        }
    }

    actions
    {
    }
}

