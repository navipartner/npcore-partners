page 6060091 "NPR MM Admis. Service Entries"
{

    Caption = 'MM Admission Service Entries';
    Editable = false;
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR MM Admis. Service Entry";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; "Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Entry No. field';
                }
                field(Type; Type)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Type field';
                }
                field("Created Date"; "Created Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Created Date field';
                }
                field("Modify Date"; "Modify Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Modify Date field';
                }
                field(Token; Token)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Token field';
                }
                field("Key"; Key)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Key field';
                }
                field("Scanner Station Id"; "Scanner Station Id")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Scanner Station Id field';
                }
                field(Arrived; Arrived)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Arrived field';
                }
                field("Admission Is Valid"; "Admission Is Valid")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Admission Is Valid field';
                }
                field("Card Entry No."; "Card Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Card Entry No. field';
                }
                field("Membership Entry No."; "Membership Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Membership Entry No. field';
                }
                field("Member Entry No."; "Member Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Member Entry No. field';
                }
                field("External Card No."; "External Card No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the External Card No. field';
                }
                field("External Membership No."; "External Membership No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the External Membership No. field';
                }
                field("External Member No."; "External Member No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the External Member No. field';
                }
                field("Ticket Entry No."; "Ticket Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ticket Entry No. field';
                }
                field("External Ticket No."; "External Ticket No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the External Ticket No. field';
                }
                field("Message"; Message)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Message field';
                }
                field("Ticket Type Code"; "Ticket Type Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ticket Type Code field';
                }
                field("Ticket Type Description"; "Ticket Type Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ticket Type Description field';
                }
                field("Membership Code"; "Membership Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Membership Code field';
                }
                field("Membership Description"; "Membership Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Membership Description field';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
        }
        area(navigation)
        {
            action(Log)
            {
                Caption = 'Log';
                Image = Setup;
                Promoted = true;
                PromotedCategory = Process;
                RunObject = Page "NPR MM Admission Service Log";
                RunPageLink = "Entry No." = FIELD("Entry No.");
                ApplicationArea = All;
                ToolTip = 'Executes the Log action';
            }
        }
    }
}

