page 6060069 "NPR MM Admis. Scanner Stations"
{

    Caption = 'MM Admission Scanner Stations';
    PageType = ListPart;
    UsageCategory = Administration;
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
                }
                field("Guest Avatar"; "Guest Avatar")
                {
                    ApplicationArea = All;
                }
                field("Turnstile Default Image"; "Turnstile Default Image")
                {
                    ApplicationArea = All;
                }
                field("Turnstile Error Image"; "Turnstile Error Image")
                {
                    ApplicationArea = All;
                }
                field("Admission Code"; "Admission Code")
                {
                    ApplicationArea = All;
                }
                field(Activated; Activated)
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
    }
}

