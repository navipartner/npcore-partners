table 6060107 "NPR Ean Box Setup Event"
{
    Caption = 'Ean Box Setup Event';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Setup Code"; Code[20])
        {
            Caption = 'Setup Code';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = "NPR Ean Box Setup";
        }
        field(2; "Event Code"; Code[20])
        {
            Caption = 'Event Code';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = "NPR Ean Box Event";

            trigger OnLookup()
            var
                EanBoxSetup: Record "NPR Ean Box Setup";
                EanBoxEvent: Record "NPR Ean Box Event";
            begin
                EanBoxSetup.Get(Rec."Setup Code");
                EanBoxEvent.SetRange("POS View", EanBoxSetup."POS View");
                if Page.RunModal(0, EanBoxEvent) = Action::LookupOK then begin
                    Rec.Validate("Event Code", EanBoxEvent.Code);
                end;
            end;

            trigger OnValidate()
            var
                EanBoxEvent: Record "NPR Ean Box Event";
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
            CalcFormula = Lookup("NPR Ean Box Setup"."POS View" WHERE(Code = FIELD("Setup Code")));
            Caption = 'POS View';
            Editable = false;
            FieldClass = FlowField;
            OptionCaption = 'Sale,Payment';
            OptionMembers = Sale,Payment;
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
            TableRelation = "NPR POS Action";

            trigger OnValidate()
            begin
            end;
        }
        field(21; "Action Description"; Text[250])
        {
            CalcFormula = Lookup("NPR POS Action".Description WHERE(Code = FIELD("Action Code")));
            Caption = 'Action Description';
            Editable = false;
            FieldClass = FlowField;
        }
        field(100; "Module Name"; Text[50])
        {
            CalcFormula = Lookup("NPR Ean Box Event"."Module Name" WHERE(Code = FIELD("Event Code")));
            Caption = 'Module Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(105; "Event Description"; Text[50])
        {
            CalcFormula = Lookup("NPR Ean Box Event".Description WHERE(Code = FIELD("Event Code")));
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

