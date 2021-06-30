table 6014445 "NPR RP Template Line"
{
    // NPR5.32/MMV /20170411 CASE 241995 Retail Print 2.0
    // NPR5.44/MMV /20180706 CASE 315362 Added field 60, renamed field 44
    // NPR5.46/MMV /20180911 CASE 314067 Added field 52
    // NPR5.51/MMV /20190712 CASE 360972 Added field 70

    Caption = 'RP Template Line';
    DataClassification = CustomerContent;

    fields
    {
        field(2; "Template Code"; Code[20])
        {
            Caption = 'Template Code';
            TableRelation = "NPR RP Template Header".Code;
            DataClassification = CustomerContent;
        }
        field(3; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(5; "Type Option"; Text[30])
        {
            Caption = 'Type Option';
            DataClassification = CustomerContent;

            trigger OnLookup()
            var
                RPTemplateHeader: Record "NPR RP Template Header";
                MatrixInterface: Codeunit "NPR RP Matrix Printer Interf.";
                LineInterface: Codeunit "NPR RP Line Printer Interf.";
                LookupOK: Boolean;
                Value: Text;
                RetailLogo: Record "NPR Retail Logo";
            begin
                RPTemplateHeader.Get("Template Code");
                RPTemplateHeader.TestField("Printer Device");

                case Type of
                    Type::Data,
                    Type::FieldCaption:
                        begin
                            case RPTemplateHeader."Printer Type" of
                                RPTemplateHeader."Printer Type"::Line:
                                    begin
                                        LineInterface.Construct(RPTemplateHeader."Printer Device");
                                        LineInterface.OnLookupFont(LookupOK, Value);
                                        LineInterface.Dispose();
                                    end;
                                RPTemplateHeader."Printer Type"::Matrix:
                                    begin
                                        MatrixInterface.Construct(RPTemplateHeader."Printer Device");
                                        MatrixInterface.OnLookupFont(LookupOK, Value);
                                        MatrixInterface.Dispose();
                                    end;
                            end;
                            if LookupOK then
                                "Type Option" := Value;
                        end;

                    Type::Command:
                        begin
                            case RPTemplateHeader."Printer Type" of
                                RPTemplateHeader."Printer Type"::Line:
                                    begin
                                        LineInterface.Construct(RPTemplateHeader."Printer Device");
                                        LineInterface.OnLookupCommand(LookupOK, Value);
                                        LineInterface.Dispose();
                                    end;
                                RPTemplateHeader."Printer Type"::Matrix:
                                    begin
                                        MatrixInterface.Construct(RPTemplateHeader."Printer Device");
                                        MatrixInterface.OnLookupCommand(LookupOK, Value);
                                        MatrixInterface.Dispose();
                                    end;
                            end;
                            if LookupOK then
                                "Type Option" := Value;
                        end;

                    Type::Logo:
                        if PAGE.RunModal(PAGE::"NPR Retail Logo Setup", RetailLogo) = ACTION::LookupOK then
                            "Type Option" := RetailLogo.Keyword;
                end;
            end;
        }
        field(6; Width; Integer)
        {
            BlankZero = true;
            Caption = 'Barcode Size/Width';
            DataClassification = CustomerContent;
        }
        field(8; Rotation; Option)
        {
            Caption = 'Rotation';
            OptionCaption = '0,90,180,270';
            OptionMembers = "0","90","180","270";
            DataClassification = CustomerContent;
        }
        field(9; X; Integer)
        {
            Caption = 'X';
            DataClassification = CustomerContent;
        }
        field(10; Y; Integer)
        {
            Caption = 'Y';
            DataClassification = CustomerContent;
        }
        field(11; "Data Item Table"; Integer)
        {
            BlankZero = true;
            Caption = 'Table';
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Table));
            DataClassification = CustomerContent;

            trigger OnLookup()
            begin
                DataItemLookup();
            end;

            trigger OnValidate()
            var
                AllObj: Record AllObj;
            begin
                AllObj.Get(AllObj."Object Type"::Table, "Data Item Table");
            end;
        }
        field(12; "Data Item Name"; Text[50])
        {
            Caption = 'Table Name';
            DataClassification = CustomerContent;

            trigger OnLookup()
            begin
                DataItemLookup();
            end;

            trigger OnValidate()
            var
                DataItem: Record "NPR RP Data Items";
            begin
                if "Data Item Name" = '' then begin
                    "Data Item Table" := 0;
                    exit;
                end;

                DataItem.SetRange(Code, "Template Code");
                DataItem.SetFilter(Name, '@' + "Data Item Name");
                if not DataItem.FindFirst() then begin
                    DataItem.SetFilter(Name, '@' + "Data Item Name" + '*');
                    DataItem.FindFirst();
                end;
                "Data Item Name" := DataItem.Name;
                "Data Item Table" := DataItem."Table ID";
            end;
        }
        field(13; "Field"; Integer)
        {
            Caption = 'Field';
            DataClassification = CustomerContent;

            trigger OnLookup()
            begin
            end;

            trigger OnValidate()
            var
                "Fields": Record "Field";
            begin
                Fields.Get("Data Item Table", Field);
                "Field Name" := Fields.FieldName;
            end;
        }
        field(14; "Field Name"; Text[50])
        {
            Caption = 'Field Name';
            DataClassification = CustomerContent;

            trigger OnLookup()
            var
                "Fields": Record "Field";
            begin
                Fields.SetRange(TableNo, "Data Item Table");
                if PAGE.RunModal(PAGE::"NPR Field Lookup", Fields) = ACTION::LookupOK then begin
                    Field := Fields."No.";
                    "Field Name" := Fields.FieldName;
                end;
            end;

            trigger OnValidate()
            var
                "Fields": Record "Field";
            begin
                if "Field Name" = '' then begin
                    Field := 0;
                    exit;
                end;

                Fields.SetRange(TableNo, "Data Item Table");
                Fields.SetFilter(FieldName, '@' + "Field Name");
                if not Fields.FindFirst() then begin
                    Fields.SetFilter(FieldName, '@' + "Field Name" + '*');
                    Fields.FindFirst();
                end;
                Field := Fields."No.";
                "Field Name" := Fields.FieldName;
            end;
        }
        field(15; "Max Length"; Integer)
        {
            BlankZero = true;
            Caption = 'Max Length';
            DataClassification = CustomerContent;
        }
        field(17; Prefix; Text[30])
        {
            Caption = 'Prefix';
            DataClassification = CustomerContent;
        }
        field(18; Postfix; Text[30])
        {
            Caption = 'Postfix';
            DataClassification = CustomerContent;
        }
        field(21; Comments; Text[128])
        {
            Caption = 'Comments';
            DataClassification = CustomerContent;
        }
        field(22; Align; Option)
        {
            Caption = 'Align';
            OptionCaption = 'Left,Center,Right';
            OptionMembers = Left,Center,Right;
            DataClassification = CustomerContent;
        }
        field(23; Height; Integer)
        {
            BlankZero = true;
            Caption = 'Height';
            DataClassification = CustomerContent;
        }
        field(25; Type; Option)
        {
            Caption = 'Type';
            OptionCaption = 'Data,Loop,Command,Logo,FieldCaption';
            OptionMembers = Data,Loop,Command,Logo,FieldCaption;
            DataClassification = CustomerContent;
        }
        field(26; "Parent Line No."; Integer)
        {
            Caption = 'Parent Line No.';
            DataClassification = CustomerContent;
        }
        field(27; Level; Integer)
        {
            Caption = 'Level';
            MaxValue = 10;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if Level <> xRec.Level then
                    FindParentLine();
            end;
        }
        field(30; Operator; Option)
        {
            Caption = 'Operator';
            OptionCaption = '+,-,/,*';
            OptionMembers = "+","-","/","*";
            DataClassification = CustomerContent;
        }
        field(31; "Field 2"; Integer)
        {
            Caption = 'Field 2';
            DataClassification = CustomerContent;

            trigger OnLookup()
            begin
            end;

            trigger OnValidate()
            var
                "Fields": Record "Field";
            begin
                Fields.Get("Data Item Table", Field);
                "Field 2 Name" := Fields.FieldName;
            end;
        }
        field(32; "Field 2 Name"; Text[50])
        {
            Caption = 'Field 2 Name';
            DataClassification = CustomerContent;

            trigger OnLookup()
            var
                "Fields": Record "Field";
            begin
                Fields.SetRange(TableNo, "Data Item Table");
                if PAGE.RunModal(PAGE::"NPR Field Lookup", Fields) = ACTION::LookupOK then begin
                    "Field 2" := Fields."No.";
                    "Field 2 Name" := Fields.FieldName;
                end;
            end;

            trigger OnValidate()
            var
                "Fields": Record "Field";
            begin
                if "Field 2 Name" = '' then begin
                    "Field 2" := 0;
                    exit;
                end;

                Fields.SetRange(TableNo, "Data Item Table");
                Fields.SetFilter(FieldName, '@' + "Field 2 Name");
                if not Fields.FindFirst() then begin
                    Fields.SetFilter(FieldName, '@' + "Field 2 Name" + '*');
                    Fields.FindFirst();
                end;
                "Field 2" := Fields."No.";
                "Field 2 Name" := Fields.FieldName;
            end;
        }
        field(35; "Processing Codeunit"; Integer)
        {
            Caption = 'Processing Codeunit';
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = CONST(Codeunit));
            DataClassification = CustomerContent;

            trigger OnLookup()
            var
                TempAllObj: Record AllObj temporary;
            begin
                OnBuildFunctionCodeunitList(TempAllObj);
                if PAGE.RunModal(PAGE::"All Objects", TempAllObj) = ACTION::LookupOK then
                    "Processing Codeunit" := TempAllObj."Object ID";
            end;
        }
        field(36; "Processing Function ID"; Code[30])
        {
            Caption = 'Processing Function ID';
            DataClassification = CustomerContent;

            trigger OnLookup()
            var
                TempRetailList: Record "NPR Retail List" temporary;
            begin
                OnBuildFunctionList("Processing Codeunit", TempRetailList);
                if PAGE.RunModal(0, TempRetailList) = ACTION::LookupOK then
                    "Processing Function ID" := TempRetailList.Choice;
            end;
        }
        field(37; "Processing Value"; Text[250])
        {
            Caption = 'Proccesing Value';
            DataClassification = CustomerContent;
        }
        field(40; "Start Char"; Integer)
        {
            BlankZero = true;
            Caption = 'Start Char';
            DataClassification = CustomerContent;
        }
        field(41; "Prefix Next Line"; Boolean)
        {
            Caption = 'Prefix Next Line';
            DataClassification = CustomerContent;
        }
        field(42; Attribute; Code[30])
        {
            Caption = 'Attribute';
            TableRelation = "NPR Attribute ID"."Attribute Code" WHERE("Table ID" = FIELD("Data Item Table"));
            DataClassification = CustomerContent;
        }
        field(44; "Root Record No."; Integer)
        {
            Caption = 'Root Record No.';
            DataClassification = CustomerContent;
        }
        field(45; "Template Column No."; Integer)
        {
            BlankZero = true;
            Caption = 'Column No.';
            DataClassification = CustomerContent;
        }
        field(46; Bold; Boolean)
        {
            Caption = 'Bold';
            DataClassification = CustomerContent;
        }
        field(47; "Pad Char"; Text[1])
        {
            Caption = 'Pad Char';
            DataClassification = CustomerContent;
        }
        field(48; Underline; Boolean)
        {
            Caption = 'Underline';
            DataClassification = CustomerContent;
        }
        field(49; "Blank Zero"; Boolean)
        {
            Caption = 'Blank Zero';
            DataClassification = CustomerContent;
        }
        field(50; "Skip If Empty"; Boolean)
        {
            Caption = 'Skip If Empty';
            DataClassification = CustomerContent;
        }
        field(51; "Default Value"; Text[250])
        {
            Caption = 'Default Value';
            DataClassification = CustomerContent;
        }
        field(52; "Default Value Record Required"; Boolean)
        {
            Caption = 'Only Fill Default Value On Data';
            DataClassification = CustomerContent;
        }
        field(60; "Data Item Record No."; Integer)
        {
            Caption = 'Data Item Record No.';
            DataClassification = CustomerContent;
        }
        field(70; "Processing Function Parameter"; Text[30])
        {
            Caption = 'Processing Function Parameter';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Template Code", "Line No.")
        {
        }
        key(Key2; "Template Code", Level, "Parent Line No.", "Line No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        ModifiedRec();
    end;

    trigger OnInsert()
    begin
        ModifiedRec();
    end;

    trigger OnModify()
    begin
        ModifiedRec();
    end;

    trigger OnRename()
    begin
        ModifiedRec();
    end;

    procedure FindParentLine()
    var
        RPTemplateLine: Record "NPR RP Template Line";
    begin
        RPTemplateLine.SetRange("Template Code", "Template Code");
        RPTemplateLine.SetFilter("Line No.", '<%1', "Line No.");
        RPTemplateLine.SetFilter(Level, '<%1', Level);
        if RPTemplateLine.FindLast() then
            "Parent Line No." := RPTemplateLine."Line No."
        else
            "Parent Line No." := 0;
    end;

    local procedure ModifiedRec()
    var
        RPTemplateHeader: Record "NPR RP Template Header";
    begin
        if IsTemporary then
            exit;
        if RPTemplateHeader.Get("Template Code") then
            RPTemplateHeader.Modify(true);
    end;

    local procedure DataItemLookup()
    var
        DataItem: Record "NPR RP Data Items";
        TempRetailList: Record "NPR Retail List" temporary;
        "Integer": Integer;
    begin
        DataItem.SetRange(Code, "Template Code");
        if DataItem.FindSet() then
            repeat
                TempRetailList.Number += 1;
                TempRetailList.Choice := DataItem.Name;
                TempRetailList.Value := Format(DataItem."Table ID");
                TempRetailList.Insert();
            until DataItem.Next() = 0;

        if PAGE.RunModal(PAGE::"NPR Retail List", TempRetailList) = ACTION::LookupOK then begin
            Evaluate(Integer, TempRetailList.Value);
            Validate("Data Item Table", Integer);
            Validate("Data Item Name", TempRetailList.Choice);
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBuildFunctionCodeunitList(var tmpAllObj: Record AllObj temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBuildFunctionList(CodeunitID: Integer; var tmpRetailList: Record "NPR Retail List" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnFunction(CodeunitID: Integer; FunctionName: Text; var TemplateLine: Record "NPR RP Template Line"; RecID: RecordID; var Skip: Boolean; var Handled: Boolean)
    begin
    end;
}

