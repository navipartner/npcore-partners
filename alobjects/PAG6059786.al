page 6059786 "TM Ticket Access Entry List"
{
    // TM1.00/TSA/20151217  CASE 219658-01 NaviPartner Ticket Management
    // TM1.12/TSA/20160407  CASE 230600 Added DAN Captions
    // TM1.17/NPKNAV/20161026  CASE 256152 Transport TM1.17
    // TM1.21/TSA/20170504  CASE 274843 Added ToggleBlockUnblock() function
    // TM1.27/TSA /20180125 CASE 301140 Refactored

    Caption = 'Ticket access Entry List';
    Editable = false;
    PageType = List;
    SourceTable = "TM Ticket Access Entry";
    UsageCategory = ReportsAndAnalysis;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No.";"Entry No.")
                {
                }
                field("Ticket No.";"Ticket No.")
                {
                }
                field("Ticket Type Code";"Ticket Type Code")
                {
                }
                field("Admission Code";"Admission Code")
                {
                }
                field("Access Date";"Access Date")
                {
                }
                field("Access Time";"Access Time")
                {
                }
                field(Description;Description)
                {
                }
                field("Member Card Code";"Member Card Code")
                {
                }
                field(Status;Status)
                {
                }
                field(Quantity;Quantity)
                {
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action("Detailed Access Entries")
            {
                Caption = 'Detailed Access Entries';
                Image = LedgerEntries;
                Promoted = true;
                PromotedCategory = Process;
                RunObject = Page "TM Det. Ticket Access Entry";
                //RunPageLink = "Ticket Access Entry No."=FIELD("Entry No.");
            }
        }
        area(processing)
        {
            action("Register Arrival")
            {
                Caption = 'Register Arrival';
                Image = Approve;

                trigger OnAction()
                var
                    TicketManagement: Codeunit "TM Ticket Management";
                    MessageId: Integer;
                    MessageText: Text;
                    NoValue: BigInteger;
                begin

                    //-TM1.27 [301140]
                    NoValue := -1;
                    MessageId := TicketManagement.ValidateTicketForArrival (0, "Ticket No.", "Admission Code", NoValue, true, MessageText);
                    //MessageId := TicketManagement.ValidateTicketForArrival (0, "Ticket No.", "Admission Code", -1, TRUE, MessageText);
                    //+TM1.27 [301140]
                end;
            }
            action("Register Departure")
            {
                Caption = 'Register Departure';
                Image = DefaultFault;

                trigger OnAction()
                var
                    TicketManagement: Codeunit "TM Ticket Management";
                    MessageId: Integer;
                    MessageText: Text;
                begin

                    MessageId := TicketManagement.ValidateTicketForDeparture (0, "Ticket No.", "Admission Code", true, MessageText);
                end;
            }
            action("Block/Unblock")
            {
                Caption = 'Block/Unblock';
                Image = change;

                trigger OnAction()
                begin
                    ToggleBlockUnblock ();
                end;
            }
        }
    }

    local procedure ToggleBlockUnblock()
    var
        TicketAccessEntry: Record "TM Ticket Access Entry";
        TicketAccessEntry2: Record "TM Ticket Access Entry";
    begin

        CurrPage.SetSelectionFilter (TicketAccessEntry);
        if (TicketAccessEntry.FindSet ()) then begin
          repeat
            TicketAccessEntry2.Get (TicketAccessEntry."Entry No.");

            case TicketAccessEntry.Status of
              TicketAccessEntry.Status::ACCESS : TicketAccessEntry2.Status := TicketAccessEntry2.Status::BLOCKED;
              TicketAccessEntry.Status::BLOCKED : TicketAccessEntry2.Status := TicketAccessEntry2.Status::ACCESS;
            end;

            TicketAccessEntry2.Modify ();
          until (TicketAccessEntry.Next () = 0);
        end;
    end;
}

