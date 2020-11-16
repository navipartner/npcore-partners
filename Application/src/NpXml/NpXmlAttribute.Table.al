table 6151554 "NPR NpXml Attribute"
{
    // NC1.00 /MHA /20150113  CASE 199932 Refactored object from Web - XML
    // NC1.07 /MHA /20150309  CASE 206395 Added Field 140 Default Field Type
    // NC1.21 /TTH /20151020  CASE 224528 Adding versioning and possibility to lock the modified versions. Added field 20 Template Version number and 5210 Last Modified. New function XmlTemplateChanged.
    // NC1.22 /MHA /20151203  CASE 224528 Function XmlTemplateChanged() deleted and GetVersionNo() created
    // NC1.22 /MHA /20151203  CASE 224528 Deleted function XmlTemplateChanged() and credted GetVersionNo()
    // NC2.00 /MHA /20160525  CASE 240005 NaviConnect
    // NC2.03 /MHA /20170404  CASE 267094 Added field 5105 Namespace
    // NC2.17/JDH /20181112 CASE 334163 Added Caption to Object
    // NC2.18/JDH /20181210 CASE 334163 Added Caption to Object (again)

    Caption = 'NpXml Attribute';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Xml Template Code"; Code[20])
        {
            Caption = 'Xml Template Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR NpXml Template";
        }
        field(5; "Xml Element Line No."; Integer)
        {
            Caption = 'Xml Element Line No.';
            DataClassification = CustomerContent;
        }
        field(10; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(20; "Template Version No."; Code[20])
        {
            Caption = 'Template Version No.';
            DataClassification = CustomerContent;
            Description = 'NC1.21';
        }
        field(100; "Table No."; Integer)
        {
            Caption = 'Table No.';
            DataClassification = CustomerContent;
            TableRelation = AllObj."Object ID" WHERE("Object Type" = CONST(Table));
        }
        field(110; "Attribute Name"; Text[50])
        {
            Caption = 'Attribute Name';
            DataClassification = CustomerContent;
        }
        field(120; "Attribute Field No."; Integer)
        {
            Caption = 'Attribute Field No.';
            DataClassification = CustomerContent;
            TableRelation = Field."No." WHERE(TableNo = FIELD("Table No."));

            trigger OnLookup()
            var
                "Field": Record "Field";
            begin
                Field.SetRange(TableNo, "Table No.");
                if PAGE.RunModal(Page::"NPR Field Lookup", Field) = ACTION::LookupOK then
                    "Attribute Field No." := Field."No.";

                CalcFields("Attribute Field Name");
            end;

            trigger OnValidate()
            begin
                CalcFields("Attribute Field Name");
            end;
        }
        field(130; "Attribute Field Name"; Text[50])
        {
            CalcFormula = Lookup (Field.FieldName WHERE(TableNo = FIELD("Table No."),
                                                        "No." = FIELD("Attribute Field No.")));
            Caption = 'Attribute Field Name';
            Editable = false;
            FieldClass = FlowField;

            trigger OnValidate()
            var
                "Field": Record "Field";
            begin
            end;
        }
        field(140; "Default Field Type"; Boolean)
        {
            Caption = 'Default Field Type';
            DataClassification = CustomerContent;
            Description = 'NC1.07';
        }
        field(150; "Default Value"; Text[250])
        {
            Caption = 'Default Value';
            DataClassification = CustomerContent;
        }
        field(5105; Namespace; Text[50])
        {
            Caption = 'Namespace';
            DataClassification = CustomerContent;
            Description = 'NC2.03';
            TableRelation = "NPR NpXml Namespace".Alias WHERE("Xml Template Code" = FIELD("Xml Template Code"));
        }
        field(5210; "Only with Value"; Boolean)
        {
            Caption = 'Only with Value';
            DataClassification = CustomerContent;
            Description = 'XML Tag is excluded if set and no Value';
        }
        field(5215; "Last Modified at"; DateTime)
        {
            Caption = 'Last Modified at';
            DataClassification = CustomerContent;
            Description = 'NC1.21';
        }
    }

    keys
    {
        key(Key1; "Xml Template Code", "Xml Element Line No.", "Line No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        //-NC1.22
        ////-NC1.21
        //XmlTemplateChanged;
        ////+NC1.21
        //+NC1.22
    end;

    trigger OnInsert()
    begin
        //-NC1.22
        ////-NC1.21
        //XmlTemplateChanged;
        ////+NC1.21
        "Template Version No." := GetTemplateVersionNo();
        //+NC1.22
    end;

    trigger OnModify()
    var
        XMLTemplate: Record "NPR NpXml Template";
        NpXmlTemplateHistory: Record "NPR NpXml Template History";
        RecRef: RecordRef;
        xRecRef: RecordRef;
    begin
        //-NC1.21
        ////-NC1.22
        //XmlTemplateChanged;
        "Template Version No." := GetTemplateVersionNo();
        //+NC1.22
        "Last Modified at" := CreateDateTime(Today, Time);
        //+NC1.21
    end;

    local procedure GetTemplateVersionNo(): Code[20]
    var
        NpXmlTemplate: Record "NPR NpXml Template";
    begin
        //-NC1.22
        NpXmlTemplate.Get("Xml Template Code");
        exit(NpXmlTemplate."Template Version");
        //+NC1.22
    end;
}

