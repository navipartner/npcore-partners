table 6060120 "TM Admission"
{
    // TM1.00/TSA/20151217  CASE 228982 NaviPartner Ticket Management
    // TM1.04/TSA/20160104  CASE 230600 Caption Change Occation -> Event
    // TM1.08/TSA/20160262  CASE 232262 Dependant admission objects
    // TM80.1.09/TSA/20160229  CASE 235795 Default Schedule option on Admission Code
    // TM80.1.09/TSA/20160310  CASE 236689 Change field from percentage to absolute
    // TM1.11/BR/20160331  CASE 237850 Changed recurrance calculation, Addded check to OnDelete
    // TM1.11/TSA/20160404  CASE 232250 Added field 47 and 48
    // TM1.12/TSA/20160407  CASE 230600 Added DAN Captions
    // TM1.16/TSA/20160622  CASE 245004 Added field Prompt For Email
    // TM1.21/ANEN /20170406 CASE 271150 Added field "POS Schedule Selection To Date" (to be used for by fcn. [SelectSchedule] in page [TM Ticket Make reservation] filtering adm. sch. entries to be shown in scheudle selection page on POs)
    // TM1.28/TSA /20180131 CASE 303925 Added Admission Base Calendar Code to establish "non-working" days.
    // TM1.28/TSA /20180219 CASE 305707 Added Ticket Base Calendar functionality
    // TM1.38/TSA /20181012 CASE 332109 Added eTicket

    Caption = 'Admission';
    LookupPageID = "TM Ticket Admissions";

    fields
    {
        field(1;"Admission Code";Code[20])
        {
            Caption = 'Admission Code';
        }
        field(2;Type;Option)
        {
            Caption = 'Type';
            OptionCaption = 'Location,Event';
            OptionMembers = LOCATION,OCCASION;
        }
        field(10;Description;Text[50])
        {
            Caption = 'Description';
        }
        field(15;"Location Admission Code";Code[20])
        {
            Caption = 'Location Admission Code';
            TableRelation = "TM Admission" WHERE (Type=CONST(LOCATION));
        }
        field(20;"Capacity Limits By";Option)
        {
            Caption = 'Capacity Limits By';
            OptionCaption = 'Admission,Schedule,Override';
            OptionMembers = ADMISSION,SCHEDULE,OVERRIDE;
        }
        field(21;"Default Schedule";Option)
        {
            Caption = 'Default Schedule';
            OptionCaption = 'Today,Next Available,Schedule Entry Required,None';
            OptionMembers = TODAY,NEXT_AVAILABLE,SCHEDULE_ENTRY,"NONE";
        }
        field(40;"Prebook Is Required";Boolean)
        {
            Caption = 'Prebook Is Required';
        }
        field(41;"Max Capacity Per Sch. Entry";Integer)
        {
            Caption = 'Max Capacity Per Sch. Entry';
        }
        field(42;"Reserved For Web";Integer)
        {
            Caption = 'Reserved For Web';
        }
        field(43;"Reserved For Members";Integer)
        {
            Caption = 'Reserved For Members';
        }
        field(44;"Capacity Control";Option)
        {
            Caption = 'Capacity Control';
            OptionCaption = 'None,Sales,Admitted,Full';
            OptionMembers = "NONE",SALES,ADMITTED,FULL;
        }
        field(45;"Prebook From";DateFormula)
        {
            Caption = 'Prebook From';
        }
        field(47;"Unbookable Before Start (Secs)";Integer)
        {
            Caption = 'Unbookable Before Start (Secs)';
        }
        field(48;"Bookable Passed Start (Secs)";Integer)
        {
            Caption = 'Bookable Passed Start (Secs)';
        }
        field(50;"Dependent Admission Code";Code[20])
        {
            Caption = 'Dependent Admission Code';
            TableRelation = "TM Admission";
        }
        field(51;"Dependency Type";Option)
        {
            Caption = 'Dependency Type';
            OptionCaption = ' ,Within Timeframe,Exclude';
            OptionMembers = NA,TIMEFRAME,EXCLUDE;
        }
        field(52;"Dependency Timeframe";DateFormula)
        {
            Caption = 'Dependency Timeframe';
        }
        field(60;"Ticketholder Notification Type";Option)
        {
            Caption = 'Ticketholder Notification Type';
            OptionCaption = 'Not Required,Optional,Required';
            OptionMembers = NOT_REQUIRED,OPTIONAL,REQUIRED;
        }
        field(61;"POS Schedule Selection Date F.";DateFormula)
        {
            Caption = 'POS Admission Schedule Entry Selection Date Filter';
        }
        field(100;"Admission Base Calendar Code";Code[10])
        {
            Caption = 'Admission Base Calendar Code';
            TableRelation = "Base Calendar";
        }
        field(110;"Ticket Base Calendar Code";Code[10])
        {
            Caption = 'Ticket Base Calendar Code';
            TableRelation = "Base Calendar";
        }
        field(210;"eTicket Type Code";Text[30])
        {
            Caption = 'eTicket Type Code';
            Description = '//-TM1.38 [332109]';
        }
    }

    keys
    {
        key(Key1;"Admission Code")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        TMAdmissionScheduleLines: Record "TM Admission Schedule Lines";
        TMTicketAdmissionBOM: Record "TM Ticket Admission BOM";
        MMMembershipAdmissionSetup: Record "MM Membership Admission Setup";
    begin
        //-TM1.11
        TMTicketAdmissionBOM.SetRange("Admission Code","Admission Code");
        if (TMTicketAdmissionBOM.FindFirst ()) then
          Error (ADMISSION_REF, "Admission Code", TMTicketAdmissionBOM.TableCaption, TMTicketAdmissionBOM."Item No.");

        MMMembershipAdmissionSetup.SetRange("Admission Code","Admission Code");
        if (MMMembershipAdmissionSetup.FindFirst ()) then
          Error (ADMISSION_REF, "Admission Code", MMMembershipAdmissionSetup.TableCaption, MMMembershipAdmissionSetup."Membership  Code");

        TMAdmissionScheduleLines.Reset;
        TMAdmissionScheduleLines.SetRange("Admission Code","Admission Code");
        TMAdmissionScheduleLines.DeleteAll(true);
        //+TM1.11
    end;

    trigger OnModify()
    begin
        UpdateScheduleLines ();
    end;

    var
        ADMISSION_REF: Label 'Admission Code %1 is referenced in %2 for %3 and can''t be deleted.';

    local procedure UpdateScheduleLines()
    var
        AdmissionScheduleLines: Record "TM Admission Schedule Lines";
    begin
        AdmissionScheduleLines.SetFilter ("Admission Code", '=%1', "Admission Code");
        if (AdmissionScheduleLines.FindSet ()) then begin
          repeat
            AdmissionScheduleLines.SyncAdmissionSettings (Rec);
            AdmissionScheduleLines.Modify ();
          until (AdmissionScheduleLines.Next () = 0);
        end;
    end;
}

