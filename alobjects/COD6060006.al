codeunit 6060006 "GIM - Parser"
{
    // GIM1.00/MH/20150814 CASE 210725 Added code to ParseFile()
    //                                 Added new functions ParseLevel() and NewElement()
    // GIM1.00.01/MHA/20160726  CASE 242557 NaviConnnect reference (NpXml Dom Mgt.) updated according to NC2.00


    trigger OnRun()
    begin
    end;

    var
        TrueCond: Boolean;
        MyInStream: InStream;
        TempMappingTable: Record "GIM - Mapping Table" temporary;
        Text001: Label 'Fields not properly delimited by set field delimiter.';
        SupportedDataFormat: Record "GIM - Supported Data Format";
        MapTableField2: Record "GIM - Mapping Table Field";
        UsedFor: Integer;
        ImpDoc: Record "GIM - Import Document";

    procedure ParseFile(ImportDocHere: Record "GIM - Import Document";DefineMapping: Boolean;ColumnNoOnly: Integer;TableIDHere: Integer;FieldIDHere: Integer)
    var
        MappingTable: Record "GIM - Mapping Table";
        FileFormatSetup: Record "GIM - Data Format";
        XmlDoc: DotNet XmlDocument;
        XmlElement: DotNet XmlElement;
        FieldDelimiter: Text[30];
        FieldSeparator: Text[30];
        ParsedField: Text[250];
        StreamLine: Text[1024];
        WorkingText: Text[1024];
        WorkPart: Text[30];
        ColumnNo: Integer;
        FieldCount: Integer;
        FirstDataRow: Integer;
        Level: Integer;
        RowCount: Integer;
        Continue: Boolean;
        BufferDetail: Record "GIM - Import Buffer Detail";
        BufferTable: Record "GIM - Import Buffer";
        MapSpec: Record "GIM - Mapping Table Field Spec";
    begin
        ImpDoc := ImportDocHere;
        SupportedDataFormat.Get(UpperCase(ImpDoc."File Extension"));
        case SupportedDataFormat.Extension of
          'CSV':
            begin
              RowCount := 1;
              ImpDoc.CalcFields("File Container");
              ImpDoc."File Container".CreateInStream(MyInStream);
              FileFormatSetup.GetCSVSetup(ImpDoc."No.",FieldDelimiter,FieldSeparator,FirstDataRow);
              WorkPart := FieldDelimiter + FieldSeparator + FieldDelimiter;
              SetTrueCond(DefineMapping,RowCount,FirstDataRow,ColumnNoOnly);
              while TrueCond do begin
                FieldCount := 1;
                if DefineMapping and (ColumnNoOnly = 0) then
                  Continue := RowCount = FirstDataRow
                else
                  Continue := FirstDataRow <= RowCount;
                if Continue then begin
                  MyInStream.ReadText(WorkingText);
                  if (FieldDelimiter <> '') and (Format(WorkingText[1]) <> FieldDelimiter) then
                    Error(Text001);
                  while StrPos(WorkingText,WorkPart) > 0 do begin
                    ParsedField := CopyStr(WorkingText,1,StrPos(WorkingText,WorkPart) - 1);
                    WorkingText := CopyStr(WorkingText,StrPos(WorkingText,WorkPart) + StrLen(WorkPart));
                    if DefineMapping then begin
                      if ColumnNoOnly = 0 then
                        MappingTable.InsertLine(ImpDoc."No.",ParsedField,FieldCount,'',0,0,'',ImpDoc."Document Type",ImpDoc."Sender ID")
                      else if ColumnNoOnly = FieldCount then
                        MapSpec.InsertLine(ParsedField,FieldCount,MapTableField2,UsedFor);
                    end else begin
                      BufferTable.InsertLine(ImpDoc."No.",ParsedField,FieldCount,RowCount,0,0);
                      BufferDetail.InsertLines(ImpDoc."No.",ParsedField,FieldCount,RowCount,0,0);
                    end;
                    FieldCount += 1;
                  end;
                  if FieldDelimiter <> '' then
                    if StrPos(WorkingText,FieldDelimiter) = 0 then
                      Error(Text001)
                    else
                      ParsedField := CopyStr(WorkingText,1,StrPos(WorkingText,FieldDelimiter) - 1)
                  else
                    ParsedField := WorkingText;
                  if DefineMapping then begin
                    if ColumnNoOnly = 0 then
                      MappingTable.InsertLine(ImpDoc."No.",ParsedField,FieldCount,'',0,0,'',ImpDoc."Document Type",ImpDoc."Sender ID")
                    else if ColumnNoOnly = FieldCount then
                      MapSpec.InsertLine(ParsedField,FieldCount,MapTableField2,UsedFor);
                  end else begin
                    BufferTable.InsertLine(ImpDoc."No.",ParsedField,FieldCount,RowCount,0,0);
                    BufferDetail.InsertLines(ImpDoc."No.",ParsedField,FieldCount,RowCount,0,0);
                  end;
                end;
                RowCount += 1;
                SetTrueCond(DefineMapping,RowCount,FirstDataRow,ColumnNoOnly);
              end;
              if not DefineMapping then
                ProcessOtherMappingFields();
            end;
          'XML':
            begin
              ColumnNo := 0;
              RowCount := 1;
              ImpDoc.CalcFields("File Container");
              ImpDoc."File Container".CreateInStream(MyInStream);
              XmlDoc := XmlDoc.XmlDocument;
              XmlDoc.Load(MyInStream);
              XmlElement := XmlDoc.DocumentElement.FirstChild;
              ParseLevel(ImpDoc,XmlElement,1,0,true,ColumnNo,DefineMapping,ColumnNoOnly,TableIDHere,FieldIDHere);
              if not DefineMapping then
                ProcessOtherMappingFields();
            end;
        end;
    end;

    local procedure ParseLevel(ImportDocHere: Record "GIM - Import Document";var XmlElement: DotNet XmlElement;Level: Integer;ParentEntryNo: Integer;UniqueElement: Boolean;var ColumnNo: Integer;DefineMapping: Boolean;ColumnNoOnly: Integer;TableIDHere: Integer;FieldIDHere: Integer)
    var
        MappingTable: Record "GIM - Mapping Table";
        MappingTable2: Record "GIM - Mapping Table";
        MappingTableLine: Record "GIM - Mapping Table Line";
        MappingTableField: Record "GIM - Mapping Table Field";
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        XmlAttributes: DotNet XmlAttributeCollection;
        XmlAttribute: DotNet XmlAttribute;
        XmlElement2: DotNet XmlElement;
        ParsedText: Text[250];
        i: Integer;
        Continue: Boolean;
        BufferDetail: Record "GIM - Import Buffer Detail";
        BufferTable: Record "GIM - Import Buffer";
        MapSpec: Record "GIM - Mapping Table Field Spec";
        RowCount: Integer;
        ElementName: Text;
        AttributeName: Text;
        HasMappingTable: Boolean;
        HasMappingTableField: Boolean;
    begin
        while not IsNull(XmlElement) do begin
          ParsedText := CopyStr(XmlElement.Name,1,MaxStrLen(ParsedText));
          if NpXmlDomMgt.IsLeafNode(XmlElement) then
            ParsedText := CopyStr(XmlElement.InnerText,1,MaxStrLen(ParsedText));

          Continue := true;
          ElementName := CopyStr(XmlElement.Name,1,MaxStrLen(MappingTable."Column Name"));
          if DefineMapping then begin
            if ColumnNoOnly <> 0 then begin
              if NewElement(ElementName) then
                AddTempElement(ElementName);
            end else begin
              Continue := NewElement(ElementName);
              if Continue then
                AddTempElement(ElementName);
            end;
          end else begin
            if NewElement(ElementName) then
              AddTempElement(ElementName);
          end;

          if Continue then begin
            if ParsedText = CopyStr(XmlElement.Name,1,MaxStrLen(ParsedText)) then begin
              if DefineMapping then
                MappingTable.InsertLine(ImportDocHere."No.",ParsedText,0,ElementName,Level,ParentEntryNo,ElementName,ImportDocHere."Document Type",ImportDocHere."Sender ID");
            end else begin
              if DefineMapping then begin
                if ColumnNoOnly <> 0 then begin
                  MappingTable2.Reset;
                  MappingTable2.SetRange("Document No.",ImportDocHere."No.");
                  MappingTable2.SetRange("Column Name",ElementName);
                  MappingTable2.SetRange("Element Name",ElementName);
                  MappingTable2.SetRange("Column No.",ColumnNoOnly);
                  if MappingTable2.FindFirst then
                    MapSpec.InsertLine(ParsedText,MappingTable2."Column No.",MapTableField2,UsedFor);
                end else begin
                  ColumnNo += 1;
                  MappingTable.InsertLine(ImportDocHere."No.",ParsedText,ColumnNo,ElementName,Level,ParentEntryNo,ElementName,ImportDocHere."Document Type",ImportDocHere."Sender ID");
                end;
              end else begin
                MappingTable2.Reset;
                MappingTable2.SetRange("Document No.",ImportDocHere."No.");
                MappingTable2.SetRange("Element Name",ElementName);
                MappingTable2.SetRange("Column Name",ElementName);
                MappingTable2.FindFirst; //this will intentionally break if no element name in later nodes. Is this allowed in the xml structure even or can there be this case?
                BufferTable.InsertLine(ImportDocHere."No.",ParsedText,MappingTable2."Column No.",GetRowNo(ElementName),Level,ParentEntryNo);
                BufferDetail.InsertLines(ImportDocHere."No.",ParsedText,MappingTable2."Column No.",GetRowNo(ElementName),Level,ParentEntryNo);
              end;
            end;

            XmlAttributes := XmlElement.Attributes;
            if not IsNull(XmlAttributes) then begin
              for i := 0 to XmlAttributes.Count - 1 do begin
                XmlAttribute := XmlAttributes.ItemOf(i);
                ParsedText := CopyStr(XmlAttribute.Value,1,MaxStrLen(ParsedText));
                AttributeName := CopyStr(XmlAttribute.Name,1,MaxStrLen(MappingTable."Column Name"));
                if DefineMapping then begin
                  if ColumnNoOnly <> 0 then begin
                    MappingTable2.Reset;
                    MappingTable2.SetRange("Document No.",ImportDocHere."No.");
                    MappingTable2.SetRange("Column Name",AttributeName);
                    MappingTable2.SetRange("Element Name",ElementName);
                    MappingTable2.SetRange("Column No.",ColumnNoOnly);
                    if MappingTable2.FindFirst then
                      MapSpec.InsertLine(ParsedText,MappingTable2."Column No.",MapTableField2,UsedFor);
                  end else begin
                    ColumnNo += 1;
                    MappingTable.InsertLine(ImportDocHere."No.",ParsedText,ColumnNo,AttributeName,Level + 1,MappingTable."Entry No.",ElementName,ImportDocHere."Document Type",ImportDocHere."Sender ID");
                  end;
                end else begin
                  MappingTable2.Reset;
                  MappingTable2.SetRange("Document No.",ImportDocHere."No.");
                  MappingTable2.SetRange("Element Name",ElementName);
                  MappingTable2.SetRange("Column Name",AttributeName);
                  MappingTable2.FindFirst;
                  BufferTable.InsertLine(ImportDocHere."No.",ParsedText,MappingTable2."Column No.",GetRowNo(ElementName),Level + 1,ParentEntryNo); //passing elementname on purpose to GetRowNo()
                  BufferDetail.InsertLines(ImportDocHere."No.",ParsedText,MappingTable2."Column No.",GetRowNo(ElementName),Level + 1,ParentEntryNo);
                end;
              end;
            end;

            if not NpXmlDomMgt.IsLeafNode(XmlElement) then begin
              XmlElement2 := XmlElement.FirstChild;
              ParseLevel(ImportDocHere,XmlElement2,Level + 1,MappingTable."Entry No.",UniqueElement,ColumnNo,DefineMapping,ColumnNoOnly,TableIDHere,FieldIDHere);
            end;
          end;
          XmlElement := XmlElement.NextSibling;
        end;
    end;

    local procedure NewElement(ElementName: Text[50]): Boolean
    begin
        TempMappingTable.SetRange("Column Name",ElementName);
        if TempMappingTable.FindFirst then begin
          TempMappingTable."Column No." := TempMappingTable."Column No." + 1; //using column no. as a container for row no. counter
          TempMappingTable.Modify;
          exit(false);
        end;
        exit(true);
    end;

    local procedure SetTrueCond(DefineMappingHere: Boolean;RowCountHere: Integer;FirstDataRowHere: Integer;ColumnNoOnly: Integer)
    begin
        TrueCond := not MyInStream.EOS;
        if DefineMappingHere and (ColumnNoOnly = 0) then
          TrueCond := TrueCond and (RowCountHere <= FirstDataRowHere);
    end;

    local procedure GetRowNo(ElementName: Text[50]): Integer
    begin
        TempMappingTable.SetRange("Column Name",ElementName);
        if TempMappingTable.FindFirst then
          exit(TempMappingTable."Column No.");
    end;

    local procedure AddTempElement(ElementName: Text[50])
    begin
        TempMappingTable.Reset;
        if TempMappingTable.FindLast then;
        TempMappingTable."Entry No." := TempMappingTable."Entry No." + 1;
        TempMappingTable."Column No." := 1;
        TempMappingTable."Column Name" := ElementName;
        TempMappingTable.Insert;
    end;

    procedure SetMapTableFieldSpecData(MapTableFieldHere: Record "GIM - Mapping Table Field";UsedForHere: Integer)
    begin
        MapTableField2 := MapTableFieldHere;
        UsedFor := UsedForHere;
    end;

    local procedure ProcessOtherMappingFields()
    var
        BufferDetail: Record "GIM - Import Buffer Detail";
        MaxRowNo: Integer;
        i: Integer;
        MapTableField: Record "GIM - Mapping Table Field";
        MapTableLine: Record "GIM - Mapping Table Line";
        ParsedField: Text[250];
    begin
        MapTableLine.SetRange("Document No.",ImpDoc."No.");
        if MapTableLine.FindSet then
          repeat
            BufferDetail.Reset;
            BufferDetail.SetCurrentKey("Row No.");
            BufferDetail.SetRange("Document No.",ImpDoc."No.");
            BufferDetail.SetRange("Mapping Table Line No.",MapTableLine."Line No.");
            if BufferDetail.FindLast then
              MaxRowNo := BufferDetail."Row No."
            else begin
              BufferDetail.SetRange("Mapping Table Line No.");
              if BufferDetail.FindLast then
                MaxRowNo := BufferDetail."Row No.";
            end;

            MapTableField.Reset;
            MapTableField.SetRange("Document No.",ImpDoc."No.");
            MapTableField.SetRange("Mapping Table Line No.",MapTableLine."Line No.");
            MapTableField.SetRange(Mapped,true);
            if MapTableField.FindSet then
              repeat
                if (MapTableField."Value Type" <> MapTableField."Value Type"::Specific) and (MapTableField."Filter Value Type" <> MapTableField."Filter Value Type"::Specific) then begin
                  ParsedField := '';
                  for i := 1 to MaxRowNo do begin
                    BufferDetail.Reset;
                    BufferDetail.SetRange("Document No.",ImpDoc."No.");
                    BufferDetail.SetRange("Mapping Table Line No.",MapTableField."Mapping Table Line No.");
                    BufferDetail.SetRange("Field ID",MapTableField."Field ID");
                    BufferDetail.SetRange("Row No.",i);
                    if BufferDetail.FindFirst then begin
                      if BufferDetail."Value Type" = BufferDetail."Value Type"::Column then
                        ParsedField := BufferDetail."Parsed Text";
                    end else
                      BufferDetail.InsertLine(ImpDoc."No.",ParsedField,0,i,false,MapTableField,0,0);
                  end;
                end;
              until MapTableField.Next = 0;
          until MapTableLine.Next = 0;
    end;
}

