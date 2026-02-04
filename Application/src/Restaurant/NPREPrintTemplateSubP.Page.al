page 6150898 "NPR NPRE Print Template SubP."
{
    Extensible = false;
    Caption = 'NPRE Print Templates Subpage';
    PageType = ListPart;
    SourceTable = "NPR NPRE Print Template";
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Print Type"; Rec."Print Type")
                {
                    ToolTip = 'Specifies the document type the print templated is used for.';
                    ApplicationArea = NPRNewRestaurantPrintExp;
                }
                field("Restaurant Code"; Rec."Restaurant Code")
                {
                    ToolTip = 'Specifies the restaurant this print template is used at. Leave the field blank if you want the template to be used for all restaurants.';
                    ApplicationArea = NPRNewRestaurantPrintExp;
                }
                field("Seating Location"; Rec."Seating Location")
                {
                    ToolTip = 'Specifies the seating location this print template is used at. Leave the field blank if you want the template to be used for all seating locations.';
                    ApplicationArea = NPRNewRestaurantPrintExp;
                }
                field("Serving Step"; Rec."Serving Step")
                {
                    ToolTip = 'Specifies the serving step this print template is used at. Leave the field blank if you want the template to be used regardless of the serving step.';
                    ApplicationArea = NPRNewRestaurantPrintExp;
                }
                field("Print Category Code"; Rec."Print Category Code")
                {
                    ToolTip = 'Specifies the item print/production category this print template is used for. Leave the field blank if you want the template to be used regardless of the category.';
                    ApplicationArea = NPRNewRestaurantPrintExp;
                }
                field("Codeunit ID"; Rec."Codeunit ID")
                {
                    ToolTip = 'Specifies the codeunit to be used for the print processing.';
                    ApplicationArea = NPRNewRestaurantPrintExp;
                }
                field("Codeunit Name"; Rec."Codeunit Name")
                {
                    ToolTip = 'Specifies the name of the codeunit.';
                    ApplicationArea = NPRNewRestaurantPrintExp;
                }
            }
        }
    }
}
