table 6151556 "NpXml Template Trigger Link"
{
    // NC1.01/MH/20150201  CASE 199932 Object created - defines which table changes should trigger NpXml Templates (Transaction Task).
    // NC1.03/MH/20150205  CASE 199932 Added field 330 Previous Filter Value and Previous Options to field 300 Link Type.
    // NC1.06/MH/20150224  CASE 206395 Added Option, PreviousField, to field 300 Link Type.
    // NC1.07/MH/20150309  CASE 208131 Updated captions
    // NC1.08/MH/20150310  CASE 206395 Added Field Value Lookup
    // NC1.11/MH/20150330  CASE 210171 Added multi level triggers
    // NC1.13/MH/20150414  CASE 211360 Restructured NpXml Codeunits. Independent functions moved to new codeunits
    // NC1.21/TTH/20151020 CASE 224528 Adding versioning and possibility to lock the modified versions. Added field 20 Template Version number and 340 Last Modified. New function XmlTemplateChanged.
    // NC1.22/MHA/20151203 CASE 224528 Function XmlTemplateChanged() deleted and GetVersionNo() created
    // NC1.22/MHA/20151203 CASE 224528 Deleted function XmlTemplateChanged() and credted GetVersionNo()
    // NC2.00/MHA/20160525  CASE 240005 NaviConnect

    Caption = 'NpXml Template Trigger Link';

    fields
    {
        field(1;"Xml Template Code";Code[20])
        {
            Caption = 'Xml Template Code';
            TableRelation = "NpXml Template";
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
        }
        field(5;"Xml Template Trigger Line No.";Integer)
        {
            Caption = 'Xml Template Trigger Line No.';
            Description = 'NC1.07';
        }
        field(10;"Line No.";Integer)
        {
            Caption = 'Line No.';
        }
        field(20;"Template Version No.";Code[20])
        {
            Caption = 'Template Version No.';
            Description = 'NC1.21';
        }
        field(100;"Parent Table No.";Integer)
        {
            Caption = 'Parent Table No.';
            Description = 'NC1.11';
            Editable = false;
            TableRelation = AllObj."Object ID" WHERE ("Object Type"=CONST(Table));
        }
        field(110;"Parent Field No.";Integer)
        {
            Caption = 'Parent Field No.';
            Description = 'NC1.11';
            TableRelation = Field."No." WHERE (TableNo=FIELD("Parent Table No."));

            trigger OnLookup()
            var
                "Field": Record "Field";
            begin
                Field.SetRange(TableNo,"Parent Table No.");
                if PAGE.RunModal(PAGE::"Field List",Field) = ACTION::LookupOK then
                  "Parent Field No." := Field."No.";

                CalcFields("Parent Table Name");
            end;

            trigger OnValidate()
            begin
                CalcFields("Parent Table Name");
            end;
        }
        field(120;"Parent Table Name";Text[50])
        {
            CalcFormula = Lookup(AllObj."Object Name" WHERE ("Object Type"=CONST(Table),
                                                             "Object ID"=FIELD("Parent Table No.")));
            Caption = 'Parent Table Name';
            Description = 'NC1.11';
            Editable = false;
            FieldClass = FlowField;
        }
        field(130;"Parent Field Name";Text[50])
        {
            CalcFormula = Lookup(Field.FieldName WHERE (TableNo=FIELD("Parent Table No."),
                                                        "No."=FIELD("Parent Field No.")));
            Caption = 'Parent Field Name';
            Description = 'NC1.11';
            Editable = false;
            FieldClass = FlowField;

            trigger OnValidate()
            var
                "Field": Record "Field";
            begin
            end;
        }
        field(200;"Table No.";Integer)
        {
            Caption = 'Table No.';
            TableRelation = AllObj."Object ID" WHERE ("Object Type"=CONST(Table));
        }
        field(210;"Field No.";Integer)
        {
            Caption = 'Field No.';
            NotBlank = true;
            TableRelation = Field."No." WHERE (TableNo=FIELD("Table No."));

            trigger OnLookup()
            var
                "Field": Record "Field";
            begin
                Field.SetRange(TableNo,"Table No.");
                if PAGE.RunModal(PAGE::"Field List",Field) = ACTION::LookupOK then
                  "Field No." := Field."No.";

                CalcFields("Table Name");
            end;

            trigger OnValidate()
            begin
                CalcFields("Table Name");
            end;
        }
        field(220;"Table Name";Text[50])
        {
            CalcFormula = Lookup(AllObj."Object Name" WHERE ("Object Type"=CONST(Table),
                                                             "Object ID"=FIELD("Table No.")));
            Caption = 'Table Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(230;"Field Name";Text[50])
        {
            CalcFormula = Lookup(Field.FieldName WHERE (TableNo=FIELD("Table No."),
                                                        "No."=FIELD("Field No.")));
            Caption = 'Field Name';
            Editable = false;
            FieldClass = FlowField;

            trigger OnValidate()
            var
                "Field": Record "Field";
            begin
            end;
        }
        field(300;"Link Type";Option)
        {
            Caption = 'Link Type';
            Description = 'NC1.06,NC1.11';
            OptionCaption = 'Table Link,Constant (Parent),Filter (Parent),Constant,Filter,Table Link (Previous),Constant (Previous)';
            OptionMembers = TableLink,ParentConstant,ParentFilter,Constant,"Filter",PreviousTableLink,PreviousConstant;
        }
        field(310;"Parent Filter Value";Text[250])
        {
            Caption = 'Parent Filter Value';
            Description = 'NC1.08';

            trigger OnLookup()
            begin
                //-NC1.13
                ////-NC1.08
                //NpXmlMgt.LookupFieldValue("Parent Table No.","Parent Field No.","Parent Filter Value");
                ////+NC1.08
                NpXmlTemplateMgt.LookupFieldValue("Parent Table No.","Parent Field No.","Parent Filter Value");
                //+NC1.13
            end;
        }
        field(320;"Filter Value";Text[250])
        {
            Caption = 'Filter Value';
            Description = 'NC1.08';

            trigger OnLookup()
            begin
                //-NC1.13
                ////-NC1.08
                //NpXmlMgt.LookupFieldValue("Table No.","Field No.","Filter Value");
                ////+NC1.08
                NpXmlTemplateMgt.LookupFieldValue("Table No.","Field No.","Filter Value");
                //+NC1.13
            end;
        }
        field(330;"Previous Filter Value";Text[250])
        {
            Caption = 'Previous Filter Value';
            Description = 'NC1.03,NC1.11';

            trigger OnLookup()
            begin
                //-NC1.13
                ////-NC1.08
                //NpXmlMgt.LookupFieldValue("Table No.","Field No.","Previous Filter Value");
                ////+NC1.08
                NpXmlTemplateMgt.LookupFieldValue("Table No.","Field No.","Previous Filter Value");
                //+NC1.13
            end;
        }
        field(340;"Last Modified at";DateTime)
        {
            Caption = 'Last Modified at';
            Description = 'NC1.21';
        }
    }

    keys
    {
        key(Key1;"Xml Template Code","Xml Template Trigger Line No.","Line No.")
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
        XMLTemplate: Record "NpXml Template";
        NpXmlTemplateHistory: Record "NpXml Template History";
        RecRef: RecordRef;
        xRecRef: RecordRef;
    begin
        //-NC1.21
        //-NC1.22
        //XmlTemplateChanged;
        "Template Version No." := GetTemplateVersionNo();
        //+NC1.22
        "Last Modified at" := CreateDateTime(Today,Time);
        //+NC1.21
    end;

    var
        NpXmlTemplateMgt: Codeunit "NpXml Template Mgt.";

    local procedure GetTemplateVersionNo(): Code[20]
    var
        NpXmlTemplate: Record "NpXml Template";
    begin
        //-NC1.22
        NpXmlTemplate.Get("Xml Template Code");
        exit(NpXmlTemplate."Template Version");
        //+NC1.22
    end;
}

