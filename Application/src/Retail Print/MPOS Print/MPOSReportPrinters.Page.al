page 6059883 "NPR MPOS Report Printers"
{
    Extensible = false;
    PageType = List;
    ContextSensitiveHelpPage = 'docs/retail/mpos/how-to/mpos_view/';
    ApplicationArea = NPRRetail;
    UsageCategory = Lists;
    SourceTable = "NPR MPOS Report Printer";
    DelayedInsert = true;
    Caption = 'MPOS Report Printer Setup';

    layout
    {
        area(Content)
        {
            repeater(fields)
            {
                field(ID; Rec.ID)
                {
                    ToolTip = 'The ID of the printed used for printer selection internally';
                    ApplicationArea = NPRRetail;
                }
                field(Name; Rec."LAN IP")
                {
                    ToolTip = 'The IP of the printer on the local network that the MPOS is also connected to.';
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