table 6014445 "NPR RP Template Line"
{
#pragma warning disable AA0139
    Access = Internal;
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
                MatrixPrinter: Interface "NPR IMatrix Printer";
                LinePrinter: Interface "NPR ILine Printer";
                LookupOK: Boolean;
                Value: Text;
                RetailLogo: Record "NPR Retail Logo";
            begin
                RPTemplateHeader.Get("Template Code");

                case Type of
                    Type::Data,
                    Type::FieldCaption:
                        begin
                            case RPTemplateHeader."Printer Type" of
                                RPTemplateHeader."Printer Type"::Line:
                                    begin
                                        LinePrinter := RPTemplateHeader."Line Device";
                                        LookupOK := LinePrinter.LookupFont(Value);
                                    end;
                                RPTemplateHeader."Printer Type"::Matrix:
                                    begin
                                        MatrixPrinter := RPTemplateHeader."Matrix Device";
                                        LookupOK := MatrixPrinter.LookupFont(Value);
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
                                        LinePrinter := RPTemplateHeader."Line Device";
                                        LookupOK := LinePrinter.LookupCommand(Value);
                                    end;
                                RPTemplateHeader."Printer Type"::Matrix:
                                    begin
                                        MatrixPrinter := RPTemplateHeader."Matrix Device";
                                        LookupOK := MatrixPrinter.LookupCommand(Value);
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
                Fields.SetFilter(ObsoleteState, '<>%1', Fields.ObsoleteState::Removed);
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
            OptionCaption = 'Data,Loop,Command,Logo,Field Caption,If Data Found';
            OptionMembers = Data,Loop,Command,Logo,FieldCaption,IfDataFound;
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
                PrintTemplateHeader: Record "NPR RP Template Header";
                MatrixPrintMgt: Codeunit "NPR RP Matrix Print Mgt.";
                LinePrintMgt: Codeunit "NPR RP Line Print Mgt.";
            begin
                PrintTemplateHeader.Get(Rec."Template Code");

                case PrintTemplateHeader."Printer Type" of
                    PrintTemplateHeader."Printer Type"::Line:
                        LinePrintMgt.OnBuildFunctionCodeunitList(TempAllObj);
                    PrintTemplateHeader."Printer Type"::Matrix:
                        MatrixPrintMgt.OnBuildFunctionCodeunitList(TempAllObj);
                end;

                if TempAllObj.IsEmpty() then
                    exit;
                if Page.RunModal(Page::"All Objects", TempAllObj) <> Action::LookupOK then
                    exit;

                Rec."Processing Codeunit" := TempAllObj."Object ID";
                Rec.Modify();
            end;

            trigger OnValidate()
            var
                TempAllObj: Record AllObj temporary;
                PrintTemplateHeader: Record "NPR RP Template Header";
                MatrixPrintMgt: Codeunit "NPR RP Matrix Print Mgt.";
                LinePrintMgt: Codeunit "NPR RP Line Print Mgt.";
            begin
                if Rec."Processing Codeunit" = 0 then
                    exit;

                PrintTemplateHeader.Get(Rec."Template Code");

                case PrintTemplateHeader."Printer Type" of
                    PrintTemplateHeader."Printer Type"::Line:
                        LinePrintMgt.OnBuildFunctionCodeunitList(TempAllObj);
                    PrintTemplateHeader."Printer Type"::Matrix:
                        MatrixPrintMgt.OnBuildFunctionCodeunitList(TempAllObj);
                end;

                TempAllObj.SetRange("Object ID", Rec."Processing Codeunit");
                TempAllObj.FindFirst();
            end;
        }
        field(36; "Processing Function ID"; Code[30])
        {
            Caption = 'Processing Function ID';
            DataClassification = CustomerContent;

            trigger OnLookup()
            var
                TempRetailList: Record "NPR Retail List" temporary;
                PrintTemplateHeader: Record "NPR RP Template Header";
                MatrixPrintMgt: Codeunit "NPR RP Matrix Print Mgt.";
                LinePrintMgt: Codeunit "NPR RP Line Print Mgt.";
            begin
                PrintTemplateHeader.Get(Rec."Template Code");

                case PrintTemplateHeader."Printer Type" of
                    PrintTemplateHeader."Printer Type"::Line:
                        LinePrintMgt.OnBuildFunctionList(Rec."Processing Codeunit", TempRetailList);
                    PrintTemplateHeader."Printer Type"::Matrix:
                        MatrixPrintMgt.OnBuildFunctionList(Rec."Processing Codeunit", TempRetailList);
                end;

                if TempRetailList.IsEmpty() then
                    exit;
                if Page.RunModal(0, TempRetailList) <> Action::LookupOK then
                    exit;

                Rec."Processing Function ID" := TempRetailList.Choice;
                Rec.Modify();
            end;

            trigger OnValidate()
            var
                TempRetailList: Record "NPR Retail List" temporary;
                PrintTemplateHeader: Record "NPR RP Template Header";
                MatrixPrintMgt: Codeunit "NPR RP Matrix Print Mgt.";
                LinePrintMgt: Codeunit "NPR RP Line Print Mgt.";
            begin
                if Rec."Processing Function ID" = '' then
                    exit;

                PrintTemplateHeader.Get(Rec."Template Code");

                case PrintTemplateHeader."Printer Type" of
                    PrintTemplateHeader."Printer Type"::Line:
                        LinePrintMgt.OnBuildFunctionList(Rec."Processing Codeunit", TempRetailList);
                    PrintTemplateHeader."Printer Type"::Matrix:
                        MatrixPrintMgt.OnBuildFunctionList(Rec."Processing Codeunit", TempRetailList);
                end;

                TempRetailList.SetRange(Value, TempRetailList.Value);
                TempRetailList.FindFirst();
            end;
        }
        field(37; "Processing Value"; Text[2048])
        {
            Caption = 'Proccesing Value';
            DataClassification = CustomerContent;
        }
        field(38; "Processing Codeunit Name"; Text[249])
        {
            CalcFormula = Lookup(AllObjWithCaption."Object Caption" WHERE("Object Type" = CONST(Codeunit),
                                                                           "Object ID" = FIELD("Processing Codeunit")));
            Caption = 'Processing Codeunit Name';
            Editable = false;
            FieldClass = FlowField;
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
        field(51; "Default Value"; Text[2048])
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
        field(75; "Hide HRI"; Boolean)
        {
            Caption = 'Hide HRI';
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
        key(Key3; "Template Code", Type, "Data Item Name")
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

    internal procedure IndentLine(var RPTemplateLine: Record "NPR RP Template Line")
    begin
        if RPTemplateLine.FindSet() then
            repeat
                RPTemplateLine.Validate(Level, RPTemplateLine.Level + 1);
                RPTemplateLine.Modify(true);
            until RPTemplateLine.Next() = 0;
    end;

    internal procedure UnindentLine(var RPTemplateLine: Record "NPR RP Template Line")
    begin
        if RPTemplateLine.FindSet() then
            repeat
                if RPTemplateLine.Level > 0 then begin
                    RPTemplateLine.Validate(Level, RPTemplateLine.Level - 1);
                    RPTemplateLine.Modify(true);
                end;
            until RPTemplateLine.Next() = 0;
    end;
#pragma warning restore AA0139
}

