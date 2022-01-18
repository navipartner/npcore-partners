report 6014415 "NPR Rep. Check Missing Fields"
{
    ApplicationArea = NPRRetail;
    Caption = 'Check Missing Fields';
    DefaultLayout = RDLC;
    RDLCLayout = './src/Replication/RepCheckMissingFields.rdl';
    UsageCategory = ReportsAndAnalysis;
    DataAccessIntent = ReadOnly;

    dataset
    {
        dataitem(NPRReplicationEndpoint; "NPR Replication Endpoint")
        {
            RequestFilterFields = "Service Code", "EndPoint ID", "Table ID", Enabled;
            PrintOnlyIfDetail = true;
            column(ServiceCode; "Service Code") { }
            column(EndPointID; "EndPoint ID") { }
            column(Description; Description) { }
            column(TableID; "Table ID") { }
            column(Path; Path) { }
            column(EndpointMethod; "Endpoint Method") { }
            column(Enabled; Enabled) { }

            dataitem(TempField; Field)
            {
                DataItemLink = TableNo = field("Table ID");
                UseTemporary = true;
                column(TableNo; TableNo) { }
                column(TableName; TableName) { }
                column(No_; "No.") { }
                column(FieldName; FieldName) { }
            }

            trigger OnAfterGetRecord()
            begin
                InsertTempMissingFields(NPRReplicationEndpoint);
            end;

            trigger OnPreDataItem()
            begin
                InitializeExceptedSystemFields();
            end;
        }
    }
    requestpage
    {
        SaveValues = true;
        layout
        {
            area(content)
            {
                group(GroupName)
                {
                }
            }
        }
        actions
        {
            area(processing)
            {
            }
        }
    }

    local procedure InsertTempMissingFields(Endpoint: Record "NPR Replication Endpoint")
    var
        FieldRec: Record Field;
        TempSpecialFieldMapping: Record "NPR Rep. Special Field Mapping" temporary;
        RepGetBCGenericData: Codeunit "NPR Rep. Get BC Generic Data";
        URI: Text;
        MetadataURI: Text;
        DummyNextEndpointURI: Text;
        ReplicationAPI: Codeunit "NPR Replication API";
        EntitySet: Text;
    begin
        if ServiceSetup."API Version" <> Endpoint."Service Code" then
            ServiceSetup.Get(Endpoint."Service Code");

        URI := ReplicationAPI.CreateURI(ServiceSetup, Endpoint, DummyNextEndpointURI);
        MetadataURI := GetMetadataURI(URI, ServiceSetup);
        EntitySet := GetResource(URI);
        UpdateMetadata(MetadataURI, ServiceSetup);

        RepGetBCGenericData.InitializeTempSpecialFieldMapping(TempSpecialFieldMapping, Endpoint);
        FieldRec.SetRange(TableNo, Endpoint."Table ID");
        FieldRec.SetRange(Class, FieldRec.Class::Normal);
        FieldRec.SetRange(Enabled, true);
        FieldRec.SetRange(IsPartOfPrimaryKey, false);
        FieldRec.SetFilter(ObsoleteState, '<>%1', FieldRec.ObsoleteState::Removed);
        FieldRec.SetFilter(Type, '<>%1&<>%2&<>%3', FieldRec.Type::Binary, FieldRec.Type::TableFilter, FieldRec.Type::RecordID);
        if FieldRec.FindSet() then
            repeat
                if not ExceptedFields.Contains(FieldRec.FieldName) and not SkipMasterPictureField(FieldRec) then
                    if not FindAPIField(FieldRec, MetadataURI, EntitySet, TempSpecialFieldMapping) then begin
                        TempField := FieldRec;
                        TempField.Insert();
                    end;
            until FieldRec.Next() = 0;
    end;

    local procedure GetMetadataURI(URI: Text; ServiceSetup: Record "NPR Replication Service Setup") MetadataURI: Text
    begin
        MetadataURI := CopyStr(URI, 1, StrPos(URI, '/companies') - 1) + '/$metadata';
        if ServiceSetup."From Company Tenant" <> '' then
            MetadataURI += '/?tenant=' + ServiceSetup."From Company Tenant";
    end;

    local procedure GetResource(URI: Text) Resource: Text
    begin
        if StrPos(URI, '/?') > 0 then
            URI := URI.Remove(StrPos(URI, '/?'), StrLen(URI) - StrPos(URI, '/?') + 1);
        Resource := CopyStr(URI, URI.LastIndexOf('/') + 1, StrLen(URI) - URI.LastIndexOf('/'));
    end;

    local procedure UpdateMetadata(MetadataURI: Text; ServiceSetup: Record "NPR Replication Service Setup")
    var
        Client: HttpClient;
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
        [NonDebuggable]
        Headers: HttpHeaders;
        ResponseXMLText: text;
        XMLDoc: XmlDocument;
        XMLNodes: XmlNodeList;
        XMLNode1: XmlNode;
        Properties: XmlNodeList;
        Property: XmlNode;
        XmlDomManagement: Codeunit "XML DOM Management";
        Attribute: XmlAttribute;
        EntityType: Text;
        EntitySet: Text;
        EntityTypeDict: Dictionary of [Text, Text];
    begin
        if not ImportedMetadatas.Contains(MetadataURI) then begin
            RequestMessage.Method := 'GET';
            RequestMessage.SetRequestUri(MetadataURI);
            RequestMessage.GetHeaders(Headers);
            ServiceSetup.SetRequestHeadersAuthorization(Headers);
            if not Client.Send(RequestMessage, ResponseMessage) then
                Error(WebAPIErrorTxtG, ResponseMessage.HttpStatusCode, ResponseMessage.ReasonPhrase);

            ResponseMessage.Content.ReadAs(ResponseXMLText);
            ResponseXMLText := XmlDomManagement.RemoveNamespaces(ResponseXMLText);
            XmlDocument.ReadFrom(ResponseXMLText, XMLDoc);
            ReadEntitySets(XMLDoc, EntityTypeDict);
            XMLDoc.SelectNodes('//Schema/EntityType', XMLNodes);
            foreach XMLNode1 in XMLNodes do begin
                TempMetadata.Reset();
                XMLNode1.AsXmlElement().Attributes().Get('Name', Attribute);
                EntityType := Attribute.Value;
                Clear(EntitySet);
                if EntityTypeDict.Get(EntityType, EntitySet) then;
                Clear(Properties);
                XMLNode1.SelectNodes('Property', Properties);
                foreach Property in Properties do begin
                    Property.AsXmlElement().Attributes().Get('Name', Attribute); //field name
                    InsertTempMetadata(MetadataURI, EntityType, EntitySet, Attribute.Value);
                end;
            end;
            ImportedMetadatas.Add(MetadataURI);
        end;
    end;

    local procedure ReadEntitySets(XMLDoc: XmlDocument; EntityTypeDict: Dictionary of [Text, Text])
    var
        XMLNodes: XmlNodeList;
        XMLNode1: XmlNode;
        Attribute: XmlAttribute;
        EntityType: Text;
    begin
        XMLDoc.SelectNodes('//Schema/EntityContainer/EntitySet', XMLNodes);
        foreach XMLNode1 in XMLNodes do begin
            XMLNode1.AsXmlElement().Attributes().Get('EntityType', Attribute);
            EntityType := Attribute.Value.Replace('Microsoft.NAV.', '');
            if not EntityTypeDict.ContainsKey(EntityType) then begin
                XMLNode1.AsXmlElement().Attributes().Get('Name', Attribute); // Entity Set!
                EntityTypeDict.Add(EntityType, Attribute.Value);
            end;
        end;
    end;

    local procedure InsertTempMetadata(MetadataURI: Text; EntityType: Text; EntitySet: Text; FieldName: Text)
    begin
        TempMetadata.Init();
        TempMetadata."Entry No." := LastMetadataEntryNo + 1;
        TempMetadata.Name := EntitySet; // this should be used in the API request url
        TempMetadata.Value := FieldName;
        TempMetadata.Path := EntityType;
        TempMetadata.Namespace := MetadataURI;
        TempMetadata.Insert();

        LastMetadataEntryNo := TempMetadata."Entry No.";
    end;

    local procedure FindAPIField(FieldRec: Record Field; MetadataURI: Text; EntitySet: Text; var TempSpecialFieldMapping: Record "NPR Rep. Special Field Mapping"): Boolean;
    var
        TextFunctions: Codeunit "NPR Text Functions";
    begin
        //try find by Replication Special Name Mappings settings
        TempSpecialFieldMapping.SetRange("Field ID", FieldRec."No.");
        if TempSpecialFieldMapping.FindSet() then
            repeat
                if FieldRec.Type in [FieldRec.Type::BLOB, FieldRec.Type::Media, FieldRec.Type::MediaSet] then
                    TempSpecialFieldMapping."API Field Name" := TempSpecialFieldMapping."API Field Name".Replace('@odata.mediaReadLink', '');
                if FindFieldInMetadata(MetadataURI, EntitySet, TempSpecialFieldMapping."API Field Name") then
                    exit(true);
            until TempSpecialFieldMapping.Next() = 0;

        // try find by Field Name in camelcase
        if FindFieldInMetadata(MetadataURI, EntitySet, TextFunctions.Camelize(FieldRec.FieldName)) then
            exit(true);

        Exit(false);
    end;

    local procedure FindFieldInMetadata(MetadataURI: Text; EntitySet: Text; APIFieldName: Text): Boolean
    begin
        TempMetadata.SetRange(Namespace, MetadataURI);
        TempMetadata.SetRange(Name, EntitySet);
        TempMetadata.SetRange(Value, APIFieldName);
        Exit(not TempMetadata.IsEmpty());
    end;

    local procedure InitializeExceptedSystemFields()
    begin
        ExceptedFields.Add('NPR Replication Counter');
        ExceptedFields.Add('SystemCreatedAt');
        ExceptedFields.Add('SystemCreatedBy');
        ExceptedFields.Add('SystemModifiedAt');
        ExceptedFields.Add('SystemModifiedBy');
    end;

    local procedure SkipMasterPictureField(FieldRec: Record Field): Boolean
    begin
        exit((FieldRec.Type in [FieldRec.Type::Media, FieldRec.Type::MediaSet]) and (FieldRec.TableNo in [18, 23, 27]))
    end;

    var
        ServiceSetup: Record "NPR Replication Service Setup";
        TempMetadata: Record "XML Buffer" temporary;
        LastMetadataEntryNo: Integer;
        ImportedMetadatas: List Of [Text];
        ExceptedFields: List of [Text];
        WebAPIErrorTxtG: Label 'Something went wrong:\\Error Status Code: %1;\\Description: %2';
}
