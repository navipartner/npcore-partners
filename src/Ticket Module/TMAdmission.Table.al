table 6060120 "NPR TM Admission"
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
    // TM1.43/TSA /20190903 CASE 357359 Added option to Capacity Control (SEATING)
    // TM1.45/TSA /20191101 CASE 374620 Added "Stakeholder (E-Mail/Phone No.)"
    // TM1.45/TSA /20191203 CASE 380754 Added Waiting List Setup Code

    Caption = 'Admission';
    DataClassification = CustomerContent;
    LookupPageID = "NPR TM Ticket Admissions";

    fields
    {
        field(1; "Admission Code"; Code[20])
        {
            Caption = 'Admission Code';
            DataClassification = CustomerContent;
        }
        field(2; Type; Option)
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Location,Event';
            OptionMembers = LOCATION,OCCASION;
        }
        field(10; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(15; "Location Admission Code"; Code[20])
        {
            Caption = 'Location Admission Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR TM Admission" WHERE(Type = CONST(LOCATION));
        }
        field(20; "Capacity Limits By"; Option)
        {
            Caption = 'Capacity Limits By';
            DataClassification = CustomerContent;
            OptionCaption = 'Admission,Schedule,Override';
            OptionMembers = ADMISSION,SCHEDULE,OVERRIDE;
        }
        field(21; "Default Schedule"; Option)
        {
            Caption = 'Default Schedule';
            DataClassification = CustomerContent;
            OptionCaption = 'Today,Next Available,Schedule Entry Required,None';
            OptionMembers = TODAY,NEXT_AVAILABLE,SCHEDULE_ENTRY,"NONE";
        }
        field(40; "Prebook Is Required"; Boolean)
        {
            Caption = 'Prebook Is Required';
            DataClassification = CustomerContent;
        }
        field(41; "Max Capacity Per Sch. Entry"; Integer)
        {
            Caption = 'Max Capacity Per Sch. Entry';
            DataClassification = CustomerContent;
        }
        field(42; "Reserved For Web"; Integer)
        {
            Caption = 'Reserved For Web';
            DataClassification = CustomerContent;
        }
        field(43; "Reserved For Members"; Integer)
        {
            Caption = 'Reserved For Members';
            DataClassification = CustomerContent;
        }
        field(44; "Capacity Control"; Option)
        {
            Caption = 'Capacity Control';
            DataClassification = CustomerContent;
            OptionCaption = 'None,Sales,Admitted,Admitted & Departed,Seating';
            OptionMembers = "NONE",SALES,ADMITTED,FULL,SEATING;
        }
        field(45; "Prebook From"; DateFormula)
        {
            Caption = 'Prebook From';
            DataClassification = CustomerContent;
        }
        field(47; "Unbookable Before Start (Secs)"; Integer)
        {
            Caption = 'Unbookable Before Start (Secs)';
            DataClassification = CustomerContent;
        }
        field(48; "Bookable Passed Start (Secs)"; Integer)
        {
            Caption = 'Bookable Passed Start (Secs)';
            DataClassification = CustomerContent;
        }
        field(50; "Dependent Admission Code"; Code[20])
        {
            Caption = 'Dependent Admission Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR TM Admission";
            ObsoleteState = Removed;
            ObsoleteReason = 'Replace by NPR TM Adm. Dependency subtables to handle more complex setup';
        }
        field(51; "Dependency Type"; Option)
        {
            Caption = 'Dependency Type';
            DataClassification = CustomerContent;
            OptionCaption = ' ,Within Timeframe,Exclude';
            OptionMembers = NA,TIMEFRAME,EXCLUDE;
            ObsoleteState = Removed;
            ObsoleteReason = 'Replace by NPR TM Adm. Dependency subtables to handle more complex setup';
        }
        field(52; "Dependency Timeframe"; DateFormula)
        {
            Caption = 'Dependency Timeframe';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Replace by NPR TM Adm. Dependency subtables to handle more complex setup';
        }
        field(53; "Dependency Code"; Code[20])
        {
            Caption = 'Admission Dependency Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR TM Adm. Dependency";
        }
        field(60; "Ticketholder Notification Type"; Option)
        {
            Caption = 'Ticketholder Notification Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Not Required,Optional,Required';
            OptionMembers = NOT_REQUIRED,OPTIONAL,REQUIRED;
        }
        field(61; "POS Schedule Selection Date F."; DateFormula)
        {
            Caption = 'POS Admission Schedule Entry Selection Date Filter';
            DataClassification = CustomerContent;
        }
        field(70; "Stakeholder (E-Mail/Phone No.)"; Text[40])
        {
            Caption = 'Stakeholder (E-Mail/Phone No.)';
            DataClassification = CustomerContent;
        }
        field(80; "Waiting List Setup Code"; Code[20])
        {
            Caption = 'Waiting List Setup Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR TM Waiting List Setup";
        }
        field(100; "Admission Base Calendar Code"; Code[10])
        {
            Caption = 'Admission Base Calendar Code';
            DataClassification = CustomerContent;
            TableRelation = "Base Calendar";
        }
        field(110; "Ticket Base Calendar Code"; Code[10])
        {
            Caption = 'Ticket Base Calendar Code';
            DataClassification = CustomerContent;
            TableRelation = "Base Calendar";
        }
        field(210; "eTicket Type Code"; Text[30])
        {
            Caption = 'eTicket Type Code';
            DataClassification = CustomerContent;
            Description = '//-TM1.38 [332109]';
        }
    }

    keys
    {
        key(Key1; "Admission Code")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        TMAdmissionScheduleLines: Record "NPR TM Admis. Schedule Lines";
        TMTicketAdmissionBOM: Record "NPR TM Ticket Admission BOM";
        MMMembershipAdmissionSetup: Record "NPR MM Members. Admis. Setup";
    begin
        //-TM1.11
        TMTicketAdmissionBOM.SetRange("Admission Code", "Admission Code");
        if (TMTicketAdmissionBOM.FindFirst()) then
            Error(ADMISSION_REF, "Admission Code", TMTicketAdmissionBOM.TableCaption, TMTicketAdmissionBOM."Item No.");

        MMMembershipAdmissionSetup.SetRange("Admission Code", "Admission Code");
        if (MMMembershipAdmissionSetup.FindFirst()) then
            Error(ADMISSION_REF, "Admission Code", MMMembershipAdmissionSetup.TableCaption, MMMembershipAdmissionSetup."Membership  Code");

        TMAdmissionScheduleLines.Reset;
        TMAdmissionScheduleLines.SetRange("Admission Code", "Admission Code");
        TMAdmissionScheduleLines.DeleteAll(true);
        //+TM1.11
    end;

    trigger OnModify()
    begin
        UpdateScheduleLines();
    end;

    var
        ADMISSION_REF: Label 'Admission Code %1 is referenced in %2 for %3 and can''t be deleted.';

    local procedure UpdateScheduleLines()
    var
        AdmissionScheduleLines: Record "NPR TM Admis. Schedule Lines";
    begin
        AdmissionScheduleLines.SetFilter("Admission Code", '=%1', "Admission Code");
        if (AdmissionScheduleLines.FindSet()) then begin
            repeat
                AdmissionScheduleLines.SyncAdmissionSettings(Rec);
                AdmissionScheduleLines.Modify();
            until (AdmissionScheduleLines.Next() = 0);
        end;
    end;
}

