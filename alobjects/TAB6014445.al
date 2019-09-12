table 6014445 "RP Template Line"
{
    // NPR5.32/MMV /20170411 CASE 241995 Retail Print 2.0
    // NPR5.44/MMV /20180706 CASE 315362 Added field 60, renamed field 44
    // NPR5.46/MMV /20180911 CASE 314067 Added field 52
    // NPR5.51/MMV /20190712 CASE 360972 Added field 70

    Caption = 'RP Template Line';

    fields
    {
        field(2;"Template Code";Code[20])
        {
            Caption = 'Template Code';
            TableRelation = "RP Template Header".Code;
        }
        field(3;"Line No.";Integer)
        {
            Caption = 'Line No.';
        }
        field(5;"Type Option";Text[30])
        {
            Caption = 'Type Option';

            trigger OnLookup()
            var
                TemplateHeader: Record "RP Template Header";
                MatrixInterface: Codeunit "RP Matrix Printer Interface";
                LineInterface: Codeunit "RP Line Printer Interface";
                LookupOK: Boolean;
                Value: Text;
                RetailLogo: Record "Retail Logo";
            begin
                TemplateHeader.Get("Template Code");
                TemplateHeader.TestField("Printer Device");

                case Type of
                  Type::Data,
                  Type::FieldCaption :
                    begin
                      case TemplateHeader."Printer Type" of
                        TemplateHeader."Printer Type"::Line:
                          begin
                            LineInterface.Construct(TemplateHeader."Printer Device");
                            LineInterface.OnLookupFont(LookupOK, Value);
                            LineInterface.Dispose();
                          end;
                        TemplateHeader."Printer Type"::Matrix:
                          begin
                            MatrixInterface.Construct(TemplateHeader."Printer Device");
                            MatrixInterface.OnLookupFont(LookupOK, Value);
                            MatrixInterface.Dispose();
                          end;
                      end;
                      if LookupOK then
                        "Type Option" := Value;
                    end;

                  Type::Command :
                    begin
                      case TemplateHeader."Printer Type" of
                        TemplateHeader."Printer Type"::Line:
                          begin
                            LineInterface.Construct(TemplateHeader."Printer Device");
                            LineInterface.OnLookupCommand(LookupOK, Value);
                            LineInterface.Dispose();
                          end;
                        TemplateHeader."Printer Type"::Matrix:
                          begin
                            MatrixInterface.Construct(TemplateHeader."Printer Device");
                            MatrixInterface.OnLookupCommand(LookupOK, Value);
                            MatrixInterface.Dispose();
                          end;
                      end;
                      if LookupOK then
                        "Type Option" := Value;
                    end;

                  Type::Logo :
                    if PAGE.RunModal(PAGE::"Retail Logo Setup", RetailLogo) = ACTION::LookupOK then
                      "Type Option" := RetailLogo.Keyword;
                end;
            end;
        }
        field(6;Width;Integer)
        {
            BlankZero = true;
            Caption = 'Barcode Size/Width';
        }
        field(8;Rotation;Option)
        {
            Caption = 'Rotation';
            OptionCaption = '0,90,180,270';
            OptionMembers = "0","90","180","270";
        }
        field(9;X;Integer)
        {
            Caption = 'X';
        }
        field(10;Y;Integer)
        {
            Caption = 'Y';
        }
        field(11;"Data Item Table";Integer)
        {
            BlankZero = true;
            Caption = 'Table';
            TableRelation = AllObj."Object ID" WHERE ("Object Type"=CONST(Table));

            trigger OnLookup()
            begin
                DataItemLookup();
            end;

            trigger OnValidate()
            var
                AllObj: Record AllObj;
            begin
                AllObj.Get(AllObj."Object Type"::Table,"Data Item Table");
            end;
        }
        field(12;"Data Item Name";Text[50])
        {
            Caption = 'Table Name';

            trigger OnLookup()
            begin
                DataItemLookup();
            end;

            trigger OnValidate()
            var
                DataItem: Record "RP Data Items";
            begin
                if "Data Item Name" = '' then begin
                  "Data Item Table" := 0;
                  exit;
                end;

                DataItem.SetRange(Code,"Template Code");
                DataItem.SetFilter(Name, '@' + "Data Item Name");
                if not DataItem.FindFirst then begin
                  DataItem.SetFilter(Name, '@' + "Data Item Name" + '*');
                  DataItem.FindFirst;
                end;
                "Data Item Name" := DataItem.Name;
                "Data Item Table" := DataItem."Table ID";
            end;
        }
        field(13;"Field";Integer)
        {
            Caption = 'Field';

            trigger OnLookup()
            var
                "fields": Record "Field";
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
        field(14;"Field Name";Text[50])
        {
            Caption = 'Field Name';

            trigger OnLookup()
            var
                DataItem: Record "RP Data Items";
                "Fields": Record "Field";
                TableFilter: Text;
            begin
                Fields.SetRange(TableNo, "Data Item Table");
                if PAGE.RunModal(PAGE::"Field Lookup",Fields) = ACTION::LookupOK then begin
                  Field        := Fields."No.";
                  "Field Name" := Fields.FieldName;
                end;
            end;

            trigger OnValidate()
            var
                DataItem: Record "RP Data Items";
                "Fields": Record "Field";
                TableFilter: Text;
            begin
                if "Field Name" = '' then begin
                  Field := 0;
                  exit;
                end;

                Fields.SetRange(TableNo, "Data Item Table");
                Fields.SetFilter(FieldName, '@' + "Field Name");
                if not Fields.FindFirst then begin
                  Fields.SetFilter(FieldName, '@' + "Field Name" + '*');
                  Fields.FindFirst;
                end;
                Field        := Fields."No.";
                "Field Name" := Fields.FieldName;
            end;
        }
        field(15;"Max Length";Integer)
        {
            BlankZero = true;
            Caption = 'Max Length';
        }
        field(17;Prefix;Text[30])
        {
            Caption = 'Prefix';
        }
        field(18;Postfix;Text[30])
        {
            Caption = 'Postfix';
        }
        field(21;Comments;Text[128])
        {
            Caption = 'Comments';
        }
        field(22;Align;Option)
        {
            Caption = 'Align';
            OptionCaption = 'Left,Center,Right';
            OptionMembers = Left,Center,Right;
        }
        field(23;Height;Integer)
        {
            BlankZero = true;
            Caption = 'Height';
        }
        field(25;Type;Option)
        {
            Caption = 'Type';
            OptionCaption = 'Data,Loop,Command,Logo,FieldCaption';
            OptionMembers = Data,Loop,Command,Logo,FieldCaption;
        }
        field(26;"Parent Line No.";Integer)
        {
            Caption = 'Parent Line No.';
        }
        field(27;Level;Integer)
        {
            Caption = 'Level';
            MaxValue = 10;

            trigger OnValidate()
            begin
                if Level <> xRec.Level then
                  FindParentLine();
            end;
        }
        field(30;Operator;Option)
        {
            Caption = 'Operator';
            OptionCaption = '+,-,/,*';
            OptionMembers = "+","-","/","*";
        }
        field(31;"Field 2";Integer)
        {
            Caption = 'Field 2';

            trigger OnLookup()
            var
                "fields": Record "Field";
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
        field(32;"Field 2 Name";Text[50])
        {
            Caption = 'Field 2 Name';

            trigger OnLookup()
            var
                DataItem: Record "RP Data Items";
                "Fields": Record "Field";
                TableFilter: Text;
            begin
                Fields.SetRange(TableNo, "Data Item Table");
                if PAGE.RunModal(PAGE::"Field Lookup",Fields) = ACTION::LookupOK then begin
                  "Field 2"      := Fields."No.";
                  "Field 2 Name" := Fields.FieldName;
                end;
            end;

            trigger OnValidate()
            var
                DataItem: Record "RP Data Items";
                "Fields": Record "Field";
                TableFilter: Text;
            begin
                if "Field 2 Name" = '' then begin
                  "Field 2" := 0;
                  exit;
                end;

                Fields.SetRange(TableNo, "Data Item Table");
                Fields.SetFilter(FieldName, '@' + "Field 2 Name");
                if not Fields.FindFirst then begin
                  Fields.SetFilter(FieldName,'@' + "Field 2 Name" + '*');
                  Fields.FindFirst;
                end;
                "Field 2"      := Fields."No.";
                "Field 2 Name" := Fields.FieldName;
            end;
        }
        field(35;"Processing Codeunit";Integer)
        {
            Caption = 'Processing Codeunit';
            TableRelation = AllObj."Object ID" WHERE ("Object Type"=CONST(Codeunit));

            trigger OnLookup()
            var
                tmpAllObj: Record AllObj temporary;
            begin
                OnBuildFunctionCodeunitList(tmpAllObj);
                if PAGE.RunModal(PAGE::"All Objects", tmpAllObj) = ACTION::LookupOK then
                  "Processing Codeunit" := tmpAllObj."Object ID";
            end;
        }
        field(36;"Processing Function ID";Code[30])
        {
            Caption = 'Processing Function ID';

            trigger OnLookup()
            var
                tmpRetailList: Record "Retail List" temporary;
            begin
                OnBuildFunctionList("Processing Codeunit", tmpRetailList);
                if PAGE.RunModal(0, tmpRetailList) = ACTION::LookupOK then
                  "Processing Function ID" := tmpRetailList.Choice;
            end;
        }
        field(37;"Processing Value";Text[250])
        {
            Caption = 'Proccesing Value';
        }
        field(40;"Start Char";Integer)
        {
            BlankZero = true;
            Caption = 'Start Char';
        }
        field(41;"Prefix Next Line";Boolean)
        {
            Caption = 'Prefix Next Line';
        }
        field(42;Attribute;Code[30])
        {
            Caption = 'Attribute';
            TableRelation = "NPR Attribute ID"."Attribute Code" WHERE ("Table ID"=FIELD("Data Item Table"));
        }
        field(44;"Root Record No.";Integer)
        {
            Caption = 'Root Record No.';
        }
        field(45;"Template Column No.";Integer)
        {
            BlankZero = true;
            Caption = 'Column No.';
        }
        field(46;Bold;Boolean)
        {
            Caption = 'Bold';
        }
        field(47;"Pad Char";Text[1])
        {
            Caption = 'Pad Char';
        }
        field(48;Underline;Boolean)
        {
            Caption = 'Underline';
        }
        field(49;"Blank Zero";Boolean)
        {
            Caption = 'Blank Zero';
        }
        field(50;"Skip If Empty";Boolean)
        {
            Caption = 'Skip If Empty';
        }
        field(51;"Default Value";Text[250])
        {
            Caption = 'Default Value';
        }
        field(52;"Default Value Record Required";Boolean)
        {
            Caption = 'Only Fill Default Value On Data';
        }
        field(60;"Data Item Record No.";Integer)
        {
            Caption = 'Data Item Record No.';
        }
        field(70;"Processing Function Parameter";Text[30])
        {
            Caption = 'Processing Function Parameter';
        }
    }

    keys
    {
        key(Key1;"Template Code","Line No.")
        {
        }
        key(Key2;"Template Code",Level,"Parent Line No.","Line No.")
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

    var
        PrinterInterface: Codeunit "RP Matrix Printer Interface";

    local procedure "// Locals"()
    begin
    end;

    procedure FindParentLine()
    var
        TemplateLine: Record "RP Template Line";
    begin
        TemplateLine.SetRange("Template Code", "Template Code");
        TemplateLine.SetFilter("Line No.", '<%1', "Line No.");
        TemplateLine.SetFilter(Level, '<%1', Level);
        if TemplateLine.FindLast then
          "Parent Line No." := TemplateLine."Line No."
        else
          "Parent Line No." := 0;
    end;

    local procedure ModifiedRec()
    var
        TemplateHeader: Record "RP Template Header";
    begin
        if IsTemporary then
          exit;
        if TemplateHeader.Get("Template Code") then
          TemplateHeader.Modify(true);
    end;

    local procedure DataItemLookup()
    var
        DataItem: Record "RP Data Items";
        TempRetailList: Record "Retail List" temporary;
        "Integer": Integer;
    begin
        DataItem.SetRange(Code,"Template Code");
        if DataItem.FindSet then repeat
          TempRetailList.Number += 1;
          TempRetailList.Choice := DataItem.Name;
          TempRetailList.Value := Format(DataItem."Table ID");
          TempRetailList.Insert;
        until DataItem.Next = 0;

        if PAGE.RunModal(PAGE::"Retail List",TempRetailList) = ACTION::LookupOK then begin
          Evaluate(Integer, TempRetailList.Value);
          Validate("Data Item Table", Integer);
          Validate("Data Item Name", TempRetailList.Choice);
        end;
    end;

    local procedure "// Event Publishers"()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBuildFunctionCodeunitList(var tmpAllObj: Record AllObj temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBuildFunctionList(CodeunitID: Integer;var tmpRetailList: Record "Retail List" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnFunction(CodeunitID: Integer;FunctionName: Text;var TemplateLine: Record "RP Template Line";RecID: RecordID;var Skip: Boolean;var Handled: Boolean)
    begin
    end;
}

