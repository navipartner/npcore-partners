page 6150634 "NPR NPRE Print Templ. Subpage"
{
    // NPR5.41/THRO/20180412 CASE 309873 Page created
    // NPR5.53/ALPO/20200102 CASE 360258 Possibility to send to kitchen only selected waiter pad lines or lines of specific print category
    // NPR5.55/ALPO/20200708 CASE 382428 Kitchen Display System (KDS) for NP Restaurant (further enhancements)

    Caption = 'NPRE Print Templates Subpage';
    PageType = ListPart;
    UsageCategory = Administration;
    ApplicationArea = All;
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
                    ToolTip = 'Specifies the value of the Print Type field';
                }
                field("Restaurant Code"; "Restaurant Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Restaurant Code field';
                }
                field("Seating Location"; "Seating Location")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Seating Location field';
                }
                field("Serving Step"; "Serving Step")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Serving Step field';
                }
                field("Print Category Code"; "Print Category Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Print Category Code field';
                }
                field("Template Code"; "Template Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Template Code field';
                }
            }
        }
    }

    actions
    {
    }
}

