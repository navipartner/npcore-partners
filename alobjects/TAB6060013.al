table 6060013 "GIM - Mapping Table Field"
{
    Caption = 'GIM - Mapping Table Field';
    LookupPageID = "GIM - Mapping Table Fields";

    fields
    {
        field(1;"Document No.";Code[20])
        {
            Caption = 'Document No.';
        }
        field(2;"Column No.";Integer)
        {
            Caption = 'Column No.';
        }
        field(3;"Table ID";Integer)
        {
            Caption = 'Table ID';

            trigger OnLookup()
            var
                Objects: Page Objects;
                "Object": Record "Object";
            begin
            end;
        }
        field(4;"Field ID";Integer)
        {
            Caption = 'Field ID';

            trigger OnLookup()
            var
                GIMBufferFields: Page "GIM - Fields List";
            begin
                TableField.SetRange(TableNo,"Table ID");
                if "Field ID" <> 0 then begin
                  TableField.SetRange("No.","Field ID");
                  if TableField.FindFirst then
                    GIMBufferFields.SetRecord(TableField);
                  TableField.SetRange("No.");
                end;
                GIMBufferFields.SetTableView(TableField);
                GIMBufferFields.LookupMode(true);
                GIMBufferFields.Editable(false);
                if GIMBufferFields.RunModal = ACTION::LookupOK then begin
                  GIMBufferFields.GetRecord(TableField);
                  Validate("Field ID",TableField."No.");
                end;
            end;

            trigger OnValidate()
            begin
                TableField.Get("Table ID","Field ID");
                "Field Type" := Format(TableField.Type);
                "Field Additional Info" := '';

                "Part of Primary Key" := PartOfPrimaryKey("Table ID","Field ID");

                DataTypeProperty.SetRange("Data Type",UpperCase("Field Type"));
                if DataTypeProperty.FindSet then
                  repeat
                    AttrValue := MappingTable.GetAttribute("Table ID","Field ID",DataTypeProperty.Property);
                    if AttrValue <> '' then begin
                      if DataTypeProperty.Property = 'OptionString' then
                        "Field Options" := AttrValue;
                      if "Field Additional Info" = '' then begin
                        if StrLen(DataTypeProperty.Property) + 1 + StrLen(AttrValue) < MaxStrLen("Field Additional Info") then
                          "Field Additional Info" := DataTypeProperty.Property + ':' + AttrValue
                        else
                          "Field Additional Info" := CopyStr(DataTypeProperty.Property + ':' + AttrValue,1,MaxStrLen("Field Additional Info"));
                      end else begin
                        if 1 + StrLen(DataTypeProperty.Property) + 1 + StrLen(AttrValue) < MaxStrLen("Field Additional Info") then
                          "Field Additional Info" := ';' + DataTypeProperty.Property + ':' + AttrValue
                        else
                         "Field Additional Info" := CopyStr(';' + DataTypeProperty.Property + ':' + AttrValue,1,MaxStrLen("Field Additional Info"));
                      end;
                    end;
                  until DataTypeProperty.Next = 0;
            end;
        }
        field(10;"Field Caption";Text[250])
        {
            CalcFormula = Lookup(Field."Field Caption" WHERE (TableNo=FIELD("Table ID"),
                                                              "No."=FIELD("Field ID")));
            Caption = 'Field Caption';
            Editable = false;
            FieldClass = FlowField;
        }
        field(11;"Field Type";Text[30])
        {
            Caption = 'Field Type';
        }
        field(12;"Field Additional Info";Text[250])
        {
            Caption = 'Field Additional Info';
        }
        field(13;"Field Options";Text[250])
        {
            Caption = 'Field Options';
        }
        field(14;"Part of Primary Key";Boolean)
        {
            Caption = 'Part of Primary Key';
        }
        field(20;"Table Caption";Text[250])
        {
            CalcFormula = Lookup(AllObjWithCaption."Object Caption" WHERE ("Object Type"=CONST(Table),
                                                                           "Object ID"=FIELD("Table ID")));
            Caption = 'Table Caption';
            Editable = false;
            FieldClass = FlowField;
        }
        field(30;"Value Type";Option)
        {
            Caption = 'Value Type';
            OptionCaption = 'Const,Column,Incremental,NoSeries,Specific';
            OptionMembers = "Const",Column,Incremental,NoSeries,Specific;

            trigger OnValidate()
            begin
                "Formatted Value" := '';
                case "Value Type" of
                  "Value Type"::Const:
                    begin
                      "Column ID" := 0;
                      "No. Series Code" := '';
                      "Formatted Value" := "Const Value";
                      RemoveMapTableFieldSpec();
                    end;
                  "Value Type"::Column:
                    begin
                      "Const Value" := '';
                      "No. Series Code" := '';
                      "Formatted Value" := Format("Column ID");
                      RemoveMapTableFieldSpec();
                    end;
                  "Value Type"::Incremental:
                    begin
                      "Const Value" := '';
                      "No. Series Code" := '';
                      "Column ID" := 0;
                      RemoveMapTableFieldSpec();
                    end;
                  "Value Type"::NoSeries:
                    begin
                      "Const Value" := '';
                      "Column ID" := 0;
                      "Formatted Value" := "No. Series Code";
                      RemoveMapTableFieldSpec();
                    end;
                  "Value Type"::Specific:
                    begin
                      "Const Value" := '';
                      "No. Series Code" := '';
                      "Column ID" := 0;
                    end;
                end;

                if "Use on Field ID" <> 0 then
                  AutoFieldLinesMgt(0,"Use on Field ID","Use on Field ID",Rec)
            end;
        }
        field(40;"Const Value";Text[250])
        {
            Caption = 'Const Value';

            trigger OnValidate()
            begin
                if ("Field Type" = 'Option') and ("Const Value" <> '') then
                  if StrPos("Field Options","Const Value") = 0 then
                    Error(Text001,"Field Options");
            end;
        }
        field(50;"Column ID";Integer)
        {
            Caption = 'Column ID';

            trigger OnValidate()
            begin
                MappingTable.Reset;
                MappingTable.SetRange("Document No.","Document No.");
                MappingTable.SetRange("Skip Processing",false);
                MappingTable.SetRange("Column No.","Column ID");
                if not MappingTable.FindFirst then
                  Error(Text002,"Column ID");
            end;
        }
        field(60;"No. Series Code";Code[10])
        {
            Caption = 'No. Series Code';
            TableRelation = "No. Series";

            trigger OnValidate()
            begin
                ReplicateAndChangeStatus(FieldNo("No. Series Code"));
            end;
        }
        field(61;"No. Series Code Rule";Option)
        {
            Caption = 'No. Series Code Rule';
            OptionCaption = 'Increment Per Row,Use same';
            OptionMembers = "Increment Per Row","Use same";

            trigger OnValidate()
            begin
                ReplicateAndChangeStatus(FieldNo("No. Series Code Rule"));
            end;
        }
        field(70;"Find Filter";Boolean)
        {
            Caption = 'Find Filter';

            trigger OnValidate()
            begin
                if "Find Filter" then
                  Mapped := "Find Filter"
                else begin
                  if "Formatted Value" = '' then
                    Mapped := "Find Filter";
                  "Filter Value Type" := 0;
                  "Filter Value" := '';
                end;
                ReplicateAndChangeStatus(FieldNo("Find Filter"));
            end;
        }
        field(71;"Modify Value";Boolean)
        {
            Caption = 'Modify Value';

            trigger OnValidate()
            begin
                if "Part of Primary Key" then
                  Error(Text007);
                ReplicateAndChangeStatus(FieldNo("Modify Value"));
            end;
        }
        field(72;"Filter Value Type";Option)
        {
            Caption = 'Filter Value Type';
            OptionCaption = 'Const,Column,Specific';
            OptionMembers = "Const",Column,Specific;

            trigger OnValidate()
            begin
                if "Automatically Created" and ("Filter Value Type" <> "Filter Value Type"::Const) then
                  Error(Text009,FieldCaption("Filter Value Type"));
            end;
        }
        field(73;"Filter Value";Text[250])
        {
            Caption = 'Filter Value';

            trigger OnLookup()
            var
                GIMMappingColumns: Page "GIM - Mapping Columns";
            begin
                ImpDoc.Get("Document No.");
                FileFormat.Get(ImpDoc."File Extension");
                case "Filter Value Type" of
                  "Filter Value Type"::Column:
                    begin
                      MappingTable.Reset;
                      MappingTable.SetRange("Document No.","Document No.");
                      MappingTable.SetRange("Skip Processing",false);
                      GIMMappingColumns.SetTableView(MappingTable);
                      GIMMappingColumns.Editable(FileFormat."Value Lookup Editable");
                      GIMMappingColumns.LookupMode(true);
                      if GIMMappingColumns.RunModal = ACTION::LookupOK then begin
                        GIMMappingColumns.GetRecord(MappingTable);
                        Validate("Filter Value",Format(MappingTable."Column No."));
                      end;
                    end;
                  "Filter Value Type"::Specific:
                    begin
                      MappingTable.Reset;
                      MappingTable.SetRange("Document No.","Document No.");
                      MappingTable.SetRange("Skip Processing",false);
                      GIMMappingColumns.SetTableView(MappingTable);
                      GIMMappingColumns.Editable(false);
                      GIMMappingColumns.LookupMode(true);
                      if GIMMappingColumns.RunModal = ACTION::LookupOK then begin
                        GIMMappingColumns.GetRecord(MappingTable);
                        OpenMapSpecPage(MappingTable."Column No.",1);
                      end;
                    end;
                end;
            end;

            trigger OnValidate()
            var
                IntValue: Integer;
            begin
                if "Automatically Created" and ("Filter Value" <> '') then
                  Error(Text009,FieldCaption("Filter Value"));

                if ("Field Type" = 'Option') and ("Filter Value" <> '') then begin
                  IntValue := ImpBufferDetail.GetIntegerFromOption(UpperCase("Field Options"),UpperCase("Filter Value"));
                  if IntValue < 0 then
                    Error(Text001,"Field Options");
                  "Filter Value" := SelectStr(IntValue + 1,"Field Options");
                end;
            end;
        }
        field(80;"Use on Mapping Table Line No.";Integer)
        {
            Caption = 'Use on Mapping Table Line No.';
        }
        field(81;"Use on Table ID";Integer)
        {
            Caption = 'Use on Table ID';

            trigger OnLookup()
            var
                MappingLines: Page "GIM - Mapping Lines";
                MapTableLine: Record "GIM - Mapping Table Line";
            begin
                MapTableLine.SetRange("Document No.","Document No.");
                MappingLines.SetTableView(MapTableLine);
                MappingLines.Editable(false);
                MappingLines.LookupMode(true);
                if MappingLines.RunModal = ACTION::LookupOK then begin
                  MappingLines.GetRecord(MapTableLine);
                  Validate("Use on Field ID",0);
                  "Use on Mapping Table Line No." := MapTableLine."Line No.";
                  FromUseOnTableIDLookup := true;
                  Validate("Use on Table ID",MapTableLine."Table ID");
                end;
            end;

            trigger OnValidate()
            var
                MapTableLine: Record "GIM - Mapping Table Line";
                MappingLines: Page "GIM - Mapping Lines";
                UseOnMapTableLineNo: Integer;
            begin
                if "Use on Table ID" <> xRec."Use on Table ID" then begin
                  if "Use on Table ID" <> 0 then begin
                    if "Mapping Table Line No." <> 0 then
                      MapTableLine.Get("Document No.","Doc. Type Code","Sender ID","Version No.","Mapping Table Line No.");
                    MapTableLine.SetRange("Document No.","Document No.");
                    MapTableLine.SetRange("Table ID","Use on Table ID");
                    if MapTableLine.Count > 1 then begin
                      if GuiAllowed then begin
                        if FromUseOnTableIDLookup then begin
                          if Confirm(Text012) then
                            UseOnMapTableLineNo := 0
                          else
                            UseOnMapTableLineNo := "Use on Mapping Table Line No."
                        end else begin
                          if not Confirm(Text010) then
                            UseOnMapTableLineNo := 0
                          else begin
                            MappingLines.SetTableView(MapTableLine);
                            MappingLines.Editable(false);
                            MappingLines.LookupMode(true);
                            if MappingLines.RunModal = ACTION::LookupOK then begin
                              MappingLines.GetRecord(MapTableLine);
                              UseOnMapTableLineNo := MapTableLine."Line No.";
                            end;
                          end;
                        end;
                      end;
                    end else begin
                      if not MapTableLine.FindFirst then
                        Error(Text011,Format("Use on Table ID"));
                      UseOnMapTableLineNo := MapTableLine."Line No.";
                    end;
                  end;
                  ReplicateAndChangeStatus(FieldNo("Use on Table ID"));
                  Validate("Use on Field ID",0);
                  if "Use on Table ID" = 0 then
                    "Use on Mapping Table Line No." := 0
                  else
                    "Use on Mapping Table Line No." := UseOnMapTableLineNo;
                end;
                FromUseOnTableIDLookup := false;
            end;
        }
        field(82;"Use on Field ID";Integer)
        {
            Caption = 'Use on Field ID';

            trigger OnLookup()
            var
                GIMBufferFields: Page "GIM - Fields List";
            begin
                TableField.SetRange(TableNo,"Use on Table ID");
                if "Use on Field ID" <> 0 then begin
                  TableField.SetRange("No.","Use on Field ID");
                  if TableField.FindFirst then
                    GIMBufferFields.SetRecord(TableField);
                  TableField.SetRange("No.");
                end;
                GIMBufferFields.SetTableView(TableField);
                GIMBufferFields.LookupMode(true);
                GIMBufferFields.Editable(false);
                if GIMBufferFields.RunModal = ACTION::LookupOK then begin
                  GIMBufferFields.GetRecord(TableField);
                  Validate("Use on Field ID",TableField."No.");
                end;
            end;

            trigger OnValidate()
            begin
                if ("Use on Table ID" <> 0) and ("Use on Field ID" <> 0) then begin
                  TableField.Get("Use on Table ID","Use on Field ID");
                  if UpperCase(Format(TableField.Type)) <> UpperCase("Field Type") then
                    Error(Text003);
                end;
                ReplicateAndChangeStatus(FieldNo("Use on Field ID"));

                if "Use on Field ID" <> 0 then
                  AutoFieldLinesMgt(0,xRec."Use on Field ID","Use on Field ID",Rec)
                else
                  AutoFieldLinesMgt(1,xRec."Use on Field ID",xRec."Use on Field ID",Rec);
            end;
        }
        field(83;"Propagate To All Rows";Boolean)
        {
            Caption = 'Propagate To All Rows';
        }
        field(90;"Validate Field";Boolean)
        {
            Caption = 'Validate Field';

            trigger OnValidate()
            begin
                ReplicateAndChangeStatus(FieldNo("Validate Field"));
            end;
        }
        field(100;"Apply Enrichment";Boolean)
        {
            Caption = 'Apply Enrichment';

            trigger OnValidate()
            begin
                ReplicateAndChangeStatus(FieldNo("Apply Enrichment"));
            end;
        }
        field(110;"Formatted Value";Text[250])
        {
            Caption = 'Formatted Value';

            trigger OnLookup()
            var
                NoSeriesList: Page "No. Series";
                NoSeries: Record "No. Series";
                GIMMappingColumns: Page "GIM - Mapping Columns";
            begin
                ImpDoc.Get("Document No.");
                FileFormat.Get(ImpDoc."File Extension");
                case "Value Type" of
                  "Value Type"::Column:
                    begin
                      MappingTable.Reset;
                      MappingTable.SetRange("Document No.","Document No.");
                      MappingTable.SetRange("Skip Processing",false);
                      GIMMappingColumns.SetTableView(MappingTable);
                      GIMMappingColumns.Editable(FileFormat."Value Lookup Editable");
                      GIMMappingColumns.LookupMode(true);
                      if GIMMappingColumns.RunModal = ACTION::LookupOK then begin
                        GIMMappingColumns.GetRecord(MappingTable);
                        Validate("Formatted Value",Format(MappingTable."Column No."));
                      end;
                    end;
                  "Value Type"::NoSeries:
                    begin
                      NoSeriesList.LookupMode(true);
                      if NoSeriesList.RunModal = ACTION::LookupOK then begin
                        NoSeriesList.GetRecord(NoSeries);
                        Validate("Formatted Value",NoSeries.Code);
                      end;
                    end;
                  "Value Type"::Specific:
                    begin
                      MappingTable.Reset;
                      MappingTable.SetRange("Document No.","Document No.");
                      MappingTable.SetRange("Skip Processing",false);
                      GIMMappingColumns.SetTableView(MappingTable);
                      GIMMappingColumns.Editable(false);
                      GIMMappingColumns.LookupMode(true);
                      if GIMMappingColumns.RunModal = ACTION::LookupOK then begin
                        GIMMappingColumns.GetRecord(MappingTable);
                        OpenMapSpecPage(MappingTable."Column No.",0);
                      end;
                    end;
                end;
            end;

            trigger OnValidate()
            var
                ColumnID: Integer;
            begin
                case "Value Type" of
                  "Value Type"::Const:
                    begin
                      if "Field Type" = 'Option' then begin
                        ColumnID := ImpBufferDetail.GetIntegerFromOption(UpperCase("Field Options"),UpperCase("Formatted Value"));
                        if ColumnID < 0 then
                          Validate("Const Value","Formatted Value")
                        else begin
                          "Formatted Value" := SelectStr(ColumnID + 1,"Field Options");
                          Validate("Const Value","Formatted Value");
                        end;
                      end else
                        Validate("Const Value","Formatted Value");
                    end;
                  "Value Type"::Column:
                    begin
                      Evaluate(ColumnID,"Formatted Value");
                      Validate("Column ID",ColumnID);
                    end;
                  "Value Type"::Incremental,"Value Type"::Specific:
                    if "Formatted Value" <> '' then
                      Error(Text004,FieldCaption("Value Type"),Format("Value Type"));
                  "Value Type"::NoSeries:
                    Validate("No. Series Code","Formatted Value");
                end;

                if "Use on Field ID" <> 0 then
                  AutoFieldLinesMgt(0,"Use on Field ID","Use on Field ID",Rec)
            end;
        }
        field(120;"Automatically Created";Boolean)
        {
            Caption = 'Automatically Created';
            Description = 'When row is created by Use on Field ID code';
        }
        field(121;"From Table ID";Integer)
        {
            Caption = 'From Table ID';
        }
        field(122;"From Field ID";Integer)
        {
            Caption = 'From Field ID';
        }
        field(123;"From Table Caption";Text[250])
        {
            CalcFormula = Lookup(AllObjWithCaption."Object Caption" WHERE ("Object Type"=CONST(Table),
                                                                           "Object ID"=FIELD("From Table ID")));
            Caption = 'From Table Caption';
            Editable = false;
            FieldClass = FlowField;
        }
        field(124;"From Field Caption";Text[250])
        {
            CalcFormula = Lookup(Field."Field Caption" WHERE (TableNo=FIELD("From Table ID"),
                                                              "No."=FIELD("From Field ID")));
            Caption = 'From Field Caption';
            Editable = false;
            FieldClass = FlowField;
        }
        field(130;Mapped;Boolean)
        {
            Caption = 'Mapped';

            trigger OnValidate()
            begin
                if Mapped <> xRec.Mapped then
                  if not Mapped and "Find Filter" then begin
                    if not Confirm(Text008) then
                      Error('');
                    "Filter Value Type" := 0;
                    "Filter Value" := '';
                  end;
            end;
        }
        field(140;Priority;Integer)
        {
            Caption = 'Priority';
        }
        field(150;"Buffer Indentation Level";Integer)
        {
            Caption = 'Buffer Indentation Level';
        }
        field(160;"Doc. Type Code";Code[10])
        {
            Caption = 'Doc. Type Code';
        }
        field(170;"Sender ID";Code[20])
        {
            Caption = 'Sender ID';
        }
        field(180;"Version No.";Integer)
        {
            Caption = 'Version No.';
        }
        field(190;"Mapping Table Line No.";Integer)
        {
            Caption = 'Mapping Table Line No.';
        }
    }

    keys
    {
        key(Key1;"Document No.","Doc. Type Code","Sender ID","Version No.","Mapping Table Line No.","Field ID")
        {
        }
        key(Key2;"Column ID")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        if "Document No." <> '' then
          ChangeStatus(DocType.FieldNo("Data Type Validator"));
        DeleteBufferData("Document No.");
        RemoveMapTableFieldSpec();
        if ("Use on Table ID" <> 0) or ("Use on Field ID" <> 0) then
          AutoFieldLinesMgt(1,"Field ID","Field ID",Rec);
    end;

    trigger OnInsert()
    begin
        ChangeStatus(DocType.FieldNo("Data Type Validator"));
        DeleteBufferData("Document No.");
        TableField.Get("Table ID","Field ID");
    end;

    trigger OnModify()
    begin
        ChangeStatus(DocType.FieldNo("Data Type Validator"));
        DeleteBufferData("Document No.");
    end;

    var
        TableField: Record "Field";
        DataTypeProperty: Record "GIM - Data Type Property";
        AttrValue: Text[250];
        MappingTable: Record "GIM - Mapping Table";
        Text001: Label 'Available options are: %1.';
        Text002: Label 'Column No. %1 is not available.';
        AllObjWithCaption: Record AllObjWithCaption;
        "Object": Record "Object";
        DocType: Record "GIM - Document Type";
        Text003: Label 'Field must be of same type.';
        ImpBufferDetail: Record "GIM - Import Buffer Detail";
        Text004: Label 'You can''t enter values when %1 is %2.';
        MapTableField: Record "GIM - Mapping Table Field";
        Text005: Label 'You can''t propagate values from this row as other rows are allready propagating here.';
        Text006: Label 'You can''t include propagated values in a filter.';
        Text007: Label 'Field is part of primary key and renaming is not supported. If you want to change this value delete the data and then create it through the import process or set mapping differently.';
        Text008: Label 'This field is part of the filtering setup. If you unmap it, filter setup will be changed. Do you want to continue?';
        ImpDoc: Record "GIM - Import Document";
        FileFormat: Record "GIM - Supported Data Format";
        Text009: Label 'You can''t change %1 since it will receive filtering results from other mapping table that is propagating it''s values.';
        Text010: Label 'There are multiple mapping table lines with this Table ID. Would you like to choose to which line would you propagate this value?';
        Text011: Label 'Table %1 is not part of mapping table setup and you first need to add it in order to be able to replicate values to it.';
        FromUseOnTableIDLookup: Boolean;
        Text012: Label 'Selected mapping table line Table ID is used multiple times. Would you rather use it on all occurences of this Table ID?';

    procedure ReplicateAndChangeStatus(FieldNumber: Integer)
    begin
        //influences data verification
        Replicate(FieldNumber);
        ChangeStatus(DocType.FieldNo("Data Verification"));
    end;

    procedure Replicate(FieldNumber: Integer)
    var
        ImpBufferDetailHere: Record "GIM - Import Buffer Detail";
    begin
        ImpBufferDetailHere.SetRange("Document No.","Document No.");
        ImpBufferDetailHere.SetRange("Mapping Table Line No.","Mapping Table Line No.");
        ImpBufferDetailHere.SetRange("Field ID","Field ID");
        case FieldNumber of
          FieldNo("No. Series Code"): ImpBufferDetailHere.ModifyAll("No. Series Code","No. Series Code");
          FieldNo("No. Series Code Rule"): ImpBufferDetailHere.ModifyAll("No. Series Code Rule","No. Series Code Rule");
          FieldNo("Find Filter"): ImpBufferDetailHere.ModifyAll("Find Filter","Find Filter");
          FieldNo("Use on Table ID"): ImpBufferDetailHere.ModifyAll("Use on Table ID","Use on Table ID");
          FieldNo("Use on Field ID"): ImpBufferDetailHere.ModifyAll("Use on Field ID","Use on Field ID");
          FieldNo("Validate Field"): ImpBufferDetailHere.ModifyAll("Validate Field","Validate Field");
          FieldNo("Apply Enrichment"): ImpBufferDetailHere.ModifyAll("Apply Enrichment","Apply Enrichment");
          FieldNo("Modify Value"): ImpBufferDetailHere.ModifyAll("Modify Value","Modify Value");
        end;
    end;

    procedure ChangeStatus(FieldNumber: Integer)
    var
        ImpDocument: Record "GIM - Import Document";
        ProcessFlow: Record "GIM - Process Flow";
        ProcessFlowCurrent: Record "GIM - Process Flow";
    begin
        ImpDocument.Get("Document No.");
        ProcessFlowCurrent.Get(ImpDocument."Paused at Process Code");

        ProcessFlow.SetRange("Doc. Type Field ID",FieldNumber);
        ProcessFlow.FindFirst;

        if ProcessFlowCurrent.Stage >= ProcessFlow.Stage then begin
          ImpDocument.Process := ImpDocument.Process::Error;
          ImpDocument."Paused at Process Code" := ProcessFlow.Code;
          ImpDocument.Modify;
        end;
    end;

    procedure PartOfPrimaryKey(TableID: Integer;FieldID: Integer) IsPart: Boolean
    var
        RecRef: RecordRef;
        PrimaryKeyRef: KeyRef;
        FldRef: FieldRef;
        i: Integer;
    begin
        IsPart := false;
        RecRef.Open(TableID);
        PrimaryKeyRef := RecRef.KeyIndex(1);
        for i := 1 to PrimaryKeyRef.FieldCount do begin
          FldRef := PrimaryKeyRef.FieldIndex(i);
          if not IsPart then
            IsPart := FldRef.Number = FieldID;
        end;
        exit(IsPart);
    end;

    procedure RemoveMapTableFieldSpec()
    var
        MapTableFieldSpecHere: Record "GIM - Mapping Table Field Spec";
    begin
        MapTableFieldSpecHere.SetRange("Document No.","Document No.");
        MapTableFieldSpecHere.SetRange("Doc. Type Code","Doc. Type Code");
        MapTableFieldSpecHere.SetRange("Sender ID","Sender ID");
        MapTableFieldSpecHere.SetRange("Version No.","Version No.");
        MapTableFieldSpecHere.SetRange("Mapping Table Line No.","Mapping Table Line No.");
        MapTableFieldSpecHere.SetRange("Field ID","Field ID");
        MapTableFieldSpecHere.DeleteAll;
    end;

    procedure AutoFieldLinesMgt("Action": Option Update,Reset;OldFieldID: Integer;NewFieldID: Integer;MapFieldHere: Record "GIM - Mapping Table Field")
    var
        MapTableFieldHere: Record "GIM - Mapping Table Field";
        MapTableLine: Record "GIM - Mapping Table Line";
    begin
        case Action of
          Action::Update:
            begin
              ResetAutoMapTableField(OldFieldID,MapFieldHere);
              CreateAutoFieldLine(NewFieldID,MapFieldHere);
            end;
          Action::Reset: ResetAutoMapTableField(OldFieldID,MapFieldHere);
        end;
    end;

    procedure CreateAutoFieldLine(FieldIDHere: Integer;MapField: Record "GIM - Mapping Table Field")
    var
        MapTableFieldHere: Record "GIM - Mapping Table Field";
        MapTableLineHere: Record "GIM - Mapping Table Line";
    begin
        MapTableFieldHere.SetRange("Document No.",MapField."Document No.");
        MapTableFieldHere.SetRange("Doc. Type Code",MapField."Doc. Type Code");
        MapTableFieldHere.SetRange("Sender ID",MapField."Sender ID");
        MapTableFieldHere.SetRange("Version No.",MapField."Version No.");
        if MapField."Use on Mapping Table Line No." = 0 then
          MapTableFieldHere.SetRange("Table ID",MapField."Use on Table ID")
        else
          MapTableFieldHere.SetRange("Mapping Table Line No.",MapField."Use on Mapping Table Line No.");
        MapTableFieldHere.SetRange("Field ID",FieldIDHere);
        if MapTableFieldHere.FindSet then
          repeat
            MapTableFieldHere."Value Type" := MapField."Value Type";
            MapTableFieldHere."Const Value" := MapField."Const Value";
            MapTableFieldHere."Column ID" := MapField."Column ID";
            MapTableFieldHere."No. Series Code" := MapField."No. Series Code";
            MapTableFieldHere."No. Series Code Rule" := MapField."No. Series Code Rule";
            MapTableFieldHere."Formatted Value" := MapField."Formatted Value";
            MapTableFieldHere."Automatically Created" := true;
            MapTableFieldHere."From Table ID" := MapField."Table ID";
            MapTableFieldHere."From Field ID" := MapField."Field ID";
            MapTableFieldHere.Mapped := true;
            MapTableFieldHere.Modify(true);
          until MapTableFieldHere.Next = 0;
    end;

    procedure DeleteBufferData(DocNo: Code[20])
    var
        ImportBuffer: Record "GIM - Import Buffer";
        ImportBufferDetailHere: Record "GIM - Import Buffer Detail";
        ImportEntityHere: Record "GIM - Import Entity";
    begin
        ImportBuffer.SetRange("Document No.",DocNo);
        ImportBuffer.DeleteAll;

        ImportBufferDetailHere.SetRange("Document No.",DocNo);
        ImportBufferDetailHere.DeleteAll;

        ImportEntityHere.SetRange("Document No.",DocNo);
        ImportEntityHere.DeleteAll;
    end;

    procedure InsertLine(MapTableLineHere: Record "GIM - Mapping Table Line";FieldID: Integer)
    begin
        Init;
        "Document No." := MapTableLineHere."Document No.";
        "Doc. Type Code" := MapTableLineHere."Doc. Type Code";
        "Sender ID" := MapTableLineHere."Sender ID";
        "Version No." := MapTableLineHere."Version No.";
        "Mapping Table Line No." := MapTableLineHere."Line No.";
        "Table ID" := MapTableLineHere."Table ID";
        Validate("Field ID",FieldID);
        Priority := MapTableLineHere.Priority;
        "Buffer Indentation Level" := MapTableLineHere."Buffer Indentation Level";
        Insert;
    end;

    local procedure ResetAutoMapTableField(OldFieldID: Integer;MapFieldHere: Record "GIM - Mapping Table Field")
    var
        MapTableFieldHere: Record "GIM - Mapping Table Field";
    begin
        MapTableFieldHere.SetRange("Document No.",MapFieldHere."Document No.");
        MapTableFieldHere.SetRange("Doc. Type Code",MapFieldHere."Doc. Type Code");
        MapTableFieldHere.SetRange("Sender ID",MapFieldHere."Sender ID");
        MapTableFieldHere.SetRange("Version No.",MapFieldHere."Version No.");
        if MapFieldHere."Use on Mapping Table Line No." = 0 then
          MapTableFieldHere.SetRange("Table ID",MapFieldHere."Use on Table ID")
        else
          MapTableFieldHere.SetRange("Mapping Table Line No.",MapFieldHere."Use on Mapping Table Line No.");
        MapTableFieldHere.SetRange("Field ID",OldFieldID);
        MapTableFieldHere.SetRange("Automatically Created",true);
        if MapTableFieldHere.FindSet then
          repeat
            MapTableFieldHere."Value Type" := 0;
            MapTableFieldHere."Const Value" := '';
            MapTableFieldHere."Column ID" := 0;
            MapTableFieldHere."No. Series Code" := '';
            MapTableFieldHere."No. Series Code Rule" := 0;
            MapTableFieldHere."Formatted Value" := '';
            MapTableFieldHere."Automatically Created" := false;
            MapTableFieldHere.Mapped := false;
            MapTableFieldHere."From Table ID" := 0;
            MapTableFieldHere."From Field ID" := 0;
            MapTableFieldHere.Modify;
          until MapTableFieldHere.Next = 0;
    end;

    procedure OpenMapSpecPage(ColumnNo: Integer;UsedFor: Integer)
    var
        MapSpec: Record "GIM - Mapping Table Field Spec";
        MapSpecList: Page "GIM - Mapping Table Field Spec";
        MapTableField: Record "GIM - Mapping Table Field";
    begin
        MapSpec.SetRange("Document No.","Document No.");
        MapSpec.SetRange("Doc. Type Code","Doc. Type Code");
        MapSpec.SetRange("Sender ID","Sender ID");
        MapSpec.SetRange("Version No.","Version No.");
        MapSpec.SetRange("Mapping Table Line No.","Mapping Table Line No.");
        MapSpec.SetRange("Field ID","Field ID");
        MapSpec.SetRange("Column No.",ColumnNo);
        MapSpec.SetFilter("Map To",'<>%1','');
        if not MapSpec.FindFirst then
          MapSpec.AddLine(Rec,ColumnNo,UsedFor);
        MapSpec.SetRange("Map To");
        MapSpecList.SetTableView(MapSpec);
        MapSpecList.Run;
    end;
}

