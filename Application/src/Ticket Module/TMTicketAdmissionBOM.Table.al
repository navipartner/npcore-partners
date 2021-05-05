table 6060121 "NPR TM Ticket Admission BOM"
{

    Caption = 'Ticket Admission BOM';
    DataClassification = CustomerContent;
    fields
    {
        field(1; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = CustomerContent;
            TableRelation = Item;

            trigger OnValidate()
            begin
                UpdateItemDescription();
            end;
        }
        field(2; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            DataClassification = CustomerContent;
            TableRelation = "Item Variant".Code where("Item No." = field("Item No."));
        }
        field(3; "Admission Code"; Code[20])
        {
            Caption = 'Admission Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR TM Admission";

            trigger OnValidate()
            begin
                UpdateAdmissionDescription();
            end;
        }
        field(10; Quantity; Integer)
        {
            Caption = 'Quantity';
            DataClassification = CustomerContent;
            InitValue = 1;
        }
        field(11; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(12; Default; Boolean)
        {
            Caption = 'Default';
            DataClassification = CustomerContent;
        }
        field(15; "Prefered Sales Display Method"; Option)
        {
            Caption = 'Preferred Sales Display Method';
            DataClassification = CustomerContent;
            OptionCaption = ' ,Schedule,Calendar';
            OptionMembers = DEFAULT,SCHEDULE,CALENDAR;
        }
        field(20; "Percentage of Adm. Capacity"; Decimal)
        {
            BlankNumbers = BlankZero;
            Caption = 'Percentage of Adm. Capacity';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 2;
            InitValue = 100;
            MaxValue = 100;
            MinValue = 0;
        }
        field(30; "Reschedule Policy"; Option)
        {
            Caption = 'Reschedule Policy';
            DataClassification = CustomerContent;
            OptionCaption = 'Not Allowed,Always (Until Used),Cut-Off (Hours)';
            OptionMembers = NOT_ALLOWED,UNTIL_USED,CUTOFF_HOUR;
        }
        field(32; "Reschedule Cut-Off (Hours)"; Decimal)
        {
            Caption = 'Reschedule Cut-Off (Hours)';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 2;
            BlankNumbers = BlankZero;
        }
        field(40; "Admission Dependency Code"; Code[20])
        {
            Caption = 'Admission Dependency Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR TM Adm. Dependency";
        }
        field(45; "Duration Formula"; DateFormula)
        {
            Caption = 'Duration Formula';
            DataClassification = CustomerContent;
            Description = 'TM1.00';
        }
        field(46; "Max No. Of Entries"; Integer)
        {
            BlankZero = true;
            Caption = 'Max No. Of Entries';
            DataClassification = CustomerContent;
            Description = 'TM1.00';
        }
        field(50; "Admission Inclusion"; Option)
        {
            Caption = 'Admission Inclusion';
            DataClassification = CustomerContent;
            OptionCaption = 'Required,Optional and Selected,Optional and not Selected';
            OptionMembers = REQUIRED,SELECTED,NOT_SELECTED;
        }
        field(55; "Admission Unit Price"; Decimal)
        {
            Caption = 'Admission Unit Price';
            DataClassification = CustomerContent;
        }
        field(60; "Activation Method"; Option)
        {
            Caption = 'Activation Method';
            DataClassification = CustomerContent;
            OptionCaption = ' ,On Scan,On Sale,Always,Per Unit';
            OptionMembers = NA,SCAN,POS,ALWAYS,PER_UNIT;
        }
        field(62; "Admission Entry Validation"; Option)
        {
            Caption = 'Admission Entry Validation';
            DataClassification = CustomerContent;
            OptionCaption = ' ,Single,Same Day,Multiple';
            OptionMembers = NA,SINGLE,SAME_DAY,MULTIPLE;
        }
        field(65; "Revisit Condition (Statistics)"; Option)
        {
            Caption = 'Revisit Condition (Statistics)';
            DataClassification = CustomerContent;
            InitValue = NONINITIAL;
            OptionCaption = ' ,Non-Initial,Daily Non-Initial,Never';
            OptionMembers = NA,NONINITIAL,DAILY_NONINITIAL,NEVER;
        }
        field(70; "Revoke Policy"; Option)
        {
            Caption = 'Revoke Policy';
            DataClassification = CustomerContent;
            OptionCaption = 'Unused Admission,Never Allow,Always Allow';
            OptionMembers = UNUSED,NEVER,ALWAYS;
        }
        field(75; "Refund Price %"; Decimal)
        {
            Caption = 'Refund Price %';
            DataClassification = CustomerContent;
            MaxValue = 100;
            MinValue = 0;
        }
        field(80; "Allow Rescan Within (Sec.)"; Option)
        {
            Caption = 'Allow Rescan Within (Sec.)';
            DataClassification = CustomerContent;
            OptionCaption = ' ,15 Seconds,30 Seconds,60 Seconds,120 Seconds';
            OptionMembers = SINGLE_ENTRY_ONLY,"15","30","60","120";
        }
        field(85; "Publish As eTicket"; Boolean)
        {
            Caption = 'Publish As eTicket';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                Item: Record Item;
                TicketType: Record "NPR TM Ticket Type";
                Admission: Record "NPR TM Admission";
            begin
                if ("Publish As eTicket") then begin

                    Item.Get("Item No.");
                    TicketType.Get(Item."NPR Ticket Type");
                    TicketType.TestField("eTicket Activated", true);

                    "eTicket Type Code" := TicketType."eTicket Type Code";

                    Admission.Get("Admission Code");
                    if (Admission."eTicket Type Code" <> '') then
                        "eTicket Type Code" := Admission."eTicket Type Code";

                    TestField("eTicket Type Code");

                end;
            end;
        }
        field(90; "eTicket Type Code"; Text[30])
        {
            Caption = 'eTicket Type Code';
            DataClassification = CustomerContent;
            Description = '//-TM1.38 [332109]';
        }
        field(95; "Publish Ticket URL"; Option)
        {
            Caption = 'Publish Ticket URL';
            DataClassification = CustomerContent;
            OptionCaption = 'Disable,Publish,Publish & Send';
            OptionMembers = DISABLE,PUBLISH,SEND;

            trigger OnValidate()
            var
                Item: Record Item;
                TicketType: Record "NPR TM Ticket Type";
            begin

                if ("Publish Ticket URL" >= "Publish Ticket URL"::PUBLISH) then begin
                    Item.Get("Item No.");
                    TicketType.Get(Item."NPR Ticket Type");
                    TicketType.TestField(TicketType."DIY Print Layout Code");
                end;
            end;
        }
        field(100; "Admission Description"; Text[50])
        {
            Caption = 'Admission Description';
            DataClassification = CustomerContent;
        }
        field(110; "Ticket Base Calendar Code"; Code[10])
        {
            Caption = 'Ticket Base Calendar Code';
            DataClassification = CustomerContent;
            TableRelation = "Base Calendar";
        }
        field(166; "Sales From Date"; Date)
        {
            Caption = 'Sales From Date';
            DataClassification = CustomerContent;
        }
        field(167; "Sales Until Date"; Date)
        {
            Caption = 'Sales Until Date';
            DataClassification = CustomerContent;
        }
        field(168; "Enforce Schedule Sales Limits"; Boolean)
        {
            Caption = 'Enforce Schedule Sales Limits';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Item No.", "Variant Code", "Admission Code")
        {
        }
    }

    local procedure UpdateItemDescription()
    var
        Item: Record Item;
    begin
        if (Item.Get("Item No.")) then
            Description := Item.Description;
    end;

    local procedure UpdateAdmissionDescription()
    var
        Admission: Record "NPR TM Admission";
    begin
        if (Admission.Get("Admission Code")) then
            "Admission Description" := Admission.Description;
    end;
}

