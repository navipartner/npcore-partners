page 6059862 "NPR HWC Printers"
{
    Extensible = false;
    PageType = List;
    ContextSensitiveHelpPage = 'docs/retail/printing/how-to/printing_module_setup/';
    ApplicationArea = NPRRetail;
    UsageCategory = Lists;
    DelayedInsert = true;
    SourceTable = "NPR HWC Printer";
    Caption = 'Hardware Connector Report Printer Setup';

    layout
    {
        area(Content)
        {
            repeater(fields)
            {
                field(ID; Rec.ID)
                {
                    ToolTip = 'The ID of the printer used for printer selection internally';
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
                field("Paper Height"; Rec."Printer Paper Height")
                {
                    ToolTip = 'The paper height to use on the printer';
                    ApplicationArea = NPRRetail;
                }
                field("Paper Width"; Rec."Printer Paper Width")
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