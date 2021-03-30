page 6060115 "NPR TM Ticket Access Stats"
{
    Caption = 'Ticket Access Statistics';
    Editable = false;
    PageType = List;
    SourceTable = "NPR TM Ticket Access Stats";
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Entry No. field';
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Item No. field';
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Variant Code field';
                }
                field("Ticket Type"; Rec."Ticket Type")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Ticket Type field';
                }
                field("Admission Code"; Rec."Admission Code")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Admission Code field';
                }
                field("Admission Date"; Rec."Admission Date")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Admission Date field';
                }
                field("Admission Hour"; Rec."Admission Hour")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Admission Hour field';
                }
                field("Admission Count"; Rec."Admission Count")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Admission Count field';
                }
                field("Admission Count (Neg)"; Rec."Admission Count (Neg)")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Admission Count (Neg) field';
                }
                field("Admission Count (Re-Entry)"; Rec."Admission Count (Re-Entry)")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Admission Count (Re-Entry) field';
                }
                field("Generated Count (Pos)"; Rec."Generated Count (Pos)")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Generated Count (Pos) field';
                }
                field("Generated Count (Neg)"; Rec."Generated Count (Neg)")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Generated Count (Neg) field';
                }
                field("Sum Admission Count"; Rec."Sum Admission Count")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Sum Admission Count field';
                }
            }
        }
    }

    actions
    {
    }
}

