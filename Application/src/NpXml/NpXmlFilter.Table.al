table 6151553 "NPR NpXml Filter"
{
    Caption = 'NpXml Filter';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Xml Template Code"; Code[20])
        {
            Caption = 'Xml Template Code';
            DataClassification = CustomerContent;
            Description = 'NC1.05';
            TableRelation = "NPR NpXml Template";
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
        }
        field(5; "Xml Element Line No."; Integer)
        {
            Caption = 'Xml Element Line No.';
            DataClassification = CustomerContent;
            Description = 'NC1.07';
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
        field(100; "Parent Table No."; Integer)
        {
            Caption = 'Parent Table No.';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Table));
        }
        field(110; "Parent Field No."; Integer)
        {
            Caption = 'Parent Field No.';
            DataClassification = CustomerContent;
            TableRelation = Field."No." WHERE(TableNo = FIELD("Parent Table No."));

            trigger OnLookup()
            var
                "Field": Record "Field";
            begin
                Field.SetRange(TableNo, "Parent Table No.");
                if PAGE.RunModal(Page::"NPR Field Lookup", Field) = ACTION::LookupOK then
                    "Parent Field No." := Field."No.";

                CalcFields("Parent Table Name");
            end;

            trigger OnValidate()
            begin
                CalcFields("Parent Table Name");
            end;
        }
        field(120; "Parent Table Name"; Text[50])
        {
            CalcFormula = Lookup(AllObj."Object Name" WHERE("Object Type" = CONST(Table),
                                                             "Object ID" = FIELD("Parent Table No.")));
            Caption = 'Parent Table Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(130; "Parent Field Name"; Text[50])
        {
            CalcFormula = Lookup(Field.FieldName WHERE(TableNo = FIELD("Parent Table No."),
                                                        "No." = FIELD("Parent Field No.")));
            Caption = 'Parent Field Name';
            Editable = false;
            FieldClass = FlowField;

            trigger OnValidate()
            var
                "Field": Record "Field";
            begin
            end;
        }
        field(200; "Table No."; Integer)
        {
            Caption = 'Table No.';
            DataClassification = CustomerContent;
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Table));
        }
        field(210; "Field No."; Integer)
        {
            Caption = 'Field No.';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = Field."No." WHERE(TableNo = FIELD("Table No."));

            trigger OnLookup()
            var
                "Field": Record "Field";
            begin
                Field.SetRange(TableNo, "Table No.");
                if PAGE.RunModal(Page::"NPR Field Lookup", Field) = ACTION::LookupOK then
                    "Field No." := Field."No.";

                CalcFields("Table Name");
            end;

            trigger OnValidate()
            begin
                CalcFields("Table Name");
            end;
        }
        field(220; "Table Name"; Text[50])
        {
            CalcFormula = Lookup(AllObj."Object Name" WHERE("Object Type" = CONST(Table),
                                                             "Object ID" = FIELD("Table No.")));
            Caption = 'Table Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(230; "Field Name"; Text[50])
        {
            CalcFormula = Lookup(Field.FieldName WHERE(TableNo = FIELD("Table No."),
                                                        "No." = FIELD("Field No.")));
            Caption = 'Field Name';
            Editable = false;
            FieldClass = FlowField;

            trigger OnValidate()
            var
                "Field": Record "Field";
            begin
            end;
        }
        field(300; "Filter Type"; Option)
        {
            Caption = 'Filter Type';
            DataClassification = CustomerContent;
            Description = 'NC1.11';
            OptionCaption = 'Table Link,Constant,Filter';
            OptionMembers = TableLink,Constant,"Filter";
        }
        field(310; "Filter Value"; Text[250])
        {
            Caption = 'Filter Value';
            DataClassification = CustomerContent;
            Description = 'NC1.08';

            trigger OnLookup()
            var
                NewFilterValue: Text;
            begin
                NpXmlTemplateMgt.LookupFieldValue("Table No.", "Field No.", "Filter Value");
            end;
        }
        field(320; "Last Modified at"; DateTime)
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

    var
        NpXmlTemplateMgt: Codeunit "NPR NpXml Template Mgt.";

    local procedure GetTemplateVersionNo(): Code[20]
    var
        NpXmlTemplate: Record "NPR NpXml Template";
    begin
        NpXmlTemplate.Get("Xml Template Code");
        exit(NpXmlTemplate."Template Version");
    end;
}

