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
                field("Entry No.";"Entry No.")
                {
                }
                field(Type;Type)
                {
                }
                field("Created Date";"Created Date")
                {
                }
                field("Modify Date";"Modify Date")
                {
                }
                field(Token;Token)
                {
                }
                field("Key";Key)
                {
                }
                field("Scanner Station Id";"Scanner Station Id")
                {
                }
                field(Arrived;Arrived)
                {
                }
                field("Admission Is Valid";"Admission Is Valid")
                {
                }
                field("Card Entry No.";"Card Entry No.")
                {
                }
                field("Membership Entry No.";"Membership Entry No.")
                {
                }
                field("Member Entry No.";"Member Entry No.")
                {
                }
                field("External Card No.";"External Card No.")
                {
                }
                field("External Membership No.";"External Membership No.")
                {
                }
                field("External Member No.";"External Member No.")
                {
                }
                field("Ticket Entry No.";"Ticket Entry No.")
                {
                }
                field("External Ticket No.";"External Ticket No.")
                {
                }
                field(Message;Message)
                {
                }
                field("Ticket Type Code";"Ticket Type Code")
                {
                }
                field("Ticket Type Description";"Ticket Type Description")
                {
                }
                field("Membership Code";"Membership Code")
                {
                }
                field("Membership Description";"Membership Description")
                {
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
                RunPageLink = "Entry No."=FIELD("Entry No.");
            }
        }
    }
}

