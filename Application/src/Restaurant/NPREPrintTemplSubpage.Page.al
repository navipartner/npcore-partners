page 6150634 "NPR NPRE Print Templ. Subpage"
{
    Extensible = False;
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

                    ToolTip = 'Specifies the value of the Print Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Restaurant Code"; Rec."Restaurant Code")
                {

                    ToolTip = 'Specifies the value of the Restaurant Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Seating Location"; Rec."Seating Location")
                {

                    ToolTip = 'Specifies the value of the Seating Location field';
                    ApplicationArea = NPRRetail;
                }
                field("Serving Step"; Rec."Serving Step")
                {

                    ToolTip = 'Specifies the value of the Serving Step field';
                    ApplicationArea = NPRRetail;
                }
                field("Print Category Code"; Rec."Print Category Code")
                {

                    ToolTip = 'Specifies the value of the Print Category Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Template Code"; Rec."Template Code")
                {

                    ToolTip = 'Specifies the value of the Template Code field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}
