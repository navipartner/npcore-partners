table 6014555 "NPR Attribute Value Set"
{
    // NPR5.00/TSA /20150422  CASE 209946 - Entity and Shortcut Attributes
    // NPR5.26/LS  /20160823  CASE 249858 Increase Length of field "Text Value" from 100 to 250
    // NPR5.37/MHA /20171026  CASE 293180 Added flowfields for filtering

    Caption = 'Attribute Value Set';
    LookupPageID = "NPR Attribute Values";
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Attribute Set ID"; Integer)
        {
            Caption = 'Attribute Set ID';
            TableRelation = "NPR Attribute Key"."Attribute Set ID";
            DataClassification = CustomerContent;
        }
        field(2; "Attribute Code"; Code[20])
        {
            Caption = 'Attribute Code';
            TableRelation = "NPR Attribute".Code;
            DataClassification = CustomerContent;
        }
        field(10; "Text Value"; Text[250])
        {
            Caption = 'Text Value';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                tmpTextValue := Format("Text Value");
                AttributeManager.SetAttributeValue("Attribute Set ID", "Attribute Code", tmpTextValue, Rec);
                // Rec.Get() ("Attribute Set ID", "Attribute Code");
            end;
        }
        field(11; "Datetime Value"; DateTime)
        {
            Caption = 'Datetime Value';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                tmpTextValue := Format("Datetime Value");
                AttributeManager.SetAttributeValue("Attribute Set ID", "Attribute Code", tmpTextValue, Rec);
                // Rec.Get() ("Attribute Set ID", "Attribute Code");
            end;
        }
        field(12; "Numeric Value"; Decimal)
        {
            Caption = 'Numeric Value';
            DecimalPlaces = 0 : 5;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                tmpTextValue := Format("Numeric Value");
                AttributeManager.SetAttributeValue("Attribute Set ID", "Attribute Code", tmpTextValue, Rec);
                // Rec.Get() ("Attribute Set ID", "Attribute Code");
            end;
        }
        field(13; "Boolean Value"; Boolean)
        {
            Caption = 'Boolean Value';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                tmpTextValue := Format("Boolean Value");
                AttributeManager.SetAttributeValue("Attribute Set ID", "Attribute Code", tmpTextValue, Rec);
                // Rec.Get() ("Attribute Set ID", "Attribute Code");
            end;
        }
        field(1000; "Table ID"; Integer)
        {
            CalcFormula = Lookup("NPR Attribute Key"."Table ID" WHERE("Attribute Set ID" = FIELD("Attribute Set ID")));
            Caption = 'Table ID';
            Description = 'NPR5.37';
            Editable = false;
            FieldClass = FlowField;
        }
        field(1005; "MDR Code PK"; Code[20])
        {
            CalcFormula = Lookup("NPR Attribute Key"."MDR Code PK" WHERE("Attribute Set ID" = FIELD("Attribute Set ID")));
            Caption = 'MDR Code PK';
            Description = 'NPR5.37';
            Editable = false;
            FieldClass = FlowField;
        }
        field(1010; "MDR Line PK"; Integer)
        {
            CalcFormula = Lookup("NPR Attribute Key"."MDR Line PK" WHERE("Attribute Set ID" = FIELD("Attribute Set ID")));
            Caption = 'MDR Line PK';
            Description = 'NPR5.37';
            Editable = false;
            FieldClass = FlowField;
        }
        field(1015; "MDR Option PK"; Integer)
        {
            CalcFormula = Lookup("NPR Attribute Key"."MDR Option PK" WHERE("Attribute Set ID" = FIELD("Attribute Set ID")));
            Caption = 'MDR Option PK';
            Description = 'NPR5.37';
            Editable = false;
            FieldClass = FlowField;
        }
        field(1020; "MDR Code 2 PK"; Code[20])
        {
            CalcFormula = Lookup("NPR Attribute Key"."MDR Code 2 PK" WHERE("Attribute Set ID" = FIELD("Attribute Set ID")));
            Caption = 'MDR Code 2 PK';
            Description = 'NPR5.37';
            Editable = false;
            FieldClass = FlowField;
        }
        field(1025; "MDR Line 2 PK"; Integer)
        {
            CalcFormula = Lookup("NPR Attribute Key"."MDR Line 2 PK" WHERE("Attribute Set ID" = FIELD("Attribute Set ID")));
            Caption = 'MDR Line 2 PK';
            Description = 'NPR5.37';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "Attribute Set ID", "Attribute Code")
        {
        }
    }

    fieldgroups
    {
    }

    var
        AttributeManager: Codeunit "NPR Attribute Management";
        tmpTextValue: Text[100];
}

