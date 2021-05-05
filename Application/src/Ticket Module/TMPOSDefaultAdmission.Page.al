page 6014446 "NPR TM POS Default Admission"
{
    PageType = List;
    ApplicationArea = NPRTicketAdvanced;
    UsageCategory = Administration;
    SourceTable = "NPR TM POS Default Admission";
    DelayedInsert = true;
    Caption = 'Default Admissions';
    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Item No. field';
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Variant Code field';
                }
                field("Admission Code"; Rec."Admission Code")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Admission Code field';
                }

                field("Station Type"; Rec."Station Type")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Station Type field';
                }
                field("Station Identifier"; Rec."Station Identifier")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Station Identifier field';
                }
                field("Activation Method"; Rec."Activation Method")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Activation Method field';
                }

            }
        }
    }

}