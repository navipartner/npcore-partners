page 6150938 "NPR TMTicketAccessEntryList"
{
    PageType = List;
    UsageCategory = None;
    SourceTable = "NPR TM Ticket Access Entry";
    Caption = 'Ticket Access Entry List (Editable)';
    Extensible = False;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Entry No. field';
                }
                field("Ticket No."; Rec."Ticket No.")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Ticket No. field';
                }
                field("Ticket Type Code"; Rec."Ticket Type Code")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Ticket Type Code field';
                }
                field("Admission Code"; Rec."Admission Code")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Admission Code field';
                }
                field("Access Date"; Rec."Access Date")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Access Date field';
                }
                field("Access Time"; Rec."Access Time")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Access Time field';
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Customer No. field.', Comment = '%';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field(DurationUntilDate; Rec.DurationUntilDate)
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies if the validity is limited by duration rather than the scheduled end date.';
                }
                field(DurationUntilTime; Rec.DurationUntilTime)
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies if the validity is limited by duration rather than the scheduled end time.';
                }
                field("Member Card Code"; Rec."Member Card Code")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Member Card Code field';
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Qty. field';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Status field';
                }
            }
        }
    }
}