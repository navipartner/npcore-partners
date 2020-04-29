table 6060121 "TM Ticket Admission BOM"
{
    // NPR4.16/TSA/20150803 CASE219658 Ticket Initial Version
    // TM1.00/TSA/20151217  CASE 228982 NaviPartner Ticket Management
    // TM1.07/TSA/20160125  CASE 232495 Added field Default for auto selection for admission code
    // TM80.1.09/TSA/20160310  CASE 236742 Ticket BOM defaults on registration
    // TM1.11/TSA/20160404  CASE 232250 Added new field Prefered Sales Display Method
    // TM1.12/TSA/20160407  CASE 230600 Added DAN Captions
    // TM1.16/TSA/20160701  CASE 245455 Added fields 45, 46, 60 from ticket type that must configurable on a lower level.
    // TM1.18/TSA/20170103  CASE 262095 Added option field Revoke Policy
    // TM1.20/TSA/20170323  CASE 269171 Added field Refund Price %
    // TM1.28/TSA /20180219 CASE 305707 Ticket Base Calendar functionality
    // TM1.36/TSA /20180801 CASE 316463 Added field "Allow Rescan Within (Sec.)"
    // TM1.38/TSA /20181012 CASE 332109 New field "publish as eTicket"
    // TM1.42/TSA /20190411 CASE 351050 Added field "Revisit Condition (Statistics)"
    // TM1.45/TSA /20191120 CASE 378212 Added Sales cut-off dates
    // TM1.45/TSA /20191216 CASE 382535 Added "Admission Inclusion", "Admission Unit Price"
    // TM90.1.46/TSA /20200127 CASE 387138 Added "Publish Ticket URL"

    Caption = 'Ticket Admission BOM';

    fields
    {
        field(1;"Item No.";Code[20])
        {
            Caption = 'Item No.';
            TableRelation = Item;

            trigger OnValidate()
            begin
                UpdateItemDescription ();
            end;
        }
        field(2;"Variant Code";Code[10])
        {
            Caption = 'Variant Code';
            TableRelation = "Item Variant".Code WHERE ("Item No."=FIELD("Item No."));
        }
        field(3;"Admission Code";Code[20])
        {
            Caption = 'Admission Code';
            TableRelation = "TM Admission";

            trigger OnValidate()
            begin
                UpdateAdmissionDescription ();
            end;
        }
        field(10;Quantity;Integer)
        {
            Caption = 'Quantity';
            InitValue = 1;
        }
        field(11;Description;Text[50])
        {
            Caption = 'Description';
        }
        field(12;Default;Boolean)
        {
            Caption = 'Default';
        }
        field(15;"Prefered Sales Display Method";Option)
        {
            Caption = 'Prefered Sales Display Method';
            OptionCaption = ' ,Schedule,Calendar';
            OptionMembers = DEFAULT,SCHEDULE,CALENDAR;
        }
        field(45;"Duration Formula";DateFormula)
        {
            Caption = 'Duration Formula';
            Description = 'TM1.00';
        }
        field(46;"Max No. Of Entries";Integer)
        {
            BlankZero = true;
            Caption = 'Max No. Of Entries';
            Description = 'TM1.00';
        }
        field(50;"Admission Inclusion";Option)
        {
            Caption = 'Admission Inclusion';
            OptionCaption = 'Required,Optional and Selected,Optional and not Selected';
            OptionMembers = REQUIRED,SELECTED,NOT_SELECTED;
        }
        field(55;"Admission Unit Price";Decimal)
        {
            Caption = 'Admission Unit Price';
        }
        field(60;"Activation Method";Option)
        {
            Caption = 'Activation Method';
            OptionCaption = ' ,Scan,POS';
            OptionMembers = NA,SCAN,POS;
        }
        field(62;"Admission Entry Validation";Option)
        {
            Caption = 'Admission Entry Validation';
            OptionCaption = ' ,Single,Same Day,Multiple';
            OptionMembers = NA,SINGLE,SAME_DAY,MULTIPLE;
        }
        field(65;"Revisit Condition (Statistics)";Option)
        {
            Caption = 'Revisit Condition (Statistics)';
            InitValue = NONINITIAL;
            OptionCaption = ' ,Non-Initial,Daily Non-Initial,Never';
            OptionMembers = NA,NONINITIAL,DAILY_NONINITIAL,NEVER;
        }
        field(70;"Revoke Policy";Option)
        {
            Caption = 'Revoke Policy';
            OptionCaption = 'Unused Admission,Never Allow,Always Allow';
            OptionMembers = UNUSED,NEVER,ALWAYS;
        }
        field(75;"Refund Price %";Decimal)
        {
            Caption = 'Refund Price %';
            MaxValue = 100;
            MinValue = 0;
        }
        field(80;"Allow Rescan Within (Sec.)";Option)
        {
            Caption = 'Allow Rescan Within (Sec.)';
            OptionCaption = ' ,15 Seconds,30 Seconds,60 Seconds,120 Seconds';
            OptionMembers = SINGLE_ENTRY_ONLY,"15","30","60","120";
        }
        field(85;"Publish As eTicket";Boolean)
        {
            Caption = 'Publish As eTicket';

            trigger OnValidate()
            var
                TicketSetup: Record "TM Ticket Setup";
                Item: Record Item;
                TicketType: Record "TM Ticket Type";
                Admission: Record "TM Admission";
            begin
                if ("Publish As eTicket") then begin

                  Item.Get ("Item No.");
                  TicketType.Get (Item."Ticket Type");
                  TicketType.TestField ("eTicket Activated", true);

                  "eTicket Type Code" := TicketType."eTicket Type Code";

                  Admission.Get ("Admission Code");
                  if (Admission."eTicket Type Code" <> '') then
                    "eTicket Type Code" := Admission."eTicket Type Code";

                  TestField("eTicket Type Code");

                end;
            end;
        }
        field(90;"eTicket Type Code";Text[30])
        {
            Caption = 'eTicket Type Code';
            Description = '//-TM1.38 [332109]';
        }
        field(95;"Publish Ticket URL";Option)
        {
            Caption = 'Publish Ticket URL';
            OptionCaption = 'Disable,Publish,Publish & Send';
            OptionMembers = DISABLE,PUBLISH,SEND;

            trigger OnValidate()
            var
                Item: Record Item;
                TicketType: Record "TM Ticket Type";
            begin

                //-TM90.1.46 [387138]
                if ("Publish Ticket URL" >= "Publish Ticket URL"::PUBLISH) then begin
                  Item.Get ("Item No.");
                  TicketType.Get (Item."Ticket Type");
                  TicketType.TestField (TicketType."DIY Print Layout Code");
                end;
                //+TM90.1.46 [387138]
            end;
        }
        field(100;"Admission Description";Text[50])
        {
            Caption = 'Admission Description';
        }
        field(110;"Ticket Base Calendar Code";Code[10])
        {
            Caption = 'Ticket Base Calendar Code';
            TableRelation = "Base Calendar";
        }
        field(166;"Sales From Date";Date)
        {
            Caption = 'Sales From Date';
        }
        field(167;"Sales Until Date";Date)
        {
            Caption = 'Sales Until Date';
        }
        field(168;"Enforce Schedule Sales Limits";Boolean)
        {
            Caption = 'Enforce Schedule Sales Limits';
        }
    }

    keys
    {
        key(Key1;"Item No.","Variant Code","Admission Code")
        {
        }
    }

    fieldgroups
    {
    }

    local procedure UpdateItemDescription()
    var
        Item: Record Item;
    begin
        if (Item.Get ("Item No.")) then
          Description := Item.Description;
    end;

    local procedure UpdateAdmissionDescription()
    var
        Admission: Record "TM Admission";
    begin
        if (Admission.Get ("Admission Code")) then
          "Admission Description" := Admission.Description;
    end;
}

