page 6150634 "NPR NPRE Print Templ. Subpage"
{
    Caption = 'NPRE Print Templates Subpage';
    PageType = ListPart;
    SourceTable = "NPR NPRE Print Templ.";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Print Type"; Rec."Print Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Print Type field';
                }
                field("Restaurant Code"; Rec."Restaurant Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Restaurant Code field';
                }
                field("Seating Location"; Rec."Seating Location")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Seating Location field';
                }
                field("Serving Step"; Rec."Serving Step")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Serving Step field';
                }
                field("Print Category Code"; Rec."Print Category Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Print Category Code field';
                }
                field("Template Code"; Rec."Template Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Template Code field';
                }
            }
        }
    }
}