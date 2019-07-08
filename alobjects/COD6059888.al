codeunit 6059888 "Npm Metadata Mgt."
{
    // NPR5.33/MHA /20170126  CASE 264348 Object created - Module: Np Page Manager


    trigger OnRun()
    begin
    end;

    var
        Window: Dialog;
        Counter: Integer;
        Total: Integer;
        Text000: Label 'Loading Pages: @1@@@@@@@@@@@@@@@@@@@@@@@';
        Text001: Label 'Page %1 does not exist or has not been compiled';

    local procedure "--- UpdateMetadata"()
    begin
    end;

    procedure ApplyNpmChanges(var NpmPage: Record "Npm Page")
    begin
        NpmPage.CalcFields("Npm Enabled");
        if NpmPage."Npm Enabled" then
          ApplyNpmMetadata(NpmPage)
        else
          ResetNpmMetadata(NpmPage);
    end;

    local procedure ApplyNpmMetadata(var NpmPage: Record "Npm Page")
    var
        ObjectMetadata: Record "Object Metadata";
        NpmField: Record "Npm Field";
        XmlDoc: DotNet XmlDocument;
        XmlNSManager: DotNet XmlNamespaceManager;
        OutStream: OutStream;
    begin
        if not LoadPageOriginalMetadataXml(NpmPage,XmlDoc,XmlNSManager) then
          exit;

        AddNpmMark(XmlDoc);

        ApplyPageViews(NpmPage,XmlDoc,XmlNSManager);

        Clear(NpmPage."Latest Metadata");
        NpmPage."Latest Metadata".CreateOutStream(OutStream);
        XmlDoc.Save(OutStream);
        NpmPage.Modify(true);

        ObjectMetadata.Get(ObjectMetadata."Object Type"::Page,NpmPage."Page ID");
        ObjectMetadata.Metadata := NpmPage."Latest Metadata";
        ObjectMetadata.Modify(true);
    end;

    local procedure ApplyPageViews(NpmPage: Record "Npm Page";var XmlDoc: DotNet XmlDocument;var XmlNSManager: DotNet XmlNamespaceManager)
    var
        NpmPageView: Record "Npm Page View";
    begin
        NpmPageView.SetRange("Page ID",NpmPage."Page ID");
        if NpmPageView.IsEmpty then
          exit;
        NpmPageView.FindSet;
        repeat
          if NpmPageView."Show Mandatory Fields" then
            AddShowMandatory(NpmPageView,XmlDoc,XmlNSManager);
          if NpmPageView."Show Field Captions" then
            AddShowFieldCaption(NpmPageView,XmlDoc,XmlNSManager);
        until NpmPageView.Next = 0;
    end;

    procedure ResetNpmMetadata(var NpmPage: Record "Npm Page")
    var
        ObjectMetadata: Record "Object Metadata";
        XmlDoc: DotNet XmlDocument;
        XmlNSManager: DotNet XmlNamespaceManager;
    begin
        if not LoadPageOriginalMetadataXml(NpmPage,XmlDoc,XmlNSManager) then
          exit;
        if not ObjectMetadata.Get(ObjectMetadata."Object Type"::Page,NpmPage."Page ID") then
          exit;

        if not LoadMetadataXml(ObjectMetadata,XmlDoc) then
          exit;

        if not HasNpmMark(XmlDoc) then
          exit;

        NpmPage.CalcFields("Original Metadata");
        ObjectMetadata.Metadata := NpmPage."Original Metadata";
        ObjectMetadata.Modify(true);
    end;

    local procedure AddShowMandatory(var NpmPageView: Record "Npm Page View";var XmlDoc: DotNet XmlDocument;var XmlNSManager: DotNet XmlNamespaceManager)
    var
        ObjectMetadata: Record "Object Metadata";
        NpmField: Record "Npm Field";
        XmlElement: DotNet XmlElement;
        XmlElementField: DotNet XmlElement;
        XmlNodeList: DotNet XmlNodeList;
        i: Integer;
    begin
        NpmPageView.CalcFields("Source Table No.");
        NpmField.SetRange(Type,NpmField.Type::Mandatory);
        NpmField.SetRange("Table No.",NpmPageView."Source Table No.");
        NpmField.SetRange("View Code",NpmPageView."View Code");
        if NpmField.IsEmpty then
          exit;

        XmlElement := XmlDoc.DocumentElement;
        if IsNull(XmlElement) then
          exit;

        NpmField.FindSet;
        repeat
          XmlNodeList := XmlElement.SelectNodes('//nav:Controls[@DataColumnName=' + Format(NpmField."Field No.") + ']',XmlNSManager);
          for i := 0 to XmlNodeList.Count - 1 do begin
            XmlElementField := XmlNodeList.Item(i);
            AddAttribute(XmlElementField,'ShowMandatory','TRUE');
          end;
        until NpmField.Next = 0;
    end;

    local procedure AddShowFieldCaption(var NpmPageView: Record "Npm Page View";var XmlDoc: DotNet XmlDocument;var XmlNSManager: DotNet XmlNamespaceManager)
    var
        ObjectMetadata: Record "Object Metadata";
        NpmField: Record "Npm Field";
        XmlElement: DotNet XmlElement;
        XmlElementField: DotNet XmlElement;
        XmlNodeList: DotNet XmlNodeList;
        i: Integer;
        CaptionStringML: Text;
    begin
        NpmPageView.CalcFields("Source Table No.");
        NpmField.SetRange(Type,NpmField.Type::Caption);
        NpmField.SetRange("Table No.",NpmPageView."Source Table No.");
        NpmField.SetRange("View Code",NpmPageView."View Code");
        if NpmField.IsEmpty then
          exit;

        XmlElement := XmlDoc.DocumentElement;
        if IsNull(XmlElement) then
          exit;

        NpmField.FindSet;
        repeat
          CaptionStringML := GetCaptionStringML(NpmField);
          if CaptionStringML <> '' then begin
            XmlNodeList := XmlElement.SelectNodes('//nav:Controls[@DataColumnName=' + Format(NpmField."Field No.") + ']',XmlNSManager);
            for i := 0 to XmlNodeList.Count - 1 do begin
              XmlElementField := XmlNodeList.Item(i);
              AddAttribute(XmlElementField,'CaptionML',CaptionStringML);
            end;
          end;
        until NpmField.Next = 0;
    end;

    local procedure AddNpmMark(var XmlDoc: DotNet XmlDocument)
    var
        XmlComment: DotNet XmlComment;
    begin
        XmlComment := XmlDoc.CreateComment(NpmMark());
        XmlDoc.InsertBefore(XmlComment,XmlDoc.DocumentElement);
    end;

    local procedure HasNpmMark(var XmlDoc: DotNet XmlDocument): Boolean
    var
        XmlComment: DotNet XmlComment;
    begin
        XmlComment := XmlDoc.DocumentElement.PreviousSibling;
        if IsNull(XmlComment) then
          exit(false);

        exit(XmlComment.InnerText = NpmMark);
    end;

    local procedure "--- Subscribers"()
    begin
    end;

    [EventSubscriber(ObjectType::Table, 6059892, 'OnAfterInsertEvent', '', true, true)]
    local procedure OnInsertPageView(var Rec: Record "Npm Page View")
    var
        NpmPage: Record "Npm Page";
    begin
        if Rec.IsTemporary then
          exit;

        if not (Rec."Show Mandatory Fields" or Rec."Show Field Captions") then
          exit;

        if not NpmPage.Get(Rec."Page ID") then
          exit;
        NpmPage.CalcFields("Npm Enabled");
        ApplyNpmChanges(NpmPage);
    end;

    [EventSubscriber(ObjectType::Table, 6059892, 'OnAfterModifyEvent', '', true, true)]
    local procedure OnModifyPageView(var Rec: Record "Npm Page View";var xRec: Record "Npm Page View")
    var
        NpmPage: Record "Npm Page";
    begin
        if Rec.IsTemporary then
          exit;

        if not NpmPage.Get(Rec."Page ID") then
          exit;

        ApplyNpmChanges(NpmPage);
    end;

    [EventSubscriber(ObjectType::Table, 6059892, 'OnAfterDeleteEvent', '', true, true)]
    local procedure OnDeletePageView(var Rec: Record "Npm Page View")
    var
        NpmPage: Record "Npm Page";
    begin
        if Rec.IsTemporary then
          exit;

        if not (Rec."Show Mandatory Fields" or Rec."Show Field Captions") then
          exit;

        if not NpmPage.Get(Rec."Page ID") then
          exit;

        ApplyNpmChanges(NpmPage);
    end;

    [EventSubscriber(ObjectType::Table, 6059888, 'OnBeforeDeleteEvent', '', true, true)]
    local procedure OnDeleteNpmPage(var Rec: Record "Npm Page";RunTrigger: Boolean)
    begin
        ResetNpmMetadata(Rec);
    end;

    local procedure "--- Update Pages"()
    begin
    end;

    procedure LoadNpmPages()
    var
        ObjectMetadata: Record "Object Metadata";
    begin
        ObjectMetadata.SetRange("Object Type",ObjectMetadata."Object Type"::Page);
        if ObjectMetadata.IsEmpty then
          exit;

        if UseDialog() then begin
          Window.Open(Text000);
          Counter := 0;
          Total := ObjectMetadata.Count;
        end;
        ObjectMetadata.FindSet;
        repeat
          if UseDialog() then begin
            Counter += 1;
            Window.Update(1,Round((Counter / Total) * 10000,1));
          end;

          LoadNpmPage(ObjectMetadata);
        until ObjectMetadata.Next = 0;
        if UseDialog() then
          Window.Close;
    end;

    local procedure LoadNpmPage(ObjectMetadata: Record "Object Metadata")
    var
        NpmPage: Record "Npm Page";
        XmlDoc: DotNet XmlDocument;
        XmlElement: DotNet XmlElement;
        SourceTableID: Integer;
    begin
        if ObjectMetadata."Object Type" <> ObjectMetadata."Object Type"::Page then
          exit;

        if not LoadMetadataXml(ObjectMetadata,XmlDoc) then
          exit;

        RemoveNameSpaces(XmlDoc);
        XmlElement := XmlDoc.DocumentElement.SelectSingleNode('Properties/SourceObject');
        if IsNull(XmlElement) then
          exit;

        if not Evaluate(SourceTableID,XmlElement.GetAttribute('SourceTable'),9) then
          exit;

        if not NpmPage.Get(ObjectMetadata."Object ID") then begin
          ObjectMetadata.CalcFields(Metadata);

          NpmPage.Init;
          NpmPage."Page ID" := ObjectMetadata."Object ID";
          NpmPage."Source Table No." := SourceTableID;
          NpmPage.Insert(true);
        end else if NpmPage."Source Table No." <> SourceTableID then begin
          NpmPage."Source Table No." := SourceTableID;
          NpmPage.Modify(true);
        end;
    end;

    local procedure "--- Xml Dom"()
    begin
    end;

    procedure AddAttribute(var XmlNode: DotNet XmlNode;Name: Text[260];NodeValue: Text[260]) ExitStatus: Integer
    var
        NewAttributeXmlNode: DotNet XmlNode;
    begin
        NewAttributeXmlNode := XmlNode.OwnerDocument.CreateAttribute(Name);

        if IsNull(NewAttributeXmlNode) then begin
          ExitStatus := 60;
          exit(ExitStatus)
        end;

        if NodeValue <> '' then
          NewAttributeXmlNode.InnerText := NodeValue;

        XmlNode.Attributes.SetNamedItem(NewAttributeXmlNode);
    end;

    [TryFunction]
    procedure LoadXmlInStream(var InStream: InStream;var XmlDoc: DotNet XmlDocument)
    begin
        XmlDoc := XmlDoc.XmlDocument;
        XmlDoc.Load(InStream);
    end;

    [TryFunction]
    procedure LoadXmlString(XmlString: Text;var XmlDoc: DotNet XmlDocument)
    begin
        XmlDoc := XmlDoc.XmlDocument;
        XmlDoc.LoadXml(XmlString);
    end;

    local procedure LoadMetadataXml(ObjectMetadata: Record "Object Metadata";var XmlDoc: DotNet XmlDocument): Boolean
    var
        InStream: InStream;
    begin
        if not ObjectMetadata.Metadata.HasValue then
          exit(false);

        ObjectMetadata.CalcFields(Metadata);
        ObjectMetadata.Metadata.CreateInStream(InStream);
        if not LoadXmlInStream(InStream,XmlDoc) then
          exit(false);

        exit(not IsNull(XmlDoc.DocumentElement));
    end;

    local procedure LoadPageOriginalMetadataXml(var NpmPage: Record "Npm Page";var XmlDoc: DotNet XmlDocument;var XmlNSManager: DotNet XmlNamespaceManager): Boolean
    var
        ObjectMetadata: Record "Object Metadata";
        InStream: InStream;
    begin
        if not ObjectMetadata.Get(ObjectMetadata."Object Type"::Page,NpmPage."Page ID") then
          Error(Text001,NpmPage."Page ID");

        if LoadMetadataXml(ObjectMetadata,XmlDoc) and (not HasNpmMark(XmlDoc)) then begin
          ObjectMetadata.CalcFields(Metadata);
          NpmPage."Original Metadata" := ObjectMetadata.Metadata;
        end;

        if not NpmPage."Original Metadata".HasValue then
          exit(false);

        NpmPage.CalcFields("Original Metadata");
        NpmPage."Original Metadata".CreateInStream(InStream);
        if not LoadXmlInStream(InStream,XmlDoc) then
          exit(false);

        XmlNSManager := XmlNSManager.XmlNamespaceManager(XmlDoc.NameTable);
        XmlNSManager.AddNamespace('nav','urn:schemas-microsoft-com:dynamics:NAV:MetaObjects');
        exit(not IsNull(XmlDoc.DocumentElement));
    end;

    local procedure NpmMark(): Text
    begin
        exit('Updated by Np Page Manager');
    end;

    procedure RemoveNameSpaces(var XmlDoc: DotNet XmlDocument)
    var
        MemoryStream: DotNet MemoryStream;
        MemoryStream2: DotNet MemoryStream;
        XmlStyleSheet: DotNet XmlDocument;
        XslCompiledTransform: DotNet XslCompiledTransform;
        XmlReader: DotNet XmlReader;
        XmlWriter: DotNet XmlWriter;
    begin
        if IsNull(XmlStyleSheet) then begin
          XmlStyleSheet := XmlStyleSheet.XmlDocument;
          XmlStyleSheet.LoadXml('<?xml version="1.0" encoding="UTF-8"?>' +
                                '<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">' +
                                  '<xsl:output method="xml" encoding="UTF-8" />' +
                                  '<xsl:template match="/">' +
                                    '<xsl:copy>' +
                                      '<xsl:apply-templates />' +
                                    '</xsl:copy>' +
                                  '</xsl:template>' +
                                  '<xsl:template match="*">' +
                                    '<xsl:element name="{local-name()}">' +
                                       '<xsl:apply-templates select="@* | node()" />' +
                                    '</xsl:element>' +
                                  '</xsl:template>' +
                                  '<xsl:template match="@*">' +
                                    '<xsl:attribute name="{local-name()}"><xsl:value-of select="."/></xsl:attribute>' +
                                  '</xsl:template>' +
                                  '<xsl:template match="text() | processing-instruction() | comment()">' +
                                    '<xsl:copy />' +
                                  '</xsl:template>' +
                                '</xsl:stylesheet>');
          XslCompiledTransform := XslCompiledTransform.XslCompiledTransform;
          XslCompiledTransform.Load(XmlStyleSheet);
        end;
        MemoryStream := MemoryStream.MemoryStream;
        XmlDoc.Save(MemoryStream);
        MemoryStream.Position := 0;
        XmlReader := XmlReader.Create(MemoryStream);

        MemoryStream2 := MemoryStream2.MemoryStream;
        XmlWriter := XmlWriter.Create(MemoryStream2);
        XslCompiledTransform.Transform(XmlReader,XmlWriter);
        MemoryStream2.Position := 0;

        Clear(XmlDoc);
        XmlDoc := XmlDoc.XmlDocument;
        XmlDoc.Load(MemoryStream2);
    end;

    local procedure "--- Aux"()
    begin
    end;

    local procedure UseDialog(): Boolean
    begin
        exit(GuiAllowed);
    end;

    local procedure GetCaptionStringML(NpmField: Record "Npm Field") CaptionStringML: Text
    var
        NpmFieldCaption: Record "Npm Field Caption";
    begin
        NpmFieldCaption.SetRange("Table No.",NpmField."Table No.");
        NpmFieldCaption.SetRange("View Code",NpmField."View Code");
        NpmFieldCaption.SetRange("Field No.",NpmField."Field No.");
        if NpmFieldCaption.IsEmpty then
          exit('');

        NpmFieldCaption.FindSet;
        NpmFieldCaption.CalcFields("Language Code");
        CaptionStringML := NpmFieldCaption."Language Code" + '="' + NpmFieldCaption.Caption + '"';
        while NpmFieldCaption.Next <> 0 do begin
          NpmFieldCaption.CalcFields("Language Code");
          CaptionStringML += '; ' + NpmFieldCaption."Language Code" + '="' + NpmFieldCaption.Caption + '"';
        end;
        exit(CaptionStringML);
    end;
}

