table 6060120 "NPR TM Admission"
{
    Access = Internal;

    Caption = 'Admission';
    DataClassification = CustomerContent;
    LookupPageID = "NPR TM Ticket Admissions";

    fields
    {
        field(1; "Admission Code"; Code[20])
        {
            Caption = 'Admission Code';
            DataClassification = CustomerContent;
            NotBlank = true;
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
        field(20; "Capacity Limits By"; Enum "NPR TM CapacityLimit")
        {
            Caption = 'Capacity Limits By';
            DataClassification = CustomerContent;
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
            ObsoleteState = Pending;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Never implemented. Use field "Visibility On Web"';
        }
        field(43; "Reserved For Members"; Integer)
        {
            Caption = 'Reserved For Members';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Never implemented. Use field "Visibility On Web"';
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
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Use "Event Arrival From Time"';
        }
        field(48; "Bookable Passed Start (Secs)"; Integer)
        {
            Caption = 'Bookable Passed Start (Secs)';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Use "Event Arrival Until Time"';
        }
        field(50; "Dependent Admission Code"; Code[20])
        {
            Caption = 'Dependent Admission Code';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Replace by NPR TM Adm. Dependency subtables to handle more complex setup';
        }
        field(51; "Dependency Type"; Option)
        {
            Caption = 'Dependency Type';
            DataClassification = CustomerContent;
            OptionCaption = ' ,Within Timeframe,Exclude';
            OptionMembers = NA,TIMEFRAME,EXCLUDE;
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Replace by NPR TM Adm. Dependency subtables to handle more complex setup';
        }
        field(52; "Dependency Timeframe"; DateFormula)
        {
            Caption = 'Dependency Timeframe';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
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
        field(150; "Event Arrival From Time"; Time)
        {
            Caption = 'Event Arrival From Time';
            DataClassification = CustomerContent;
        }
        field(151; "Event Arrival Until Time"; Time)
        {
            Caption = 'Event Arrival Until Time';
            DataClassification = CustomerContent;
        }
        field(160; "Sales From Date (Rel.)"; DateFormula)
        {
            Caption = 'Sales From Date (Rel.)';
            DataClassification = CustomerContent;
        }
        field(162; "Sales From Time"; Time)
        {
            Caption = 'Sales From Time';
            DataClassification = CustomerContent;
        }
        field(163; "Sales Until Date (Rel.)"; DateFormula)
        {
            Caption = 'Sales Until Date (Rel.)';
            DataClassification = CustomerContent;
        }
        field(165; "Sales Until Time"; Time)
        {
            Caption = 'Sales Until Time';
            DataClassification = CustomerContent;
        }
        field(170; AdmissionImage; Media)
        {
            Caption = 'Admission Image';
            DataClassification = CustomerContent;
        }

        field(210; "eTicket Type Code"; Text[30])
        {
            Caption = 'eTicket Type Code';
            DataClassification = CustomerContent;
        }
        field(220; "Additional Experience Item No."; Code[20])
        {
            Caption = 'Additional Experience Item No.';
            DataClassification = CustomerContent;
            TableRelation = Item;

            trigger OnValidate()
            var
                TicketBom: Record "NPR TM Ticket Admission BOM";
                CanNotBlank: Label 'This field can be cleared when all %4 records and field %1 has value %2, check item %3.', Comment = '1=field name, 2=value, 3=item number, 4=table name';
            begin
                if ((Rec."Additional Experience Item No." = '') and (xRec."Additional Experience Item No." <> '')) then begin
                    TicketBom.SetFilter("Admission Code", '=%1', Rec."Admission Code");
                    TicketBom.SetFilter("Admission Inclusion", '<>%1', TicketBom."Admission Inclusion"::REQUIRED);
                    if (TicketBom.FindFirst()) then
                        Error(CanNotBlank, TicketBom.FieldCaption("Admission Inclusion"), TicketBom."Admission Inclusion"::REQUIRED, TicketBom."Item No.", TicketBom.TableCaption());
                end;
            end;
        }
        
        field(380; TimeZoneNo; Integer)
        {
            Caption = 'Time Zone No.';
            DataClassification = CustomerContent;
            InitValue = 0;
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
        TMTicketAdmissionBOM.SetRange("Admission Code", "Admission Code");
        if (TMTicketAdmissionBOM.FindFirst()) then
            Error(ADMISSION_REF, "Admission Code", TMTicketAdmissionBOM.TableCaption, TMTicketAdmissionBOM."Item No.");

        MMMembershipAdmissionSetup.SetRange("Admission Code", "Admission Code");
        if (MMMembershipAdmissionSetup.FindFirst()) then
            Error(ADMISSION_REF, "Admission Code", MMMembershipAdmissionSetup.TableCaption, MMMembershipAdmissionSetup."Membership  Code");

        TMAdmissionScheduleLines.Reset();
        TMAdmissionScheduleLines.SetRange("Admission Code", "Admission Code");
        TMAdmissionScheduleLines.DeleteAll(true);
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

