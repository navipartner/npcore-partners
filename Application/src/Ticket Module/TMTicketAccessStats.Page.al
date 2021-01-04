page 6060115 "NPR TM Ticket Access Stats"
{
    // NPR4.14/TSA/20150803/CASE214262 - Initial Version
    // TM1.00/TSA/20151217  CASE 228982 NaviPartner Ticket Management
    // TM1.07/TSA/20160126  CASE 232495 Transport T0005 - 26 January 2016
    // TM1.12/TSA/20160407  CASE 230600 Added DAN Captions
    // TM1.22/TSA/20170601  CASE 274464 (Touched) Changing the principal for recognizing last transaction aggregated
    // TM1.36/TSA /20180727 CASE 323024 Added Variant Code
    // TM1.39/TSA /20181102 CASE 334585 A control of type 'FlowFilter' is not allowed in a parent control of type 'Repeater'

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
                field("Entry No."; "Entry No.")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Entry No. field';
                }
                field("Item No."; "Item No.")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Item No. field';
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Variant Code field';
                }
                field("Ticket Type"; "Ticket Type")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Ticket Type field';
                }
                field("Admission Code"; "Admission Code")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Admission Code field';
                }
                field("Admission Date"; "Admission Date")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Admission Date field';
                }
                field("Admission Hour"; "Admission Hour")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Admission Hour field';
                }
                field("Admission Count"; "Admission Count")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Admission Count field';
                }
                field("Admission Count (Neg)"; "Admission Count (Neg)")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Admission Count (Neg) field';
                }
                field("Admission Count (Re-Entry)"; "Admission Count (Re-Entry)")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Admission Count (Re-Entry) field';
                }
                field("Generated Count (Pos)"; "Generated Count (Pos)")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Generated Count (Pos) field';
                }
                field("Generated Count (Neg)"; "Generated Count (Neg)")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Generated Count (Neg) field';
                }
                field("Sum Admission Count"; "Sum Admission Count")
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

