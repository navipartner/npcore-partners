table 6059784 "NPR TM Ticket Type"
{
    Caption = 'Ticket Type';
    LookupPageID = "NPR TM Ticket Type";
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
            NotBlank = true;
            DataClassification = CustomerContent;
        }
        field(2; Description; Text[30])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(15; "Related Ticket Type"; Code[20])
        {
            Caption = 'Related Ticket Type';
            TableRelation = "NPR TM Ticket Type";
            DataClassification = CustomerContent;
        }
        field(20; "Print Ticket"; Boolean)
        {
            Caption = 'Print Ticket';
            DataClassification = CustomerContent;
        }
        field(21; "Print Object ID"; Integer)
        {
            Caption = 'Print Object ID';
            TableRelation = IF ("Print Object Type" = CONST(CODEUNIT)) AllObj."Object ID" WHERE("Object Type" = CONST(Codeunit))
            ELSE
            IF ("Print Object Type" = CONST(REPORT)) AllObj."Object ID" WHERE("Object Type" = CONST(Report));
            DataClassification = CustomerContent;
        }
        field(22; "Print Object Type"; Option)
        {
            Caption = 'Print Object Type';
            InitValue = TEMPLATE;
            OptionCaption = 'Codeunit,Report,Template';
            OptionMembers = "CODEUNIT","REPORT",TEMPLATE;
            DataClassification = CustomerContent;
        }
        field(23; "Admission Registration"; Option)
        {
            Caption = 'Admission Registration';
            Description = 'TM1.03';
            OptionCaption = 'Individual,Group';
            OptionMembers = INDIVIDUAL,GROUP;
            DataClassification = CustomerContent;
        }
        field(30; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            TableRelation = "No. Series";
            DataClassification = CustomerContent;
        }
        field(31; "External Ticket Pattern"; Code[30])
        {
            Caption = 'External Ticket Pattern';
            DataClassification = CustomerContent;
        }
        field(35; "Ticket Configuration Source"; Option)
        {
            Caption = 'Ticket Configuration Source';
            OptionCaption = 'Ticket Type,Ticket BOM';
            OptionMembers = TICKET_TYPE,TICKET_BOM;
            DataClassification = CustomerContent;
        }
        field(40; "Is Ticket"; Boolean)
        {
            Caption = 'Ticket';
            Description = 'DEPRECIATE';
            InitValue = true;
            DataClassification = CustomerContent;
        }
        field(41; "Is Reservation"; Boolean)
        {
            Caption = 'Reservation';
            Description = 'DEPRECIATE';
            DataClassification = CustomerContent;
        }
        field(45; "Duration Formula"; DateFormula)
        {
            Caption = 'Duration Formula';
            Description = 'TM1.00';
            DataClassification = CustomerContent;
        }
        field(46; "Max No. Of Entries"; Integer)
        {
            Caption = 'Max No. Of Entries';
            Description = 'TM1.00';
            DataClassification = CustomerContent;
        }
        field(60; "Activation Method"; Option)
        {
            Caption = 'Activation Method';
            Description = 'TM1.00';
            OptionCaption = 'Scan,(POS) Default Admission,Invoice,(POS) All Admissions,Not Applicable';
            OptionMembers = SCAN,POS_DEFAULT,INVOICE,POS_ALL,NA;
            DataClassification = CustomerContent;
        }
        field(61; "Defer Revenue"; Boolean)
        {
            Caption = 'Defer Revenue';
            Description = 'TM1.00';
            DataClassification = CustomerContent;
        }
        field(62; "Ticket Entry Validation"; Option)
        {
            Caption = 'Ticket Entry Validation';
            Description = 'TM1.00';
            OptionCaption = 'Single,Same Day,Multiple,Not Applicable';
            OptionMembers = SINGLE,SAME_DAY,MULTIPLE,NA;
            DataClassification = CustomerContent;
        }
        field(70; "Membership Sales Item No."; Code[20])
        {
            Caption = 'Membership Sales Item No.';
            TableRelation = Item;
            DataClassification = CustomerContent;
        }
        field(80; "RP Template Code"; Code[20])
        {
            Caption = 'RP Template Code';
            TableRelation = "NPR RP Template Header";
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                TestField("Print Object Type", "Print Object Type"::TEMPLATE);
            end;
        }
        field(100; "DIY Print Layout Code"; Text[30])
        {
            Caption = 'Ticket Layout Code';
            DataClassification = CustomerContent;
        }
        field(200; "eTicket Template"; BLOB)
        {
            Caption = 'eTicket Template';
            Description = '';
            DataClassification = CustomerContent;
        }
        field(210; "eTicket Type Code"; Text[30])
        {
            Caption = 'eTicket Type Code';
            Description = '';
            DataClassification = CustomerContent;
        }
        field(220; "eTicket Activated"; Boolean)
        {
            Caption = 'eTicket Activated';
            Description = '';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                TicketSetup: Record "NPR TM Ticket Setup";
            begin

                if ("eTicket Activated") then begin
                    TicketSetup.Get();
                    TicketSetup.TestField("NP-Pass Token");

                    TestField("eTicket Type Code");
                    CalcFields("eTicket Template");
                    if (not Rec."eTicket Template".HasValue()) then
                        Error('%1 is not initialized.', Rec.FieldCaption("eTicket Template"));

                end;
            end;
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

    var
}

