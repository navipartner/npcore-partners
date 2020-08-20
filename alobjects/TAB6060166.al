table 6060166 "Event Exch. Int. E-Mail"
{
    // NPR5.38/NPKNAV/20180126  CASE 285194 Transport NPR5.38 - 26 January 2018
    // NPR5.46/TJ  /20180605  CASE 317448 New fields "Time Zone Id", "Time Zone Display Name" and "Time Zone Custom Offset (Min)"

    Caption = 'Event Exch. Int. E-Mail';
    DataClassification = CustomerContent;
    LookupPageID = "Event Exch. Int. E-Mails";

    fields
    {
        field(1; "E-Mail"; Text[50])
        {
            Caption = 'E-Mail';
            DataClassification = CustomerContent;
            ExtendedDatatype = EMail;
        }
        field(10; "Search E-Mail"; Code[50])
        {
            Caption = 'Search E-Mail';
            DataClassification = CustomerContent;
        }
        field(20; Password; BLOB)
        {
            Caption = 'Password';
            DataClassification = CustomerContent;
        }
        field(30; "Exchange Server Url"; Text[250])
        {
            Caption = 'Server Url';
            DataClassification = CustomerContent;
        }
        field(40; "Default Organizer E-Mail"; Boolean)
        {
            Caption = 'Default Organizer E-Mail';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                EventExchIntEMail.SetRange("Default Organizer E-Mail", true);
                EventExchIntEMail.SetFilter("Search E-Mail", '<>%1', "Search E-Mail");
                if EventExchIntEMail.FindFirst then begin
                    EventExchIntEMail."Default Organizer E-Mail" := false;
                    EventExchIntEMail.Modify;
                end;
            end;
        }
        field(50; "Time Zone No."; Integer)
        {
            Caption = 'Time Zone No.';
            DataClassification = CustomerContent;
            Description = 'NPR5.46';
            TableRelation = "Time Zone";

            trigger OnLookup()
            var
                TimeZone: Record "Time Zone";
                TimeZones: Page "Time Zones";
            begin
                //-NPR5.46 [323953]
                if TimeZone.Get("Time Zone No.") then
                    TimeZones.SetRecord(TimeZone);
                TimeZones.LookupMode(true);
                if TimeZones.RunModal = ACTION::LookupOK then begin
                    TimeZones.GetRecord(TimeZone);
                    Validate("Time Zone No.", TimeZone."No.");
                end;
                //+NPR5.46 [323953]
            end;
        }
        field(51; "Time Zone Display Name"; Text[250])
        {
            CalcFormula = Lookup ("Time Zone"."Display Name" WHERE("No." = FIELD("Time Zone No.")));
            Caption = 'Time Zone Display Name';
            Description = 'NPR5.46';
            Editable = false;
            FieldClass = FlowField;
        }
        field(52; "Time Zone Custom Offset (Min)"; Integer)
        {
            Caption = 'Time Zone Custom Offset (Min)';
            DataClassification = CustomerContent;
            Description = 'NPR5.46';
        }
    }

    keys
    {
        key(Key1; "E-Mail")
        {
        }
        key(Key2; "Search E-Mail")
        {
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "E-Mail", "Default Organizer E-Mail")
        {
        }
    }

    trigger OnInsert()
    begin
        UpdateSearchEmail();
    end;

    trigger OnRename()
    begin
        UpdateSearchEmail();
    end;

    var
        EventExchIntEMail: Record "Event Exch. Int. E-Mail";
        EMailExists: Label '%1 %2 already exists.';
        EventEWSMgt: Codeunit "Event EWS Management";

    procedure SetPassword()
    begin
        EventEWSMgt.SetEmailPassword(Rec);
        Modify;
    end;

    local procedure GetPassword(): Text
    begin
        exit(EventEWSMgt.GetEmailPassword(Rec));
    end;

    procedure TestServerConnection()
    begin
        EventEWSMgt.TestEmailServerConnection(Rec);
        Modify;
    end;

    local procedure UpdateSearchEmail()
    begin
        EventExchIntEMail.SetRange("Search E-Mail", "E-Mail");
        if not EventExchIntEMail.IsEmpty then
            Error(EMailExists, FieldCaption("E-Mail"), "E-Mail");
        "Search E-Mail" := "E-Mail";
    end;
}

