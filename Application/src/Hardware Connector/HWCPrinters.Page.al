page 6059862 "NPR HWC Printers"
{
    Extensible = false;
    PageType = List;
    ApplicationArea = NPRRetail;
    UsageCategory = Lists;
    SourceTable = "NPR HWC Printer";

    layout
    {
        area(Content)
        {
            repeater(fields)
            {
                field(ID; Rec.ID)
                {
                    ToolTip = 'The ID of the local printer';
                    ApplicationArea = NPRRetail;
                }
                field(Name; Rec.Name)
                {
                    ToolTip = 'The name of the local printer';
                    ApplicationArea = NPRRetail;
                }
                field("Paper Size"; Rec."Paper Size")
                {
                    ToolTip = 'The paper size to use on the printer. Set to custom to define via the other fields.';
                    ApplicationArea = NPRRetail;
                }
                field("Paper Height"; Rec."Paper Height")
                {
                    ToolTip = 'The paper height to use on the printer';
                    ApplicationArea = NPRRetail;
                }
                field("Paper Width"; Rec."Paper Width")
                {
                    ToolTip = 'The paper width to use on the printer';
                    ApplicationArea = NPRRetail;
                }
                field("Paper Unit"; Rec."Paper Unit")
                {
                    ToolTip = 'The paper unit to use on the printer';
                    ApplicationArea = NPRRetail;
                }
                field("Paper Source"; Rec."Paper Source")
                {
                    ToolTip = 'The paper source to use on the printer';
                    ApplicationArea = NPRRetail;
                }
                field(Landscape; Rec.Landscape)
                {
                    ToolTip = 'Check if printer should print as landscape';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}