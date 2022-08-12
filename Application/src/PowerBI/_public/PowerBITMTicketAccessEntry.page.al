page 6184624 NPRPowerBITMticketAccessEntry
{
    PageType = List;
    Caption = 'PowerBI TM Ticket Access Entry';
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "NPR TM Ticket Access Entry";
    Editable = false;
    ObsoleteState = pending;
    ObsoleteReason = 'Page type changed to API';
    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Admission Code"; Rec."Admission Code")
                {
                    ToolTip = 'Specifies the value of the Admission Code field';
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = All;
                }
                field("Entry No."; Rec."Entry No.")
                {
                    ToolTip = 'Specifies the value of the Entry No. field';
                    ApplicationArea = All;
                }
                field(Quantity; Rec.Quantity)
                {
                    ToolTip = 'Specifies the value of the Qty. field';
                    ApplicationArea = All;
                }
                field("Ticket No."; Rec."Ticket No.")
                {
                    ToolTip = 'Specifies the value of the Ticket No. field';
                    ApplicationArea = All;
                }
                field("Ticket Type Code"; Rec."Ticket Type Code")
                {
                    ToolTip = 'Specifies the value of the Ticket Type Code field';
                    ApplicationArea = All;
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ToolTip = 'Specifies the value of the Customer No. field.';
                    ApplicationArea = All;
                }
            }
        }
    }
}