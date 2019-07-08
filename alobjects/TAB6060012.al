table 6060012 "GIM - Import Buffer Detail"
{
    Caption = 'GIM - Import Buffer Detail';
    LookupPageID = "GIM - Mapping";

    fields
    {
        field(1;"Entry No.";Integer)
        {
            Caption = 'Entry No.';
        }
        field(10;"Document No.";Code[20])
        {
            Caption = 'Document No.';
            TableRelation = "GIM - Import Document";
        }
        field(20;"Parsed Text";Text[250])
        {
            Caption = 'Parsed Text';

            trigger OnValidate()
            begin
                DataTypeValidation();
                DataMapper();
                UpdateImpDocStatus();
            end;
        }
        field(25;"Skip Column";Boolean)
        {
            Caption = 'Skip Column';
        }
        field(26;"Skip Row";Boolean)
        {
            Caption = 'Skip Row';
        }
        field(30;"Process Code";Code[10])
        {
            Caption = 'Process Code';
        }
        field(40;"Table ID";Integer)
        {
            Caption = 'Table ID';
            Editable = false;
        }
        field(41;"Table Caption";Text[250])
        {
            CalcFormula = Lookup(AllObjWithCaption."Object Caption" WHERE ("Object Type"=CONST(TableData),
                                                                           "Object ID"=FIELD("Table ID")));
            Caption = 'Table Caption';
            Editable = false;
            FieldClass = FlowField;
        }
        field(50;"Field ID";Integer)
        {
            Caption = 'Field ID';
        }
        field(51;"Field Caption";Text[250])
        {
            CalcFormula = Lookup(Field."Field Caption" WHERE (TableNo=FIELD("Table ID"),
                                                              "No."=FIELD("Field ID")));
            Caption = 'Field Caption';
            Editable = false;
            FieldClass = FlowField;
        }
        field(52;"Part of Primary Key";Boolean)
        {
            Caption = 'Part of Primary Key';
        }
        field(60;"Field Type";Text[30])
        {
            Caption = 'Field Type';
        }
        field(61;"Integer Value";Integer)
        {
            Caption = 'Integer Value';
        }
        field(62;"Decimal Value";Decimal)
        {
            Caption = 'Decimal Value';
        }
        field(63;"Date Value";Date)
        {
            Caption = 'Date Value';
        }
        field(64;"Time Value";Time)
        {
            Caption = 'Time Value';
        }
        field(65;"Datetime Value";DateTime)
        {
            Caption = 'Datetime Value';
        }
        field(66;"Boolean Value";Boolean)
        {
            Caption = 'Boolean Value';
        }
        field(67;"DateFormula Value";DateFormula)
        {
            Caption = 'DateFormula Value';
        }
        field(68;"Option Value";Text[250])
        {
            Caption = 'Option Value';
        }
        field(69;"Text Value";Text[250])
        {
            Caption = 'Text Value';
        }
        field(70;"Field Additional Info";Text[250])
        {
            Caption = 'Field Additional Info';
        }
        field(71;"Formatted Value";Text[250])
        {
            Caption = 'Formatted Value';
        }
        field(72;"Filter Value Type";Option)
        {
            Caption = 'Filter Value Type';
            OptionCaption = 'Const,Column,Specific';
            OptionMembers = "Const",Column,Specific;
        }
        field(73;"Filter Value";Text[250])
        {
            Caption = 'Filter Value';

            trigger OnLookup()
            var
                GIMMappingColumns: Page "GIM - Mapping Columns";
            begin
            end;
        }
        field(74;"Filter Column Value";Text[250])
        {
            Caption = 'Filter Column Value';
        }
        field(75;"Filter Specific Value";Text[250])
        {
            Caption = 'Filter Specific Value';
        }
        field(80;Level;Integer)
        {
            Caption = 'Level';
        }
        field(90;"Parent Entry No.";Integer)
        {
            Caption = 'Parent Entry No.';
        }
        field(100;"Column No.";Integer)
        {
            Caption = 'Column No.';
        }
        field(101;"Row No.";Integer)
        {
            Caption = 'Row No.';
        }
        field(110;"Failed Data Type Validation";Boolean)
        {
            Caption = 'Failed Data Type Validation';
        }
        field(120;"Failed Data Mapping";Boolean)
        {
            Caption = 'Failed Data Mapping';
        }
        field(130;"Failed Data Verification";Boolean)
        {
            Caption = 'Failed Data Verification';
        }
        field(140;"Failed Data Creation";Boolean)
        {
            Caption = 'Failed Data Creation';
        }
        field(150;"Fail Reason";Text[250])
        {
            Caption = 'Fail Reason';
        }
        field(160;"Value Type";Option)
        {
            Caption = 'Value Type';
            OptionCaption = 'Const,Column,Incremental,NoSeries,Specific';
            OptionMembers = "Const",Column,Incremental,NoSeries,Specific;
        }
        field(170;"Const Value";Text[250])
        {
            Caption = 'Const Value';
        }
        field(180;"Column ID";Integer)
        {
            Caption = 'Column ID';
        }
        field(190;"No. Series Code";Code[10])
        {
            Caption = 'No. Series Code';
        }
        field(191;"No. Series Code Rule";Option)
        {
            Caption = 'No. Series Code Rule';
            OptionCaption = 'Increment Per Row,Use same';
            OptionMembers = "Increment Per Row","Use same";
        }
        field(192;"No. Series Value";Code[20])
        {
            Caption = 'No. Series Value';
        }
        field(200;"Find Filter";Boolean)
        {
            Caption = 'Find Filter';
        }
        field(201;"Found Integer Value";Integer)
        {
            Caption = 'Found Integer Value';
        }
        field(202;"Found Decimal Value";Decimal)
        {
            Caption = 'Found Decimal Value';
        }
        field(203;"Found Date Value";Date)
        {
            Caption = 'Found Date Value';
        }
        field(204;"Found Time Value";Time)
        {
            Caption = 'Found Time Value';
        }
        field(205;"Found Datetime Value";DateTime)
        {
            Caption = 'Found Datetime Value';
        }
        field(206;"Found Boolean Value";Boolean)
        {
            Caption = 'Found Boolean Value';
        }
        field(207;"Found DateFormula Value";DateFormula)
        {
            Caption = 'Found DateFormula Value';
        }
        field(208;"Found Option Value";Text[250])
        {
            Caption = 'Found Option Value';
        }
        field(209;"Found Text";Text[250])
        {
            Caption = 'Found Text';
        }
        field(210;"Field Options";Text[250])
        {
            Caption = 'Field Options';
        }
        field(211;Found;Boolean)
        {
            Caption = 'Found';
        }
        field(212;"Prepare Imp. Entity";Option)
        {
            Caption = 'Prepare Imp. Entity';
            OptionCaption = ' ,Insert,Modify';
            OptionMembers = " ",Insert,Modify;
        }
        field(213;"Modify Value";Boolean)
        {
            Caption = 'Modify Value';
        }
        field(220;"Use Value";Boolean)
        {
            Caption = 'Use Value';
        }
        field(221;"Use on Table ID";Integer)
        {
            Caption = 'Use on Table ID';
        }
        field(222;"Use on Field ID";Integer)
        {
            Caption = 'Use on Field ID';
        }
        field(223;"Propagate To All Rows";Boolean)
        {
            Caption = 'Propagate To All Rows';
        }
        field(224;"Use on Mapping Table Line No.";Integer)
        {
            Caption = 'Use on Mapping Table Line No.';
        }
        field(230;"Validate Field";Boolean)
        {
            Caption = 'Validate Field';
        }
        field(240;"Apply Enrichment";Boolean)
        {
            Caption = 'Apply Enrichment';
        }
        field(250;"Automatically Created";Boolean)
        {
            Caption = 'Automatically Created';
        }
        field(251;"From Table ID";Integer)
        {
            Caption = 'From Table ID';
        }
        field(252;"From Field ID";Integer)
        {
            Caption = 'From Field ID';
        }
        field(260;"Duplicate Value";Boolean)
        {
            Caption = 'Duplicate Value';
        }
        field(270;Priority;Integer)
        {
            Caption = 'Priority';
        }
        field(280;"Buffer Indentation Level";Integer)
        {
            Caption = 'Buffer Indentation Level';
        }
        field(290;"Mapping Table Line No.";Integer)
        {
            Caption = 'Mapping Table Line No.';
        }
    }

    keys
    {
        key(Key1;"Entry No.")
        {
        }
        key(Key2;"Row No.")
        {
        }
    }

    fieldgroups
    {
    }

    var
        GIMImportEntity: Record "GIM - Mapping Table Line";
        GIMImportDocument: Record "GIM - Import Document";
        MappingTable: Record "GIM - Mapping Table";
        DataLengthExceeded: Label 'Maximum length of %1 exceeded.';
        VarInt: Integer;
        VarDec: Decimal;
        VarDate: Date;
        VarTime: Time;
        VarDateTime: DateTime;
        VarBool: Boolean;
        VarDateFormula: DateFormula;
        CantEvaluate: Label 'Can''t evaluate to %1.';
        MinValueError: Label 'Minimum value is %1.';
        MaxValueError: Label 'Maximum value is %1.';
        OptionError: Label 'Available options are %1.';
        GIMProcessFlow: Record "GIM - Process Flow";
        StageID: Integer;
        GIMProcessFlowNew: Record "GIM - Process Flow";
        DataTypeProperty: Record "GIM - Data Type Property";
        MappingTableLine: Record "GIM - Mapping Table Line";
        MappingTableField: Record "GIM - Mapping Table Field";
        Text001: Label 'No such option available.';
        Text002: Label 'Column No. %1 is not available.';
        MappingSetupErr: Label 'Error in mapping setup, column no. %1, table ID %2, field ID %3. You need to set %4 if the %5 is %6. ';
        DataExists: Label 'Data allready exists.';
        FldRef: FieldRef;
        DataDoesntExist: Label 'Data doesn''t exist.';
        NoSeriesMgt: Codeunit NoSeriesManagement;
        Text003: Label 'Table %1 must be one of the tables used in this import process.';
        MappingTableFieldSpec: Record "GIM - Mapping Table Field Spec";
        EmptyValueErr: Label 'Empty values are not allowed.';
        ImpEntity: Record "GIM - Import Entity";
        ErrLog: Record "GIM - Error Log";

    procedure InsertLines(DocNo: Code[20];ReadText: Text[250];ColumnNo: Integer;RowNo: Integer;LevelHere: Integer;ParentEntryNo: Integer)
    begin
        MappingTableField.Reset;
        MappingTableField.SetRange("Document No.",DocNo);
        MappingTableField.SetRange(Mapped,true);
        MappingTableField.SetRange("Column No.");
        if MappingTableField.FindSet then
          repeat
            if (MappingTableField."Column ID" = ColumnNo) or ((MappingTableField."Filter Value Type" = MappingTableField."Filter Value Type"::Column) and (MappingTableField."Filter Value" = Format(ColumnNo)))
               or (MappingTableField."Filter Value Type" = MappingTableField."Filter Value Type"::Specific) or (MappingTableField."Value Type" = MappingTableField."Value Type"::Specific) then
              InsertLine(DocNo,ReadText,ColumnNo,RowNo,false,MappingTableField,LevelHere,ParentEntryNo);
          until MappingTableField.Next = 0;
    end;

    procedure DataTypeValidation()
    var
        GIMImportBuffer: Record "GIM - Import Buffer Detail";
        PropertyValue: Text[250];
        TextToEvaluate: Text[250];
        MappingTableHere: Record "GIM - Mapping Table";
    begin
        //checking only if evaluation will pass
        "Failed Data Type Validation" := false;
        "Fail Reason" := '';

        TextToEvaluate := "Parsed Text";
        if "Parsed Text" = '' then
          case "Value Type" of
            "Value Type"::Const,"Value Type"::Specific: TextToEvaluate := "Const Value";
            "Value Type"::NoSeries: TextToEvaluate := "Parsed Text";
            "Value Type"::Incremental: TextToEvaluate := Format(0);
          end;

        "Formatted Value" := TextToEvaluate;
        "Integer Value" := 0;
        "Decimal Value" := 0;
        Evaluate("Date Value",'');
        Evaluate("Time Value",'');
        Evaluate("Datetime Value",'');
        "Boolean Value" := false;
        Evaluate("DateFormula Value",'');
        "Option Value" := '';

        case UpperCase("Field Type") of
          'TEXT','CODE':
            begin
              "Text Value" := TextToEvaluate;
            end;
          'INTEGER':
            if not Evaluate(VarInt,TextToEvaluate) then begin
              "Failed Data Type Validation" := true;
              "Fail Reason" := StrSubstNo(CantEvaluate,"Field Type");
            end else
              "Integer Value" := VarInt;
          'DECIMAL':
            if not Evaluate(VarDec,TextToEvaluate) then begin
              "Failed Data Type Validation" := true;
              "Fail Reason" := StrSubstNo(CantEvaluate,"Field Type");
            end else
              "Decimal Value" := VarDec;
          'DATE':
            if not Evaluate(VarDate,TextToEvaluate) then begin
              "Failed Data Type Validation" := true;
              "Fail Reason" := StrSubstNo(CantEvaluate,"Field Type");
            end else
              "Date Value" := VarDate;
          'TIME':
            if not Evaluate(VarTime,TextToEvaluate) then begin
              "Failed Data Type Validation" := true;
              "Fail Reason" := StrSubstNo(CantEvaluate,"Field Type");
            end else
              "Time Value" := VarTime;
          'DATETIME':
            if not Evaluate(VarDateTime,TextToEvaluate) then begin
              "Failed Data Type Validation" := true;
              "Fail Reason" := StrSubstNo(CantEvaluate,"Field Type");
            end else
              "Datetime Value" := VarDateTime;
          'BOOLEAN':
            if not Evaluate(VarBool,TextToEvaluate) then begin
              "Failed Data Type Validation" := true;
              "Fail Reason" := StrSubstNo(CantEvaluate,"Field Type");
            end else
              "Boolean Value" := VarBool;
          'DATEFormula':
            if not Evaluate(VarDateFormula,TextToEvaluate) then begin
              "Failed Data Type Validation" := true;
              "Fail Reason" := StrSubstNo(CantEvaluate,"Field Type");
            end else
              "DateFormula Value" := VarDateFormula;
           'OPTION':
             begin
             //options are checked in data mapping function
               "Option Value" := TextToEvaluate;
               PropertyValue := MappingTable.GetAttribute("Table ID","Field ID",'OptionString');
               "Integer Value" := GetIntegerFromOption(PropertyValue,TextToEvaluate);
               if ("Option Value" = '') and ("Integer Value" = -1) and "Find Filter" then
                 exit; //filtering values don't need to be validated
               if "Integer Value" = -1 then begin
                 "Failed Data Type Validation" := true;
                 "Fail Reason" := StrSubstNo(CantEvaluate,"Field Type");
               end;
             end;
        end;

        if "Failed Data Type Validation" then
          ErrLog.InsertLine(0,"Entry No.","Document No.",CurrentDateTime,CurrentDateTime,"Fail Reason",0,'','',"Table ID","Field ID","Mapping Table Line No.");
    end;

    procedure UpdateImpDocStatus()
    begin
        //if errors occur after manual import data change the lowest stage at which error occured must be starting point for process
        //continuation

        GIMImportDocument.Get("Document No.");
        if "Failed Data Type Validation" then begin
          StageID := 2;
          GIMImportDocument.Process := GIMImportDocument.Process::Error;
          GIMProcessFlow.Get(GIMImportDocument."Paused at Process Code");
          if StageID < GIMProcessFlow.Stage then begin
            GIMProcessFlowNew.SetRange(Stage,StageID);
            GIMProcessFlowNew.FindFirst;
            GIMImportDocument."Paused at Process Code" := GIMProcessFlowNew.Code;
          end;
          GIMImportDocument.Modify;
        end;

        if "Failed Data Mapping" then begin
          StageID := 3;
          GIMImportDocument.Process := GIMImportDocument.Process::Error;
          GIMProcessFlow.Get(GIMImportDocument."Paused at Process Code");
          if StageID < GIMProcessFlow.Stage then begin
            GIMProcessFlowNew.SetRange(Stage,StageID);
            GIMProcessFlowNew.FindFirst;
            GIMImportDocument."Paused at Process Code" := GIMProcessFlowNew.Code;
          end;
          GIMImportDocument.Modify;
        end;
    end;

    procedure DataMapper()
    var
        DataLength: Integer;
        MinValue: Integer;
        MaxValue: Integer;
        DecimalPlaces: Text[10];
        OptionString: Text[250];
        PropertyValue: Text[250];
        OptionValue: Text[30];
    begin
        //checking different field properties
        "Failed Data Mapping" := false;
        "Fail Reason" := '';
        case UpperCase("Field Type") of
          'TEXT','CODE':
            begin
              PropertyValue := MappingTable.GetAttribute("Table ID","Field ID",'DataLength');
              if PropertyValue <> '' then begin
                Evaluate(DataLength,PropertyValue);
                if StrLen("Parsed Text") > DataLength then begin
                  "Failed Data Mapping" := true;
                  "Fail Reason" := StrSubstNo(DataLengthExceeded,DataLength);
                end;
              end;
            end;
          'INTEGER':
            begin
              PropertyValue := MappingTable.GetAttribute("Table ID","Field ID",'MinValue');
              if PropertyValue <> '' then begin
                Evaluate(MinValue,PropertyValue);
                if "Integer Value" < MinValue then begin
                  "Failed Data Mapping" := true;
                  "Fail Reason" := StrSubstNo(MinValueError,MinValue);
                end;
              end;
              PropertyValue := MappingTable.GetAttribute("Table ID","Field ID",'MaxValue');
              if PropertyValue <> '' then begin
                Evaluate(MaxValue,PropertyValue);
                if "Integer Value" > MaxValue then begin
                  "Failed Data Mapping" := true;
                  if "Fail Reason" = '' then
                    "Fail Reason" := StrSubstNo(MaxValueError,MaxValue)
                  else
                    "Fail Reason" := "Fail Reason" + '; ' + StrSubstNo(MaxValueError,MaxValue);
                end;
              end;
            end;
          'DECIMAL':
            begin
              PropertyValue := MappingTable.GetAttribute("Table ID","Field ID",'MinValue');
              if PropertyValue <> '' then begin
                Evaluate(MinValue,PropertyValue);
                if "Decimal Value" < MinValue then begin
                  "Failed Data Mapping" := true;
                  "Fail Reason" := StrSubstNo(MinValueError,MinValue);
                end;
              end;
              PropertyValue := MappingTable.GetAttribute("Table ID","Field ID",'MaxValue');
              if PropertyValue <> '' then begin
                Evaluate(MaxValue,PropertyValue);
                if "Decimal Value" > MaxValue then begin
                  "Failed Data Mapping" := true;
                  if "Fail Reason" = '' then
                    "Fail Reason" := StrSubstNo(MaxValueError,MaxValue)
                  else
                    "Fail Reason" := "Fail Reason" + '; ' + StrSubstNo(MaxValueError,MaxValue);
                end;
              end;
            end;
          'OPTION':
            begin
              PropertyValue := UpperCase(MappingTable.GetAttribute("Table ID","Field ID",'OptionString'));
              if (PropertyValue <> '') and ("Option Value" <> '') then begin
                OptionValue := "Option Value";
                if StrPos(PropertyValue,UpperCase(OptionValue)) = 0 then begin
                  "Failed Data Mapping" := true;
                  "Fail Reason" := StrSubstNo(OptionError,PropertyValue);
                end;
              end;
            end;
        end;

        if "Failed Data Mapping" then
          ErrLog.InsertLine(0,"Entry No.","Document No.",CurrentDateTime,CurrentDateTime,"Fail Reason",0,'','',"Table ID","Field ID","Mapping Table Line No.");
    end;

    procedure DataVerification(MappingTableLineHere: Record "GIM - Mapping Table Line";CreateErrLog: Boolean)
    var
        RecRefHere: RecordRef;
        ImpBufferDetailHere: Record "GIM - Import Buffer Detail";
        LastRow: Integer;
        i: Integer;
    begin
        //running defined checks and fetching additional data
        ImpBufferDetailHere.SetCurrentKey("Row No.");
        ImpBufferDetailHere.SetRange("Document No.",MappingTableLineHere."Document No.");
        if ImpBufferDetailHere.FindLast then
          LastRow := ImpBufferDetailHere."Row No.";

        for i := 1 to LastRow do begin
          Reset;
          SetRange("Document No.",MappingTableLineHere."Document No.");
          SetRange("Skip Column",false);
          SetRange("Skip Row",false);
          SetRange("Row No.",i);
          SetRange("Mapping Table Line No.",MappingTableLineHere."Line No.");
          SetRange("Table ID",MappingTableLineHere."Table ID");
          SetRange("Duplicate Value",false);
          if FindSet then begin
            if MappingTableLineHere."Find Record" then begin
              RecRefHere.Open("Table ID");
              Clear(FldRef);
            end;
            repeat
              "Failed Data Verification" := false;
              "Fail Reason" := '';
              Found := false;
              "Prepare Imp. Entity" := "Prepare Imp. Entity"::" ";
              Modify;
              if "Find Filter" then begin
                FldRef := RecRefHere.Field("Field ID");
                FilterFieldRef2(Rec);
              end;
            until Next = 0;
            if MappingTableLineHere."Find Record" then begin
              if RecRefHere.FindFirst then begin
                case MappingTableLineHere."If Found" of
                  MappingTableLineHere."If Found"::Warn:
                    begin
                      FindSet;
                      repeat
                        "Failed Data Verification" := true;
                        "Fail Reason" := DataExists;
                        Modify;
                        if CreateErrLog then
                          ErrLog.InsertLine(0,"Entry No.","Document No.",CurrentDateTime,CurrentDateTime,"Fail Reason",0,'','',"Table ID","Field ID","Mapping Table Line No.");
                      until Next = 0;
                    end;
                  MappingTableLineHere."If Found"::"Use First":
                    begin
                      if FindSet then
                        repeat
                          FldRef := RecRefHere.Field("Field ID");
                          case UpperCase("Field Type") of
                            'TEXT','CODE':
                              "Found Text" := FldRef.Value;
                            'INTEGER':
                              "Found Integer Value" := FldRef.Value;
                            'DECIMAL':
                              "Found Decimal Value" := FldRef.Value;
                            'DATE':
                              "Found Date Value" := FldRef.Value;
                            'TIME':
                              "Found Time Value" := FldRef.Value;
                            'DATETIME':
                              "Found Datetime Value" := FldRef.Value;
                            'BOOLEAN':
                              "Found Boolean Value" := FldRef.Value;
                            'DATEFormula':
                              "Found DateFormula Value" := FldRef.Value;
                            'OPTION':
                              begin
                                "Found Integer Value" := GetIntegerFromOption("Field Options",Format(FldRef));
                                "Found Option Value" := FldRef.Value;
                                if "Found Integer Value" = -1 then begin
                                  "Failed Data Verification" := true;
                                  "Fail Reason" := StrSubstNo(CantEvaluate,"Field Type");
                                  Modify;
                                  if CreateErrLog then
                                    ErrLog.InsertLine(0,"Entry No.","Document No.",CurrentDateTime,CurrentDateTime,"Fail Reason",0,'','',"Table ID","Field ID","Mapping Table Line No.");
                                end;
                              end;
                          end;
                          if "Fail Reason" = '' then begin
                            "Formatted Value" := Format(FldRef);
                            Found := true;
                            if MappingTableLineHere."Data Action" in [MappingTableLineHere."Data Action"::Modify,MappingTableLineHere."Data Action"::"Modify or Insert"] then
                              "Prepare Imp. Entity" := "Prepare Imp. Entity"::Modify;
                            Modify;
                            if ("Use on Table ID" <> 0) and ("Use on Field ID" <> 0) then
                              UpdateAddLines(Rec);
                          end;
                        until Next = 0;
                    end;
                end
              end else begin
                case MappingTableLineHere."If Not Found" of
                  MappingTableLineHere."If Not Found"::" ":
                    begin
                      FindSet;
                      repeat

                      until Next = 0;
                    end;
                  MappingTableLineHere."If Not Found"::Warn:
                    begin
                      FindSet;
                      repeat
                        "Failed Data Verification" := true;
                        "Fail Reason" := DataDoesntExist;
                        Modify;
                        if CreateErrLog then
                          ErrLog.InsertLine(0,"Entry No.","Document No.",CurrentDateTime,CurrentDateTime,"Fail Reason",0,'','',"Table ID","Field ID","Mapping Table Line No.");
                      until Next = 0;
                    end;
                end;
                if MappingTableLineHere."Data Action" = MappingTableLineHere."Data Action"::"Modify or Insert" then begin
                  if FindSet then
                    repeat
                      "Prepare Imp. Entity" := "Prepare Imp. Entity"::Insert;
                      "No. Series Value" := NoSeriesValueMgt("Document No.",i,"No. Series Code","No. Series Code Rule");
                      if "Value Type" = "Value Type"::Incremental then
                        "Integer Value" := 10000 * i;
                      Modify;
                      if ("Use on Table ID" <> 0) and ("Use on Field ID" <> 0) then
                        UpdateAddLines(Rec);
                    until Next = 0;
                end;
              end;
              RecRefHere.Close;
            end;
            if MappingTableLineHere."Data Action" = MappingTableLineHere."Data Action"::Insert then begin
              if FindSet then
                repeat
                  "Prepare Imp. Entity" := "Prepare Imp. Entity"::Insert;
                  "No. Series Value" := NoSeriesValueMgt("Document No.",i,"No. Series Code","No. Series Code Rule");
                  if "Value Type" = "Value Type"::Incremental then
                    "Integer Value" := 10000 * i;
                  Modify;
                  if ("Use on Table ID" <> 0) and ("Use on Field ID" <> 0) then
                    UpdateAddLines(Rec);
                until Next = 0;
            end;
            SetFilter("Fail Reason",'<>%1','');
            if (Count = 0) and (MappingTableLineHere."Data Action" <> MappingTableLineHere."Data Action"::" ") then begin
              SetRange("Fail Reason");
              SetFilter("Prepare Imp. Entity",'>%1',0);
              if FindSet then
                repeat
                  PrepareImpEntity();
                until Next = 0;
            end;
          end;
        end;
    end;

    procedure InsertLine(DocNo: Code[20];ReadText: Text[250];ColumnNo: Integer;RowNo: Integer;SkipProcess: Boolean;MappingTableFieldHere: Record "GIM - Mapping Table Field";LevelHere: Integer;ParentEntryNo: Integer)
    var
        EntryNo: Integer;
        BufferTable: Record "GIM - Import Buffer Detail";
    begin
        if (MappingTableField."Value Type" = MappingTableField."Value Type"::Specific) or (MappingTableField."Filter Value Type" = MappingTableField."Filter Value Type"::Specific) then begin
          MappingTableFieldSpec.Reset;
          MappingTableFieldSpec.SetRange("Document No.",DocNo);
          MappingTableFieldSpec.SetRange("Doc. Type Code",MappingTableField."Doc. Type Code");
          MappingTableFieldSpec.SetRange("Sender ID",MappingTableField."Sender ID");
          MappingTableFieldSpec.SetRange("Version No.",MappingTableField."Version No.");
          MappingTableFieldSpec.SetRange("Mapping Table Line No.",MappingTableField."Mapping Table Line No.");
          MappingTableFieldSpec.SetRange("Field ID",MappingTableField."Field ID");
          MappingTableFieldSpec.SetRange("File Value",ReadText);
          if MappingTableFieldSpec.Count = 0 then
            exit;
        end;

        if BufferTable.FindLast then
          EntryNo := BufferTable."Entry No." + 1
        else
          EntryNo := 1;

        Init;
        "Entry No." := EntryNo;
        "Document No." := DocNo;
        "Parsed Text" := ReadText;
        if MappingTableFieldHere."Column ID" = 0 then
          "Parsed Text" := '';
        "Row No." := RowNo;
        "Skip Column" := SkipProcess;
        "Table ID" := MappingTableFieldHere."Table ID";
        "Field ID" := MappingTableFieldHere."Field ID";
        "Field Type" := MappingTableFieldHere."Field Type";
        "Field Additional Info" := MappingTableFieldHere."Field Additional Info";
        "Column No." := MappingTableFieldHere."Column No.";
        "Value Type" := MappingTableFieldHere."Value Type";
        "Const Value" := MappingTableFieldHere."Const Value";

        if (MappingTableField."Value Type" = MappingTableField."Value Type"::Specific) or (MappingTableField."Filter Value Type" = MappingTableField."Filter Value Type"::Specific) then begin
          if MappingTableFieldSpec.FindSet then
            repeat
              case MappingTableFieldSpec."Used For" of
                MappingTableFieldSpec."Used For"::Mapping: "Const Value" := MappingTableFieldSpec."Map To";
                MappingTableFieldSpec."Used For"::Filtering: "Filter Specific Value" := MappingTableFieldSpec."Map To";
              end;
            until MappingTableFieldSpec.Next = 0;
        end;

        "Column ID" := MappingTableFieldHere."Column ID";
        "No. Series Code" := MappingTableFieldHere."No. Series Code";
        "No. Series Code Rule" := MappingTableFieldHere."No. Series Code Rule";
        "Find Filter" := MappingTableFieldHere."Find Filter";
        "Use on Table ID" := MappingTableFieldHere."Use on Table ID";
        "Use on Field ID" := MappingTableFieldHere."Use on Field ID";
        "Use on Mapping Table Line No." := MappingTableFieldHere."Use on Mapping Table Line No.";
        "Field Options" := MappingTableFieldHere."Field Options";
        "Validate Field" := MappingTableFieldHere."Validate Field";
        "Part of Primary Key" := MappingTableFieldHere."Part of Primary Key";
        "Apply Enrichment" := MappingTableFieldHere."Apply Enrichment";
        "Automatically Created" := MappingTableFieldHere."Automatically Created";
        "From Table ID" := MappingTableFieldHere."From Table ID";
        "From Field ID" := MappingTableFieldHere."From Field ID";
        "Modify Value" := MappingTableFieldHere."Modify Value";
        Level := LevelHere;
        "Parent Entry No." := ParentEntryNo;
        "Propagate To All Rows" := MappingTableFieldHere."Propagate To All Rows";
        Priority := MappingTableFieldHere.Priority;
        "Buffer Indentation Level" := MappingTableFieldHere."Buffer Indentation Level";
        "Mapping Table Line No." := MappingTableFieldHere."Mapping Table Line No.";
        "Filter Value Type" := MappingTableFieldHere."Filter Value Type";
        "Filter Value" := MappingTableFieldHere."Filter Value";
        if "Filter Value Type" = "Filter Value Type"::Column then
          "Filter Column Value" := ReadText;
        Insert;
    end;

    local procedure FilterFieldRef(ImpBufferDetailHere: Record "GIM - Import Buffer Detail")
    begin
        case UpperCase(ImpBufferDetailHere."Field Type") of
          'TEXT','CODE':
            FldRef.SetRange(ImpBufferDetailHere."Text Value");
          'INTEGER','OPTION':
            FldRef.SetRange(ImpBufferDetailHere."Integer Value");
          'DECIMAL':
            FldRef.SetRange(ImpBufferDetailHere."Decimal Value");
          'DATE':
            FldRef.SetRange(ImpBufferDetailHere."Date Value");
          'TIME':
            FldRef.SetRange(ImpBufferDetailHere."Time Value");
          'DATETIME':
            FldRef.SetRange(ImpBufferDetailHere."Datetime Value");
          'BOOLEAN':
            FldRef.SetRange(ImpBufferDetailHere."Boolean Value");
          'DATEFormula':
            FldRef.SetRange(ImpBufferDetailHere."DateFormula Value");
        end;
    end;

    local procedure FilterFieldRef2(ImpBufferDetailHere: Record "GIM - Import Buffer Detail")
    var
        MapTableField: Record "GIM - Mapping Table Field";
        ImpDoc: Record "GIM - Import Document";
    begin
        with ImpBufferDetailHere do begin
          case "Filter Value Type" of
            "Filter Value Type"::Const: FldRef.SetFilter("Filter Value");
            "Filter Value Type"::Column: FldRef.SetFilter("Filter Column Value");
            "Filter Value Type"::Specific: FldRef.SetFilter("Filter Specific Value");
          end;
        end;
    end;

    procedure GetIntegerFromOption(OptionString: Text[250];TextToSearch: Text[250]): Integer
    var
        WorkingText: Text[250];
        OptionCount: Integer;
        Continue: Boolean;
    begin
        WorkingText := UpperCase(OptionString);
        TextToSearch := UpperCase(TextToSearch);
        OptionCount := -1;
        if StrPos(WorkingText,TextToSearch) = 0 then
          exit(OptionCount);
        while true do begin //just need a loop so be carefull if adding code in here to manage loop exits
          OptionCount += 1;
          if StrPos(WorkingText,TextToSearch) = 1 then
            exit(OptionCount)
          else begin
            if StrPos(WorkingText,',') = 0 then begin
              if StrPos(WorkingText,TextToSearch) <> 0 then
                exit(OptionCount)
              else
                exit(-1);
            end else if StrPos(CopyStr(WorkingText,1,StrPos(WorkingText,',') - 1),TextToSearch) <> 0 then begin
              if TextToSearch = ' ' then begin
                if StrLen(CopyStr(WorkingText,1,StrPos(WorkingText,',') - 1)) = 1 then
                  exit(OptionCount)
                else
                  WorkingText := CopyStr(WorkingText,StrPos(WorkingText,',') + 1);
              end else
                exit(OptionCount)
            end else
              WorkingText := CopyStr(WorkingText,StrPos(WorkingText,',') + 1);

            if WorkingText = '' then
              exit(OptionCount + 1);
          end;
        end;
    end;

    local procedure PrepareImpEntity()
    var
        RecRefHere: RecordRef;
        FldRefHere: FieldRef;
        ImpEntEntryNo: Integer;
        MaxRowNo: Integer;
        i: Integer;
        CurrentRowNo: Integer;
        ImpBufferDetail: Record "GIM - Import Buffer Detail";
    begin
        ImpEntity.SetRange("Document No.","Document No.");
        ImpEntity.SetRange("Row No.","Row No.");
        ImpEntity.SetRange("Mapping Table Line No.","Mapping Table Line No.");
        ImpEntity.SetRange("Field ID","Field ID");
        if ImpEntity.FindFirst then
          exit;

        ImpEntity.Reset;
        if ImpEntity.FindLast then
          ImpEntEntryNo := ImpEntity."Entry No." + 1
        else
          ImpEntEntryNo := 1;

        CurrentRowNo := "Row No.";
        MaxRowNo := CurrentRowNo;
        if "Propagate To All Rows" then begin
          ImpBufferDetail.SetCurrentKey("Row No.");
          ImpBufferDetail.SetRange("Document No.","Document No.");
          ImpBufferDetail.SetFilter("Row No.",'>%1',CurrentRowNo);
          ImpBufferDetail.SetRange("Mapping Table Line No.","Mapping Table Line No.");
          ImpBufferDetail.SetRange("Field ID","Field ID");
          if ImpBufferDetail.FindLast then
            MaxRowNo := ImpBufferDetail."Row No.";
        end;

        for i := CurrentRowNo to MaxRowNo do begin
          ImpEntity.Init;
          ImpEntity."Entry No." := ImpEntEntryNo;
          ImpEntity."Document No." := "Document No.";
          ImpEntity."Row No." := i;
          ImpEntity."Column No." := "Column No.";
          ImpEntity."Table ID" := "Table ID";
          ImpEntity."Field ID" := "Field ID";
          ImpEntity."Part of Primary Key" := "Part of Primary Key";
          ImpEntity."Data Type" := "Field Type";

          case UpperCase(ImpEntity."Data Type") of
            'TEXT','CODE':
              begin
                if "No. Series Value" <> '' then
                  ImpEntity."Text Value" := "No. Series Value"
                else if Found then
                  ImpEntity."Text Value" := "Found Text"
                else
                  ImpEntity."Text Value" := "Text Value";
                case "Prepare Imp. Entity" of
                  "Prepare Imp. Entity"::Insert:
                    begin
                      ImpEntity."Current Value" := '';
                      ImpEntity."New Value" := ImpEntity."Text Value";
                    end;
                  "Prepare Imp. Entity"::Modify:
                    begin
                      ImpEntity."Current Value" := "Found Text";
                      if "Modify Value" then
                        ImpEntity."New Value" := "Text Value"
                      else
                        ImpEntity."New Value" := "Found Text";
                    end;
                end;
              end;
            'INTEGER':
              begin
                if Found then
                  ImpEntity."Integer Value" := "Found Integer Value"
                else
                  ImpEntity."Integer Value" := "Integer Value";
                ImpEntity."New Value" := Format(ImpEntity."Integer Value");
                case "Prepare Imp. Entity" of
                  "Prepare Imp. Entity"::Insert:
                    begin
                      ImpEntity."Current Value" := '';
                      ImpEntity."New Value" := Format(ImpEntity."Integer Value");
                    end;
                  "Prepare Imp. Entity"::Modify:
                    begin
                      ImpEntity."Current Value" := Format("Found Integer Value");
                      if "Modify Value" then
                        ImpEntity."New Value" := Format("Integer Value")
                      else
                        ImpEntity."New Value" := Format("Found Integer Value");
                    end;
                end;
              end;
            'DECIMAL':
              begin
                if Found then
                  ImpEntity."Decimal Value" := "Found Decimal Value"
                else
                  ImpEntity."Decimal Value" := "Decimal Value";
                ImpEntity."New Value" := Format(ImpEntity."Decimal Value");
                case "Prepare Imp. Entity" of
                  "Prepare Imp. Entity"::Insert:
                    begin
                      ImpEntity."Current Value" := '';
                      ImpEntity."New Value" := Format(ImpEntity."Decimal Value");
                    end;
                  "Prepare Imp. Entity"::Modify:
                    begin
                      ImpEntity."Current Value" := Format("Found Decimal Value");
                      if "Modify Value" then
                        ImpEntity."New Value" := Format("Decimal Value")
                      else
                        ImpEntity."New Value" := Format("Found Decimal Value");
                    end;
                end;
              end;
            'DATE':
              begin
                if Found then
                  ImpEntity."Date Value" := "Found Date Value"
                else
                  ImpEntity."Date Value" := "Date Value";
                case "Prepare Imp. Entity" of
                  "Prepare Imp. Entity"::Insert:
                    begin
                      ImpEntity."Current Value" := '';
                      ImpEntity."New Value" := Format(ImpEntity."Date Value");
                    end;
                  "Prepare Imp. Entity"::Modify:
                    begin
                      ImpEntity."Current Value" := Format("Found Date Value");
                      if "Modify Value" then
                        ImpEntity."New Value" := Format("Date Value")
                      else
                        ImpEntity."New Value" := Format("Found Date Value");
                    end;
                end;
              end;
            'TIME':
              begin
                if Found then
                  ImpEntity."Time Value" := "Found Time Value"
                else
                  ImpEntity."Time Value" := "Time Value";
                case "Prepare Imp. Entity" of
                  "Prepare Imp. Entity"::Insert:
                    begin
                      ImpEntity."Current Value" := '';
                      ImpEntity."New Value" := Format(ImpEntity."Time Value");
                    end;
                  "Prepare Imp. Entity"::Modify:
                    begin
                      ImpEntity."Current Value" := Format("Found Time Value");
                      if "Modify Value" then
                        ImpEntity."New Value" := Format("Time Value")
                      else
                        ImpEntity."New Value" := Format("Found Time Value");
                    end;
                end;
              end;
            'DATETIME':
              begin
                if Found then
                  ImpEntity."Datetime Value" := "Found Datetime Value"
                else
                  ImpEntity."Datetime Value" := "Datetime Value";
                case "Prepare Imp. Entity" of
                  "Prepare Imp. Entity"::Insert:
                    begin
                      ImpEntity."Current Value" := '';
                      ImpEntity."New Value" := Format(ImpEntity."Datetime Value");
                    end;
                  "Prepare Imp. Entity"::Modify:
                    begin
                      ImpEntity."Current Value" := Format("Found Datetime Value");
                      if "Modify Value" then
                        ImpEntity."New Value" := Format("Datetime Value")
                      else
                        ImpEntity."New Value" := Format("Found Datetime Value");
                    end;
                end;
              end;
            'BOOLEAN':
              begin
                if Found then
                  ImpEntity."Boolean Value" := "Found Boolean Value"
                else
                  ImpEntity."Boolean Value" := "Boolean Value";
                case "Prepare Imp. Entity" of
                  "Prepare Imp. Entity"::Insert:
                    begin
                      ImpEntity."Current Value" := '';
                      ImpEntity."New Value" := Format(ImpEntity."Boolean Value");
                    end;
                  "Prepare Imp. Entity"::Modify:
                    begin
                      ImpEntity."Current Value" := Format("Found Boolean Value");
                      if "Modify Value" then
                        ImpEntity."New Value" := Format("Boolean Value")
                      else
                        ImpEntity."New Value" := Format("Found Boolean Value");
                    end;
                end;
              end;
            'DATEFormula':
              begin
                if Found then
                  ImpEntity."DateFormula Value" := "Found DateFormula Value"
                else
                  ImpEntity."DateFormula Value" := "DateFormula Value";
                case "Prepare Imp. Entity" of
                  "Prepare Imp. Entity"::Insert:
                    begin
                      ImpEntity."Current Value" := '';
                      ImpEntity."New Value" := Format(ImpEntity."DateFormula Value");
                    end;
                  "Prepare Imp. Entity"::Modify:
                    begin
                      ImpEntity."Current Value" := Format("Found DateFormula Value");
                      if "Modify Value" then
                        ImpEntity."New Value" := Format("DateFormula Value")
                      else
                        ImpEntity."New Value" := Format("Found DateFormula Value");
                    end;
                end;
              end;
            'OPTION':
              begin
                if Found then begin
                  ImpEntity."Option Value" := "Found Option Value";
                  ImpEntity."Integer Value" := "Found Integer Value";
                end else begin
                  ImpEntity."Option Value" := "Option Value";
                  ImpEntity."Integer Value" := "Integer Value";
                end;
                case "Prepare Imp. Entity" of
                  "Prepare Imp. Entity"::Insert:
                    begin
                      ImpEntity."Current Value" := '';
                      ImpEntity."New Value" := Format(ImpEntity."Option Value");
                    end;
                  "Prepare Imp. Entity"::Modify:
                    begin
                      ImpEntity."Current Value" := Format("Found Option Value");
                      if "Modify Value" then
                        ImpEntity."New Value" := Format("Option Value")
                      else
                        ImpEntity."New Value" := Format("Found Option Value");
                    end;
                end;
              end;
          end;
          ImpEntity."Validate Field" := "Validate Field";
          ImpEntity."Apply Enrichment" := "Apply Enrichment";
          ImpEntity."Entity Action" := "Prepare Imp. Entity";
          ImpEntity.Priority := Priority;
          ImpEntity."Buffer Indentation Level" := "Buffer Indentation Level";
          ImpEntity."Mapping Table Line No." := "Mapping Table Line No.";
          ImpEntity."Column ID" := "Column ID";
          ImpEntity.Insert;
          ImpEntEntryNo += 1;
        end;
    end;

    procedure UpdateAddLines(ImpBufferDetailHere: Record "GIM - Import Buffer Detail")
    var
        ImpBufferDetailLocal: Record "GIM - Import Buffer Detail";
        MapTableLineLocal: Record "GIM - Mapping Table Line";
    begin
        ImpBufferDetailLocal.SetRange("Document No.",ImpBufferDetailHere."Document No.");

        if not ImpBufferDetailHere."Propagate To All Rows" then
          ImpBufferDetailLocal.SetRange("Row No.",ImpBufferDetailHere."Row No.");
        if ImpBufferDetailHere."Use on Mapping Table Line No." = 0 then
          ImpBufferDetailLocal.SetRange("Table ID",ImpBufferDetailHere."Use on Table ID")
        else
          ImpBufferDetailLocal.SetRange("Mapping Table Line No.",ImpBufferDetailHere."Use on Mapping Table Line No.");
        ImpBufferDetailLocal.SetRange("Field ID",ImpBufferDetailHere."Use on Field ID");
        ImpBufferDetailLocal.SetRange("Automatically Created",true);
        if ImpBufferDetailLocal.FindSet then
          repeat
            if ImpBufferDetailHere.Found then begin
              ImpBufferDetailLocal.Found := ImpBufferDetailHere.Found;
              ImpBufferDetailLocal."Integer Value" := ImpBufferDetailHere."Found Integer Value";
              ImpBufferDetailLocal."Decimal Value" := ImpBufferDetailHere."Found Decimal Value";
              ImpBufferDetailLocal."Date Value" := ImpBufferDetailHere."Found Date Value";
              ImpBufferDetailLocal."Time Value" := ImpBufferDetailHere."Found Time Value";
              ImpBufferDetailLocal."Datetime Value" := ImpBufferDetailHere."Found Datetime Value";
              ImpBufferDetailLocal."Boolean Value" := ImpBufferDetailHere."Found Boolean Value";
              ImpBufferDetailLocal."DateFormula Value" := ImpBufferDetailHere."Found DateFormula Value";
              ImpBufferDetailLocal."Option Value" := ImpBufferDetailHere."Found Option Value";
              ImpBufferDetailLocal."Text Value" := ImpBufferDetailHere."Found Text";
              if ImpBufferDetailLocal."Find Filter" then
                ImpBufferDetailLocal."Filter Value" := ImpBufferDetailHere."Formatted Value";
            end else begin
              if ImpBufferDetailLocal."Find Filter" and (ImpBufferDetailLocal."Filter Value Type" = ImpBufferDetailLocal."Filter Value Type"::Const) and (ImpBufferDetailLocal."Filter Value" = '') then
                ImpBufferDetailLocal."Filter Value" := ImpBufferDetailHere."Const Value"; //this is used when validation values are used as filters on propagated lines
              ImpBufferDetailLocal."Const Value" := ImpBufferDetailHere."Const Value";
              ImpBufferDetailLocal."Column ID" := ImpBufferDetailHere."Column ID";
              ImpBufferDetailLocal."No. Series Code" := ImpBufferDetailHere."No. Series Code";
              ImpBufferDetailLocal."No. Series Code Rule" := ImpBufferDetailHere."No. Series Code Rule";
              ImpBufferDetailLocal."No. Series Value" := ImpBufferDetailHere."No. Series Value";
              if ImpBufferDetailLocal."Value Type" in [ImpBufferDetailLocal."Value Type"::Const,ImpBufferDetailLocal."Value Type"::Specific] then
                ImpBufferDetailLocal.DataTypeValidation();
            end;
            if ImpBufferDetailHere."Propagate To All Rows" then begin
              ImpBufferDetailLocal."Propagate To All Rows" := ImpBufferDetailHere."Propagate To All Rows";
              ImpBufferDetailLocal."Prepare Imp. Entity" := ImpBufferDetailHere."Prepare Imp. Entity";
            end;
            ImpBufferDetailLocal.Modify;
          until ImpBufferDetailLocal.Next = 0;
    end;

    procedure NoSeriesValueMgt(DocNo: Code[20];RowNo: Integer;NoSeriesCode: Code[10];NoSeriesRule: Integer) NoSeriesValue: Code[20]
    var
        BufferTable: Record "GIM - Import Buffer Detail";
        FirstAppearance: Boolean;
    begin
        if NoSeriesCode <> '' then begin
          BufferTable.SetRange("Document No.",DocNo);
          BufferTable.SetRange("No. Series Code",NoSeriesCode);
          BufferTable.SetFilter("No. Series Value",'<>%1','');
          FirstAppearance := not BufferTable.FindFirst;
          if FirstAppearance then
            NoSeriesValue := NoSeriesMgt.GetNextNo(NoSeriesCode,WorkDate,true)
          else
            case NoSeriesRule of
              0:
                begin
                  BufferTable.SetRange("Row No.",RowNo);
                  if BufferTable.FindFirst then
                    NoSeriesValue := BufferTable."No. Series Value"
                  else
                    NoSeriesValue := NoSeriesMgt.GetNextNo(NoSeriesCode,WorkDate,true);
                end;
              1:
                NoSeriesValue := BufferTable."No. Series Value";
            end;
        end;
    end;
}

