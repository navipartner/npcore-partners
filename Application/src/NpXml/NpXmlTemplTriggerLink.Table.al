table 6151556 "NPR NpXml Templ.Trigger Link"
{
    Access = Internal;
    Caption = 'NpXml Template Trigger Link';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Xml Template Code"; Code[20])
        {
            Caption = 'Xml Template Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR NpXml Template";
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
        }
        field(5; "Xml Template Trigger Line No."; Integer)
        {
            Caption = 'Xml Template Trigger Line No.';
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
            Description = 'NC1.11';
            Editable = false;
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Table));
        }
        field(110; "Parent Field No."; Integer)
        {
            Caption = 'Parent Field No.';
            DataClassification = CustomerContent;
            Description = 'NC1.11';
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
            Description = 'NC1.11';
            Editable = false;
            FieldClass = FlowField;
        }
        field(130; "Parent Field Name"; Text[50])
        {
            CalcFormula = Lookup(Field.FieldName WHERE(TableNo = FIELD("Parent Table No."),
                                                        "No." = FIELD("Parent Field No.")));
            Caption = 'Parent Field Name';
            Description = 'NC1.11';
            Editable = false;
            FieldClass = FlowField;

            trigger OnValidate()
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
            begin
            end;
        }
        field(300; "Link Type"; Option)
        {
            Caption = 'Link Type';
            DataClassification = CustomerContent;
            Description = 'NC1.06,NC1.11';
            OptionCaption = 'Table Link,Constant (Parent),Filter (Parent),Constant,Filter,Table Link (Previous),Constant (Previous)';
            OptionMembers = TableLink,ParentConstant,ParentFilter,Constant,"Filter",PreviousTableLink,PreviousConstant;
        }
        field(310; "Parent Filter Value"; Text[250])
        {
            Caption = 'Parent Filter Value';
            DataClassification = CustomerContent;
            Description = 'NC1.08';

            trigger OnLookup()
            begin
                NpXmlTemplateMgt.LookupFieldValue("Parent Table No.", "Parent Field No.", "Parent Filter Value");
            end;
        }
        field(320; "Filter Value"; Text[250])
        {
            Caption = 'Filter Value';
            DataClassification = CustomerContent;
            Description = 'NC1.08';

            trigger OnLookup()
            begin
                NpXmlTemplateMgt.LookupFieldValue("Table No.", "Field No.", "Filter Value");
            end;
        }
        field(330; "Previous Filter Value"; Text[250])
        {
            Caption = 'Previous Filter Value';
            DataClassification = CustomerContent;
            Description = 'NC1.03,NC1.11';

            trigger OnLookup()
            begin
                NpXmlTemplateMgt.LookupFieldValue("Table No.", "Field No.", "Previous Filter Value");
            end;
        }
        field(340; "Last Modified at"; DateTime)
        {
            Caption = 'Last Modified at';
            DataClassification = CustomerContent;
            Description = 'NC1.21';
        }
    }

    keys
    {
        key(Key1; "Xml Template Code", "Xml Template Trigger Line No.", "Line No.")
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

