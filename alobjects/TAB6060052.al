table 6060052 "Item Worksheet Field Setup"
{
    // NPR5.25\BR  \20160720  CASE 246088 Object Created

    Caption = 'Item Worksheet Field Setup';
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

            trigger OnLookup()
            begin

                LookupField(0);
            end;

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
        field(20; "Table Name"; Text[30])
        {
            Caption = 'Table Name';
            DataClassification = CustomerContent;
        }
        field(21; "Table Caption"; Text[80])
        {
            Caption = 'Table Caption';
            DataClassification = CustomerContent;
        }
        field(30; "Field Name"; Text[30])
        {
            Caption = 'Field Name';
            DataClassification = CustomerContent;

            trigger OnLookup()
            begin
                LookupField(0);
            end;

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

            trigger OnLookup()
            begin
                LookupField(0);
            end;

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
        field(40; "Target Table No. Create"; Integer)
        {
            Caption = 'Target Table No. Create';
            DataClassification = CustomerContent;
        }
        field(41; "Target Field Number Create"; Integer)
        {
            Caption = 'Target Field Number Create';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if RecField.Get("Target Table No. Create", "Target Field Number Create") then begin
                    "Target Field Name Create" := RecField.FieldName;
                    "Target Field Caption Create" := RecField."Field Caption";
                end else begin
                    "Target Field Number Create" := 0;
                    "Target Field Name Create" := '';
                    "Target Field Caption Create" := '';
                end;
            end;
        }
        field(45; "Target Field Name Create"; Text[30])
        {
            Caption = 'Target Field Name Create';
            DataClassification = CustomerContent;

            trigger OnLookup()
            begin
                LookupField(1);
            end;

            trigger OnValidate()
            begin

                RecField.Reset;
                RecField.SetRange(TableNo, "Target Table No. Create");
                RecField.SetRange(FieldName, "Target Field Name Create");
                if RecField.FindFirst then
                    Validate("Field Number", RecField."No.")
                else
                    Validate("Field Number", 0);
            end;
        }
        field(46; "Target Field Caption Create"; Text[80])
        {
            Caption = 'Target Field Caption Create';
            DataClassification = CustomerContent;

            trigger OnLookup()
            begin
                LookupField(1);
            end;

            trigger OnValidate()
            begin

                RecField.Reset;
                RecField.SetRange(TableNo, "Target Table No. Create");
                RecField.SetRange("Field Caption", "Target Field Caption Create");
                if RecField.FindFirst then
                    Validate("Field Number", RecField."No.")
                else
                    Validate("Field Number", 0);
            end;
        }
        field(50; "Target Table No. Update"; Integer)
        {
            Caption = 'Target Table No. Update';
            DataClassification = CustomerContent;
        }
        field(51; "Target Field Number Update"; Integer)
        {
            Caption = 'Target Field Number Update';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if RecField.Get("Target Table No. Update", "Target Field Number Update") then begin
                    "Target Field Name Update" := RecField.FieldName;
                    "Target Field Caption Update" := RecField."Field Caption";
                end else begin
                    "Target Field Number Update" := 0;
                    "Target Field Name Update" := '';
                    "Target Field Caption Update" := '';
                end;
            end;
        }
        field(55; "Target Field Name Update"; Text[30])
        {
            Caption = 'Target Field Name Update';
            DataClassification = CustomerContent;

            trigger OnLookup()
            begin
                LookupField(2);
            end;

            trigger OnValidate()
            begin

                RecField.Reset;
                RecField.SetRange(TableNo, "Target Table No. Update");
                RecField.SetRange(FieldName, "Target Field Name Update");
                if RecField.FindFirst then
                    Validate("Field Number", RecField."No.")
                else
                    Validate("Field Number", 0);
            end;
        }
        field(56; "Target Field Caption Update"; Text[80])
        {
            Caption = 'Target Field Caption Update';
            DataClassification = CustomerContent;

            trigger OnLookup()
            begin
                LookupField(2);
            end;

            trigger OnValidate()
            begin

                RecField.Reset;
                RecField.SetRange(TableNo, "Target Table No. Update");
                RecField.SetRange("Field Caption", "Target Field Caption Update");
                if RecField.FindFirst then
                    Validate("Field Number", RecField."No.")
                else
                    Validate("Field Number", 0);
            end;
        }
        field(100; "Process Create"; Option)
        {
            Caption = 'Process Create';
            DataClassification = CustomerContent;
            InitValue = Process;
            OptionCaption = 'Ignore,Process,Use Default on Blank,Always use Default';
            OptionMembers = Ignore,Process,"Use Default on Blank","Always use Default";
        }
        field(101; "Process Update"; Option)
        {
            Caption = 'Process Update';
            DataClassification = CustomerContent;
            InitValue = Process;
            OptionCaption = 'Ignore,Warn and Ignore,Warn and Process,Process';
            OptionMembers = Ignore,"Warn and Ignore","Warn and Process",Process;
        }
        field(110; "Default Value for Create"; Text[50])
        {
            Caption = 'Default Value for Create';
            DataClassification = CustomerContent;
        }
        field(150; "Mapped Values"; Integer)
        {
            CalcFormula = Count ("Item Worksheet Field Mapping" WHERE("Worksheet Template Name" = FIELD("Worksheet Template Name"),
                                                                      "Worksheet Name" = FIELD("Worksheet Name"),
                                                                      "Table No." = FIELD("Table No."),
                                                                      "Field Number" = FIELD("Field Number")));
            Caption = 'Mapped Values';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "Worksheet Template Name", "Worksheet Name", "Table No.", "Field Number")
        {
        }
    }

    fieldgroups
    {
    }

    var
        RecField: Record "Field";
        ItemWorksheetManagement: Codeunit "Item Worksheet Management";

    local procedure LookupField(OptType: Option Source,TargetCreate,TargetUpdate)
    var
        FieldLookup: Page "Field Lookup";
        NPRAttributeIDs: Page "NPR Attribute IDs";
        RecTempField: Record "Field" temporary;
        ItemWorksheetLine: Record "Item Worksheet Line";
        I: Integer;
        FieldNumberFilter: Text;
    begin
        Clear(FieldLookup);
        RecField.Reset;
        case OptType of
            OptType::Source:
                begin
                    RecField.SetRange(TableNo, "Table No.");
                    FieldNumberFilter := ItemWorksheetManagement.CreateLookupFilter("Table No.");
                    RecField.SetRange("No.", "Field Number");
                    if RecField.FindFirst then
                        FieldLookup.SetRecord(RecField);
                    FieldLookup.SetRecord(RecField);
                end;
            OptType::TargetCreate:
                begin
                    RecField.SetRange(TableNo, "Target Table No. Create");
                    FieldNumberFilter := ItemWorksheetManagement.CreateLookupFilter("Target Table No. Create");
                    RecField.SetRange("No.", "Target Field Number Create");
                    if RecField.FindFirst then
                        FieldLookup.SetRecord(RecField);
                end;
            OptType::TargetUpdate:
                begin
                    RecField.SetRange(TableNo, "Target Table No. Update");
                    FieldNumberFilter := ItemWorksheetManagement.CreateLookupFilter("Target Table No. Update");
                    RecField.SetRange("No.", "Target Field Number Update");
                    if RecField.FindFirst then
                        FieldLookup.SetRecord(RecField);
                end;
        end;

        RecField.SetRange(Class, RecField.Class::Normal);
        RecField.SetFilter("No.", FieldNumberFilter);
        FieldLookup.SetTableView(RecField);

        FieldLookup.LookupMode := true;
        if FieldLookup.RunModal = ACTION::LookupOK then
            FieldLookup.GetRecord(RecField)
        else
            exit;

        case OptType of
            OptType::Source:
                Validate("Field Number", RecField."No.");
            OptType::TargetCreate:
                Validate("Target Field Number Create", RecField."No.");
            OptType::TargetUpdate:
                Validate("Target Field Number Update", RecField."No.");
        end;
    end;
}

