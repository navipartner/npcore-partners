table 6060055 "Item Worksheet Field Mapping"
{
    // NPR5.25\BR  \20160729  CASE 246088 Object Created

    Caption = 'Item Worksheet Field Mapping';

    fields
    {
        field(1;"Worksheet Template Name";Code[10])
        {
            Caption = 'Journal Template Name';
            NotBlank = true;
            TableRelation = "Item Worksheet Template";
        }
        field(2;"Worksheet Name";Code[10])
        {
            Caption = 'Name';
        }
        field(10;"Table No.";Integer)
        {
            Caption = 'Table No.';
        }
        field(11;"Field Number";Integer)
        {
            Caption = 'Field Number';

            trigger OnValidate()
            var
                WarnDataTypeExample: Label 'Warning: the imported example fields could not be evaluated ro datatype %1.';
            begin

                if RecField.Get("Table No.","Field Number") then begin
                    "Field Name" := RecField.FieldName;
                    "Field Caption" := RecField."Field Caption";
                end else begin
                  "Field Number" := 0;
                  "Field Name" :=  '';
                  "Field Caption" := '';
                end;
            end;
        }
        field(20;"Source Value";Text[250])
        {
            Caption = 'Source Value';
        }
        field(25;"Target Value";Text[250])
        {
            Caption = 'Target Value';
        }
        field(30;"Field Name";Text[30])
        {
            Caption = 'Field Name';

            trigger OnValidate()
            begin

                RecField.Reset;
                RecField.SetRange(TableNo,"Table No.");
                RecField.SetRange(FieldName,"Field Name");
                if RecField.FindFirst then
                  Validate("Field Number",RecField."No.")
                else
                  Validate("Field Number",0);
            end;
        }
        field(31;"Field Caption";Text[80])
        {
            Caption = 'Field Caption';

            trigger OnValidate()
            begin

                RecField.Reset;
                RecField.SetRange(TableNo,"Table No.");
                RecField.SetRange("Field Caption","Field Caption");
                if RecField.FindFirst then
                  Validate("Field Number",RecField."No.")
                else
                  Validate("Field Number",0);
            end;
        }
        field(40;Matching;Option)
        {
            Caption = 'Matching';
            OptionCaption = 'Exact,Starts With,Ends With,Contains';
            OptionMembers = Exact,"Starts With","Ends With",Contains;
        }
        field(45;"Case Sensitive";Boolean)
        {
            Caption = 'Case Sensitive';
        }
    }

    keys
    {
        key(Key1;"Worksheet Template Name","Worksheet Name","Table No.","Field Number","Source Value")
        {
        }
    }

    fieldgroups
    {
    }

    var
        RecField: Record "Field";
}

