table 6060051 "NPR Item Worksh. Excel Column"
{
    Caption = 'Item Worksheet Excel Column';
    DataClassification = CustomerContent;

    fields
    {
        field(10; "Worksheet Template Name"; Code[10])
        {
            Caption = 'Worksheet Template Name';
            DataClassification = CustomerContent;
        }
        field(20; "Worksheet Name"; Code[10])
        {
            Caption = 'Worksheet Name';
            DataClassification = CustomerContent;
        }
        field(30; "Excel Column No."; Integer)
        {
            Caption = 'Excel Column No.';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                c: Char;
                i: Integer;
                x: Integer;
                y: Integer;
                t: Text[30];
            begin
                "Excel Column" := '';
                x := "Excel Column No.";
                while x > 26 do begin
                    y := x mod 26;
                    if y = 0 then
                        y := 26;
                    c := 64 + y;
                    i := i + 1;
                    t[i] := c;
                    x := (x - y) div 26;
                end;
                if x > 0 then begin
                    c := 64 + x;
                    i := i + 1;
                    t[i] := c;
                end;
                for x := 1 to i do
                    "Excel Column"[x] := t[1 + i - x];
            end;
        }
        field(40; "Excel Column"; Code[3])
        {
            Caption = 'Excel Column';
            CharAllowed = 'AZ';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                i: Integer;
            begin
                "Excel Column No." := 0;
                for i := StrLen("Excel Column") downto 1 do begin
                    "Excel Column No." := "Excel Column No." + ("Excel Column"[i] - 64) * (Power(26, StrLen("Excel Column") - i));
                end;
            end;
        }
        field(50; "Excel Header Text"; Text[30])
        {
            Caption = 'Excel Header Text';
            DataClassification = CustomerContent;
        }
        field(60; "Process as"; Option)
        {
            Caption = 'Process as';
            DataClassification = CustomerContent;
            OptionCaption = 'Skip,Item,Item Variant,Item Attribute,Other';
            OptionMembers = Skip,Item,"Item Variant","Item Attribute",Other;

            trigger OnValidate()
            begin
                case "Process as" of
                    "Process as"::Skip:
                        Validate("Map to Table No.", 0);
                    "Process as"::Item:
                        begin
                            Validate("Map to Table No.", DATABASE::"NPR Item Worksheet Line");
                            Validate("Map to Attribute Code", '');
                        end;
                    "Process as"::"Item Variant":
                        begin
                            Validate("Map to Table No.", DATABASE::"NPR Item Worksh. Variant Line");
                            Validate("Map to Attribute Code", '');
                        end;
                    "Process as"::"Item Attribute":
                        begin
                            Validate("Map to Table No.", DATABASE::"NPR Item Worksheet Line");
                            Validate("Map to Field Number", 0);
                        end;
                end;
            end;
        }
        field(65; "Map to Table No."; Integer)
        {
            Caption = 'Map to Table No.';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                Validate("Map to Field Number");
            end;
        }
        field(70; "Map to Field Number"; Integer)
        {
            Caption = 'Map to Field Number';
            DataClassification = CustomerContent;

            trigger OnLookup()
            begin
                LookupItemWorksheetField;
            end;

            trigger OnValidate()
            var
                TestBoolean: Boolean;
                TestDate: Date;
                TestDateTime: DateTime;
                TestDecimal: Decimal;
                TestInteger: Integer;
                WarnDataTypeExampleMsg: Label 'Warning: the imported example fields could not be evaluated to datatype %1.', Comment = '%1 = Field type';
                TestTime: Time;
            begin
                if "Process as" in ["Process as"::Item, "Process as"::"Item Variant"] then begin
                    if RecField.Get("Map to Table No.", "Map to Field Number") then begin
                        "Map to Field Name" := RecField.FieldName;
                        "Map to Caption" := RecField."Field Caption";
                        case RecField.Type of
                            RecField.Type::DateTime:
                                begin
                                    if not ((Evaluate(TestDateTime, "Sample Data Row 1") or ("Sample Data Row 1" = '')) and
                                            (Evaluate(TestDateTime, "Sample Data Row 2") or ("Sample Data Row 2" = '')) and
                                            (Evaluate(TestDateTime, "Sample Data Row 3") or ("Sample Data Row 3" = ''))) then
                                        Message(WarnDataTypeExampleMsg, RecField.Type);
                                end;
                            RecField.Type::Date:
                                begin
                                    if not ((Evaluate(TestDate, "Sample Data Row 1") or ("Sample Data Row 1" = '')) and
                                            (Evaluate(TestDate, "Sample Data Row 2") or ("Sample Data Row 2" = '')) and
                                            (Evaluate(TestDate, "Sample Data Row 3") or ("Sample Data Row 3" = ''))) then
                                        Message(WarnDataTypeExampleMsg, RecField.Type);
                                end;
                            RecField.Type::Time:
                                begin
                                    if not ((Evaluate(TestTime, "Sample Data Row 1") or ("Sample Data Row 1" = '')) and
                                            (Evaluate(TestTime, "Sample Data Row 2") or ("Sample Data Row 2" = '')) and
                                            (Evaluate(TestTime, "Sample Data Row 3") or ("Sample Data Row 3" = ''))) then
                                        Message(WarnDataTypeExampleMsg, RecField.Type);
                                end;
                            RecField.Type::Integer:
                                begin
                                    if not ((Evaluate(TestInteger, "Sample Data Row 1") or ("Sample Data Row 1" = '')) and
                                            (Evaluate(TestInteger, "Sample Data Row 2") or ("Sample Data Row 2" = '')) and
                                            (Evaluate(TestInteger, "Sample Data Row 3") or ("Sample Data Row 3" = ''))) then
                                        Message(WarnDataTypeExampleMsg, RecField.Type);
                                end;
                            RecField.Type::Decimal:
                                begin
                                    if not ((Evaluate(TestDecimal, "Sample Data Row 1") or ("Sample Data Row 1" = '')) and
                                            (Evaluate(TestDecimal, "Sample Data Row 2") or ("Sample Data Row 2" = '')) and
                                            (Evaluate(TestDecimal, "Sample Data Row 3") or ("Sample Data Row 3" = ''))) then
                                        Message(WarnDataTypeExampleMsg, RecField.Type);
                                end;
                            RecField.Type::Boolean:
                                begin
                                    if not ((Evaluate(TestBoolean, "Sample Data Row 1") or ("Sample Data Row 1" = '')) and
                                            (Evaluate(TestBoolean, "Sample Data Row 2") or ("Sample Data Row 2" = '')) and
                                            (Evaluate(TestBoolean, "Sample Data Row 3") or ("Sample Data Row 3" = ''))) then
                                        Message(WarnDataTypeExampleMsg, RecField.Type);
                                end;

                        end;
                    end else begin
                        "Map to Field Number" := 0;
                        "Map to Field Name" := RecField.FieldName;
                        "Map to Caption" := RecField."Field Caption";
                    end;
                end;

                if "Process as" = "Process as"::Other then begin
                    "Map to Field Name" := TempFieldName("Map to Field Number");
                    "Map to Caption" := TempFieldName("Map to Field Number");
                end;
                if "Excel Header Text" = '' then
                    "Excel Header Text" := "Map to Caption";
            end;
        }
        field(80; "Map to Field Name"; Text[30])
        {
            Caption = 'Map to Field Name';
            DataClassification = CustomerContent;

            trigger OnLookup()
            begin
                LookupItemWorksheetField;
            end;

            trigger OnValidate()
            begin
                RecField.Reset();
                RecField.SetRange(TableNo, "Map to Table No.");
                RecField.SetRange(FieldName, "Map to Field Name");
                if RecField.FindFirst() then
                    Validate("Map to Field Number", RecField."No.")
                else
                    Validate("Map to Field Number", 0);
            end;
        }
        field(90; "Map to Caption"; Text[80])
        {
            Caption = 'Map to Caption';
            DataClassification = CustomerContent;

            trigger OnLookup()
            begin
                LookupItemWorksheetField;
            end;

            trigger OnValidate()
            begin
                case "Process as" of
                    "Process as"::Skip:
                        exit;
                    "Process as"::"Item Attribute":
                        begin
                            if NPRAttributeID.Get("Map to Table No.", "Map to Caption") then
                                Validate("Map to Attribute Code", NPRAttributeID."Attribute Code")
                            else
                                Validate("Map to Attribute Code", '');
                        end;
                    "Process as"::Item, "Process as"::"Item Variant":
                        begin
                            RecField.Reset();
                            RecField.SetRange(TableNo, "Map to Table No.");
                            RecField.SetRange("Field Caption", "Map to Caption");
                            if RecField.FindFirst() then
                                Validate("Map to Field Number", RecField."No.")
                            else
                                Validate("Map to Field Number", 0);
                        end;
                    "Process as"::Other:
                        begin
                            Validate("Map to Field Number");
                        end;
                end;
                if "Excel Header Text" = '' then
                    "Excel Header Text" := "Map to Caption";
            end;
        }
        field(100; "Map to Attribute Code"; Code[20])
        {
            Caption = 'Map to Attribute Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR Attribute";

            trigger OnValidate()
            begin
                if "Process as" = "Process as"::"Item Attribute" then
                    "Map to Caption" := "Map to Attribute Code";
            end;
        }
        field(200; "Sample Data Row 1"; Text[250])
        {
            Caption = 'Sample Data Row 1';
            DataClassification = CustomerContent;
        }
        field(210; "Sample Data Row 2"; Text[250])
        {
            Caption = 'Sample Data Row 2';
            DataClassification = CustomerContent;
        }
        field(220; "Sample Data Row 3"; Text[250])
        {
            Caption = 'Sample Data Row 3';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Worksheet Template Name", "Worksheet Name", "Excel Column No.")
        {
        }
        key(Key2; "Worksheet Template Name", "Worksheet Name", "Map to Table No.", "Map to Field Number")
        {
        }
    }

    fieldgroups
    {
    }

    var
        RecField: Record "Field";
        NPRAttributeID: Record "NPR Attribute ID";

    local procedure LookupItemWorksheetField()
    var
        RecTempField: Record "Field" temporary;
        NPRAttributeIDs: Page "NPR Attribute IDs";
        FieldLookup: Page "NPR Field Lookup";
        I: Integer;
    begin
        case "Process as" of
            "Process as"::Skip:
                exit;
            "Process as"::"Item Attribute":
                begin
                    NPRAttributeID.Reset();
                    NPRAttributeID.SetRange("Table ID", "Map to Table No.");
                    Clear(NPRAttributeIDs);
                    NPRAttributeIDs.SetTableView(NPRAttributeID);
                    NPRAttributeIDs.LookupMode := true;
                    if NPRAttributeIDs.RunModal() = ACTION::LookupOK then
                        NPRAttributeIDs.GetRecord(NPRAttributeID)
                    else
                        exit;
                    Validate("Map to Attribute Code", NPRAttributeID."Attribute Code");
                end;
            "Process as"::Item, "Process as"::"Item Variant":
                begin
                    RecField.Reset();
                    RecField.SetRange(TableNo, "Map to Table No.");
                    Clear(FieldLookup);
                    FieldLookup.SetTableView(RecField);
                    if "Map to Field Number" <> 0 then begin
                        RecField.SetRange("No.", "Map to Field Number");
                        if RecField.FindFirst() then
                            FieldLookup.SetRecord(RecField);
                        RecField.SetRange("No.");
                    end;
                    Clear(FieldLookup);
                    FieldLookup.SetTableView(RecField);
                    if "Map to Field Number" <> 0 then begin
                        RecField.SetRange("No.", "Map to Field Number");
                        if RecField.FindFirst() then
                            FieldLookup.SetRecord(RecField);
                        RecField.SetRange("No.");
                    end;
                    RecField.SetRange(Class, RecField.Class::Normal);
                    FieldLookup.SetTableView(RecField);
                    FieldLookup.LookupMode := true;
                    if FieldLookup.RunModal() = ACTION::LookupOK then
                        FieldLookup.GetRecord(RecField)
                    else
                        exit;
                    Validate("Map to Field Number", RecField."No.");
                end;
            "Process as"::Other:
                begin
                    if RecTempField.IsTemporary then begin
                        I := 1;
                        repeat
                            RecTempField.Init();
                            RecTempField."No." := I;
                            RecTempField."Field Caption" := TempFieldName(I);
                            RecTempField.Insert();
                            I := I + 1;
                        until TempFieldName(I) = '';
                        if PAGE.RunModal(6014547, RecTempField) = ACTION::LookupOK then
                            Validate("Map to Field Number", RecTempField."No.")
                        else
                            Validate("Map to Field Number", 0);
                    end;
                end;
        end;
    end;

    local procedure TempFieldName(FieldNumber: Integer): Text
    begin
        case FieldNumber of
            1:
                exit('');
            2:
                exit('');
        end;
        exit('');
    end;
}

