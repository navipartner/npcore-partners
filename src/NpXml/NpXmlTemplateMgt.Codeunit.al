codeunit 6151556 "NPR NpXml Template Mgt."
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
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
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

    procedure GetNpXmlElement(TemplateCode: Code[20]; ElementPath: Text; Comment: Text[250]; var NpXmlElement: Record "NPR NpXml Element"): Boolean
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

    procedure GetChildNpXmlElement(NpXmlElementParent: Record "NPR NpXml Element"; ElementPath: Text; Comment: Text[250]; var NpXmlElement: Record "NPR NpXml Element"): Boolean
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
        NpXmlTemplate: Record "NPR NpXml Template";
        TempBlob: Codeunit "Temp Blob";
        FileMgt: Codeunit "File Management";
    begin
        //-NC1.21
        NpXmlTemplate.Get(TemplateCode);
        if NpXmlTemplateToBlob(NpXmlTemplate, TempBlob) then
            FileMgt.BLOBExport(TempBlob, LowerCase(NpXmlTemplate.Code) + '.xml', true);
        //+NC1.21
    end;

    procedure ExportRecRefToXml(RecRef: RecordRef; var XmlElement: DotNet NPRNetXmlElement)
    var
        "Field": Record "Field";
        FieldRef: FieldRef;
        XmlCDATA: DotNet NPRNetXmlCDataSection;
        XmlElementField: DotNet NPRNetXmlElement;
        XmlElementTable: DotNet NPRNetXmlElement;
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
        NpXmlTemplate: Record "NPR NpXml Template";
        TempBlob: Codeunit "Temp Blob";
        FileMgt: Codeunit "File Management";
        PathHelper: DotNet NPRNetPath;
        MemoryStream: DotNet NPRNetMemoryStream;
        XmlDoc: DotNet "NPRNetXmlDocument";
        XmlElement: DotNet NPRNetXmlElement;
        XmlElementTable: DotNet NPRNetXmlElement;
        XmlNodeList: DotNet NPRNetXmlNodeList;
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
        NpXmlTemplate: Record "NPR NpXml Template";
        HttpWebRequest: DotNet NPRNetHttpWebRequest;
        HttpWebResponse: DotNet NPRNetHttpWebResponse;
        MemoryStream: DotNet NPRNetMemoryStream;
        XmlDoc: DotNet "NPRNetXmlDocument";
        XmlElement: DotNet NPRNetXmlElement;
        XmlElementTable: DotNet NPRNetXmlElement;
        XmlNodeList: DotNet NPRNetXmlNodeList;
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

    procedure InsertRecRefFromXml(var XmlElementTable: DotNet NPRNetXmlElement)
    var
        "Field": Record "Field";
        FieldRef: FieldRef;
        RecRef: RecordRef;
        XmlElementField: DotNet NPRNetXmlElement;
        XmlNodeList: DotNet NPRNetXmlNodeList;
        FieldID: Integer;
        TableID: Integer;
        i: Integer;
        PrimaryKey: Text;
        XmlCDATA: DotNet NPRNetXmlCDataSection;
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
        NPXmlAttribute: Record "NPR NpXml Attribute";
        NPXmlElement: Record "NPR NpXml Element";
        NPXmlFilter: Record "NPR NpXml Filter";
        NPXmlTemplate: Record "NPR NpXml Template";
        FileMgt: Codeunit "File Management";
        XmlDoc: DotNet "NPRNetXmlDocument";
        XmlElement: DotNet NPRNetXmlElement;
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

    local procedure InsertNpXmlElement(NPXmlTemplate: Record "NPR NpXml Template"; XmlElement: DotNet NPRNetXmlElement; var LineNo: Integer; Level: Integer)
    var
        NPXmlAttribute: Record "NPR NpXml Attribute";
        NPXmlElement: Record "NPR NpXml Element";
        ChildXmlElement: DotNet NPRNetXmlElement;
        XmlAttribute: DotNet NPRNetXmlElement;
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

    local procedure DeleteNpXmlAttributes(NpXmlElement: Record "NPR NpXml Element")
    var
        NpXmlAttribute: Record "NPR NpXml Attribute";
    begin
        NpXmlAttribute.SetRange("Xml Template Code", NpXmlElement."Xml Template Code");
        NpXmlAttribute.SetRange("Xml Element Line No.", NpXmlElement."Line No.");
        NpXmlAttribute.DeleteAll;
    end;

    local procedure DeleteNpXmlElement(NpXmlElement: Record "NPR NpXml Element")
    var
        NpXmlElement2: Record "NPR NpXml Element";
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
        NpXmlTemplate: Record "NPR NpXml Template";
        NpXmlElement: Record "NPR NpXml Element";
    begin
        //-NC2.00
        if not NpXmlTemplate.Get(TemplateCode) then
            exit;
        if not GetNpXmlElement(TemplateCode, ElementPath, Comment, NpXmlElement) then
            exit;

        DeleteNpXmlElement(NpXmlElement);
        //+NC2.00
    end;

    local procedure DeleteNpXmlFilters(NpXmlElement: Record "NPR NpXml Element")
    var
        NpXmlFilter: Record "NPR NpXml Filter";
    begin
        NpXmlFilter.SetRange("Xml Template Code", NpXmlElement."Xml Template Code");
        NpXmlFilter.SetRange("Xml Element Line No.", NpXmlElement."Line No.");
        NpXmlFilter.DeleteAll;
    end;

    procedure SetChildNpXmlElementsActive(NpXmlElement: Record "NPR NpXml Element"; Active: Boolean)
    var
        NpXmlElement2: Record "NPR NpXml Element";
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
        NpXmlTemplate: Record "NPR NpXml Template";
        NpXmlElement: Record "NPR NpXml Element";
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
        NpXmlFilter: Record "NPR NpXml Filter";
    begin
        NpXmlFilter.SetRange("Xml Template Code", TemplateCode);
        NpXmlFilter.SetRange("Xml Element Line No.", ElementLineNo);
        NpXmlFilter.SetRange("Field No.", FieldNo);
        NpXmlFilter.ModifyAll("Filter Value", FilterValue);
    end;

    procedure "--- Version Control"()
    begin
    end;

    procedure Archive(var NpXmlTemplate: Record "NPR NpXml Template"): Boolean
    var
        TempBlob: Codeunit "Temp Blob";
        NpXmlTemplateArchive: Record "NPR NpXml Template Arch.";
        NpXmlTemplateHistory: Record "NPR NpXml Template History";
        NpXmlSetup: Record "NPR NpXml Setup";
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
        NpXmlAttribute: Record "NPR NpXml Attribute";
        NpXmlElement: Record "NPR NpXml Element";
        NpXmlFilter: Record "NPR NpXml Filter";
        NpXmlTemplateTrigger: Record "NPR NpXml Template Trigger";
        NpXmlTemplateTriggerLink: Record "NPR NpXml Templ.Trigger Link";
        NpXmlTemplate: Record "NPR NpXml Template";
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

    procedure ExportArchivedNpXmlTemplate(NpXmlTemplateArchive: Record "NPR NpXml Template Arch.")
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

    procedure NpXmlTemplateToBlob(var NpXmlTemplate: Record "NPR NpXml Template"; var TempBlob: Codeunit "Temp Blob"): Boolean
    var
        NpXmlApiHeader: Record "NPR NpXml Api Header";
        NpXmlAttribute: Record "NPR NpXml Attribute";
        NpXmlElement: Record "NPR NpXml Element";
        NpXmlFilter: Record "NPR NpXml Filter";
        NpXmlNamespaces: Record "NPR NpXml Namespace";
        NpXmlTemplateTrigger: Record "NPR NpXml Template Trigger";
        NpXmlTemplateTriggerLink: Record "NPR NpXml Templ.Trigger Link";
        XmlDoc: DotNet "NPRNetXmlDocument";
        XmlElement: DotNet NPRNetXmlElement;
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

    local procedure InsertRecRefFromArchiveXml(var XmlElementTable: DotNet NPRNetXmlElement)
    var
        NpXmlTemplate: Record "NPR NpXml Template";
        "Field": Record "Field";
        XmlCDATA: DotNet NPRNetXmlCDataSection;
        XmlElementField: DotNet NPRNetXmlElement;
        XmlNodeList: DotNet NPRNetXmlNodeList;
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
        NpXmlTemplate: Record "NPR NpXml Template";
        MemoryStream: DotNet NPRNetMemoryStream;
        XmlDoc: DotNet "NPRNetXmlDocument";
        XmlElement: DotNet NPRNetXmlElement;
        XmlElementTable: DotNet NPRNetXmlElement;
        XmlNodeList: DotNet NPRNetXmlNodeList;
        InStr: InStream;
        i: Integer;
        NpXmlTemplateArchive: Record "NPR NpXml Template Arch.";
        NpXmlTemplateHistory: Record "NPR NpXml Template History";
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
        NPXmlTemplate: Record "NPR NpXml Template";
        NPXmlTemplate2: Record "NPR NpXml Template";
        NPXmlElement: Record "NPR NpXml Element";
        NPXmlElement2: Record "NPR NpXml Element";
        NPXmlAttribute: Record "NPR NpXml Attribute";
        NPXmlAttribute2: Record "NPR NpXml Attribute";
        NPXmlFilter: Record "NPR NpXml Filter";
        NPXmlFilter2: Record "NPR NpXml Filter";
    begin
        NPXmlTemplate.Get(NPXmlTemplateCodeFrom);

        if PAGE.RunModal(PAGE::"NPR NpXml Template List", NPXmlTemplate2) <> ACTION::LookupOK then
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

    procedure InitNpXmlElementAbove(TemplateCode: Code[20]; CurrLineNo: Integer; var NewNpXmlElement: Record "NPR NpXml Element")
    var
        NpXmlElement: Record "NPR NpXml Element";
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

    procedure InitNpXmlElementBelow(TemplateCode: Code[20]; CurrLineNo: Integer; var NewNpXmlElement: Record "NPR NpXml Element")
    var
        NpXmlElement: Record "NPR NpXml Element";
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
        TempNpXmlFieldValueBuffer: Record "NPR NpXml Field Val. Buffer" temporary;
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

        if PAGE.RunModal(PAGE::"NPR NpXml Field Value Buffer", TempNpXmlFieldValueBuffer) = ACTION::LookupOK then
            FieldValue := TempNpXmlFieldValueBuffer."Field Value";

        TempNpXmlFieldValueBuffer.DeleteAll;
    end;

    procedure RunProcess(Filename: Text; Arguments: Text; RunModal: Boolean)
    var
        [RunOnClient]
        Process: DotNet NPRNetProcess;
        [RunOnClient]
        ProcessStartInfo: DotNet NPRNetProcessStartInfo;
    begin
        ProcessStartInfo := ProcessStartInfo.ProcessStartInfo(Filename, Arguments);
        Process := Process.Start(ProcessStartInfo);
        if RunModal then
            Process.WaitForExit();
    end;

    procedure "--- Swap Element Line No"()
    begin
    end;

    local procedure InsertTempNpXmlAttribute(NpXmlElement: Record "NPR NpXml Element"; NpXmlElement2: Record "NPR NpXml Element"; var TempNpXmlAttribute: Record "NPR NpXml Attribute" temporary)
    var
        NpXmlAttribute: Record "NPR NpXml Attribute";
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

    local procedure InsertTempNpXmlElement(NpXmlElement: Record "NPR NpXml Element"; NpXmlElement2: Record "NPR NpXml Element"; var TempNpXmlElement: Record "NPR NpXml Element" temporary)
    begin
        TempNpXmlElement.Init;
        TempNpXmlElement := NpXmlElement;
        TempNpXmlElement."Line No." := NpXmlElement2."Line No.";
        TempNpXmlElement.Insert;
    end;

    local procedure InsertTempNpXmlFilter(NpXmlElement: Record "NPR NpXml Element"; NpXmlElement2: Record "NPR NpXml Element"; var TempNpXmlFilter: Record "NPR NpXml Filter" temporary)
    var
        NpXmlFilter: Record "NPR NpXml Filter";
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

    local procedure InsertNpXmlAttributes(var TempNpXmlAttribute: Record "NPR NpXml Attribute" temporary)
    var
        NpXmlAttribute: Record "NPR NpXml Attribute";
    begin
        if TempNpXmlAttribute.FindSet then
            repeat
                NpXmlAttribute.Init;
                NpXmlAttribute := TempNpXmlAttribute;
                NpXmlAttribute.Insert;
            until TempNpXmlAttribute.Next = 0;
    end;

    local procedure InsertNpXmlElements(var TempNpXmlElement: Record "NPR NpXml Element" temporary)
    var
        NpXmlElement: Record "NPR NpXml Element";
    begin
        if TempNpXmlElement.FindSet then
            repeat
                NpXmlElement.Init;
                NpXmlElement := TempNpXmlElement;
                NpXmlElement.UpdateParentInfo();
                NpXmlElement.Insert;
            until TempNpXmlElement.Next = 0;
    end;

    local procedure InsertNpXmlFilters(var TempNpXmlFilter: Record "NPR NpXml Filter" temporary)
    var
        NpXmlFilter: Record "NPR NpXml Filter";
    begin
        if TempNpXmlFilter.FindSet then
            repeat
                NpXmlFilter.Init;
                NpXmlFilter := TempNpXmlFilter;
                NpXmlFilter.Insert;
            until TempNpXmlFilter.Next = 0;
    end;

    procedure NormalizeNpXmlElementLineNo(TemplateCode: Code[20]; var CurrNpXmlElement: Record "NPR NpXml Element")
    var
        NpXmlElement: Record "NPR NpXml Element";
        NpXmlElement2: Record "NPR NpXml Element";
        TempNpXmlAttribute: Record "NPR NpXml Attribute" temporary;
        TempNpXmlElement: Record "NPR NpXml Element" temporary;
        TempNpXmlFilter: Record "NPR NpXml Filter" temporary;
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

    procedure SwapNpXmlElementLineNo(NpXmlElement: Record "NPR NpXml Element"; NpXmlElement2: Record "NPR NpXml Element")
    var
        TempNpXmlAttribute: Record "NPR NpXml Attribute" temporary;
        TempNpXmlElement: Record "NPR NpXml Element" temporary;
        TempNpXmlFilter: Record "NPR NpXml Filter" temporary;
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

    local procedure DeleteNpXmlTrigger(NpXmlTemplateTrigger: Record "NPR NpXml Template Trigger")
    var
        NpXmlTemplateTrigger2: Record "NPR NpXml Template Trigger";
    begin
        NpXmlTemplateTrigger2.Get(NpXmlTemplateTrigger."Xml Template Code", NpXmlTemplateTrigger."Line No.");
        NpXmlTemplateTrigger2.Delete;
    end;

    local procedure DeleteNpXmlTriggerLink(NpXmlTemplateTrigger: Record "NPR NpXml Template Trigger")
    var
        NpXmlTemplateTriggerLink: Record "NPR NpXml Templ.Trigger Link";
    begin
        NpXmlTemplateTriggerLink.SetRange("Xml Template Code", NpXmlTemplateTrigger."Xml Template Code");
        NpXmlTemplateTriggerLink.SetRange("Xml Template Trigger Line No.", NpXmlTemplateTrigger."Line No.");
        NpXmlTemplateTriggerLink.DeleteAll;
    end;

    local procedure InsertTempNpXmlTrigger(NpXmlTemplateTrigger: Record "NPR NpXml Template Trigger"; NpXmlTemplateTrigger2: Record "NPR NpXml Template Trigger"; var TempNpXmlTemplateTrigger: Record "NPR NpXml Template Trigger" temporary)
    begin
        TempNpXmlTemplateTrigger.Init;
        TempNpXmlTemplateTrigger := NpXmlTemplateTrigger;
        TempNpXmlTemplateTrigger."Line No." := NpXmlTemplateTrigger2."Line No.";
        TempNpXmlTemplateTrigger.Insert;
    end;

    local procedure InsertTempNpXmlTriggerLink(NpXmlTemplateTrigger: Record "NPR NpXml Template Trigger"; NpXmlTemplateTrigger2: Record "NPR NpXml Template Trigger"; var TempNpXmlTemplateTriggerLink: Record "NPR NpXml Templ.Trigger Link" temporary)
    var
        NpXmlTemplateTriggerLink: Record "NPR NpXml Templ.Trigger Link";
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

    local procedure InsertNpXmlTriggers(var TempNpXmlTemplateTrigger: Record "NPR NpXml Template Trigger" temporary)
    var
        NpXmlTemplateTrigger: Record "NPR NpXml Template Trigger";
    begin
        if TempNpXmlTemplateTrigger.FindSet then
            repeat
                NpXmlTemplateTrigger.Init;
                NpXmlTemplateTrigger := TempNpXmlTemplateTrigger;
                NpXmlTemplateTrigger.UpdateParentInfo();
                NpXmlTemplateTrigger.Insert;
            until TempNpXmlTemplateTrigger.Next = 0;
    end;

    local procedure InsertNpXmlTriggerLinks(var TempNpXmlTemplateTriggerLink: Record "NPR NpXml Templ.Trigger Link" temporary)
    var
        NpXmlTemplateTriggerLink: Record "NPR NpXml Templ.Trigger Link";
    begin
        if TempNpXmlTemplateTriggerLink.FindSet then
            repeat
                NpXmlTemplateTriggerLink.Init;
                NpXmlTemplateTriggerLink := TempNpXmlTemplateTriggerLink;
                NpXmlTemplateTriggerLink.Insert;
            until TempNpXmlTemplateTriggerLink.Next = 0;
    end;

    procedure SwapNpXmlTriggerLineNo(NpXmlTemplateTrigger: Record "NPR NpXml Template Trigger"; NpXmlTemplateTrigger2: Record "NPR NpXml Template Trigger")
    var
        TempNpXmlTemplateTrigger: Record "NPR NpXml Template Trigger" temporary;
        TempNpXmlTemplateTriggerLink: Record "NPR NpXml Templ.Trigger Link" temporary;
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

