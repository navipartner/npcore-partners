page 6060123 "TM Det. Ticket Access Entry"
{
    // TM1.00/TSA/20151217  CASE 228982 NaviPartner Ticket Management
    // TM1.09/TSA/20160311  CASE 236742 UX Improvemets
    // TM1.12/TSA/20160407  CASE 230600 Added DAN Captions
    // TM1.17/NPKNAV/20161026  CASE 256152 Transport TM1.17
    // TM1.28/TSA /20180130 CASE 301222 Added button to un-consume an item

    Caption = 'Detailed Ticket Access Entry';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "TM Det. Ticket Access Entry";

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
                field("Posting Date";"Posting Date")
                {
                }
                field("Ticket No.";"Ticket No.")
                {
                }
                field("Ticket Access Entry No.";"Ticket Access Entry No.")
                {
                }
                field(Type;Type)
                {
                }
                field("External Adm. Sch. Entry No.";"External Adm. Sch. Entry No.")
                {
                }
                field("Scheduled Time";ScheduledTime)
                {
                    Caption = 'Scheduled Time';
                    Editable = false;
                }
                field(Quantity;Quantity)
                {
                }
                field("Closed By Entry No.";"Closed By Entry No.")
                {
                }
                field(Open;Open)
                {
                }
                field("Sales Channel No.";"Sales Channel No.")
                {
                }
                field("Created Datetime";"Created Datetime")
                {
                }
                field("User ID";"User ID")
                {
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action("Schedule Entry")
            {
                Caption = 'Schedule Entry';
                Image = WorkCenterLoad;
                Promoted = true;
                PromotedIsBig = true;
                RunObject = Page "TM Admission Schedule Entry";
                RunPageLink = "External Schedule Entry No."=FIELD("External Adm. Sch. Entry No.");
            }
        }
        area(processing)
        {
            action("Unconsume Item")
            {
                Caption = 'Unconsume Item';
                Image = ConsumptionJournal;
                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //PromotedCategory = Process;

                trigger OnAction()
                begin

                    UnconsumeItem ();
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        AdmissionScheduleEntry: Record "TM Admission Schedule Entry";
    begin
        ScheduledTime := '';
        AdmissionScheduleEntry.SetFilter ("External Schedule Entry No.", '=%1', "External Adm. Sch. Entry No.");
        AdmissionScheduleEntry.SetFilter (Cancelled, '=%1', false);
        if (AdmissionScheduleEntry.FindFirst ()) then
          ScheduledTime := StrSubstNo ('%1 %2', AdmissionScheduleEntry."Admission Start Date", AdmissionScheduleEntry."Admission Start Time");
    end;

    var
        ScheduledTime: Text[30];

    local procedure UnconsumeItem()
    begin

        TestField (Type, Type::CONSUMED);
        if (Type = Type::CONSUMED) then
          Delete;
    end;
}

