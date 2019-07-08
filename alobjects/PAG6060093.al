page 6060093 "TM Offline Ticket Validation"
{
    // TM1.22/NPKNAV/20170612  CASE 278142 Transport T0007 - 12 June 2017

    Caption = 'Offline Ticket Validation';
    PageType = List;
    SourceTable = "TM Offline Ticket Validation";
    UsageCategory = Tasks;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No.";"Entry No.")
                {
                    Visible = false;
                }
                field("Ticket Reference Type";"Ticket Reference Type")
                {
                    Visible = false;
                }
                field("Ticket Reference No.";"Ticket Reference No.")
                {
                }
                field("Admission Code";"Admission Code")
                {
                }
                field("Member Reference Type";"Member Reference Type")
                {
                    Visible = false;
                }
                field("Member Reference No.";"Member Reference No.")
                {
                    Visible = false;
                }
                field("Event Type";"Event Type")
                {
                }
                field("Event Date";"Event Date")
                {
                }
                field("Event Time";"Event Time")
                {
                }
                field("Process Status";"Process Status")
                {
                }
                field("Process Response Text";"Process Response Text")
                {
                }
                field("Import Reference No.";"Import Reference No.")
                {
                }
                field("Imported At";"Imported At")
                {
                }
                field("Import Reference Name";"Import Reference Name")
                {
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Process Entry")
            {
                Caption = 'Process Entry';
                Image = Post;
                Promoted = true;
                PromotedIsBig = true;

                trigger OnAction()
                begin

                    OfflineTicketValidation.ProcessEntry ("Entry No.");
                    CurrPage.Update (false);
                end;
            }
            action("Process Batch")
            {
                Caption = 'Process Batch';
                Image = PostBatch;
                Promoted = true;
                PromotedIsBig = true;

                trigger OnAction()
                begin

                    OfflineTicketValidation.ProcessImportBatch ("Import Reference No.");
                    CurrPage.Update (false);
                end;
            }
        }
        area(navigation)
        {
            action(Ticket)
            {
                Caption = 'Ticket';
                Image = Navigate;
                Promoted = true;
                PromotedIsBig = true;
                RunObject = Page "TM Ticket List";
                RunPageLink = "External Ticket No."=FIELD("Ticket Reference No.");
            }
        }
    }

    trigger OnOpenPage()
    begin

        SetFilter ("Process Status", '<>%1', "Process Status"::VALID);
    end;

    var
        OfflineTicketValidation: Codeunit "TM Offline Ticket Validation";
}

