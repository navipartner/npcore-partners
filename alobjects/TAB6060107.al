table 6060107 "Ean Box Setup Event"
{
    // NPR5.32/NPKNAV/20170526  CASE 272577 Transport NPR5.32 - 26 May 2017
    // NPR5.41/TSA /20180425 CASE 307454 OptionValueInteger set -1 to get the default value
    // NPR5.45/MHA /20180814  CASE 319706 Reworked Identifier Dissociation to Ean Box Event Handler
    // NPR5.47/MHA /20181024  CASE 333512 Added field 10 Priority

    Caption = 'Ean Box Setup Event';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Setup Code"; Code[20])
        {
            Caption = 'Setup Code';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = "Ean Box Setup";
        }
        field(2; "Event Code"; Code[20])
        {
            Caption = 'Event Code';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = "Ean Box Event" WHERE("POS View" = FIELD("POS View"));

            trigger OnValidate()
            var
                EanBoxEvent: Record "Ean Box Event";
            begin
                if "Event Code" = '' then begin
                    Validate("Action Code", '');
                    exit;
                end;

                EanBoxEvent.Get("Event Code");
                Validate("Action Code", EanBoxEvent."Action Code");
            end;
        }
        field(5; "POS View"; Option)
        {
            CalcFormula = Lookup ("Ean Box Setup"."POS View" WHERE(Code = FIELD("Setup Code")));
            Caption = 'POS View';
            Editable = false;
            FieldClass = FlowField;
            OptionCaption = 'Sale';
            OptionMembers = Sale;
        }
        field(6; Enabled; Boolean)
        {
            Caption = 'Enabled';
            DataClassification = CustomerContent;
        }
        field(10; Priority; Integer)
        {
            Caption = 'Priority';
            DataClassification = CustomerContent;
            Description = 'NPR5.47';
        }
        field(20; "Action Code"; Code[20])
        {
            Caption = 'Action Code';
            DataClassification = CustomerContent;
            TableRelation = "POS Action";

            trigger OnValidate()
            var
                AllObj: Record AllObj;
                POSAction: Record "POS Action";
            begin
            end;
        }
        field(21; "Action Description"; Text[250])
        {
            CalcFormula = Lookup ("POS Action".Description WHERE(Code = FIELD("Action Code")));
            Caption = 'Action Description';
            Editable = false;
            FieldClass = FlowField;
        }
        field(100; "Module Name"; Text[50])
        {
            CalcFormula = Lookup ("Ean Box Event"."Module Name" WHERE(Code = FIELD("Event Code")));
            Caption = 'Module Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(105; "Event Description"; Text[50])
        {
            CalcFormula = Lookup ("Ean Box Event".Description WHERE(Code = FIELD("Event Code")));
            Caption = 'Event Description';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "Setup Code", "Event Code")
        {
        }
        key(Key2; Priority)
        {
        }
    }

    fieldgroups
    {
    }
}

