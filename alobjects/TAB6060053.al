table 6060053 "Item Worksheet Field Change"
{
    // NPR5.25\BR  \20160720  CASE 246088 Object Created

    Caption = 'Item Worksheet Field Change';
    DataClassification = CustomerContent;
    DrillDownPageID = "Item Worksheet Field Changes";
    LookupPageID = "Item Worksheet Field Changes";

    fields
    {
        field(1;"Worksheet Template Name";Code[10])
        {
            Caption = 'Journal Template Name';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = "Item Worksheet Template";
        }
        field(2;"Worksheet Name";Code[10])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(3;"Worksheet Line No.";Integer)
        {
            Caption = 'Worksheet Line No.';
            DataClassification = CustomerContent;
        }
        field(6;"Worksheet Variant Line No.";Integer)
        {
            Caption = 'Worksheet Variant Line No.';
            DataClassification = CustomerContent;
        }
        field(10;"Table No.";Integer)
        {
            Caption = 'Table No.';
            DataClassification = CustomerContent;
        }
        field(11;"Field Number";Integer)
        {
            Caption = 'Field Number';
            DataClassification = CustomerContent;

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
        field(20;"Table Name";Text[30])
        {
            Caption = 'Table Name';
            DataClassification = CustomerContent;
        }
        field(21;"Table Caption";Text[80])
        {
            Caption = 'Table Caption';
            DataClassification = CustomerContent;
        }
        field(30;"Field Name";Text[30])
        {
            Caption = 'Field Name';
            DataClassification = CustomerContent;
        }
        field(31;"Field Caption";Text[80])
        {
            Caption = 'Field Caption';
            DataClassification = CustomerContent;
        }
        field(50;"Target Table No. Update";Integer)
        {
            Caption = 'Target Table No. Update';
            DataClassification = CustomerContent;
        }
        field(51;"Target Field Number Update";Integer)
        {
            Caption = 'Target Field Number Update';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if RecField.Get("Target Table No. Update","Target Field Number Update") then begin
                   "Target Field Name Update" := RecField.FieldName;
                   "Target Field Caption Update" := RecField."Field Caption";
                end else begin
                  "Target Field Number Update" := 0;
                  "Target Field Name Update" :=  '';
                  "Target Field Caption Update" := '';
                end;
            end;
        }
        field(55;"Target Field Name Update";Text[30])
        {
            Caption = 'Target Field Name Update';
            DataClassification = CustomerContent;
        }
        field(56;"Target Field Caption Update";Text[80])
        {
            Caption = 'Target Field Caption Update';
            DataClassification = CustomerContent;
        }
        field(200;Process;Boolean)
        {
            Caption = 'Process';
            DataClassification = CustomerContent;
        }
        field(201;Warning;Boolean)
        {
            Caption = 'Warning';
            DataClassification = CustomerContent;
        }
        field(210;"Current Value";Text[250])
        {
            Caption = 'Current Value';
            DataClassification = CustomerContent;
        }
        field(220;"New Value";Text[250])
        {
            Caption = 'New Value';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1;"Worksheet Template Name","Worksheet Name","Worksheet Line No.","Worksheet Variant Line No.","Table No.","Field Number")
        {
        }
    }

    fieldgroups
    {
    }

    var
        RecField: Record "Field";
}

