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
                    ToolTip = 'Specifies the document type the print templated is used for.';
                    ApplicationArea = NPRRetail;
                }
                field("Restaurant Code"; Rec."Restaurant Code")
                {
                    ToolTip = 'Specifies the restaurant this print template is used at. Leave the field blank if you want the template to be used for all restaurants.';
                    ApplicationArea = NPRRetail;
                }
                field("Seating Location"; Rec."Seating Location")
                {
                    ToolTip = 'Specifies the seating location this print template is used at. Leave the field blank if you want the template to be used for all seating locations.';
                    ApplicationArea = NPRRetail;
                }
                field("Serving Step"; Rec."Serving Step")
                {
                    ToolTip = 'Specifies the serving step this print template is used at. Leave the field blank if you want the template to be used regardless of the serving step.';
                    ApplicationArea = NPRRetail;
                }
                field("Print Category Code"; Rec."Print Category Code")
                {
                    ToolTip = 'Specifies the item print/production category this print template is used for. Leave the field blank if you want the template to be used regardless of the category.';
                    ApplicationArea = NPRRetail;
                }
                field("Template Code"; Rec."Template Code")
                {
                    ToolTip = 'Specifies the print template to be used for this setup line.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}
