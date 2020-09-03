page 6150634 "NPR NPRE Print Templ. Subpage"
{
    // NPR5.41/THRO/20180412 CASE 309873 Page created
    // NPR5.53/ALPO/20200102 CASE 360258 Possibility to send to kitchen only selected waiter pad lines or lines of specific print category
    // NPR5.55/ALPO/20200708 CASE 382428 Kitchen Display System (KDS) for NP Restaurant (further enhancements)

    Caption = 'NPRE Print Templates Subpage';
    PageType = ListPart;
    SourceTable = "NPR NPRE Print Templ.";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Print Type"; "Print Type")
                {
                    ApplicationArea = All;
                }
                field("Restaurant Code"; "Restaurant Code")
                {
                    ApplicationArea = All;
                }
                field("Seating Location"; "Seating Location")
                {
                    ApplicationArea = All;
                }
                field("Serving Step"; "Serving Step")
                {
                    ApplicationArea = All;
                }
                field("Print Category Code"; "Print Category Code")
                {
                    ApplicationArea = All;
                }
                field("Template Code"; "Template Code")
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

