codeunit 6151556 "NpXml Template Mgt."
{
    // NC1.13 /MHA /20150414  CASE 211360 Object Created - Restructured NpXml Codeunits. Independent functions moved to new codeunits
    // NC1.14 /MHA /20150422  CASE 211774 Changed filter on Comment when navigating. Blank means no filter
    // NC1.21 /TTH /20151020  CASE 224528 Adding versioning and possibility to lock the modified versions. Changed Function ExportNpXmlTemplate to use NpXmlTemplateToBlob function.
    // NC1.21 /MHA /20151105  CASE 226655 Added Normalization if Line No. cannot be split during insert
    // NC1.21 /MHA /20151123  CASE 227354 Removed Database Triggers to avoid new Version Initiation during Automatic Setup
    // NC1.22 /MHA /20151203  CASE 224528 Restored Templates should be set to Archived and NaviConnectSetup should be updated after import
    // NC2.00 /MHA /20160525  CASE 240005 NaviConnect
    // NC2.06 /MHA /20170927  CASE 265779 Added Api Headers


    trigger OnRun()
    begin
    end;

    var
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        Text100: Label 'Choose Xml Document';
        Text300: Label 'Please enter a Version Description';

    local procedure AssignValue(var FieldRef: FieldRef; Value: Text[250])
    var
        TextValue: Text[250];
        DecimalValue: Decimal;
        IntegerValue: Integer;
        BooleanValue: Boolean;
        DateValue: Date;
        TimeValue: Time;
        DateFormulaValue: DateFormula;
        BigIntegerValue: BigInteger;
        DateTimeValue: DateTime;
    begin
        case LowerCase(Format(FieldRef.Type)) of
            'code', 'text':
                begin
                    TextValue := Value;
                    FieldRef.Value := TextValue;
                end;
            'decimal':
                begin
                    Evaluate(DecimalValue, Value, 9);
                    FieldRef.Value := DecimalValue;
                end;
            'boolean':
                begin
                    Evaluate(BooleanValue, Value, 9);
                    FieldRef.Value := BooleanValue;
                end;
            'dateformula':
                begin
                    Evaluate(DateFormulaValue, Value, 9);
                    FieldRef.Value := DateFormulaValue;
                end;
            'biginteger':
                begin
                    Evaluate(BigIntegerValue, Value, 9);
                    FieldRef.Value := BigIntegerValue;
                end;
            'datetime':
                begin
                    Evaluate(DateTimeValue, Value, 9);
                    FieldRef.Value := DateTimeValue;
                end;
            'option', 'integer':
                begin
                    Evaluate(IntegerValue, Value, 9);
                    FieldRef.Value := IntegerValue;
                end;
            'date':
                begin
                    Evaluate(DateValue, Value, 9);
                    FieldRef.Value := DateValue;
                end;
            'time':
                begin
                    Evaluate(TimeValue, Value, 9);
                    FieldRef.Value := TimeValue;
                end;
        end;
    end;

    procedure GetNpXmlElement(TemplateCode: Code[20]; ElementPath: Text; Comment: Text[250]; var NpXmlElement: Record "NpXml Element"): Boolean
    var
        ElementName: Text;
        Position: Integer;
    begin
        Clear(NpXmlElement);
        NpXmlElement.SetRange("Xml Template Code", TemplateCode);
        while ElementPath <> '' do begin
            Position := StrPos(ElementPath, '/');
            if Position <> 1 then begin
                if Position = 0 then begin
                    ElementName := ElementPath;
                    ElementPath := '';
                end else begin
                    ElementName := CopyStr(ElementPath, 1, Position - 1);
                    ElementPath := DelStr(ElementPath, 1, Position);
                end;
                if ElementPath = '' then
                    NpXmlElement.SetFilter(Comment, Comment);
                NpXmlElement.SetRange("Parent Line No.", NpXmlElement."Line No.");
                NpXmlElement.SetRange("Element Name", ElementName);
                if not NpXmlElement.FindFirst then
                    exit(false);
            end else
                ElementPath := DelStr(ElementPath, 1, Position);
        end;

        exit((NpXmlElement."Line No." <> 0) and (NpXmlElement."Element Name" <> ''));
    end;

    procedure GetChildNpXmlElement(NpXmlElementParent: Record "NpXml Element"; ElementPath: Text; Comment: Text[250]; var NpXmlElement: Record "NpXml Element"): Boolean
    var
        ElementName: Text;
        Position: Integer;
    begin
        NpXmlElement.Get(NpXmlElementParent."Xml Template Code", NpXmlElementParent."Line No.");
        NpXmlElement.Reset;
        while ElementPath <> '' do begin
            Position := StrPos(ElementPath, '/');
            if Position <> 1 then begin
                if Position = 0 then begin
                    ElementName := ElementPath;
                    ElementPath := '';
                end else begin
                    ElementName := CopyStr(ElementPath, 1, Position - 1);
                    ElementPath := DelStr(ElementPath, 1, Position);
                end;
                if ElementPath = '' then
                    //-NC1.14
                    //NpXmlElement.SETRANGE(Comment,Comment);
                    NpXmlElement.SetFilter(Comment, Comment);
                //+NC1.14
                NpXmlElement.SetRange("Parent Line No.", NpXmlElement."Line No.");
                NpXmlElement.SetRange("Element Name", ElementName);
                if not NpXmlElement.FindFirst then
                    exit(false);
            end else
                ElementPath := DelStr(ElementPath, 1, Position);
        end;

        exit((NpXmlElement."Line No." <> 0) and (NpXmlElement."Element Name" <> ''));
    end;

    procedure ExportNpXmlTemplate(TemplateCode: Code[20])
    var
        NpXmlTemplate: Record "NpXml Template";
        TempBlob: Codeunit "Temp Blob";
        FileMgt: Codeunit "File Management";
    begin
        //-NC1.21
        NpXmlTemplate.Get(TemplateCode);
        if NpXmlTemplateToBlob(NpXmlTemplate, TempBlob) then
            FileMgt.BLOBExport(TempBlob, LowerCase(NpXmlTemplate.Code) + '.xml', true);
        //+NC1.21
    end;

    procedure ExportRecRefToXml(RecRef: RecordRef; var XmlElement: DotNet npNetXmlElement)
    var
        "Field": Record "Field";
        FieldRef: FieldRef;
        XmlCDATA: DotNet npNetXmlCDataSection;
        XmlElementField: DotNet npNetXmlElement;
        XmlElementTable: DotNet npNetXmlElement;
    begin
        FieldRef := RecRef.Field(Field."No.");
        NpXmlDomMgt.AddElement(XmlElement, 'T' + Format(RecRef.Number, 0, 9), XmlElementTable);
        NpXmlDomMgt.AddAttribute(XmlElementTable, 'primary_key', Format(RecRef.GetPosition(false), 0, 9));
        NpXmlDomMgt.AddAttribute(XmlElementTable, 'table_no', Format(RecRef.Number, 0, 9));
        NpXmlDomMgt.AddAttribute(XmlElementTable, 'table_name', Format(RecRef.Name, 0, 9));

        Field.SetRange(TableNo, RecRef.Number);
        if Field.FindSet then
            repeat
                FieldRef := RecRef.Field(Field."No.");
                NpXmlDomMgt.AddElement(XmlElementTable, 'F' + Format(FieldRef.Number, 0, 9), XmlElementField);
                NpXmlDomMgt.AddAttribute(XmlElementField, 'field_no', Format(FieldRef.Number, 0, 9));
                NpXmlDomMgt.AddAttribute(XmlElementField, 'field_name', Format(FieldRef.Name, 0, 9));

                XmlCDATA := XmlElementField.OwnerDocument.CreateCDataSection('');
                XmlElementField.AppendChild(XmlCDATA);
                XmlCDATA.AppendData(Format(FieldRef.Value, 0, 9));
            until Field.Next = 0;
    end;

    procedure ImportNpXmlTemplate(): Boolean
    var
        NpXmlTemplate: Record "NpXml Template";
        TempBlob: Codeunit "Temp Blob";
        FileMgt: Codeunit "File Management";
        PathHelper: DotNet npNetPath;
        MemoryStream: DotNet npNetMemoryStream;
        XmlDoc: DotNet npNetXmlDocument;
        XmlElement: DotNet npNetXmlElement;
        XmlElementTable: DotNet npNetXmlElement;
        XmlNodeList: DotNet npNetXmlNodeList;
        InStr: InStream;
        i: Integer;
        FilePath: Text;
        TemplateCode: Code[20];
    begin
        Clear(TempBlob);
        FilePath := FileMgt.BLOBImport(TempBlob, 'NpXml');
        if FilePath = '' then
            exit(false);

        TemplateCode := PathHelper.GetFileNameWithoutExtension(FilePath);
        if not NpXmlTemplate.Get(TemplateCode) then begin
            TempBlob.CreateInStream(InStr);
            MemoryStream := InStr;
            XmlDoc := XmlDoc.XmlDocument;
            XmlDoc.Load(MemoryStream);
            MemoryStream.Flush;
            MemoryStream.Close;
            Clear(MemoryStream);

            XmlElement := XmlDoc.DocumentElement;
            if (XmlElement.GetAttribute('code') = TemplateCode) and XmlElement.HasChildNodes then begin
                XmlNodeList := XmlElement.ChildNodes;
                for i := 0 to XmlNodeList.Count - 1 do begin
                    XmlElementTable := XmlNodeList.ItemOf(i);
                    InsertRecRefFromXml(XmlElementTable);
                end;
            end;
            Clear(XmlDoc);

            //-NC1.22
            if NpXmlTemplate.Get(TemplateCode) then
                NpXmlTemplate.UpdateNaviConnectSetup();
            //+NC1.22
        end;

        exit(NpXmlTemplate.Get(TemplateCode));
    end;

    procedure ImportNpXmlTemplateUrl(TemplateCode: Code[20]; TemplateUrl: Text): Boolean
    var
        NpXmlTemplate: Record "NpXml Template";
        HttpWebRequest: DotNet npNetHttpWebRequest;
        HttpWebResponse: DotNet npNetHttpWebResponse;
        MemoryStream: DotNet npNetMemoryStream;
        XmlDoc: DotNet npNetXmlDocument;
        XmlElement: DotNet npNetXmlElement;
        XmlElementTable: DotNet npNetXmlElement;
        XmlNodeList: DotNet npNetXmlNodeList;
        i: Integer;
    begin
        if (TemplateCode = '') or (TemplateUrl = '') then
            exit(false);

        if not NpXmlTemplate.Get(TemplateCode) then begin
            HttpWebRequest := HttpWebRequest.Create(TemplateUrl + LowerCase(TemplateCode) + '.xml');
            HttpWebRequest.Method := 'GET'; //WebRequestMethods.Ftp.DownloadFile
            HttpWebRequest.UseDefaultCredentials(true);
            HttpWebResponse := HttpWebRequest.GetResponse;
            MemoryStream := HttpWebResponse.GetResponseStream;
            XmlDoc := XmlDoc.XmlDocument;
            XmlDoc.Load(MemoryStream);
            MemoryStream.Flush;
            MemoryStream.Close;
            Clear(MemoryStream);

            XmlElement := XmlDoc.DocumentElement;
            if (XmlElement.GetAttribute('code') = TemplateCode) and XmlElement.HasChildNodes then begin
                XmlNodeList := XmlElement.ChildNodes;
                for i := 0 to XmlNodeList.Count - 1 do begin
                    XmlElementTable := XmlNodeList.ItemOf(i);
                    InsertRecRefFromXml(XmlElementTable);
                end;
            end;
            Clear(XmlDoc);

            //-NC1.22
            if NpXmlTemplate.Get(TemplateCode) then
                NpXmlTemplate.UpdateNaviConnectSetup();
            //+NC1.22
        end;

        exit(NpXmlTemplate.Get(TemplateCode));
    end;

    procedure InsertRecRefFromXml(var XmlElementTable: DotNet npNetXmlElement)
    var
        "Field": Record "Field";
        FieldRef: FieldRef;
        RecRef: RecordRef;
        XmlElementField: DotNet npNetXmlElement;
        XmlNodeList: DotNet npNetXmlNodeList;
        FieldID: Integer;
        TableID: Integer;
        i: Integer;
        PrimaryKey: Text;
        XmlCDATA: DotNet npNetXmlCDataSection;
        NetConvHelper: Variant;
    begin
        if not Evaluate(TableID, XmlElementTable.GetAttribute('table_no'), 9) then
            exit;
        PrimaryKey := XmlElementTable.GetAttribute('primary_key');
        if PrimaryKey = '' then
            exit;

        Clear(RecRef);
        RecRef.Open(TableID);
        if XmlElementTable.GetAttribute('table_name') <> Format(RecRef.Name, 0, 9) then begin
            RecRef.Close;
            exit;
        end;

        if XmlElementTable.HasChildNodes then begin
            XmlNodeList := XmlElementTable.ChildNodes;
            for i := 0 to XmlNodeList.Count - 1 do begin
                XmlElementField := XmlNodeList.ItemOf(i);
                NetConvHelper := XmlElementField;
                XmlCDATA := NetConvHelper;
                if Evaluate(FieldID, XmlElementField.GetAttribute('field_no'), 9) and Field.Get(TableID, FieldID) then begin
                    FieldRef := RecRef.Field(FieldID);
                    if XmlElementField.GetAttribute('field_name') = Format(FieldRef.Name, 0, 9) then
                        AssignValue(FieldRef, XmlElementField.InnerText);
                end;
            end;
        end;

        if Format(RecRef.GetPosition(false), 0, 9) <> PrimaryKey then begin
            RecRef.Close;
            exit;
        end;
        //-NC1.21
        //IF RecRef.INSERT(TRUE) THEN;
        if RecRef.Insert then;
        //+NC1.21
        RecRef.Close;
    end;

    procedure ImportXmlSchema(NPXmlTemplateCode: Code[20])
    var
        NPXmlAttribute: Record "NpXml Attribute";
        NPXmlElement: Record "NpXml Element";
        NPXmlFilter: Record "NpXml Filter";
        NPXmlTemplate: Record "NpXml Template";
        FileMgt: Codeunit "File Management";
        XmlDoc: DotNet npNetXmlDocument;
        XmlElement: DotNet npNetXmlElement;
        ServerFile: File;
        InStr: InStream;
        ServerFilepath: Text;
        LineNo: Integer;
    begin
        NPXmlTemplate.Get(NPXmlTemplateCode);

        ServerFilepath := FileMgt.UploadFile(Text100, '*.xml');
        if ServerFilepath = '' then
            exit;

        ServerFile.Open(ServerFilepath);
        ServerFile.CreateInStream(InStr);
        XmlDoc := XmlDoc.XmlDocument();
        XmlDoc.Load(InStr);
        ServerFile.Close;
        if Erase(ServerFilepath) then;

        NPXmlAttribute.SetRange("Xml Template Code", NPXmlTemplate.Code);
        NPXmlAttribute.DeleteAll;
        NPXmlFilter.SetRange("Xml Template Code", NPXmlTemplate.Code);
        NPXmlFilter.DeleteAll;
        NPXmlElement.SetRange("Xml Template Code", NPXmlTemplate.Code);
        NPXmlElement.DeleteAll;

        XmlElement := XmlDoc.DocumentElement;
        NPXmlTemplate."Xml Root Name" := XmlElement.Name;
        NPXmlTemplate.Modify(true);
        LineNo := 0;
        InsertNpXmlElement(NPXmlTemplate, XmlElement, LineNo, -1);
    end;

    local procedure InsertNpXmlElement(NPXmlTemplate: Record "NpXml Template"; XmlElement: DotNet npNetXmlElement; var LineNo: Integer; Level: Integer)
    var
        NPXmlAttribute: Record "NpXml Attribute";
        NPXmlElement: Record "NpXml Element";
        ChildXmlElement: DotNet npNetXmlElement;
        XmlAttribute: DotNet npNetXmlElement;
        i: Integer;
        "Field": Record "Field";
    begin
        if IsNull(XmlElement) then
            exit;
        if XmlElement.Name = '' then
            exit;
        if CopyStr(XmlElement.Name, 1, 1) = '#' then
            exit;

        if Level >= 0 then begin
            NPXmlElement.Init;
            NPXmlElement."Xml Template Code" := NPXmlTemplate.Code;
            NPXmlElement."Line No." := LineNo;
            NPXmlElement."Element Name" := XmlElement.Name;
            NPXmlElement.Active := true;
            NPXmlElement.Level := Level;
            NPXmlElement."Table No." := NPXmlTemplate."Table No.";
            Field.SetRange(TableNo, NPXmlElement."Table No.");
            Field.SetFilter(FieldName, '@' + ConvertStr(NPXmlElement."Element Name", '_', '*'));
            if Field.FindFirst then
                NPXmlElement."Field No." := Field."No.";
            NPXmlElement.Insert(true);

            if XmlElement.HasAttributes then begin
                for i := 0 to XmlElement.Attributes.Count - 1 do begin
                    XmlAttribute := XmlElement.Attributes.Item(i);
                    NPXmlAttribute.Init;
                    NPXmlAttribute."Xml Template Code" := NPXmlElement."Xml Template Code";
                    NPXmlAttribute."Xml Element Line No." := NPXmlElement."Line No.";
                    NPXmlAttribute."Line No." := (i + 1) * 10000;
                    NPXmlAttribute."Attribute Name" := XmlAttribute.Name;
                    NPXmlAttribute."Table No." := NPXmlElement."Table No.";
                    Field.SetRange(TableNo, NPXmlElement."Table No.");
                    Field.SetFilter(FieldName, '@' + NPXmlAttribute."Attribute Name");
                    if Field.FindFirst then
                        NPXmlAttribute."Attribute Field No." := Field."No.";
                    NPXmlAttribute.Insert(true);
                end;
            end;
        end;

        if XmlElement.HasChildNodes then begin
            for i := 0 to XmlElement.ChildNodes.Count - 1 do begin
                ChildXmlElement := XmlElement.ChildNodes.Item(i);
                LineNo += 10000;
                InsertNpXmlElement(NPXmlTemplate, ChildXmlElement, LineNo, Level + 1);
            end;
        end;
    end;

    procedure "--- Edit Template"()
    begin
    end;

    local procedure DeleteNpXmlAttributes(NpXmlElement: Record "NpXml Element")
    var
        NpXmlAttribute: Record "NpXml Attribute";
    begin
        NpXmlAttribute.SetRange("Xml Template Code", NpXmlElement."Xml Template Code");
        NpXmlAttribute.SetRange("Xml Element Line No.", NpXmlElement."Line No.");
        NpXmlAttribute.DeleteAll;
    end;

    local procedure DeleteNpXmlElement(NpXmlElement: Record "NpXml Element")
    var
        NpXmlElement2: Record "NpXml Element";
    begin
        //-NC2.00
        NpXmlElement2.SetRange("Xml Template Code", NpXmlElement."Xml Template Code");
        NpXmlElement2.SetRange("Parent Line No.", NpXmlElement."Line No.");
        if NpXmlElement2.FindSet then
            repeat
                DeleteNpXmlElement(NpXmlElement2);
            until NpXmlElement2.Next = 0;

        DeleteNpXmlAttributes(NpXmlElement);
        DeleteNpXmlFilters(NpXmlElement);
        NpXmlElement.Delete;
        //+NC2.00
    end;

    procedure DeleteNpXmlElements(TemplateCode: Code[20]; ElementPath: Text; Comment: Text[250])
    var
        NpXmlTemplate: Record "NpXml Template";
        NpXmlElement: Record "NpXml Element";
    begin
        //-NC2.00
        if not NpXmlTemplate.Get(TemplateCode) then
            exit;
        if not GetNpXmlElement(TemplateCode, ElementPath, Comment, NpXmlElement) then
            exit;

        DeleteNpXmlElement(NpXmlElement);
        //+NC2.00
    end;

    local procedure DeleteNpXmlFilters(NpXmlElement: Record "NpXml Element")
    var
        NpXmlFilter: Record "NpXml Filter";
    begin
        NpXmlFilter.SetRange("Xml Template Code", NpXmlElement."Xml Template Code");
        NpXmlFilter.SetRange("Xml Element Line No.", NpXmlElement."Line No.");
        NpXmlFilter.DeleteAll;
    end;

    procedure SetChildNpXmlElementsActive(NpXmlElement: Record "NpXml Element"; Active: Boolean)
    var
        NpXmlElement2: Record "NpXml Element";
    begin
        NpXmlElement2.SetRange("Xml Template Code", NpXmlElement."Xml Template Code");
        NpXmlElement2.SetRange("Parent Line No.", NpXmlElement."Line No.");
        if NpXmlElement2.FindSet then
            repeat
                if NpXmlElement2.Active <> Active then begin
                    NpXmlElement2.Active := Active;
                    NpXmlElement2.Modify;
                end;
                SetChildNpXmlElementsActive(NpXmlElement2, Active);
            until NpXmlElement2.Next = 0;
    end;

    procedure SetNpXmlElementActive(TemplateCode: Code[20]; ElementPath: Text; Comment: Text[250]; Active: Boolean)
    var
        NpXmlTemplate: Record "NpXml Template";
        NpXmlElement: Record "NpXml Element";
    begin
        if not NpXmlTemplate.Get(TemplateCode) then
            exit;
        if not GetNpXmlElement(TemplateCode, ElementPath, Comment, NpXmlElement) then
            exit;

        if NpXmlElement.Active <> Active then begin
            NpXmlElement.Active := Active;
            NpXmlElement.Modify;
        end;
        SetChildNpXmlElementsActive(NpXmlElement, Active);
    end;

    procedure SetNpXmlFilterValue(TemplateCode: Code[10]; ElementLineNo: Integer; FieldNo: Integer; FilterValue: Text)
    var
        NpXmlFilter: Record "NpXml Filter";
    begin
        NpXmlFilter.SetRange("Xml Template Code", TemplateCode);
        NpXmlFilter.SetRange("Xml Element Line No.", ElementLineNo);
        NpXmlFilter.SetRange("Field No.", FieldNo);
        NpXmlFilter.ModifyAll("Filter Value", FilterValue);
    end;

    procedure "--- Version Control"()
    begin
    end;

    procedure Archive(var NpXmlTemplate: Record "NpXml Template"): Boolean
    var
        TempBlob: Codeunit "Temp Blob";
        NpXmlTemplateArchive: Record "NpXml Template Archive";
        NpXmlTemplateHistory: Record "NpXml Template History";
        NpXmlSetup: Record "NpXml Setup";
        RecRef: RecordRef;
    begin
        //-NC1.21
        //-NC1.22
        //IF NpXmlTemplate.Archived THEN
        //  EXIT(FALSE);
        if NpXmlTemplate.VersionArchived() then
            exit(false);
        //+NC1.22

        if not NpXmlSetup.Get then
            NpXmlSetup.Insert;

        if NpXmlTemplate."Version Description" = '' then
            Error(Text300);
        NpXmlTemplate.Archived := true;
        NpXmlTemplate.Modify;

        if NpXmlTemplateToBlob(NpXmlTemplate, TempBlob) then begin
            NpXmlTemplateArchive.Init;
            NpXmlTemplateArchive.Code := NpXmlTemplate.Code;
            NpXmlTemplateArchive."Version Description" := NpXmlTemplate."Version Description";
            NpXmlTemplateArchive."Template Version No." := NpXmlTemplate."Template Version";

            RecRef.GetTable(NpXmlTemplateArchive);
            TempBlob.ToRecordRef(RecRef, NpXmlTemplateArchive.FieldNo("Archived Template"));
            RecRef.SetTable(NpXmlTemplateArchive);

            NpXmlTemplateArchive."Archived by" := UserId;
            NpXmlTemplateArchive."Archived at" := CreateDateTime(Today, Time);
            NpXmlTemplateArchive.Insert;
        end;

        NpXmlTemplateHistory.InsertHistory(NpXmlTemplate.Code, NpXmlTemplate."Template Version", NpXmlTemplateHistory."Event Type"::Archivation, NpXmlTemplate."Version Description");

        exit(true);
        //+NC1.21
    end;

    local procedure ClearTemplateVersion(XMLTemplateCode: Code[20])
    var
        NpXmlAttribute: Record "NpXml Attribute";
        NpXmlElement: Record "NpXml Element";
        NpXmlFilter: Record "NpXml Filter";
        NpXmlTemplateTrigger: Record "NpXml Template Trigger";
        NpXmlTemplateTriggerLink: Record "NpXml Template Trigger Link";
        NpXmlTemplate: Record "NpXml Template";
    begin
        //-NC1.21
        NpXmlElement.SetRange("Xml Template Code", XMLTemplateCode);
        if NpXmlElement.FindSet then
            NpXmlElement.DeleteAll;
        NpXmlAttribute.SetRange("Xml Template Code", XMLTemplateCode);
        if NpXmlAttribute.FindSet then
            NpXmlAttribute.DeleteAll;
        NpXmlFilter.SetRange("Xml Template Code", XMLTemplateCode);
        if NpXmlFilter.FindSet then
            NpXmlFilter.DeleteAll;
        NpXmlTemplateTrigger.SetRange("Xml Template Code", XMLTemplateCode);
        if NpXmlTemplateTrigger.FindSet then
            NpXmlTemplateTrigger.DeleteAll;
        NpXmlTemplateTriggerLink.SetRange("Xml Template Code", XMLTemplateCode);
        if NpXmlTemplateTriggerLink.FindSet then
            NpXmlTemplateTriggerLink.DeleteAll;
        if NpXmlTemplate.Get(XMLTemplateCode) then
            NpXmlTemplate.Delete;
        //+NC1.21
    end;

    procedure ExportArchivedNpXmlTemplate(NpXmlTemplateArchive: Record "NpXml Template Archive")
    var
        TempBlob: Codeunit "Temp Blob";
        FileMgt: Codeunit "File Management";
    begin
        //-NC1.21
        NpXmlTemplateArchive.CalcFields("Archived Template");
        TempBlob.FromRecord(NpXmlTemplateArchive, NpXmlTemplateArchive.FieldNo("Archived Template"));
        FileMgt.BLOBExport(TempBlob, LowerCase(NpXmlTemplateArchive.Code + ' ' + NpXmlTemplateArchive."Template Version No.") + '.xml', true);
        //+NC1.21
    end;

    procedure NpXmlTemplateToBlob(var NpXmlTemplate: Record "NpXml Template"; var TempBlob: Codeunit "Temp Blob"): Boolean
    var
        NpXmlApiHeader: Record "NpXml Api Header";
        NpXmlAttribute: Record "NpXml Attribute";
        NpXmlElement: Record "NpXml Element";
        NpXmlFilter: Record "NpXml Filter";
        NpXmlNamespaces: Record "NpXml Namespace";
        NpXmlTemplateTrigger: Record "NpXml Template Trigger";
        NpXmlTemplateTriggerLink: Record "NpXml Template Trigger Link";
        XmlDoc: DotNet npNetXmlDocument;
        XmlElement: DotNet npNetXmlElement;
        RecRef: RecordRef;
        OutStr: OutStream;
    begin
        //-NC1.21
        Clear(XmlDoc);
        XmlDoc := XmlDoc.XmlDocument;
        XmlDoc.LoadXml('<?xml version="1.0" encoding="utf-8"?>' +
                       '<npxml_template code="' + NpXmlTemplate.Code + '" />');
        XmlElement := XmlDoc.DocumentElement;

        RecRef.GetTable(NpXmlTemplate);
        ExportRecRefToXml(RecRef, XmlElement);

        NpXmlElement.SetRange("Xml Template Code", NpXmlTemplate.Code);
        if NpXmlElement.FindSet then
            repeat
                RecRef.GetTable(NpXmlElement);
                ExportRecRefToXml(RecRef, XmlElement);
            until NpXmlElement.Next = 0;
        NpXmlAttribute.SetRange("Xml Template Code", NpXmlTemplate.Code);
        if NpXmlAttribute.FindSet then
            repeat
                RecRef.GetTable(NpXmlAttribute);
                ExportRecRefToXml(RecRef, XmlElement);
            until NpXmlAttribute.Next = 0;
        NpXmlFilter.SetRange("Xml Template Code", NpXmlTemplate.Code);
        if NpXmlFilter.FindSet then
            repeat
                RecRef.GetTable(NpXmlFilter);
                ExportRecRefToXml(RecRef, XmlElement);
            until NpXmlFilter.Next = 0;
        NpXmlTemplateTrigger.SetRange("Xml Template Code", NpXmlTemplate.Code);
        if NpXmlTemplateTrigger.FindSet then
            repeat
                RecRef.GetTable(NpXmlTemplateTrigger);
                ExportRecRefToXml(RecRef, XmlElement);
            until NpXmlTemplateTrigger.Next = 0;
        NpXmlTemplateTriggerLink.SetRange("Xml Template Code", NpXmlTemplate.Code);
        if NpXmlTemplateTriggerLink.FindSet then
            repeat
                RecRef.GetTable(NpXmlTemplateTriggerLink);
                ExportRecRefToXml(RecRef, XmlElement);
            until NpXmlTemplateTriggerLink.Next = 0;
        //-NC2.00
        NpXmlNamespaces.SetRange("Xml Template Code", NpXmlTemplate.Code);
        if NpXmlNamespaces.FindSet then
            repeat
                RecRef.GetTable(NpXmlNamespaces);
                ExportRecRefToXml(RecRef, XmlElement);
            until NpXmlNamespaces.Next = 0;
        //+NC2.00
        //-NC2.06 [265779]
        NpXmlApiHeader.SetRange("Xml Template Code", NpXmlTemplate.Code);
        if NpXmlApiHeader.FindSet then
            repeat
                RecRef.GetTable(NpXmlApiHeader);
                ExportRecRefToXml(RecRef, XmlElement);
            until NpXmlApiHeader.Next = 0;
        //+NC2.06 [265779]
        Clear(TempBlob);
        TempBlob.CreateOutStream(OutStr);
        XmlDoc.Save(OutStr);

        exit(TempBlob.HasValue);
        //+NC1.21
    end;

    local procedure InsertRecRefFromArchiveXml(var XmlElementTable: DotNet npNetXmlElement)
    var
        NpXmlTemplate: Record "NpXml Template";
        "Field": Record "Field";
        XmlCDATA: DotNet npNetXmlCDataSection;
        XmlElementField: DotNet npNetXmlElement;
        XmlNodeList: DotNet npNetXmlNodeList;
        RecRef: RecordRef;
        RecRefTemplate: RecordRef;
        RecordID: RecordID;
        FieldRef: FieldRef;
        FieldRefChanged: FieldRef;
        FieldId: Integer;
        TableId: Integer;
        i: Integer;
        PrimaryKey: Text;
        NetConvHelper: Variant;
    begin
        //+NC1.21
        if not Evaluate(TableId, XmlElementTable.GetAttribute('table_no'), 9) then
            exit;
        PrimaryKey := XmlElementTable.GetAttribute('primary_key');
        if PrimaryKey = '' then
            exit;

        Clear(RecRef);
        RecRef.Open(TableId);
        if XmlElementTable.GetAttribute('table_name') <> Format(RecRef.Name, 0, 9) then begin
            RecRef.Close;
            exit;
        end;

        if XmlElementTable.HasChildNodes then begin
            XmlNodeList := XmlElementTable.ChildNodes;
            for i := 0 to XmlNodeList.Count - 1 do begin
                XmlElementField := XmlNodeList.ItemOf(i);
                NetConvHelper := XmlElementField;
                XmlCDATA := NetConvHelper;
                if Evaluate(FieldId, XmlElementField.GetAttribute('field_no'), 9) and Field.Get(TableId, FieldId) then begin
                    FieldRef := RecRef.Field(FieldId);
                    if XmlElementField.GetAttribute('field_name') = Format(FieldRef.Name, 0, 9) then
                        AssignValue(FieldRef, XmlElementField.InnerText);
                end;
            end;
        end;

        if Format(RecRef.GetPosition(false), 0, 9) <> PrimaryKey then begin
            RecRef.Close;
            exit;
        end;

        //-NC1.22
        //RecRefTemplate.GETTABLE(NpXmlTemplate);
        //RecRefTemplate.FINDFIRST;
        //RecordID := RecRefTemplate.RECORDID;
        //IF (RecordID.TABLENO = TableId) THEN BEGIN
        //  FieldRefChanged := RecRef.FIELD(NpXmlTemplate.FIELDNO(Archived));
        //  FieldRefChanged.VALUE := FALSE;
        //  IF RecRef.INSERT(TRUE) THEN;
        //END ELSE
        //  IF RecRef.INSERT(FALSE) THEN;
        if RecRef.Insert(false) then;
        //+NC1.22
        RecRef.Close;
        //+NC1.21
    end;

    procedure RestoreArchivedNpXmlTemplate(TemplateCode: Code[20]; VersionCode: Code[10]): Boolean
    var
        NpXmlTemplate: Record "NpXml Template";
        MemoryStream: DotNet npNetMemoryStream;
        XmlDoc: DotNet npNetXmlDocument;
        XmlElement: DotNet npNetXmlElement;
        XmlElementTable: DotNet npNetXmlElement;
        XmlNodeList: DotNet npNetXmlNodeList;
        InStr: InStream;
        i: Integer;
        NpXmlTemplateArchive: Record "NpXml Template Archive";
        NpXmlTemplateHistory: Record "NpXml Template History";
    begin
        //-NC1.21
        if NpXmlTemplateArchive.Get(TemplateCode, VersionCode) then begin
            NpXmlTemplateArchive.CalcFields("Archived Template");
            if NpXmlTemplateArchive."Archived Template".HasValue then begin
                ClearTemplateVersion(TemplateCode);
                NpXmlTemplateArchive."Archived Template".CreateInStream(InStr);
                MemoryStream := InStr;
                XmlDoc := XmlDoc.XmlDocument;
                XmlDoc.Load(MemoryStream);
                MemoryStream.Flush;
                MemoryStream.Close;
                Clear(MemoryStream);

                XmlElement := XmlDoc.DocumentElement;
                if (XmlElement.GetAttribute('code') = TemplateCode) and XmlElement.HasChildNodes then begin
                    XmlNodeList := XmlElement.ChildNodes;
                    for i := 0 to XmlNodeList.Count - 1 do begin
                        XmlElementTable := XmlNodeList.ItemOf(i);
                        InsertRecRefFromArchiveXml(XmlElementTable);
                    end;
                end;
                Clear(XmlDoc);

                //-NC1.22
                if NpXmlTemplate.Get(TemplateCode) then
                    NpXmlTemplate.UpdateNaviConnectSetup();
                //+NC1.22
            end;
        end;

        NpXmlTemplateHistory.InsertHistory(TemplateCode, NpXmlTemplateArchive."Template Version No.", NpXmlTemplateHistory."Event Type"::Restore, NpXmlTemplate."Version Description");
        exit(true);
        //+NC1.21
    end;

    procedure "--- UI"()
    begin
    end;

    procedure CopyXmlTemplate(NPXmlTemplateCodeFrom: Code[20])
    var
        NPXmlTemplate: Record "NpXml Template";
        NPXmlTemplate2: Record "NpXml Template";
        NPXmlElement: Record "NpXml Element";
        NPXmlElement2: Record "NpXml Element";
        NPXmlAttribute: Record "NpXml Attribute";
        NPXmlAttribute2: Record "NpXml Attribute";
        NPXmlFilter: Record "NpXml Filter";
        NPXmlFilter2: Record "NpXml Filter";
    begin
        NPXmlTemplate.Get(NPXmlTemplateCodeFrom);

        if PAGE.RunModal(PAGE::"NpXml Template List", NPXmlTemplate2) <> ACTION::LookupOK then
            exit;

        NPXmlElement.SetRange("Xml Template Code", NPXmlTemplate.Code);
        NPXmlElement.DeleteAll(true);
        NPXmlAttribute.SetRange("Xml Template Code", NPXmlTemplate.Code);
        NPXmlAttribute.DeleteAll(true);
        NPXmlFilter.SetRange("Xml Template Code", NPXmlTemplate.Code);
        NPXmlFilter.DeleteAll(true);

        NPXmlElement2.SetRange("Xml Template Code", NPXmlTemplate2.Code);
        if NPXmlElement2.FindSet then
            repeat
                NPXmlElement.Init;
                NPXmlElement := NPXmlElement2;
                NPXmlElement."Xml Template Code" := NPXmlTemplate.Code;
                NPXmlElement.Insert(true);

                NPXmlAttribute2.SetRange("Xml Template Code", NPXmlElement2."Xml Template Code");
                NPXmlAttribute2.SetRange("Xml Element Line No.", NPXmlElement2."Line No.");
                if NPXmlAttribute2.FindSet then
                    repeat
                        NPXmlAttribute.Init;
                        NPXmlAttribute := NPXmlAttribute2;
                        NPXmlAttribute."Xml Template Code" := NPXmlElement."Xml Template Code";
                        NPXmlAttribute.Insert(true);
                    until NPXmlAttribute2.Next = 0;

                NPXmlFilter2.SetRange("Xml Template Code", NPXmlElement2."Xml Template Code");
                NPXmlFilter2.SetRange("Xml Element Line No.", NPXmlElement2."Line No.");
                if NPXmlFilter2.FindSet then
                    repeat
                        NPXmlFilter.Init;
                        NPXmlFilter := NPXmlFilter2;
                        NPXmlFilter."Xml Template Code" := NPXmlElement."Xml Template Code";
                        NPXmlFilter.Insert(true);
                    until NPXmlFilter2.Next = 0;
            until NPXmlElement2.Next = 0;
    end;

    procedure InitNpXmlElementAbove(TemplateCode: Code[20]; CurrLineNo: Integer; var NewNpXmlElement: Record "NpXml Element")
    var
        NpXmlElement: Record "NpXml Element";
    begin
        //-NC2.00
        NewNpXmlElement.Init;
        NewNpXmlElement."Xml Template Code" := TemplateCode;
        if not NpXmlElement.Get(TemplateCode, CurrLineNo) then begin
            NewNpXmlElement."Line No." := 1000;
            exit;
        end;

        NpXmlElement.SetRange("Xml Template Code", TemplateCode);
        if NpXmlElement.Next(-1) = 0 then begin
            if CurrLineNo / 2 <> Round(CurrLineNo / 2, 1) then begin
                NpXmlElement.Get(TemplateCode, CurrLineNo);
                NormalizeNpXmlElementLineNo(TemplateCode, NpXmlElement);
                NewNpXmlElement."Line No." := NpXmlElement."Line No." - 5000;
                exit;
            end;

            NewNpXmlElement."Line No." := CurrLineNo / 2;
            exit;
        end;

        if (NpXmlElement."Line No." - CurrLineNo) / 2 <> Round((NpXmlElement."Line No." - CurrLineNo) / 2, 1) then begin
            NormalizeNpXmlElementLineNo(TemplateCode, NpXmlElement);
            NewNpXmlElement."Line No." := NpXmlElement."Line No." + 5000;
            exit;
        end;

        NewNpXmlElement."Line No." := CurrLineNo + (NpXmlElement."Line No." - CurrLineNo) / 2;
        //+NC2.00
    end;

    procedure InitNpXmlElementBelow(TemplateCode: Code[20]; CurrLineNo: Integer; var NewNpXmlElement: Record "NpXml Element")
    var
        NpXmlElement: Record "NpXml Element";
    begin
        //-NC2.00
        NewNpXmlElement.Init;
        NewNpXmlElement."Xml Template Code" := TemplateCode;
        if not NpXmlElement.Get(TemplateCode, CurrLineNo) then begin
            NewNpXmlElement."Line No." := 1000;
            exit;
        end;

        NpXmlElement.SetRange("Xml Template Code", TemplateCode);
        if NpXmlElement.Next = 0 then begin
            NewNpXmlElement."Line No." := NpXmlElement."Line No." + 10000;
            exit;
        end;

        if (NpXmlElement."Line No." - CurrLineNo) / 2 <> Round((NpXmlElement."Line No." - CurrLineNo) / 2, 1) then begin
            NpXmlElement.Get(TemplateCode, CurrLineNo);
            NormalizeNpXmlElementLineNo(TemplateCode, NpXmlElement);
            NewNpXmlElement."Line No." := NpXmlElement."Line No." + 5000;
            exit;
        end;

        NewNpXmlElement."Line No." := CurrLineNo + (NpXmlElement."Line No." - CurrLineNo) / 2;
        //+NC2.00
    end;

    procedure LookupFieldValue(TableNo: Integer; FieldNo: Integer; var FieldValue: Text[250])
    var
        "Field": Record "Field";
        TempNpXmlFieldValueBuffer: Record "NpXml Field Value Buffer" temporary;
        RecRef: RecordRef;
        Fieldref: FieldRef;
        OptionCaption: Text;
        Position: Integer;
        i: Integer;
    begin
        if not Field.Get(TableNo, FieldNo) then
            exit;

        TempNpXmlFieldValueBuffer.DeleteAll;
        Clear(RecRef);
        RecRef.Open(TableNo);
        Fieldref := RecRef.Field(FieldNo);
        case LowerCase(Format(Fieldref.Type)) of
            'boolean':
                begin
                    TempNpXmlFieldValueBuffer.Init;
                    TempNpXmlFieldValueBuffer."Entry No." := 0;
                    TempNpXmlFieldValueBuffer."Field Value" := Format(false, 0, 9);
                    TempNpXmlFieldValueBuffer.Description := Format(false);
                    TempNpXmlFieldValueBuffer.Insert;

                    TempNpXmlFieldValueBuffer.Init;
                    TempNpXmlFieldValueBuffer."Entry No." := 1;
                    TempNpXmlFieldValueBuffer."Field Value" := Format(true, 0, 9);
                    TempNpXmlFieldValueBuffer.Description := Format(true);
                    TempNpXmlFieldValueBuffer.Insert;
                end;
            'option':
                begin
                    i := -1;
                    OptionCaption := Fieldref.OptionCaption;
                    while OptionCaption <> '' do begin
                        i += 1;
                        Position := StrPos(OptionCaption, ',');
                        if Position = 1 then
                            OptionCaption := DelStr(OptionCaption, 1, 1)
                        else begin
                            TempNpXmlFieldValueBuffer.Init;
                            TempNpXmlFieldValueBuffer."Entry No." := i;
                            TempNpXmlFieldValueBuffer."Field Value" := Format(i);
                            if Position > 1 then begin
                                TempNpXmlFieldValueBuffer.Description := CopyStr(OptionCaption, 1, Position - 1);
                                OptionCaption := DelStr(OptionCaption, 1, Position);
                            end else begin
                                TempNpXmlFieldValueBuffer.Description := OptionCaption;
                                OptionCaption := '';
                            end;
                            TempNpXmlFieldValueBuffer.Insert;
                        end;
                    end;
                end else
                        exit;
        end;
        RecRef.Close;
        Clear(RecRef);

        if TempNpXmlFieldValueBuffer.IsEmpty then
            exit;

        if PAGE.RunModal(PAGE::"NpXml Field Value Buffer", TempNpXmlFieldValueBuffer) = ACTION::LookupOK then
            FieldValue := TempNpXmlFieldValueBuffer."Field Value";

        TempNpXmlFieldValueBuffer.DeleteAll;
    end;

    procedure RunProcess(Filename: Text; Arguments: Text; RunModal: Boolean)
    var
        [RunOnClient]
        Process: DotNet npNetProcess;
        [RunOnClient]
        ProcessStartInfo: DotNet npNetProcessStartInfo;
    begin
        ProcessStartInfo := ProcessStartInfo.ProcessStartInfo(Filename, Arguments);
        Process := Process.Start(ProcessStartInfo);
        if RunModal then
            Process.WaitForExit();
    end;

    procedure "--- Swap Element Line No"()
    begin
    end;

    local procedure InsertTempNpXmlAttribute(NpXmlElement: Record "NpXml Element"; NpXmlElement2: Record "NpXml Element"; var TempNpXmlAttribute: Record "NpXml Attribute" temporary)
    var
        NpXmlAttribute: Record "NpXml Attribute";
    begin
        NpXmlAttribute.SetRange("Xml Template Code", NpXmlElement."Xml Template Code");
        NpXmlAttribute.SetRange("Xml Element Line No.", NpXmlElement."Line No.");
        if NpXmlAttribute.FindSet then
            repeat
                TempNpXmlAttribute.Init;
                TempNpXmlAttribute := NpXmlAttribute;
                TempNpXmlAttribute."Xml Element Line No." := NpXmlElement2."Line No.";
                TempNpXmlAttribute.Insert;
            until NpXmlAttribute.Next = 0;
    end;

    local procedure InsertTempNpXmlElement(NpXmlElement: Record "NpXml Element"; NpXmlElement2: Record "NpXml Element"; var TempNpXmlElement: Record "NpXml Element" temporary)
    begin
        TempNpXmlElement.Init;
        TempNpXmlElement := NpXmlElement;
        TempNpXmlElement."Line No." := NpXmlElement2."Line No.";
        TempNpXmlElement.Insert;
    end;

    local procedure InsertTempNpXmlFilter(NpXmlElement: Record "NpXml Element"; NpXmlElement2: Record "NpXml Element"; var TempNpXmlFilter: Record "NpXml Filter" temporary)
    var
        NpXmlFilter: Record "NpXml Filter";
    begin
        NpXmlFilter.SetRange("Xml Template Code", NpXmlElement."Xml Template Code");
        NpXmlFilter.SetRange("Xml Element Line No.", NpXmlElement."Line No.");
        if NpXmlFilter.FindSet then
            repeat
                TempNpXmlFilter.Init;
                TempNpXmlFilter := NpXmlFilter;
                TempNpXmlFilter."Xml Element Line No." := NpXmlElement2."Line No.";
                TempNpXmlFilter.Insert;
            until NpXmlFilter.Next = 0;
    end;

    local procedure InsertNpXmlAttributes(var TempNpXmlAttribute: Record "NpXml Attribute" temporary)
    var
        NpXmlAttribute: Record "NpXml Attribute";
    begin
        if TempNpXmlAttribute.FindSet then
            repeat
                NpXmlAttribute.Init;
                NpXmlAttribute := TempNpXmlAttribute;
                NpXmlAttribute.Insert;
            until TempNpXmlAttribute.Next = 0;
    end;

    local procedure InsertNpXmlElements(var TempNpXmlElement: Record "NpXml Element" temporary)
    var
        NpXmlElement: Record "NpXml Element";
    begin
        if TempNpXmlElement.FindSet then
            repeat
                NpXmlElement.Init;
                NpXmlElement := TempNpXmlElement;
                NpXmlElement.UpdateParentInfo();
                NpXmlElement.Insert;
            until TempNpXmlElement.Next = 0;
    end;

    local procedure InsertNpXmlFilters(var TempNpXmlFilter: Record "NpXml Filter" temporary)
    var
        NpXmlFilter: Record "NpXml Filter";
    begin
        if TempNpXmlFilter.FindSet then
            repeat
                NpXmlFilter.Init;
                NpXmlFilter := TempNpXmlFilter;
                NpXmlFilter.Insert;
            until TempNpXmlFilter.Next = 0;
    end;

    procedure NormalizeNpXmlElementLineNo(TemplateCode: Code[20]; var CurrNpXmlElement: Record "NpXml Element")
    var
        NpXmlElement: Record "NpXml Element";
        NpXmlElement2: Record "NpXml Element";
        TempNpXmlAttribute: Record "NpXml Attribute" temporary;
        TempNpXmlElement: Record "NpXml Element" temporary;
        TempNpXmlFilter: Record "NpXml Filter" temporary;
        LineNo: Integer;
        FormatedCurrNpXmlElement: Text;
    begin
        //-NC1.21
        if TemplateCode = '' then
            exit;

        //-NC2.00
        FormatedCurrNpXmlElement := Format(CurrNpXmlElement);
        //+NC2.00

        TempNpXmlAttribute.DeleteAll;
        TempNpXmlFilter.DeleteAll;
        TempNpXmlElement.DeleteAll;

        LineNo := 0;
        NpXmlElement.SetRange("Xml Template Code", TemplateCode);
        if NpXmlElement.FindSet then
            repeat
                LineNo += 10000;
                NpXmlElement2 := NpXmlElement;
                NpXmlElement2."Line No." := LineNo;
                InsertTempNpXmlElement(NpXmlElement, NpXmlElement2, TempNpXmlElement);
                InsertTempNpXmlAttribute(NpXmlElement, NpXmlElement2, TempNpXmlAttribute);
                InsertTempNpXmlFilter(NpXmlElement, NpXmlElement2, TempNpXmlFilter);

                //-NC2.00
                if Format(NpXmlElement) = FormatedCurrNpXmlElement then
                    CurrNpXmlElement := TempNpXmlElement;
                //+NC2.00
                DeleteNpXmlAttributes(NpXmlElement);
                DeleteNpXmlFilters(NpXmlElement);
                //-NC2.00
                //DeleteNpXmlElement(NpXmlElement);
                NpXmlElement.Delete;
            //+NC2.00
            until NpXmlElement.Next = 0;

        InsertNpXmlAttributes(TempNpXmlAttribute);
        InsertNpXmlFilters(TempNpXmlFilter);
        InsertNpXmlElements(TempNpXmlElement);

        TempNpXmlAttribute.DeleteAll;
        TempNpXmlFilter.DeleteAll;
        TempNpXmlElement.DeleteAll;
        //+NC1.21
    end;

    procedure SwapNpXmlElementLineNo(NpXmlElement: Record "NpXml Element"; NpXmlElement2: Record "NpXml Element")
    var
        TempNpXmlAttribute: Record "NpXml Attribute" temporary;
        TempNpXmlElement: Record "NpXml Element" temporary;
        TempNpXmlFilter: Record "NpXml Filter" temporary;
    begin
        NpXmlElement.TestField("Xml Template Code", NpXmlElement2."Xml Template Code");

        TempNpXmlAttribute.DeleteAll;
        TempNpXmlFilter.DeleteAll;
        TempNpXmlElement.DeleteAll;

        InsertTempNpXmlElement(NpXmlElement, NpXmlElement2, TempNpXmlElement);
        InsertTempNpXmlElement(NpXmlElement2, NpXmlElement, TempNpXmlElement);
        InsertTempNpXmlAttribute(NpXmlElement, NpXmlElement2, TempNpXmlAttribute);
        InsertTempNpXmlAttribute(NpXmlElement2, NpXmlElement, TempNpXmlAttribute);
        InsertTempNpXmlFilter(NpXmlElement, NpXmlElement2, TempNpXmlFilter);
        InsertTempNpXmlFilter(NpXmlElement2, NpXmlElement, TempNpXmlFilter);

        DeleteNpXmlAttributes(NpXmlElement);
        DeleteNpXmlAttributes(NpXmlElement2);
        DeleteNpXmlFilters(NpXmlElement);
        DeleteNpXmlFilters(NpXmlElement2);
        //-NC2.00
        //DeleteNpXmlElement(NpXmlElement);
        //DeleteNpXmlElement(NpXmlElement2);
        NpXmlElement.Delete;
        NpXmlElement2.Delete;
        //+NC2.00

        InsertNpXmlAttributes(TempNpXmlAttribute);
        InsertNpXmlFilters(TempNpXmlFilter);
        InsertNpXmlElements(TempNpXmlElement);

        TempNpXmlAttribute.DeleteAll;
        TempNpXmlFilter.DeleteAll;
        TempNpXmlElement.DeleteAll;
    end;

    procedure "--- Swap Trigger Line No"()
    begin
    end;

    local procedure DeleteNpXmlTrigger(NpXmlTemplateTrigger: Record "NpXml Template Trigger")
    var
        NpXmlTemplateTrigger2: Record "NpXml Template Trigger";
    begin
        NpXmlTemplateTrigger2.Get(NpXmlTemplateTrigger."Xml Template Code", NpXmlTemplateTrigger."Line No.");
        NpXmlTemplateTrigger2.Delete;
    end;

    local procedure DeleteNpXmlTriggerLink(NpXmlTemplateTrigger: Record "NpXml Template Trigger")
    var
        NpXmlTemplateTriggerLink: Record "NpXml Template Trigger Link";
    begin
        NpXmlTemplateTriggerLink.SetRange("Xml Template Code", NpXmlTemplateTrigger."Xml Template Code");
        NpXmlTemplateTriggerLink.SetRange("Xml Template Trigger Line No.", NpXmlTemplateTrigger."Line No.");
        NpXmlTemplateTriggerLink.DeleteAll;
    end;

    local procedure InsertTempNpXmlTrigger(NpXmlTemplateTrigger: Record "NpXml Template Trigger"; NpXmlTemplateTrigger2: Record "NpXml Template Trigger"; var TempNpXmlTemplateTrigger: Record "NpXml Template Trigger" temporary)
    begin
        TempNpXmlTemplateTrigger.Init;
        TempNpXmlTemplateTrigger := NpXmlTemplateTrigger;
        TempNpXmlTemplateTrigger."Line No." := NpXmlTemplateTrigger2."Line No.";
        TempNpXmlTemplateTrigger.Insert;
    end;

    local procedure InsertTempNpXmlTriggerLink(NpXmlTemplateTrigger: Record "NpXml Template Trigger"; NpXmlTemplateTrigger2: Record "NpXml Template Trigger"; var TempNpXmlTemplateTriggerLink: Record "NpXml Template Trigger Link" temporary)
    var
        NpXmlTemplateTriggerLink: Record "NpXml Template Trigger Link";
    begin
        NpXmlTemplateTriggerLink.SetRange("Xml Template Code", NpXmlTemplateTrigger."Xml Template Code");
        NpXmlTemplateTriggerLink.SetRange("Xml Template Trigger Line No.", NpXmlTemplateTrigger."Line No.");
        if NpXmlTemplateTriggerLink.FindSet then
            repeat
                TempNpXmlTemplateTriggerLink.Init;
                TempNpXmlTemplateTriggerLink := NpXmlTemplateTriggerLink;
                TempNpXmlTemplateTriggerLink."Xml Template Trigger Line No." := NpXmlTemplateTrigger2."Line No.";
                TempNpXmlTemplateTriggerLink.Insert;
            until NpXmlTemplateTriggerLink.Next = 0;
    end;

    local procedure InsertNpXmlTriggers(var TempNpXmlTemplateTrigger: Record "NpXml Template Trigger" temporary)
    var
        NpXmlTemplateTrigger: Record "NpXml Template Trigger";
    begin
        if TempNpXmlTemplateTrigger.FindSet then
            repeat
                NpXmlTemplateTrigger.Init;
                NpXmlTemplateTrigger := TempNpXmlTemplateTrigger;
                NpXmlTemplateTrigger.UpdateParentInfo();
                NpXmlTemplateTrigger.Insert;
            until TempNpXmlTemplateTrigger.Next = 0;
    end;

    local procedure InsertNpXmlTriggerLinks(var TempNpXmlTemplateTriggerLink: Record "NpXml Template Trigger Link" temporary)
    var
        NpXmlTemplateTriggerLink: Record "NpXml Template Trigger Link";
    begin
        if TempNpXmlTemplateTriggerLink.FindSet then
            repeat
                NpXmlTemplateTriggerLink.Init;
                NpXmlTemplateTriggerLink := TempNpXmlTemplateTriggerLink;
                NpXmlTemplateTriggerLink.Insert;
            until TempNpXmlTemplateTriggerLink.Next = 0;
    end;

    procedure SwapNpXmlTriggerLineNo(NpXmlTemplateTrigger: Record "NpXml Template Trigger"; NpXmlTemplateTrigger2: Record "NpXml Template Trigger")
    var
        TempNpXmlTemplateTrigger: Record "NpXml Template Trigger" temporary;
        TempNpXmlTemplateTriggerLink: Record "NpXml Template Trigger Link" temporary;
    begin
        NpXmlTemplateTrigger.TestField("Xml Template Code", NpXmlTemplateTrigger2."Xml Template Code");

        TempNpXmlTemplateTriggerLink.DeleteAll;
        TempNpXmlTemplateTrigger.DeleteAll;

        InsertTempNpXmlTrigger(NpXmlTemplateTrigger, NpXmlTemplateTrigger2, TempNpXmlTemplateTrigger);
        InsertTempNpXmlTrigger(NpXmlTemplateTrigger2, NpXmlTemplateTrigger, TempNpXmlTemplateTrigger);
        InsertTempNpXmlTriggerLink(NpXmlTemplateTrigger, NpXmlTemplateTrigger2, TempNpXmlTemplateTriggerLink);
        InsertTempNpXmlTriggerLink(NpXmlTemplateTrigger2, NpXmlTemplateTrigger, TempNpXmlTemplateTriggerLink);

        DeleteNpXmlTriggerLink(NpXmlTemplateTrigger);
        DeleteNpXmlTriggerLink(NpXmlTemplateTrigger2);
        DeleteNpXmlTrigger(NpXmlTemplateTrigger);
        DeleteNpXmlTrigger(NpXmlTemplateTrigger2);

        InsertNpXmlTriggerLinks(TempNpXmlTemplateTriggerLink);
        InsertNpXmlTriggers(TempNpXmlTemplateTrigger);

        TempNpXmlTemplateTriggerLink.DeleteAll;
        TempNpXmlTemplateTrigger.DeleteAll;
    end;
}

