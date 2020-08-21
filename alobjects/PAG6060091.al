page 6060091 "MM Admission Service Entries"
{
    // NPR5.31/NPKNAV/20170502  CASE 263737 Transport NPR5.31 - 2 May 2017
    // NPR5.43/CLVA  /20180627  CASE 318579 Added new fields "Ticket Type Code","Ticket Type Description","Membership Code" and "Membership Description"

    Caption = 'MM Admission Service Entries';
    Editable = false;
    PageType = List;
    SourceTable = "MM Admission Service Entry";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; "Entry No.")
                {
                    ApplicationArea = All;
                }
                field(Type; Type)
                {
                    ApplicationArea = All;
                }
                field("Created Date"; "Created Date")
                {
                    ApplicationArea = All;
                }
                field("Modify Date"; "Modify Date")
                {
                    ApplicationArea = All;
                }
                field(Token; Token)
                {
                    ApplicationArea = All;
                }
                field("Key"; Key)
                {
                    ApplicationArea = All;
                }
                field("Scanner Station Id"; "Scanner Station Id")
                {
                    ApplicationArea = All;
                }
                field(Arrived; Arrived)
                {
                    ApplicationArea = All;
                }
                field("Admission Is Valid"; "Admission Is Valid")
                {
                    ApplicationArea = All;
                }
                field("Card Entry No."; "Card Entry No.")
                {
                    ApplicationArea = All;
                }
                field("Membership Entry No."; "Membership Entry No.")
                {
                    ApplicationArea = All;
                }
                field("Member Entry No."; "Member Entry No.")
                {
                    ApplicationArea = All;
                }
                field("External Card No."; "External Card No.")
                {
                    ApplicationArea = All;
                }
                field("External Membership No."; "External Membership No.")
                {
                    ApplicationArea = All;
                }
                field("External Member No."; "External Member No.")
                {
                    ApplicationArea = All;
                }
                field("Ticket Entry No."; "Ticket Entry No.")
                {
                    ApplicationArea = All;
                }
                field("External Ticket No."; "External Ticket No.")
                {
                    ApplicationArea = All;
                }
                field(Message; Message)
                {
                    ApplicationArea = All;
                }
                field("Ticket Type Code"; "Ticket Type Code")
                {
                    ApplicationArea = All;
                }
                field("Ticket Type Description"; "Ticket Type Description")
                {
                    ApplicationArea = All;
                }
                field("Membership Code"; "Membership Code")
                {
                    ApplicationArea = All;
                }
                field("Membership Description"; "Membership Description")
                {
                    ApplicationArea = All;
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
                RunObject = Page "MM Admission Service Log";
                RunPageLink = "Entry No." = FIELD("Entry No.");
            }
        }
    }
}

