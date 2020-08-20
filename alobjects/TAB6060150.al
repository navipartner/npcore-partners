table 6060150 "Event Exch. Int. Template"
{
    // NPR5.34/TJ  /20170728 CASE 277938 New object
    // NPR5.35/TJ  /20170822 CASE 281185 Added fields "Reminder Enabled (Calendar)" and "Reminder (Minutes) (Calendar)"
    // NPR5.36/TJ  /20170912 CASE 287800 Added field "First Day Only (Appointment)"
    // NPR5.43/TJ  /20180322 CASE 262079 New field "Ticket URL Placeholder(E-Mail)"
    // NPR5.55/TJ  /20200129 CASE 374887 New fields "Auto. Send. Enabled (E-Mail)" and "Auto.Send.Event Status(E-Mail)"

    Caption = 'Event Exch. Int. Template';
    DataClassification = CustomerContent;
    LookupPageID = "Event Exch. Int. Templates";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }
        field(10; Description; Text[30])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(15; "E-mail Template Header Code"; Code[20])
        {
            Caption = 'E-Mail Template Header Code';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = "E-mail Template Header";

            trigger OnValidate()
            begin
                EMailTemplateHeader.Get("E-mail Template Header Code");
                Description := EMailTemplateHeader.Description;
            end;
        }
        field(20; "Template For"; Option)
        {
            Caption = 'Template For';
            DataClassification = CustomerContent;
            OptionCaption = 'Customer,Team';
            OptionMembers = Customer,Team;

            trigger OnValidate()
            begin
                if "Template For" = "Template For"::Customer then
                    TestField("Exch. Item Type", "Exch. Item Type"::"E-Mail");
            end;
        }
        field(30; "Exch. Item Type"; Option)
        {
            Caption = 'Exch. Item Type';
            DataClassification = CustomerContent;
            OptionCaption = 'E-Mail,Appointment,Meeting Request';
            OptionMembers = "E-Mail",Appointment,"Meeting Request";

            trigger OnValidate()
            begin
                if "Template For" = "Template For"::Customer then
                    TestField("Exch. Item Type", "Exch. Item Type"::"E-Mail");
            end;
        }
        field(40; "Include Comments (Calendar)"; Boolean)
        {
            Caption = 'Include Comments (Calendar)';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Include Comments (Calendar)" then
                    if "Exch. Item Type" = "Exch. Item Type"::"E-Mail" then
                        Error(ExchItemTypeMustBeCalendar, FieldCaption("Exch. Item Type"), "Exch. Item Type"::Appointment, "Exch. Item Type"::"Meeting Request");
            end;
        }
        field(50; "Conf. Color Categ. (Calendar)"; Text[30])
        {
            Caption = 'Confirmed Color Category (Calendar)';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Conf. Color Categ. (Calendar)" <> '' then
                    if "Exch. Item Type" = "Exch. Item Type"::"E-Mail" then
                        Error(ExchItemTypeMustBeCalendar, FieldCaption("Exch. Item Type"), "Exch. Item Type"::Appointment, "Exch. Item Type"::"Meeting Request");
            end;
        }
        field(60; "Lasts Whole Day (Appointment)"; Boolean)
        {
            Caption = 'Lasts Whole Day (Appointment)';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Lasts Whole Day (Appointment)" then
                    TestField("Exch. Item Type", "Exch. Item Type"::Appointment);
            end;
        }
        field(70; "Reminder Enabled (Calendar)"; Boolean)
        {
            Caption = 'Reminder Enabled (Calendar)';
            DataClassification = CustomerContent;
            Description = 'NPR5.35';
        }
        field(80; "Reminder (Minutes) (Calendar)"; Integer)
        {
            Caption = 'Reminder (Minutes) (Calendar)';
            DataClassification = CustomerContent;
            Description = 'NPR5.35';

            trigger OnValidate()
            begin
                //-NPR5.35 [281185]
                if "Reminder (Minutes) (Calendar)" < 0 then
                    Error(ReminderMinutesPositiveOnly, FieldCaption("Reminder (Minutes) (Calendar)"));
                //+NPR5.35 [281185]
            end;
        }
        field(90; "First Day Only (Appointment)"; Boolean)
        {
            Caption = 'First Day Only (Appointment)';
            DataClassification = CustomerContent;
            Description = 'NPR5.36';
        }
        field(100; "Ticket URL Placeholder(E-Mail)"; Text[30])
        {
            Caption = 'Ticket URL Placeholder(E-Mail)';
            DataClassification = CustomerContent;
            Description = 'NPR5.43';
        }
        field(110; "Auto. Send. Enabled (E-Mail)"; Boolean)
        {
            Caption = 'Enabled';
            DataClassification = CustomerContent;
            Description = 'NPR5.55';
        }
        field(120; "Auto.Send.Event Status(E-Mail)"; Option)
        {
            Caption = 'For Event Status';
            DataClassification = CustomerContent;
            Description = 'NPR5.55';
            OptionCaption = 'Planning,Quote,Order,Completed,,,,,,Postponed,Cancelled,Ready to be Invoiced';
            OptionMembers = Planning,Quote,"Order",Completed,,,,,,Postponed,Cancelled,"Ready to be Invoiced";
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        EventExchIntTempEntry.SetRange(Code, Rec.Code);
        if not EventExchIntTempEntry.IsEmpty then
            if not Confirm(EventExchIntTempEntryExists) then
                Error('');
        EventExchIntTempEntry.DeleteAll;
    end;

    var
        EMailTemplateHeader: Record "E-mail Template Header";
        EventExchIntTempEntry: Record "Event Exch. Int. Temp. Entry";
        EventExchIntTempEntryExists: Label 'This template is used on several events. Deleting will remove this template on all those events. Do you want to continue?';
        ExchItemTypeMustBeCalendar: Label '%1 must be %2 or %3.';
        ReminderMinutesPositiveOnly: Label '%1 can''t be negative integer. It can only be 0 or positive.';
}

