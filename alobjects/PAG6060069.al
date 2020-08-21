page 6060069 "MM Admission Scanner Stations"
{
    // NPR5.43/NPKNAV/20180629  CASE 318579 Transport NPR5.43 - 29 June 2018
    // NPR5.55/CLVA  /20200608  CASE 402284 Added field "Admission Code"

    Caption = 'MM Admission Scanner Stations';
    PageType = List;
    SourceTable = "MM Admission Scanner Stations";

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

