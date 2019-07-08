table 6060003 "GIM - Mapping Table Line"
{
    // NPR5.46/BHR /20180824  CASE 322752 Replace record Object to Allobj

    Caption = 'GIM - Mapping Table Line';
    LookupPageID = "GIM - Mapping Lines";

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
                AllObjects: Page "All Objects";
                AllObj: Record AllObj;
            begin
                //-NPR5.46[322752]
                // Object.SETRANGE(Type,Object.Type::TableData);
                // Objects.SETTABLEVIEW(Object);
                // Objects.EDITABLE(FALSE);
                // Objects.LOOKUPMODE(TRUE);
                // IF Objects.RUNMODAL = ACTION::LookupOK THEN BEGIN
                //  Objects.GETRECORD(Object);
                //  "Table ID" := Object.ID;
                // END;

                AllObj.SetRange("Object Type",AllObj."Object Type"::TableData);
                AllObjects.SetTableView(AllObj);
                AllObjects.Editable(false);
                AllObjects.LookupMode(true);
                if AllObjects.RunModal = ACTION::LookupOK then begin
                  AllObjects.GetRecord(AllObj);
                  "Table ID" := AllObj."Object ID";
                end;
                //+NPR5.46[322752]
            end;

            trigger OnValidate()
            begin
                if "Table ID" <> xRec."Table ID" then begin
                  AllObjWithCaption.Get(AllObjWithCaption."Object Type"::TableData,"Table ID");
                  if "Line No." <> 0 then begin
                    DeleteMapTableField();
                    PrepareFields();
                  end;
                end;
            end;
        }
        field(10;"Table Caption";Text[250])
        {
            CalcFormula = Lookup(AllObjWithCaption."Object Caption" WHERE ("Object Type"=CONST(TableData),
                                                                           "Object ID"=FIELD("Table ID")));
            Caption = 'Table Caption';
            Editable = false;
            FieldClass = FlowField;
        }
        field(20;Priority;Integer)
        {
            Caption = 'Priority';

            trigger OnValidate()
            begin
                if Priority <> xRec.Priority then
                  UpdateMapTableField();
            end;
        }
        field(30;"Find Record";Boolean)
        {
            Caption = 'Find Record';
        }
        field(31;"If Found";Option)
        {
            Caption = 'If Found';
            OptionCaption = ' ,Warn,Use First';
            OptionMembers = " ",Warn,"Use First";

            trigger OnValidate()
            begin
                if "If Found" <> "If Found"::" " then
                  TestField("Find Record");
            end;
        }
        field(32;"If Not Found";Option)
        {
            Caption = 'If Not Found';
            OptionCaption = ' ,Warn';
            OptionMembers = " ",Warn;

            trigger OnValidate()
            begin
                if "If Not Found" <> "If Not Found"::" " then
                  TestField("Find Record");
            end;
        }
        field(40;"Data Action";Option)
        {
            Caption = 'Data Action';
            OptionCaption = ' ,Insert,Modify,Modify or Insert';
            OptionMembers = " ",Insert,Modify,"Modify or Insert";

            trigger OnValidate()
            begin
                if "Data Action" in ["Data Action"::Modify,"Data Action"::"Modify or Insert"] then
                  TestField("Find Record");
            end;
        }
        field(50;"Look for Existant Data";Boolean)
        {
            Caption = 'Look for Existant Data';

            trigger OnValidate()
            begin
                if "Look for Existant Data" then begin
                  MappTableLine.SetRange("Document No.","Document No.");
                  MappTableLine.SetFilter("Column No.",'<>%1',"Column No.");
                  MappTableLine.SetFilter("Table ID",'<>%1',"Table ID");
                  MappTableLine.SetRange("Look for Existant Data","Look for Existant Data");
                  if MappTableLine.FindFirst then
                    Error(Text001,MappTableLine."Column No.",MappTableLine."Table ID");
                end;
            end;
        }
        field(60;"Buffer Indentation Level";Integer)
        {
            Caption = 'Buffer Indentation Level';

            trigger OnValidate()
            begin
                if "Buffer Indentation Level" <> xRec."Buffer Indentation Level" then
                  UpdateMapTableField();
            end;
        }
        field(70;"Column Name";Text[50])
        {
            Caption = 'Column Name';
        }
        field(80;"Doc. Type Code";Code[10])
        {
            Caption = 'Doc. Type Code';
        }
        field(90;"Sender ID";Code[20])
        {
            Caption = 'Sender ID';
        }
        field(100;"Version No.";Integer)
        {
            Caption = 'Version No.';
        }
        field(110;"Line No.";Integer)
        {
            Caption = 'Line No.';
        }
        field(120;Note;Text[250])
        {
            Caption = 'Note';
        }
    }

    keys
    {
        key(Key1;"Document No.","Doc. Type Code","Sender ID","Version No.","Line No.")
        {
        }
        key(Key2;Priority)
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        DeleteMapTableField();
    end;

    trigger OnInsert()
    begin
        PrepareFields();

        MappingTableField.Reset;
        MappingTableField.SetRange("Document No.","Document No.");

        MappingTableField.SetRange("Doc. Type Code","Doc. Type Code");
        MappingTableField.SetRange("Sender ID","Sender ID");
        MappingTableField.SetRange("Version No.","Version No.");
        MappingTableField.SetRange("Use on Table ID","Table ID");
        if MappingTableField.FindSet then
          repeat
            MappingTableField.AutoFieldLinesMgt(0,MappingTableField."Field ID",MappingTableField."Field ID",MappingTableField);
          until MappingTableField.Next = 0;
    end;

    var
        AllObjWithCaption: Record AllObjWithCaption;
        MappingTableField: Record "GIM - Mapping Table Field";
        MappTableLine: Record "GIM - Mapping Table Line";
        Text001: Label 'You can''t monitor for existant data on more column/tables. Column %1, Table ID %2 allready has this setup.';
        Text002: Label 'You can''t define mapping table for a column no. 0.';
        MappingTable: Record "GIM - Mapping Table";
        MapTableFieldSpec: Record "GIM - Mapping Table Field Spec";
        Text003: Label 'Current mapping differs from mapping defined in template or there is no template for this document type. Do you want to save current mapping as template?';
        Text004: Label 'Update template with changes,Create new template version';
        Text005: Label 'Selecting other version will delete current mapping and copy new mapping from selected version. Do you want to continue?';
        Text006: Label 'Mapping is allready fully/partially defined. Do you want to delete it and start over?';
        DocTypeVersion: Record "GIM - Document Type Version";
        MappingTableField2: Record "GIM - Mapping Table Field";
        MapTableFieldSpec2: Record "GIM - Mapping Table Field Spec";
        MappTableLine2: Record "GIM - Mapping Table Line";
        Text007: Label 'You can only select version from import document.';

    procedure ShowFields()
    var
        GIMTableField: Record "GIM - Mapping Table Field";
    begin
        GIMTableField.SetRange("Document No.","Document No.");
        GIMTableField.SetRange("Doc. Type Code","Doc. Type Code");
        GIMTableField.SetRange("Sender ID","Sender ID");
        GIMTableField.SetRange("Version No.","Version No.");
        GIMTableField.SetRange("Mapping Table Line No.","Line No.");
        PAGE.Run(0,GIMTableField);
    end;

    local procedure UpdateMapTableField()
    begin
        MappingTableField.Reset;
        MappingTableField.SetRange("Document No.","Document No.");
        MappingTableField.SetRange("Doc. Type Code","Doc. Type Code");
        MappingTableField.SetRange("Sender ID","Sender ID");
        MappingTableField.SetRange("Version No.","Version No.");
        MappingTableField.SetRange("Mapping Table Line No.","Line No.");
        if MappingTableField.FindSet then
          repeat
            if Priority <> xRec.Priority then
              MappingTableField.Priority := Priority;
            if "Buffer Indentation Level" <> xRec."Buffer Indentation Level" then
              MappingTableField."Buffer Indentation Level" := "Buffer Indentation Level";
            MappingTableField.Modify(true);
          until MappingTableField.Next = 0;
    end;

    procedure ChangeIndentationLevel(IncreaseHere: Boolean)
    var
        SignLocal: Integer;
    begin
        SignLocal := 1;
        if not IncreaseHere then
          SignLocal := -1;

        "Buffer Indentation Level" += SignLocal * 1;
        Modify;

        MappingTableField.Reset;
        MappingTableField.SetRange("Document No.","Document No.");
        MappingTableField.SetRange("Doc. Type Code","Doc. Type Code");
        MappingTableField.SetRange("Sender ID","Sender ID");
        MappingTableField.SetRange("Version No.","Version No.");
        MappingTableField.SetRange("Mapping Table Line No.","Line No.");
        MappingTableField.ModifyAll("Buffer Indentation Level","Buffer Indentation Level",true);
    end;

    procedure ResetMapping()
    var
        MappingTableLine: Record "GIM - Mapping Table Line";
        GIMParser: Codeunit "GIM - Parser";
        ImportDoc: Record "GIM - Import Document";
    begin
        ImportDoc.Get("Document No.");
        MappingTableLine.SetRange("Document No.","Document No.");
        if MappingTableLine.Count <> 0 then
          if not Confirm(Text006) then
            exit
          else
            MappingTableLine.DeleteAll(true);

        GIMParser.ParseFile(ImportDoc,true,0,0,0);
    end;

    procedure SaveAsNewTemplateVersion()
    var
        LastVersionNo: Integer;
        MapTableLineTemp: Record "GIM - Mapping Table Line" temporary;
        MapTableFieldTemp: Record "GIM - Mapping Table Field" temporary;
        MapTableFieldSpecTemp: Record "GIM - Mapping Table Field Spec" temporary;
    begin
        DocTypeVersion.SetRange(Code,"Doc. Type Code");
        DocTypeVersion.SetRange("Sender ID","Sender ID");
        if DocTypeVersion.FindLast then
          LastVersionNo := DocTypeVersion."Version No.";

        DocTypeVersion.Init;
        DocTypeVersion.Code := "Doc. Type Code";
        DocTypeVersion."Sender ID" := "Sender ID";
        DocTypeVersion."Version No." := LastVersionNo + 1;
        DocTypeVersion.Insert;

        MappTableLine.Reset;
        MappTableLine.SetRange("Document No.","Document No.");
        MappTableLine.SetRange("Doc. Type Code","Doc. Type Code");
        MappTableLine.SetRange("Sender ID","Sender ID");
        MappTableLine.SetRange("Version No.","Version No.");
        if MappTableLine.FindSet then
          repeat
            MapTableLineTemp.Init;
            MapTableLineTemp := MappTableLine;
            MapTableLineTemp.Insert;

            MappingTableField.Reset;
            MappingTableField.SetRange("Document No.",MappTableLine."Document No.");
            MappingTableField.SetRange("Doc. Type Code",MappTableLine."Doc. Type Code");
            MappingTableField.SetRange("Sender ID",MappTableLine."Sender ID");
            MappingTableField.SetRange("Version No.",MappTableLine."Version No.");
            MappingTableField.SetRange("Mapping Table Line No.",MappTableLine."Line No.");
            if MappingTableField.FindSet then
              repeat
                MapTableFieldTemp.Init;
                MapTableFieldTemp := MappingTableField;
                MapTableFieldTemp.Insert;

                MapTableFieldSpec.SetRange("Document No.",MappTableLine."Document No.");
                MapTableFieldSpec.SetRange("Doc. Type Code",MappTableLine."Doc. Type Code");
                MapTableFieldSpec.SetRange("Sender ID",MappTableLine."Sender ID");
                MapTableFieldSpec.SetRange("Version No.",MappTableLine."Version No.");
                MapTableFieldSpec.SetRange("Mapping Table Line No.",MappTableLine."Line No.");
                MapTableFieldSpec.SetRange("Field ID",MappingTableField."Field ID");
                if MapTableFieldSpec.FindSet then
                  repeat
                    MapTableFieldSpecTemp.Init;
                    MapTableFieldSpecTemp := MapTableFieldSpec;
                    MapTableFieldSpecTemp.Insert;
                  until MapTableFieldSpec.Next = 0;
              until MappingTableField.Next = 0;
          until MappTableLine.Next = 0;

        if MapTableLineTemp.FindSet then begin
          MappTableLine.DeleteAll(true);
          repeat
        //one set of records is uset for current document no. in which we update version no.
            MappTableLine.Init;
            MappTableLine := MapTableLineTemp;
            MappTableLine."Version No." := DocTypeVersion."Version No.";
            MappTableLine.Insert;

        //other set of records is used to store same version but without a document no. so it can serve as a template
            MappTableLine.Init;
            MappTableLine := MapTableLineTemp;
            MappTableLine."Document No." := '';
            MappTableLine."Version No." := DocTypeVersion."Version No.";
            MappTableLine.Insert;
          until MapTableLineTemp.Next = 0;

        if MapTableFieldTemp.FindSet then
          repeat
            MappingTableField.Init;
            MappingTableField := MapTableFieldTemp;
            MappingTableField."Version No." := DocTypeVersion."Version No.";
            MappingTableField.Insert;
            MappingTableField.Init;
            MappingTableField := MapTableFieldTemp;
            MappingTableField."Document No." := '';
            MappingTableField."Version No." := DocTypeVersion."Version No.";
            MappingTableField.Insert;
          until MapTableFieldTemp.Next = 0;

        if MapTableFieldSpecTemp.FindSet then
          repeat
            MapTableFieldSpec.Init;
            MapTableFieldSpec := MapTableFieldSpecTemp;
            MapTableFieldSpec."Version No." := DocTypeVersion."Version No.";
            MapTableFieldSpec.Insert;
            MapTableFieldSpec.Init;
            MapTableFieldSpec := MapTableFieldSpecTemp;
            MapTableFieldSpec."Document No." := '';
            MapTableFieldSpec."Version No." := DocTypeVersion."Version No.";
            MapTableFieldSpec.Insert;
          until MapTableFieldSpecTemp.Next = 0;
        end;
    end;

    procedure ModifyTemplate()
    begin
        //first everything from template is deleted as that way we don't need to figure out if anything from template needs to be deleted or inserted when compared to current version
        MappTableLine2.Reset;
        MappTableLine2.SetRange("Document No.",'');
        MappTableLine2.SetRange("Doc. Type Code","Doc. Type Code");
        MappTableLine2.SetRange("Sender ID","Sender ID");
        MappTableLine2.SetRange("Version No.","Version No.");
        MappTableLine2.DeleteAll(true);

        MappTableLine2.SetRange("Document No.","Document No.");
        if MappTableLine2.FindSet then
          repeat
            MappTableLine.Init;
            MappTableLine := MappTableLine2;
            MappTableLine."Document No." := '';
            MappTableLine.Insert;

            MappingTableField2.SetRange("Document No.",MappTableLine2."Document No.");
            MappingTableField2.SetRange("Doc. Type Code",MappTableLine2."Doc. Type Code");
            MappingTableField2.SetRange("Sender ID",MappTableLine2."Sender ID");
            MappingTableField2.SetRange("Version No.",MappTableLine2."Version No.");
            MappingTableField2.SetRange("Mapping Table Line No.",MappTableLine2."Line No.");
            if MappingTableField2.FindSet then
              repeat
                MappingTableField.Init;
                MappingTableField := MappingTableField2;
                MappingTableField."Document No." := '';
                MappingTableField.Insert;

                MapTableFieldSpec2.SetRange("Document No.",MappingTableField2."Document No.");
                MapTableFieldSpec2.SetRange("Doc. Type Code",MappingTableField2."Doc. Type Code");
                MapTableFieldSpec2.SetRange("Sender ID",MappingTableField2."Sender ID");
                MapTableFieldSpec2.SetRange("Version No.",MappingTableField2."Version No.");
                MapTableFieldSpec2.SetRange("Mapping Table Line No.",MappingTableField2."Mapping Table Line No.");
                MapTableFieldSpec2.SetRange("Field ID",MappingTableField2."Field ID");
                if MapTableFieldSpec2.FindSet then
                  repeat
                    MapTableFieldSpec.Init;
                    MapTableFieldSpec := MapTableFieldSpec2;
                    MapTableFieldSpec."Document No." := '';
                    MapTableFieldSpec.Insert;
                  until MapTableFieldSpec2.Next = 0;
              until MappingTableField2.Next = 0;
          until MappTableLine2.Next = 0;
    end;

    procedure CompareVersionWithTemplate(): Boolean
    var
        CountHere: Integer;
        RecRefHere: RecordRef;
        RecRefHere2: RecordRef;
    begin
        MappTableLine.Reset;
        MappTableLine.SetRange("Document No.",'');
        MappTableLine.SetRange("Doc. Type Code","Doc. Type Code");
        MappTableLine.SetRange("Sender ID","Sender ID");
        MappTableLine.SetRange("Version No.","Version No.");
        CountHere := MappTableLine.Count;
        MappTableLine2.Reset;
        MappTableLine2.CopyFilters(MappTableLine);
        MappTableLine2.SetRange("Document No.","Document No.");
        if MappTableLine2.Count <> CountHere then
          exit(true);
        if CountHere <> 0 then begin
          MappTableLine.FindSet;
          MappTableLine2.FindSet;
          repeat
            RecRefHere.GetTable(MappTableLine);
            RecRefHere2.GetTable(MappTableLine2);
            if CompareFieldValues(RecRefHere,RecRefHere2) then
              exit(true);
            Clear(RecRefHere);
            Clear(RecRefHere2);
          until (MappTableLine.Next = 0) and (MappTableLine2.Next = 0);
        end;

        MappingTableField.Reset;
        MappingTableField.SetRange("Document No.",'');
        MappingTableField.SetRange("Doc. Type Code","Doc. Type Code");
        MappingTableField.SetRange("Sender ID","Sender ID");
        MappingTableField.SetRange("Version No.","Version No.");
        CountHere := MappingTableField.Count;
        MappingTableField2.Reset;
        MappingTableField2.CopyFilters(MappingTableField);
        MappingTableField2.SetRange("Document No.","Document No.");
        if MappingTableField.Count <> CountHere then
          exit(true);
        if CountHere <> 0 then begin
          MappingTableField.FindSet;
          MappingTableField2.FindSet;
          repeat
            RecRefHere.GetTable(MappingTableField);
            RecRefHere2.GetTable(MappingTableField2);
            if CompareFieldValues(RecRefHere,RecRefHere2) then
              exit(true);
            Clear(RecRefHere);
            Clear(RecRefHere2);
          until (MappingTableField.Next = 0) and (MappingTableField2.Next = 0);
        end;

        MapTableFieldSpec.Reset;
        MapTableFieldSpec.SetRange("Document No.",'');
        MapTableFieldSpec.SetRange("Doc. Type Code","Doc. Type Code");
        MapTableFieldSpec.SetRange("Sender ID","Sender ID");
        MapTableFieldSpec.SetRange("Version No.","Version No.");
        CountHere := MapTableFieldSpec.Count;
        MapTableFieldSpec2.Reset;
        MapTableFieldSpec2.CopyFilters(MapTableFieldSpec);
        MapTableFieldSpec2.SetRange("Document No.","Document No.");
        if MapTableFieldSpec2.Count <> CountHere then
          exit(true);
        if CountHere <> 0 then begin
          MapTableFieldSpec.FindSet;
          MapTableFieldSpec2.FindSet;
          repeat
            RecRefHere.GetTable(MapTableFieldSpec);
            RecRefHere2.GetTable(MapTableFieldSpec2);
            if CompareFieldValues(RecRefHere,RecRefHere2) then
              exit(true);
            Clear(RecRefHere);
            Clear(RecRefHere2);
          until (MapTableFieldSpec.Next = 0) and (MapTableFieldSpec2.Next = 0);
        end;
    end;

    local procedure CompareFieldValues(RecRefHere: RecordRef;RecRefHere2: RecordRef): Boolean
    var
        FldRefHere: FieldRef;
        FldRefHere2: FieldRef;
        i: Integer;
        KeyRefHere: KeyRef;
        PartOfPrimaryKey: Boolean;
        KeyRefField: FieldRef;
        j: Integer;
    begin
        KeyRefHere := RecRefHere.KeyIndex(1);
        for i := 1 to RecRefHere.FieldCount do begin
          FldRefHere := RecRefHere.FieldIndex(i);
          FldRefHere2 := RecRefHere2.FieldIndex(i);
          PartOfPrimaryKey := false;
          j := 0;
          repeat
            j += 1;
            KeyRefField := KeyRefHere.FieldIndex(j);
            PartOfPrimaryKey := KeyRefField.Number = FldRefHere.Number;
          until (j = KeyRefHere.FieldCount) or PartOfPrimaryKey;
          if not PartOfPrimaryKey and (UpperCase(Format(FldRefHere.Type)) <> 'BLOB') and (UpperCase(Format(FldRefHere.Class)) = 'NORMAL') then
            if FldRefHere.Value <> FldRefHere2.Value then
              exit(true);
        end;
        exit(false);
    end;

    procedure CheckVersionAndPrompt()
    begin
        if CompareVersionWithTemplate() then begin
          if not Confirm(Text003) then
            exit;
          case StrMenu(Text004) of
            1: ModifyTemplate();
            2: SaveAsNewTemplateVersion();
          end;
        end;
    end;

    local procedure PrepareFields()
    var
        GIMTableField: Record "GIM - Mapping Table Field";
        GIMTableField2: Record "GIM - Mapping Table Field";
        RecRef: RecordRef;
        FldRef: FieldRef;
        i: Integer;
    begin
        GIMTableField.SetRange("Document No.","Document No.");
        GIMTableField.SetRange("Doc. Type Code","Doc. Type Code");
        GIMTableField.SetRange("Sender ID","Sender ID");
        GIMTableField.SetRange("Version No.","Version No.");
        GIMTableField.SetRange("Mapping Table Line No.","Line No.");
        if GIMTableField.Count = 0 then begin
          RecRef.Open("Table ID");
          for i := 1 to RecRef.FieldCount do begin
            FldRef := RecRef.FieldIndex(i);
            if (UpperCase(Format(FldRef.Type)) <> 'BLOB') and (UpperCase(Format(FldRef.Class)) = 'NORMAL') then begin
              GIMTableField.InsertLine(Rec,FldRef.Number);
              GIMTableField2.SetRange("Document No.","Document No.");
              GIMTableField2.SetRange("Doc. Type Code","Doc. Type Code");
              GIMTableField2.SetRange("Sender ID","Sender ID");
              GIMTableField2.SetRange("Version No.","Version No.");
              GIMTableField2.SetRange("Use on Table ID","Table ID");
              GIMTableField2.SetRange("Use on Field ID",FldRef.Number);
              if GIMTableField2.FindFirst then begin
                GIMTableField."Value Type" := GIMTableField2."Value Type";
                GIMTableField."Const Value" := GIMTableField2."Const Value";
                GIMTableField."Column ID" := GIMTableField2."Column ID";
                GIMTableField."No. Series Code" := GIMTableField2."No. Series Code";
                GIMTableField."No. Series Code Rule" := GIMTableField2."No. Series Code Rule";
                GIMTableField."Formatted Value" := GIMTableField2."Formatted Value";
                GIMTableField."Automatically Created" := true;
                GIMTableField.Mapped := true;
                GIMTableField.Modify;
              end;
            end;
          end;
          RecRef.Close();
        end;
    end;

    local procedure DeleteMapTableField()
    begin
        MappingTableField.SetRange("Document No.","Document No.");
        MappingTableField.SetRange("Doc. Type Code","Doc. Type Code");
        MappingTableField.SetRange("Sender ID","Sender ID");
        MappingTableField.SetRange("Version No.","Version No.");
        MappingTableField.SetRange("Mapping Table Line No.","Line No.");
        MappingTableField.DeleteAll(true);
    end;

    procedure SelectVersion(Manual: Boolean;DocNo: Code[20];DocTypeCode: Code[10];SenderID: Code[20];OldVersionNo: Integer)
    var
        DocTypeVersions: Page "GIM - Document Type Versions";
        GotVersion: Boolean;
    begin
        if DocNo = '' then
          Error(Text007);

        if Manual then begin
          if not Confirm(Text005) then
            exit;

          DocTypeVersion.Reset;
          DocTypeVersion.SetRange(Code,DocTypeCode);
          DocTypeVersion.SetRange("Sender ID",SenderID);
          DocTypeVersions.SetTableView(DocTypeVersion);
          DocTypeVersions.LookupMode(true);
          DocTypeVersions.Editable(false);
          if DocTypeVersions.RunModal = ACTION::LookupOK then begin
            DocTypeVersions.GetRecord(DocTypeVersion);
            GotVersion := true;
          end;
        end else begin
          DocTypeVersion.SetRange(Code,DocTypeCode);
          DocTypeVersion.SetRange("Sender ID",SenderID);
          DocTypeVersion.SetRange(Base,true);
          GotVersion := DocTypeVersion.FindFirst;
        end;

        if GotVersion then begin
          MappTableLine.Reset;
          MappTableLine.SetRange("Document No.",DocNo);
          MappTableLine.SetRange("Doc. Type Code",DocTypeCode);
          MappTableLine.SetRange("Sender ID",SenderID);
          MappTableLine.SetRange("Version No.",OldVersionNo);
          MappTableLine.DeleteAll(true);

          CopyFromTemplate(DocNo,DocTypeCode,SenderID);
        end;
    end;

    local procedure CopyFromTemplate(DocNo: Code[20];DocTypeCode: Code[10];SenderID: Code[20])
    begin
        MappTableLine.SetRange("Document No.",'');
        MappTableLine.SetRange("Version No.",DocTypeVersion."Version No.");
        if MappTableLine.FindSet then
          repeat
            MappTableLine2.Init;
            MappTableLine2 := MappTableLine;
            MappTableLine2."Document No." := DocNo;
            MappTableLine2.Insert;
          until MappTableLine.Next = 0;

        MappingTableField.Reset;
        MappingTableField.SetRange("Document No.",'');
        MappingTableField.SetRange("Doc. Type Code",DocTypeCode);
        MappingTableField.SetRange("Sender ID",SenderID);
        MappingTableField.SetRange("Version No.",DocTypeVersion."Version No.");
        if MappingTableField.FindSet then
          repeat
            MappingTableField2.Init;
            MappingTableField2 := MappingTableField;
            MappingTableField2."Document No." := DocNo;
            MappingTableField2.Insert;
          until MappingTableField.Next = 0;

        MapTableFieldSpec.Reset;
        MapTableFieldSpec.SetRange("Document No.",'');
        MapTableFieldSpec.SetRange("Doc. Type Code",DocTypeCode);
        MapTableFieldSpec.SetRange("Sender ID",SenderID);
        MapTableFieldSpec.SetRange("Version No.",DocTypeVersion."Version No.");
        if MapTableFieldSpec.FindSet then
          repeat
            MapTableFieldSpec2.Init;
            MapTableFieldSpec2 := MapTableFieldSpec;
            MapTableFieldSpec2."Document No." := DocNo;
            MapTableFieldSpec2.Insert;
          until MapTableFieldSpec.Next = 0;
    end;
}

