table 6060055 "Item Worksheet Field Mapping"
{
    // NPR5.25\BR  \20160729  CASE 246088 Object Created

    Caption = 'Item Worksheet Field Mapping';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Worksheet Template Name"; Code[10])
        {
            Caption = 'Journal Template Name';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = "Item Worksheet Template";
        }
        field(2; "Worksheet Name"; Code[10])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
        }
        field(10; "Table No."; Integer)
        {
            Caption = 'Table No.';
            DataClassification = CustomerContent;
        }
        field(11; "Field Number"; Integer)
        {
            Caption = 'Field Number';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                WarnDataTypeExample: Label 'Warning: the imported example fields could not be evaluated ro datatype %1.';
            begin

                if RecField.Get("Table No.", "Field Number") then begin
                    "Field Name" := RecField.FieldName;
                    "Field Caption" := RecField."Field Caption";
                end else begin
                    "Field Number" := 0;
                    "Field Name" := '';
                    "Field Caption" := '';
                end;
            end;
        }
        field(20; "Source Value"; Text[250])
        {
            Caption = 'Source Value';
            DataClassification = CustomerContent;
        }
        field(25; "Target Value"; Text[250])
        {
            Caption = 'Target Value';
            DataClassification = CustomerContent;
        }
        field(30; "Field Name"; Text[30])
        {
            Caption = 'Field Name';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin

                RecField.Reset;
                RecField.SetRange(TableNo, "Table No.");
                RecField.SetRange(FieldName, "Field Name");
                if RecField.FindFirst then
                    Validate("Field Number", RecField."No.")
                else
                    Validate("Field Number", 0);
            end;
        }
        field(31; "Field Caption"; Text[80])
        {
            Caption = 'Field Caption';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin

                RecField.Reset;
                RecField.SetRange(TableNo, "Table No.");
                RecField.SetRange("Field Caption", "Field Caption");
                if RecField.FindFirst then
                    Validate("Field Number", RecField."No.")
                else
                    Validate("Field Number", 0);
            end;
        }
        field(40; Matching; Option)
        {
            Caption = 'Matching';
            DataClassification = CustomerContent;
            OptionCaption = 'Exact,Starts With,Ends With,Contains';
            OptionMembers = Exact,"Starts With","Ends With",Contains;
        }
        field(45; "Case Sensitive"; Boolean)
        {
            Caption = 'Case Sensitive';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Worksheet Template Name", "Worksheet Name", "Table No.", "Field Number", "Source Value")
        {
        }
    }

    fieldgroups
    {
    }

    var
        RecField: Record "Field";
}

