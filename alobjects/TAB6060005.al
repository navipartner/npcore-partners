table 6060005 "GIM - Mapping Table"
{
    // GIM1.00/MH/20150814 CASE 210725 Added field 45 Level and 50 "Parent Entry No."
    //                                 Added Parameters to InsertLine(): ColumName, Level, ParentEntryNo
    // NPR5.38/MHA /20180104  CASE 301054 Removed unused Automation variable in GetAttribute()

    Caption = 'GIM - Mapping Table';
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
        }
        field(25;"Skip Processing";Boolean)
        {
            Caption = 'Skip Processing';
        }
        field(30;"Column Name";Text[50])
        {
            Caption = 'Column Name';
        }
        field(40;"Allow Empty Value";Boolean)
        {
            Caption = 'Allow Empty Value';
        }
        field(45;Level;Integer)
        {
            Caption = 'Level';
        }
        field(50;"Parent Entry No.";Integer)
        {
            Caption = 'Parent Entry No.';
        }
        field(51;"Element Name";Text[50])
        {
            Caption = 'Element Name';
        }
        field(60;"Doc. Type Code";Code[10])
        {
            Caption = 'Doc. Type Code';
        }
        field(70;"Sender ID";Code[20])
        {
            Caption = 'Sender ID';
        }
        field(100;"Column No.";Integer)
        {
            Caption = 'Column No.';
        }
    }

    keys
    {
        key(Key1;"Entry No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        MappingTableLine.SetRange("Document No.","Document No.");
        MappingTableLine.SetRange("Column No.","Column No.");
        MappingTableLine.DeleteAll(true);
    end;

    var
        GIMImportEntity: Record "GIM - Mapping Table Line";
        TableField: Record "Field";
        GIMImportDocument: Record "GIM - Import Document";
        DotNetNamespaceURI: Label 'urn:schemas-microsoft-com:dynamics:NAV:MetaObjects';
        XMLNodeReturn: DotNet XmlNode;
        MappingTableLine: Record "GIM - Mapping Table Line";

    procedure InsertLine(DocNo: Code[20];ParsedText: Text[250];ColumnNo: Integer;ColumName: Text[50];NewLevel: Integer;ParentEntryNo: Integer;ElementName: Text[50];DocTypeCode: Code[10];SenderID: Code[20])
    var
        EntryNo: Integer;
        BufferTable: Record "GIM - Mapping Table";
    begin
        if BufferTable.FindLast then
          EntryNo := BufferTable."Entry No." + 1
        else
          EntryNo := 1;

        Init;

        "Entry No." := EntryNo;
        "Document No." := DocNo;
        "Parsed Text" := ParsedText;
        "Column No." := ColumnNo;
        "Column Name" := ColumName;
        Level := NewLevel;
        "Parent Entry No." := ParentEntryNo;
        "Element Name" := ElementName;
        "Doc. Type Code" := DocTypeCode;
        "Sender ID" := SenderID;
        Insert;
    end;

    local procedure GetFieldNode(TableID: Integer;FieldID: Integer)
    var
        InStr: InStream;
        ObjMeta: Record "Object Metadata";
        XmlDoc: DotNet XmlDocument;
        XMLNode: DotNet XmlNode;
        XmlNamespaceManager: DotNet XmlNamespaceManager;
        FileMgt: Codeunit "File Management";
    begin
        ObjMeta.Get(ObjMeta."Object Type"::Table,TableID);
        if ObjMeta.Metadata.HasValue then begin
          ObjMeta.CalcFields(Metadata);
          Clear(XMLNodeReturn);
          XmlDoc := XmlDoc.XmlDocument;
          XmlDoc.Load(ObjMeta.Metadata.Export(FileMgt.ServerTempFileName('xml')));
          XmlNamespaceManager := XmlNamespaceManager.XmlNamespaceManager(XmlDoc.NameTable);
          XmlNamespaceManager.AddNamespace('n','urn:schemas-microsoft-com:dynamics:NAV:MetaObjects');
          XMLNodeReturn := XmlDoc.SelectSingleNode('/n:MetaTable/n:Fields/n:Field[@ID="' + Format(FieldID) + '"]',XmlNamespaceManager);
        end;
    end;

    procedure GetAttribute(TableID: Integer;FieldID: Integer;AttributeName: Text[250]): Text[250]
    var
        XMLNodeReturn: DotNet XmlNode;
    begin
        GetFieldNode(TableID,FieldID);
        exit(GetAttributeFromNode(AttributeName));
    end;

    local procedure GetAttributeFromNode(AttributeName: Text[250]): Text[250]
    var
        XMLAttributeNode: DotNet XmlNode;
    begin
        XMLAttributeNode := XMLNodeReturn.Attributes.GetNamedItem(AttributeName);
        if IsNull(XMLAttributeNode) then
          exit('');
        exit(CopyStr(Format(XMLAttributeNode.InnerText),1,250));
    end;
}

