table 6151552 "NPR NpXml Element"
{
    Caption = 'NpXml Element';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Xml Template Code"; Code[20])
        {
            Caption = 'Xml Template Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR NpXml Template";
        }
        field(5; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(10; "Table No."; Integer)
        {
            Caption = 'Table No.';
            DataClassification = CustomerContent;
            TableRelation = AllObj."Object ID" WHERE("Object Type" = CONST(Table));
        }
        field(20; "Template Version No."; Code[20])
        {
            Caption = 'Template Version No.';
            DataClassification = CustomerContent;
            Description = 'NC1.21';
        }
        field(100; "Field No."; Integer)
        {
            Caption = 'Field No.';
            DataClassification = CustomerContent;
            TableRelation = Field."No." WHERE(TableNo = FIELD("Table No."));

            trigger OnLookup()
            var
                "Field": Record "Field";
            begin
                Field.SetRange(TableNo, "Table No.");
                if PAGE.RunModal(Page::"NPR Field Lookup", Field) = ACTION::LookupOK then
                    "Field No." := Field."No.";

                CalcFields("Field Name");
            end;

            trigger OnValidate()
            begin
                CalcFields("Field Name");
            end;
        }
        field(110; "Field Name"; Text[50])
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
        field(200; "Parent Line No."; Integer)
        {
            Caption = 'Parent Line No.';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                NpXmlElement: Record "NPR NpXml Element";
                XMLTemplate: Record "NPR NpXml Template";
            begin
                if NpXmlElement.Get("Xml Template Code", "Parent Line No.") then
                    "Parent Table No." := NpXmlElement."Table No."
                else
                    if XMLTemplate.Get("Xml Template Code") then
                        "Parent Table No." := XMLTemplate."Table No.";
            end;
        }
        field(201; "Parent Table No."; Integer)
        {
            Caption = 'Parent Table No.';
            DataClassification = CustomerContent;
            TableRelation = AllObj."Object ID" WHERE("Object Type" = CONST(Table));
        }
        field(300; Comment; Text[250])
        {
            Caption = 'Comment';
            DataClassification = CustomerContent;
            Description = 'NC1.04';
        }
        field(500; Level; Integer)
        {
            Caption = 'Level';
            DataClassification = CustomerContent;
        }
        field(600; "Generic Child Codeunit ID"; Integer)
        {
            BlankZero = true;
            Caption = 'Generic Child Codeunit ID';
            DataClassification = CustomerContent;
            Description = 'NC2.01';

            trigger OnLookup()
            var
                EventSubscription: Record "Event Subscription";
            begin
                EventSubscription.SetRange("Publisher Object Type", EventSubscription."Publisher Object Type"::Codeunit);
                EventSubscription.SetRange("Publisher Object ID", CODEUNIT::"NPR NpXml Mgt.");
                EventSubscription.SetRange("Published Function", 'OnSetupGenericChildTable');
                if PAGE.RunModal(PAGE::"Event Subscriptions", EventSubscription) <> ACTION::LookupOK then
                    exit;

                "Generic Child Codeunit ID" := EventSubscription."Subscriber Codeunit ID";
                "Generic Child Function" := EventSubscription."Subscriber Function";
            end;

            trigger OnValidate()
            var
                EventSubscription: Record "Event Subscription";
            begin
                if "Generic Child Codeunit ID" = 0 then begin
                    "Generic Child Function" := '';
                    exit;
                end;

                EventSubscription.SetRange("Publisher Object Type", EventSubscription."Publisher Object Type"::Codeunit);
                EventSubscription.SetRange("Publisher Object ID", CODEUNIT::"NPR NpXml Mgt.");
                EventSubscription.SetRange("Published Function", 'OnSetupGenericChildTable');
                EventSubscription.SetRange("Subscriber Codeunit ID", "Generic Child Codeunit ID");
                if "Generic Child Function" <> '' then
                    EventSubscription.SetRange("Subscriber Function", "Generic Child Function");
                EventSubscription.FindFirst;
            end;
        }
        field(605; "Generic Child Codeunit Name"; Text[50])
        {
            CalcFormula = Lookup(AllObj."Object Name" WHERE("Object Type" = CONST(Codeunit),
                                                             "Object ID" = FIELD("Generic Child Codeunit ID")));
            Caption = 'Generic Child Codeunit Name';
            Description = 'NC2.01';
            Editable = false;
            FieldClass = FlowField;
        }
        field(610; "Generic Child Function"; Text[250])
        {
            Caption = 'Generic Child Function';
            DataClassification = CustomerContent;
            Description = 'NC2.01';

            trigger OnLookup()
            var
                EventSubscription: Record "Event Subscription";
            begin
                EventSubscription.SetRange("Publisher Object Type", EventSubscription."Publisher Object Type"::Codeunit);
                EventSubscription.SetRange("Publisher Object ID", CODEUNIT::"NPR NpXml Mgt.");
                EventSubscription.SetRange("Published Function", 'OnSetupGenericChildTable');
                if PAGE.RunModal(PAGE::"Event Subscriptions", EventSubscription) <> ACTION::LookupOK then
                    exit;

                "Generic Child Codeunit ID" := EventSubscription."Subscriber Codeunit ID";
                "Generic Child Function" := EventSubscription."Subscriber Function";
            end;

            trigger OnValidate()
            var
                EventSubscription: Record "Event Subscription";
            begin
                if "Generic Child Function" = '' then begin
                    "Generic Child Codeunit ID" := 0;
                    exit;
                end;

                EventSubscription.SetRange("Publisher Object Type", EventSubscription."Publisher Object Type"::Codeunit);
                EventSubscription.SetRange("Publisher Object ID", CODEUNIT::"NPR NpXml Mgt.");
                EventSubscription.SetRange("Published Function", 'OnSetupGenericChildTable');
                EventSubscription.SetRange("Subscriber Codeunit ID", "Generic Child Codeunit ID");
                if "Generic Child Function" <> '' then
                    EventSubscription.SetRange("Subscriber Function", "Generic Child Function");
                EventSubscription.FindFirst;
            end;
        }
        field(620; "Xml Value Codeunit ID"; Integer)
        {
            BlankZero = true;
            Caption = 'Xml Value Codeunit ID';
            DataClassification = CustomerContent;
            Description = 'NC2.01';

            trigger OnLookup()
            var
                EventSubscription: Record "Event Subscription";
            begin
                EventSubscription.SetRange("Publisher Object Type", EventSubscription."Publisher Object Type"::Codeunit);
                EventSubscription.SetRange("Publisher Object ID", CODEUNIT::"NPR NpXml Value Mgt.");
                EventSubscription.SetRange("Published Function", 'OnGetXmlValue');
                if PAGE.RunModal(PAGE::"Event Subscriptions", EventSubscription) <> ACTION::LookupOK then
                    exit;

                "Xml Value Codeunit ID" := EventSubscription."Subscriber Codeunit ID";
                "Xml Value Function" := EventSubscription."Subscriber Function";
            end;

            trigger OnValidate()
            var
                EventSubscription: Record "Event Subscription";
            begin
                if "Xml Value Codeunit ID" = 0 then begin
                    "Xml Value Function" := '';
                    exit;
                end;

                EventSubscription.SetRange("Publisher Object Type", EventSubscription."Publisher Object Type"::Codeunit);
                EventSubscription.SetRange("Publisher Object ID", CODEUNIT::"NPR NpXml Value Mgt.");
                EventSubscription.SetRange("Published Function", 'OnGetXmlValue');
                EventSubscription.SetRange("Subscriber Codeunit ID", "Xml Value Codeunit ID");
                if "Xml Value Function" <> '' then
                    EventSubscription.SetRange("Subscriber Function", "Xml Value Function");
                EventSubscription.FindFirst;
            end;
        }
        field(625; "Xml Value Codeunit Name"; Text[50])
        {
            CalcFormula = Lookup(AllObj."Object Name" WHERE("Object Type" = CONST(Codeunit),
                                                             "Object ID" = FIELD("Xml Value Codeunit ID")));
            Caption = 'Xml Value Codeunit Name';
            Description = 'NC2.01';
            Editable = false;
            FieldClass = FlowField;
        }
        field(630; "Xml Value Function"; Text[250])
        {
            Caption = 'Xml Value Function';
            DataClassification = CustomerContent;
            Description = 'NC2.01';

            trigger OnLookup()
            var
                EventSubscription: Record "Event Subscription";
            begin
                EventSubscription.SetRange("Publisher Object Type", EventSubscription."Publisher Object Type"::Codeunit);
                EventSubscription.SetRange("Publisher Object ID", CODEUNIT::"NPR NpXml Value Mgt.");
                EventSubscription.SetRange("Published Function", 'OnGetXmlValue');
                if PAGE.RunModal(PAGE::"Event Subscriptions", EventSubscription) <> ACTION::LookupOK then
                    exit;

                "Xml Value Codeunit ID" := EventSubscription."Subscriber Codeunit ID";
                "Xml Value Function" := EventSubscription."Subscriber Function";
            end;

            trigger OnValidate()
            var
                EventSubscription: Record "Event Subscription";
            begin
                if "Xml Value Function" = '' then begin
                    "Xml Value Codeunit ID" := 0;
                    exit;
                end;

                EventSubscription.SetRange("Publisher Object Type", EventSubscription."Publisher Object Type"::Codeunit);
                EventSubscription.SetRange("Publisher Object ID", CODEUNIT::"NPR NpXml Value Mgt.");
                EventSubscription.SetRange("Published Function", 'OnGetXmlValue');
                EventSubscription.SetRange("Subscriber Codeunit ID", "Xml Value Codeunit ID");
                if "Xml Value Function" <> '' then
                    EventSubscription.SetRange("Subscriber Function", "Xml Value Function");
                EventSubscription.FindFirst;
            end;
        }
        field(1000; Active; Boolean)
        {
            Caption = 'Active';
            DataClassification = CustomerContent;
            InitValue = true;
        }
        field(1010; Hidden; Boolean)
        {
            Caption = 'Hidden';
            DataClassification = CustomerContent;
            Description = 'No xml output,NC1.07';
        }
        field(5100; "Element Name"; Text[50])
        {
            Caption = 'Element Name';
            DataClassification = CustomerContent;
        }
        field(5105; Namespace; Text[50])
        {
            Caption = 'Namespace';
            DataClassification = CustomerContent;
            Description = 'NC1.22';
            TableRelation = "NPR NpXml Namespace".Alias WHERE("Xml Template Code" = FIELD("Xml Template Code"));
        }
        field(5117; "Default Value"; Text[50])
        {
            Caption = 'Default Value';
            DataClassification = CustomerContent;
            Description = 'Default value if Field Value is empty';
        }
        field(5120; "Table Name"; Text[50])
        {
            CalcFormula = Lookup(AllObj."Object Name" WHERE("Object Type" = CONST(Table),
                                                             "Object ID" = FIELD("Table No.")));
            Caption = 'Table Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(5200; "Field Type"; Option)
        {
            Caption = 'Field Type';
            DataClassification = CustomerContent;
            Description = 'NC1.16';
            OptionCaption = ' ,,Primary Key,,,,Enum';
            OptionMembers = " ",,PrimaryKey,,,,Enum;
        }
        field(5201; "Custom Codeunit ID"; Integer)
        {
            BlankZero = true;
            Caption = 'Custom Codeunit ID';
            DataClassification = CustomerContent;
            Description = 'NC1.01,NC1.07,NC1.10,NC1.16';
            TableRelation = AllObj."Object ID" WHERE("Object Type" = CONST(Codeunit),
                                                      "Object Name" = FILTER('NpXml Value*'));
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;

            trigger OnValidate()
            var
                "Object": Record "Object";
                AllObj: Record AllObj;
            begin
                if "Custom Codeunit ID" <> 0 then
                    AllObj.Get(AllObj."Object Type"::Codeunit, "Custom Codeunit ID");
            end;
        }
        field(5202; "Custom Codeunit Name"; Text[50])
        {
            CalcFormula = Lookup(AllObj."Object Name" WHERE("Object Type" = CONST(Codeunit),
                                                             "Object ID" = FIELD("Custom Codeunit ID")));
            Caption = 'Custom Codeunit Name';
            Description = 'NC1.01,NC1.07,NC1.10';
            Editable = false;
            FieldClass = FlowField;
        }
        field(5203; CDATA; Boolean)
        {
            Caption = 'CDATA';
            DataClassification = CustomerContent;
            Description = 'NC1.07';
        }
        field(5205; "Enum List (,)"; Text[250])
        {
            Caption = 'Enum List';
            DataClassification = CustomerContent;
            Description = 'NC1.07';
        }
        field(5210; "Only with Value"; Boolean)
        {
            Caption = 'Only with Value';
            DataClassification = CustomerContent;
            Description = 'XML Tag is excluded if set and no Value';
        }
        field(5215; Prefix; Text[50])
        {
            Caption = 'Prefix';
            DataClassification = CustomerContent;
            Description = 'NC1.20';
        }
        field(5220; "Iteration Type"; Option)
        {
            Caption = 'Iteration Type';
            DataClassification = CustomerContent;
            OptionCaption = ' ,First,Last';
            OptionMembers = " ",First,Last;
        }
        field(5230; "Reverse Sign"; Boolean)
        {
            Caption = 'Reverse Sign';
            DataClassification = CustomerContent;
            Description = 'NC1.07';
        }
        field(5235; "Round Precision"; Decimal)
        {
            Caption = 'Round Precision';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            MinValue = 0;
            MaxValue = 100;
            BlankZero = true;

            trigger OnValidate()
            begin
                if "Round Precision" > 0 then
                    "Round Direction" := '='
                else
                    "Round Direction" := '';
            end;
        }
        field(5236; "Round Direction"; Text[1])
        {
            Caption = 'Round Direction';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                ValuesAllowed: Boolean;
                ErrorText: Label 'Value ''%1'' is not a valid value. The following values can be used: ,<,>,=';
            begin
                if "Round Direction" in ['', '<', '>', '='] then
                    ValuesAllowed := true;

                if not ValuesAllowed then
                    Error(ErrorText, "Round Direction");
            end;
        }
        field(5240; "Lower Case"; Boolean)
        {
            Caption = 'Lower Case';
            DataClassification = CustomerContent;
            Description = 'NC1.07';
        }
        field(5250; "Blank Zero"; Boolean)
        {
            Caption = 'Blank Zero';
            DataClassification = CustomerContent;
        }
        field(5255; "Last Modified at"; DateTime)
        {
            Caption = 'Last Modified at';
            DataClassification = CustomerContent;
            Description = 'NC1.21';
        }
        field(100000; "Has Filter"; Boolean)
        {
            CalcFormula = Exist("NPR NpXml Filter" WHERE("Xml Template Code" = FIELD("Xml Template Code"),
                                                      "Xml Element Line No." = FIELD("Line No.")));
            Caption = 'Has Filter';
            Editable = false;
            FieldClass = FlowField;
        }
        field(100010; "Has Attribute"; Boolean)
        {
            CalcFormula = Exist("NPR NpXml Attribute" WHERE("Xml Template Code" = FIELD("Xml Template Code"),
                                                         "Xml Element Line No." = FIELD("Line No.")));
            Caption = 'Has Attribute';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "Xml Template Code", "Line No.")
        {
        }
    }

    trigger OnDelete()
    var
        NpXmlAttribute: Record "NPR NpXml Attribute";
        NpXmlElement: Record "NPR NpXml Element";
        XMLFilter: Record "NPR NpXml Filter";
    begin
        XMLFilter.SetRange("Xml Template Code", "Xml Template Code");
        XMLFilter.SetRange("Xml Element Line No.", "Line No.");
        XMLFilter.DeleteAll;

        NpXmlAttribute.SetRange("Xml Template Code", "Xml Template Code");
        NpXmlAttribute.SetRange("Xml Element Line No.", "Line No.");
        NpXmlAttribute.DeleteAll;
    end;

    trigger OnInsert()
    begin
        UpdateParentInfo();
        SetEnumList();
        "Template Version No." := GetTemplateVersionNo();
    end;

    trigger OnModify()
    var
        NpXmlAttribute: Record "NPR NpXml Attribute";
        NpXmlElement: Record "NPR NpXml Element";
        XMLFilter: Record "NPR NpXml Filter";
    begin
        UpdateParentInfo();
        NpXmlElement.SetRange("Xml Template Code", "Xml Template Code");
        NpXmlElement.SetFilter("Line No.", '<>%1', "Line No.");
        if NpXmlElement.FindSet then
            repeat
                NpXmlElement.UpdateParentInfo();
                NpXmlElement.Modify;
            until NpXmlElement.Next = 0;

        if "Table No." <> xRec."Table No." then begin
            XMLFilter.SetRange("Xml Template Code", "Xml Template Code");
            XMLFilter.SetRange("Xml Element Line No.", "Line No.");
            XMLFilter.SetFilter("Table No.", '<>%1', 0);
            XMLFilter.ModifyAll("Table No.", "Table No.");

            NpXmlAttribute.SetRange("Xml Template Code", "Xml Template Code");
            NpXmlAttribute.SetRange("Xml Element Line No.", "Line No.");
            NpXmlAttribute.SetRange("Table No.", xRec."Table No.");
            NpXmlAttribute.ModifyAll("Table No.", "Table No.");
        end;

        SetEnumList();

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

    procedure GetParentLineNo() ParentLineNo: Integer
    var
        NpXmlElement: Record "NPR NpXml Element";
    begin
        Clear(NpXmlElement);
        NpXmlElement.SetRange("Xml Template Code", "Xml Template Code");
        NpXmlElement.SetFilter("Line No.", '<%1', "Line No.");
        NpXmlElement.SetFilter(Level, '<%1', Level);
        if NpXmlElement.FindLast then
            exit(NpXmlElement."Line No.");
    end;

    procedure IsContainer(): Boolean
    begin
        CalcFields("Has Attribute");
        exit(("Field No." = 0) and (not "Has Attribute") and ("Default Value" = ''));
    end;

    local procedure SetEnumList()
    var
        "Field": Record "Field";
        NpXmlAttribute: Record "NPR NpXml Attribute";
    begin
        if "Field Type" <> "Field Type"::Enum then begin
            "Enum List (,)" := '';
            exit;
        end;
        if "Enum List (,)" <> '' then
            exit;

        Clear(Field);
        if not Field.Get("Table No.", "Field No.") then begin
            NpXmlAttribute.SetRange("Xml Template Code", "Xml Template Code");
            NpXmlAttribute.SetFilter("Attribute Field No.", '<>%1', 0);
            if NpXmlAttribute.FindSet then
                repeat
                until Field.Get(NpXmlAttribute."Table No.", NpXmlAttribute."Attribute Field No.") or (NpXmlAttribute.Next = 0);
        end;
        if Field."No." = 0 then
            exit;

        case Field.Type of
            Field.Type::Option:
                "Enum List (,)" := Field.OptionString;
            Field.Type::Boolean:
                "Enum List (,)" := 'false,true';
            Field.Type::Integer:
                "Enum List (,)" := '0,1,2';
        end;
    end;

    procedure UpdateParentInfo()
    var
        XMLFilter: Record "NPR NpXml Filter";
    begin
        Validate("Parent Line No.", GetParentLineNo());
        if xRec."Parent Table No." <> "Parent Table No." then begin
            XMLFilter.SetRange("Xml Template Code", "Xml Template Code");
            XMLFilter.SetRange("Xml Element Line No.", "Line No.");
            XMLFilter.SetFilter("Parent Table No.", '<>%1', 0);
            XMLFilter.ModifyAll("Parent Table No.", "Parent Table No.");
        end;
    end;
}

