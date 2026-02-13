page 6150937 "NPR TMDetTicketAccessEntryList"
{
    PageType = List;
    UsageCategory = None;
    SourceTable = "NPR TM Det. Ticket AccessEntry";
    Caption = 'Detailed Ticket Access Entry List (Editable)';
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
                field(Type; Rec."Type")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Type field';
                }
                field(AdmittedDate; Rec.AdmittedDate)
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Admitted Date field';
                }
                field(AdmittedTime; Rec.AdmittedTime)
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Admitted Time field';
                }
                field("Closed By Entry No."; Rec."Closed By Entry No.")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Closed By Entry No. field';
                }
                field("Created Datetime"; Rec."Created Datetime")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Created Datetime field';
                }
                field("External Adm. Sch. Entry No."; Rec."External Adm. Sch. Entry No.")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the External Adm. Sch. Entry No. field';
                }
                field(Open; Rec.Open)
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Open field';
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Posting Date field';
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Quantity field';
                }
                field("Sales Channel No."; Rec."Sales Channel No.")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Sales Channel No. field';
                }
                field("Scanner Station ID"; Rec."Scanner Station ID")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Scanner Station ID field.';
                }
                field("Ticket Access Entry No."; Rec."Ticket Access Entry No.")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Ticket Access Entry No. field';
                }
                field("Ticket No."; Rec."Ticket No.")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Ticket No. field';
                }
                field("User ID"; Rec."User ID")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the User ID field';
                }
            }
        }
    }
}