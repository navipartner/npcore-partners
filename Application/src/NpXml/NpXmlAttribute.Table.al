table 6151554 "NPR NpXml Attribute"
{
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
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Table));
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
            CalcFormula = Lookup(Field.FieldName WHERE(TableNo = FIELD("Table No."),
                                                        "No." = FIELD("Attribute Field No.")));
            Caption = 'Attribute Field Name';
            Editable = false;
            FieldClass = FlowField;

            trigger OnValidate()
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

    trigger OnInsert()
    begin
        "Template Version No." := GetTemplateVersionNo();
    end;

    trigger OnModify()
    begin
        "Template Version No." := GetTemplateVersionNo();
        "Last Modified at" := CreateDateTime(Today, Time);
    end;

    local procedure GetTemplateVersionNo(): Code[20]
    var
        NpXmlTemplate: Record "NPR NpXml Template";
    begin
        NpXmlTemplate.Get("Xml Template Code");
        exit(NpXmlTemplate."Template Version");
    end;
}

