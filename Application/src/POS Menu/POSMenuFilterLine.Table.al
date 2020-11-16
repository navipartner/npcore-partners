table 6150716 "NPR POS Menu Filter Line"
{
    // NPR5.32/NPKNAV/20170526  CASE 270854 Transport NPR5.32 - 26 May 2017
    // NPR5.46/BHR /20180824  CASE 322752 Replace record Object to Allobj -fields 2,6,9

    Caption = 'POS Menu Filter';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Object Type"; Option)
        {
            Caption = 'Object Type';
            DataClassification = CustomerContent;
            OptionCaption = ',,,Report,,Codeunit,XMLPort,,Page';
            OptionMembers = "1","2","3","4","5","6","7","8","9","10","11","12";
        }
        field(2; "Object Id"; Integer)
        {
            Caption = 'Object Id';
            DataClassification = CustomerContent;
            //The property 'ValidateTableRelation' can only be set if the property 'TableRelation' is set
            //ValidateTableRelation = true;
        }
        field(3; "Filter Code"; Code[20])
        {
            Caption = 'Filter Code';
            DataClassification = CustomerContent;
        }
        field(4; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(5; "Object Name"; Text[30])
        {
            CalcFormula = Lookup (AllObj."Object Name" WHERE("Object Type" = CONST(Table),
                                                             "Object ID" = FIELD("Object Id")));
            Caption = 'Object Name';
            FieldClass = FlowField;
        }
        field(6; "Table No."; Integer)
        {
            Caption = 'Table No.';
            DataClassification = CustomerContent;
            TableRelation = AllObj."Object ID" WHERE("Object Type" = CONST(Table));
            ValidateTableRelation = true;
        }
        field(7; "Field No."; Integer)
        {
            Caption = 'Field No.';
            DataClassification = CustomerContent;
            TableRelation = Field."No." WHERE(TableNo = FIELD("Table No."));
        }
        field(8; "Filter Value"; Text[250])
        {
            Caption = 'Filter Value';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Filter Value" <> '' then CheckLineFilter;
            end;
        }
        field(9; "Table Name"; Text[30])
        {
            CalcFormula = Lookup (AllObj."Object Name" WHERE("Object Type" = CONST(Table),
                                                             "Object ID" = FIELD("Table No.")));
            Caption = 'Table Name';
            FieldClass = FlowField;
        }
        field(10; "Field Name"; Text[30])
        {
            CalcFormula = Lookup (Field.FieldName WHERE(TableNo = FIELD("Table No."),
                                                        "No." = FIELD("Field No.")));
            Caption = 'Field Name';
            FieldClass = FlowField;
        }
        field(11; "Filter Sale POS Field Id"; Integer)
        {
            Caption = 'Filter Sale POS Field Id';
            DataClassification = CustomerContent;
            TableRelation = Field."No." WHERE(TableNo = CONST(6014405));

            trigger OnLookup()
            var
                FieldLookup: Page "NPR Field Lookup";
                "Field": Record "Field";
            begin
                Field.Reset;
                Field.SetRange(TableNo, DATABASE::"NPR Sale POS");
                FieldLookup.SetTableView(Field);
                FieldLookup.LookupMode(true);
                if FieldLookup.RunModal = ACTION::LookupOK then begin
                    FieldLookup.GetRecord(Field);
                    Validate("Filter Sale POS Field Id", Field."No.");
                end;
            end;

            trigger OnValidate()
            begin
                if "Filter Sale POS Field Id" <> 0 then CheckLineFilter;
            end;
        }
        field(12; "Filter Sale Line POS Field Id"; Integer)
        {
            Caption = 'Filter Sale Line POS Field Id';
            DataClassification = CustomerContent;
            TableRelation = Field."No." WHERE(TableNo = CONST(6014406));

            trigger OnLookup()
            var
                FieldLookup: Page "NPR Field Lookup";
                "Field": Record "Field";
            begin
                Field.Reset;
                Field.SetRange(TableNo, DATABASE::"NPR Sale Line POS");
                FieldLookup.SetTableView(Field);
                FieldLookup.LookupMode(true);
                if FieldLookup.RunModal = ACTION::LookupOK then begin
                    FieldLookup.GetRecord(Field);
                    Validate("Filter Sale Line POS Field Id", Field."No.");
                end;
            end;

            trigger OnValidate()
            begin
                if "Filter Sale Line POS Field Id" <> 0 then CheckLineFilter;
            end;
        }
        field(13; "Filter Sale POS Field Name"; Text[30])
        {
            CalcFormula = Lookup (Field.FieldName WHERE(TableNo = CONST(6014405),
                                                        "No." = FIELD("Filter Sale POS Field Id")));
            Caption = 'Filter Sale POS Field Name';
            FieldClass = FlowField;
        }
        field(14; "Filter Sale Line POS Field Nam"; Text[30])
        {
            CalcFormula = Lookup (Field.FieldName WHERE(TableNo = CONST(6014407),
                                                        "No." = FIELD("Filter Sale Line POS Field Id")));
            Caption = 'Filter Sale Line POS Field Name';
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "Object Type", "Object Id", "Filter Code", "Line No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    var
        This: Record "NPR POS Menu Filter Line";
    begin
        if Rec."Line No." <> 0 then exit;
        This.Reset;
        This.SetRange("Object Type", "Object Type");
        This.SetRange("Object Id", "Object Id");
        This.SetRange("Filter Code", "Filter Code");
        if This.IsEmpty then begin
            "Line No." := 10000;
        end else begin
            This.FindLast;
            "Line No." := This."Line No." + 10000;
        end;
    end;

    var
        ERRFILTER: Label 'Only one line filter can be used per line.';

    local procedure CheckLineFilter()
    begin
        if (("Filter Value" <> '') and ("Filter Sale Line POS Field Id" <> 0) and ("Filter Sale POS Field Id" <> 0)) then Error(ERRFILTER);
    end;
}

