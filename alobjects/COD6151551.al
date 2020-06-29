codeunit 6151551 "NpXml Mgt."
{
    // NC1.00/MHA /20150115  CASE 199932 Refactored object from Web - XML
    // NC1.01/MHA /20150115  CASE 199932 Restructed flow -> Initialize() must be invoked before CreateXml()
    //                                   - Added Output Functions
    //                                   - Added Function GetCustomFieldValue: Invokes a codeunit that should save a value in Table 6151557 "NpXml Custom Value Buffer".Value
    // NC1.02/MHA /20150204  CASE 199932 Changed SendApi error
    // NC1.03/MHA /20150205  CASE 199932 Previous Filter Value to InTemplate
    // NC1.04/MHA /20150209  CASE 199932 Added Element Comment functionality and Function EnumOption()
    // NC1.05/MHA /20150219  CASE 206395 Added Options to field 5200 Field Type:
    //                                   - ExclVat
    //                                   - Firstname
    //                                   - Lastname
    //                                   - PrimaryKey
    //                                   Removed field NpXmlTemplate."Xml Element Name". Obsolete as NpXml Elements defines the Xml Schema
    //                                   Removed FIELD-filter in SetRecRefCalcFieldFilter
    // NC1.06/MHA /20150224  CASE 206395 Updated function InTemplateTrigger() and added TriggerLink Type PreviousField
    // NC1.07/MHA /20150309  CASE 206395 Added Hidden property to NpXml Elements and Standard Field Type for NpXml Attributes
    // NC1.08/MHA /20150310  CASE 206395 Added functions
    //                                   - LookupFieldValue()
    //                                   - PreviewXml()
    //                                   - RunProcess() for launching launching Applications
    // NC1.09/MHA /20150313  CASE 208758 Added parameter APIPassword to function SetupNpXmlTemplate() and updated API Security
    // NC1.10/MHA /20150319  CASE 207529 Reworked API Response parsing and added FIK functionality
    // NC1.11/MHA /20150327  CASE 210171 Implemented Swap-functions for moving NpXml-Elements and -Triggers up and down
    // NC1.13/MHA /20150414  CASE 211360 Restructured NpXml Codeunits. Independent functions moved to new codeunits
    // NC1.22/MHA /20151211  CASE 229473 Added functions GetAutomaticUsername() and ReplaceSpecialChar()
    // NC1.22/TR /20150413   CASE 226040 Refactorized CreateXml() by adding auxiliary function ParseDataToXmlDocNode()
    // NC1.22/MHA /20160429  CASE 237658 NpXml extended with Namespaces
    // NC2.00/MHA /20160525  CASE 240005 NaviConnect
    // NC2.01/MHA /20160905  CASE 242551 Updated Api Response Parsing
    // NC2.01/MHA /20161018  CASE 242550 Added function OnSetupGenericChildTable() for enabling Temporary Table Exports
    // NC2.01/MHA /20161212  CASE 260498 Added Api Request Header fields in SendApi()
    // NC2.03/MHA /20170316  CASE 268788 Added Content-Type and NameSpace to REST
    // NC2.03/MHA /20170324  CASE 267094 Added Publisher function OnBeforeTransferXml()
    // NC2.05/MHA /20170615  CASE 265609 Added REST (Json) functionality
    // NC2.06/MHA /20170809  CASE 265779 Added function MarkContainersAsArray() which is used to mark JsonClasses in Xml2Json() and Api Headers in SendApi()
    // NC2.07/THRO/20171011  CASE 293192 Removed hardcoded attribute in MarkContainersAsArray()
    // NC2.08/THRO/20171123  CASE 297308 Added option to create Json with array in root
    // NC2.08/MHA /20171205  CASE 298759 Added function GetApiMethod() to ignore Translation on NpXmlTemplate."Api Method"
    // NC2.08/THRO/20171206  CASE 286713 Added function AddApiHeader()
    // NC2.08/MHA /20171206  CASE 265541 Added Convertion of String Number to JSON Numbers in Xml2Json()
    // NC2.11/MHA /20180316  CASE 303181 Added #string# prefix in Xml2Json() to force exlusion of elements in Decimal convertion and added TextEncoding in InitializeOutput()
    // NC2.13/JDH /20180604  CASE 317971 Changed caption to ENU
    // NC2.13/THRO/20180628  CASE 310042 Xml2Json made global
    // NC2.19/MHA /20190311  CASE 345261 Getting Inner Exception Message explicitly in SendApi() is redundant
    // NC2.20/MHA /20190411  CASE 342115 SOAPAction should only be added to Header if not explicitly defined in underlying Header table
    // NC2.22/MHA /20190614  CASE 355993 NpXml Attributes with default Field Type should not have Custom Value Codeunit nor Xml Value Function
    // NC2.22/MHA /20190627  CASE 342115 Added SetTrustedCertificateValidation() in SendApi() and removed green code before 2.19
    // NC2.24/MHA /20191122  CASE 373950 Added ReplaceSpecialChar() to GetFilename()
    // NC2.25/MHA /20200311  CASE 392967 FilterGroups added to SetRecRefXmlFilter()


    trigger OnRun()
    begin
        CreateXml();
    end;

    var
        NpXmlTemplate2: Record "NpXml Template";
        OutputTempBlob: Codeunit "Temp Blob";
        ResponseTempBlob: Codeunit "Temp Blob";
        Error001: Label 'NpXml Template: %1\API Error:\%2';
        Error002: Label 'Record in %1 within the filters does not exist';
        Error003: Label '<%1> does not contain value %2';
        Text001: Label 'Checking images:     @1@@@@@@@@@@@@@@@@@@\Estimated time left: #2##################';
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        NpXmlTemplateMgt: Codeunit "NpXml Template Mgt.";
        NpXmlValueMgt: Codeunit "NpXml Value Mgt.";
        RecRef: RecordRef;
        OutputOutStr: OutStream;
        ResponseOutStr: OutStream;
        Window: Dialog;
        PrimaryKeyValue: Text;
        BatchCount: Integer;
        Text002: Label 'Exporting %1 to XML\Exporting:           @2@@@@@@@@@@@@@@@@@@@\Estimated Time Left: #3###################\Record:       #4###########################';
        Text100: Label 'Choose XML Document';
        HideDialog: Boolean;
        Initialized: Boolean;
        OutputInitialized: Boolean;
        Text200: Label 'Finding first record in %1 within the filters: @2@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\Estimated Time Left:                           #3##############################\Record:  #4####################################################################';

    procedure CreateXml()
    var
        XmlDocNode: DotNet npNetXmlNode;
        XmlDoc: DotNet npNetXmlDocument;
        FieldRef: FieldRef;
        Counter: Integer;
        XmlEntityCount: Integer;
        Total: Integer;
        StartTime: Time;
        RecordSetExists: Boolean;
    begin
        if not Initialized then
            exit;

        Initialized := false;
        StartTime := Time;
        Counter := 0;
        Total := RecRef.Count;
        OpenDialog(StrSubstNo(Text002, NpXmlTemplate2.Code));

        if NpXmlTemplate2."Max Records per File" <= 0 then
            NpXmlTemplate2."Max Records per File" := 10000;

        XmlEntityCount := 0;
        NpXmlDomMgt.InitDoc(XmlDoc, XmlDocNode, NpXmlTemplate2."Xml Root Name");
        RecordSetExists := RecRef.FindSet;
        repeat
            Counter += 1;
            UpdateDialog(Counter, Total, StartTime, RecRef.GetPosition);

            if ParseDataToXmlDocNode(RecRef, RecordSetExists, XmlDocNode) then
                XmlEntityCount += 1;

            if XmlEntityCount >= NpXmlTemplate2."Max Records per File" then begin
                FinalizeDoc(XmlDoc, NpXmlTemplate2, GetFilename(NpXmlTemplate2."Xml Root Name", PrimaryKeyValue, Counter));
                XmlEntityCount := 0;
                NpXmlDomMgt.InitDoc(XmlDoc, XmlDocNode, NpXmlTemplate2."Xml Root Name");
            end;
        until RecRef.Next = 0;

        if XmlEntityCount > 0 then
            FinalizeDoc(XmlDoc, NpXmlTemplate2, GetFilename(NpXmlTemplate2."Xml Root Name", PrimaryKeyValue, Counter));

        Clear(XmlDoc);
        CloseDialog;
    end;

    procedure ParseDataToXmlDocNode(var RecRef: RecordRef; RecordSetExists: Boolean; var XmlDocNode: DotNet npNetXmlNode) Success: Boolean
    var
        NpXmlElement: Record "NpXml Element";
        RecRef2: RecordRef;
    begin
        if IsNull(XmlDocNode) then
            exit(false);

        NpXmlElement.SetRange("Xml Template Code", NpXmlTemplate2.Code);
        NpXmlElement.SetFilter("Parent Line No.", '=%1', 0);
        NpXmlElement.SetRange(Active, true);
        if not NpXmlElement.FindSet then
            exit(false);

        Success := true;
        repeat
            SetRecRefXmlFilter(NpXmlElement, RecRef, RecRef2);
            if RecordSetExists or (RecRef.Number <> RecRef2.Number) then begin
                if RecRef2.FindSet then
                    repeat
                        Success := AddXmlElement(XmlDocNode, NpXmlElement, RecRef2, 0) and Success;
                    until RecRef2.Next = 0;
            end else
                Success := AddXmlElement(XmlDocNode, NpXmlElement, RecRef2, 0);
            RecRef2.Close;
        until NpXmlElement.Next = 0;

        exit(Success);
    end;

    procedure Initialize(NewNpXmlTemplate: Record "NpXml Template"; var NewRecRef: RecordRef; NewPrimaryKeyValue: Text; NewHideDialog: Boolean)
    begin
        NpXmlTemplate2 := NewNpXmlTemplate;
        RecRef := NewRecRef;
        PrimaryKeyValue := NewPrimaryKeyValue;
        HideDialog := NewHideDialog;
        Initialized := true;
    end;

    local procedure "--- Create Xml"()
    begin
    end;

    local procedure AddXmlElement(var XmlNode: DotNet npNetXmlNode; NpXmlElement: Record "NpXml Element"; var RecRef: RecordRef; CurrLevel: Integer) LevelAppended: Boolean
    var
        NewXmlNode: DotNet npNetXmlElement;
        NpXmlElementChild: Record "NpXml Element";
        RecRefFilter: RecordRef;
        RecRefChild: RecordRef;
        XmlComment: DotNet npNetXmlComment;
        Finished: Boolean;
        ElementName: Text;
        Namespace: Text;
    begin
        if not NpXmlElement.Active then
            exit;

        Clear(RecRefFilter);
        RecRefFilter.Open(RecRef.Number);
        RecRefFilter := RecRef.Duplicate;
        RecRefFilter.SetRecFilter;

        if not NpXmlElement.Hidden then begin
            ElementName := GetXmlElementName(NpXmlElement);
            Namespace := GetXmlNamespace(NpXmlElement);
            NpXmlDomMgt.AddElementNamespace(XmlNode, ElementName, Namespace, NewXmlNode);
            AddXmlValue(NewXmlNode, NpXmlElement, RecRefFilter);
        end else
            NewXmlNode := XmlNode;

        Clear(NpXmlElementChild);
        NpXmlElementChild.SetRange("Xml Template Code", NpXmlElement."Xml Template Code");
        NpXmlElementChild.SetRange("Parent Line No.", NpXmlElement."Line No.");
        NpXmlElementChild.SetRange(Active, true);
        if NpXmlElementChild.FindSet then
            repeat
                SetRecRefXmlFilter(NpXmlElementChild, RecRefFilter, RecRefChild);
                if RecRefChild.FindSet then
                    repeat
                        AddXmlElement(NewXmlNode, NpXmlElementChild, RecRefChild, CurrLevel + 1);
                    until RecRefChild.Next = 0;
            until (NpXmlElementChild.Next = 0);

        if NpXmlElement.Hidden then
            exit(true);

        NewXmlNode.IsEmpty(NewXmlNode.InnerXml = '');
        if NpXmlElement."Only with Value" and NewXmlNode.IsEmpty then
            XmlNode.RemoveChild(NewXmlNode)
        else
            if NpXmlElement.Comment <> '' then begin
                XmlComment := XmlNode.OwnerDocument.CreateComment(NpXmlElement.Comment);
                XmlNode.InsertBefore(XmlComment, NewXmlNode);
            end;

        exit(true);
    end;

    local procedure AddXmlNamespaces(NpXmlTemplate: Record "NpXml Template"; var XmlDoc: DotNet npNetXmlDocument)
    var
        NpXmlNamespaces: Record "NpXml Namespace";
        XmlElement: DotNet npNetXmlElement;
    begin
        if not NpXmlTemplate."Namespaces Enabled" then
            exit;

        NpXmlNamespaces.SetRange("Xml Template Code", NpXmlTemplate.Code);
        if not NpXmlNamespaces.FindSet then
            exit;

        XmlElement := XmlDoc.DocumentElement;
        repeat
            NpXmlDomMgt.AddAttribute(XmlElement, 'xmlns:' + NpXmlNamespaces.Alias, NpXmlNamespaces.Namespace);
        until NpXmlNamespaces.Next = 0;
    end;

    local procedure AddXmlValue(var XmlNode: DotNet npNetXmlElement; var NPXmlElement: Record "NpXml Element"; RecRef: RecordRef)
    var
        NpXmlAttribute: Record "NpXml Attribute";
        NPXmlElement2: Record "NpXml Element";
        NpXmlNamespace: Record "NpXml Namespace";
        XmlCDATA: DotNet npNetXmlCDataSection;
        AttributeValue: Text;
        ElementValue: Text;
    begin
        ElementValue := '';
        Clear(NpXmlAttribute);
        NpXmlAttribute.SetRange("Xml Template Code", NPXmlElement."Xml Template Code");
        NpXmlAttribute.SetRange("Xml Element Line No.", NPXmlElement."Line No.");
        NpXmlAttribute.SetFilter("Attribute Name", '<>%1', '');
        if NpXmlAttribute.FindSet then
            repeat
                AttributeValue := '';
                if NpXmlAttribute."Attribute Field No." <> 0 then
                    NPXmlElement2 := NPXmlElement;
                if NpXmlAttribute."Default Field Type" then
                    NPXmlElement2."Field Type" := NPXmlElement2."Field Type"::" ";
                //-NC2.22 [355993]
                if NpXmlAttribute."Default Field Type" then begin
                    NPXmlElement2."Custom Codeunit ID" := 0;
                    NPXmlElement2."Xml Value Codeunit ID" := 0;
                end;
                //+NC2.22 [355993]
                AttributeValue := NpXmlValueMgt.GetXmlValue(RecRef, NPXmlElement2, NpXmlAttribute."Attribute Field No.");
                if (NpXmlAttribute."Default Value" <> '') and (AttributeValue = '') then
                    AttributeValue := NpXmlAttribute."Default Value";
                if NpXmlAttribute.Namespace = '' then
                    NpXmlDomMgt.AddAttribute(XmlNode, NpXmlAttribute."Attribute Name", AttributeValue)
                else begin
                    NpXmlNamespace.Get(NpXmlAttribute."Xml Template Code", NpXmlAttribute.Namespace);
                    NpXmlDomMgt.AddAttributeNamespace(XmlNode, NpXmlAttribute.Namespace + ':' + NpXmlAttribute."Attribute Name", NpXmlNamespace.Namespace, AttributeValue);
                end;
            until NpXmlAttribute.Next = 0;

        if NPXmlElement."Field No." <> 0 then
            ElementValue := NpXmlValueMgt.GetXmlValue(RecRef, NPXmlElement, NPXmlElement."Field No.");
        if (NPXmlElement."Default Value" <> '') and (ElementValue = '') then
            ElementValue := NPXmlElement."Default Value";
        XmlNode.IsEmpty(ElementValue = '');
        if NPXmlElement.CDATA then begin
            if ElementValue <> '' then begin
                XmlCDATA := XmlNode.OwnerDocument.CreateCDataSection('');
                XmlNode.AppendChild(XmlCDATA);
                XmlCDATA.AppendData(ElementValue);
            end;
        end else
            XmlNode.InnerText := ElementValue;
    end;

    procedure "--- Filter"()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnSetupGenericChildTable(NpXmlElement: Record "NpXml Element"; ParentRecRef: RecordRef; var ChildRecRef: RecordRef; var Handled: Boolean)
    begin
    end;

    local procedure SetRecRefXmlFilter(NpXmlElement: Record "NpXml Element"; RecRef: RecordRef; var RecRef2: RecordRef)
    var
        NpXmlFilter: Record "NpXml Filter";
        FieldRef: FieldRef;
        FieldRef2: FieldRef;
        BufferDecimal: Decimal;
        BufferInteger: Integer;
        BufferBoolean: Boolean;
        Handled: Boolean;
        i: Integer;
    begin
        Clear(RecRef2);
        if NpXmlElement."Generic Child Codeunit ID" <> 0 then
            OnSetupGenericChildTable(NpXmlElement, RecRef, RecRef2, Handled);
        if (not Handled) or (NpXmlElement."Generic Child Codeunit ID" = 0) then begin
            RecRef2.Open(NpXmlElement."Table No.");
            if RecRef.Number = NpXmlElement."Table No." then
                RecRef2 := RecRef.Duplicate;
        end;
        if RecRef.Number = NpXmlElement."Table No." then
            RecRef2.SetRecFilter;

        //-NC2.25 [392967]
        i := 40;
        //+NC2.25 [392967]
        NpXmlFilter.SetRange("Xml Template Code", NpXmlElement."Xml Template Code");
        NpXmlFilter.SetRange("Xml Element Line No.", NpXmlElement."Line No.");
        if NpXmlFilter.FindSet then
            repeat
                //-NC2.25 [392967]
                i += 1;
                RecRef2.FilterGroup(i);
                //+NC2.25 [392967]
                FieldRef2 := RecRef2.Field(NpXmlFilter."Field No.");
                case NpXmlFilter."Filter Type" of
                    NpXmlFilter."Filter Type"::TableLink:
                        begin
                            FieldRef := RecRef.Field(NpXmlFilter."Parent Field No.");
                            if LowerCase(Format(FieldRef.Class)) = 'flowfield' then
                                FieldRef.CalcField;
                            FieldRef2.SetFilter('=%1', FieldRef.Value);
                        end;
                    NpXmlFilter."Filter Type"::Constant:
                        begin
                            if NpXmlFilter."Filter Value" <> '' then begin
                                case LowerCase(Format(FieldRef2.Type)) of
                                    'boolean':
                                        FieldRef2.SetFilter('=%1', LowerCase(NpXmlFilter."Filter Value") in ['1', 'yes', 'ja', 'true']);
                                    'integer', 'option':
                                        begin
                                            if Evaluate(BufferDecimal, NpXmlFilter."Filter Value") then
                                                FieldRef2.SetFilter('=%1', BufferDecimal);
                                        end;
                                    'decimal':
                                        begin
                                            if Evaluate(BufferInteger, NpXmlFilter."Filter Value") then
                                                FieldRef2.SetFilter('=%1', BufferInteger);
                                        end;
                                    else
                                        FieldRef2.SetFilter('=%1', NpXmlFilter."Filter Value");
                                end;
                            end;
                        end;
                    NpXmlFilter."Filter Type"::Filter:
                        begin
                            FieldRef2.SetFilter(NpXmlFilter."Filter Value");
                        end;
                end;
            until NpXmlFilter.Next = 0;

        //-NC2.25 [392967]
        RecRef2.FilterGroup(0);
        //+NC2.25 [392967]

        case NpXmlElement."Iteration Type" of
            NpXmlElement."Iteration Type"::First:
                begin
                    if RecRef2.FindFirst then
                        RecRef2.SetRecFilter;
                end;
            NpXmlElement."Iteration Type"::Last:
                begin
                    if RecRef2.FindLast then
                        RecRef2.SetRecFilter;
                end;
        end;
    end;

    local procedure "--- Transfer"()
    begin
    end;

    local procedure ExportToFile(NPXmlTemplate: Record "NpXml Template"; var XmlDoc: DotNet npNetXmlDocument; Filename: Text[250])
    var
        "Field": Record "Field";
        TempBlob: Codeunit "Temp Blob";
        FileMgt: Codeunit "File Management";
        InStream: InStream;
        OutStream: OutStream;
        Filepath: Text;
        TempFile: Text;
    begin
        if not NPXmlTemplate."File Transfer" then
            exit;

        AddXmlToOutputTempBlob(XmlDoc, 'Xml Template: ' + NPXmlTemplate.Code + ' || File Transfer: ' + NPXmlTemplate."File Path");

        Field.Get(DATABASE::"NpXml Template", NPXmlTemplate.FieldNo("File Transfer"));
        AddTextToResponseTempBlob('<!-- [' + NPXmlTemplate.Code + '] ' + Field."Field Caption" + ': ' + NPXmlTemplate."File Path" + ' -->' + GetChar(13) + GetChar(10));

        NPXmlTemplate.TestField("File Path");
        Filepath := NPXmlTemplate."File Path" + '\';
        if Filepath[StrLen(Filepath)] <> '\' then
            Filepath += '\';
        TempBlob.CreateOutStream(OutStream);
        XmlDoc.Save(OutStream);
        if not TempBlob.HasValue then
            exit;
        TempBlob.CreateInStream(InStream);

        TempFile := FileMgt.BLOBExport(TempBlob, Filename, false);
        FileMgt.MoveFile(TempFile, Filepath + Filename);
    end;

    local procedure FinalizeDoc(var XmlDoc: DotNet npNetXmlDocument; NPXmlTemplate: Record "NpXml Template"; Filename: Text[1024])
    var
        Transfered: Boolean;
    begin
        Transfered := TransferXml(NPXmlTemplate, XmlDoc, Filename);
        if Transfered then
            exit;

        AddXmlToOutputTempBlob(XmlDoc, 'Xml Template: ' + NPXmlTemplate.Code + ' || No Transfer');
    end;

    local procedure SendApi(NpXmlTemplate: Record "NpXml Template"; var XmlDoc: DotNet npNetXmlDocument)
    var
        "Field": Record "Field";
        NpXmlApiHeader: Record "NpXml Api Header";
        NpXmlNamespaces: Record "NpXml Namespace";
        AuthenticationLevel: DotNet npNetAuthenticationLevel;
        BinaryReader: DotNet npNetBinaryReader;
        Credential: DotNet npNetNetworkCredential;
        Encoding: DotNet npNetEncoding;
        HttpWebRequest: DotNet npNetHttpWebRequest;
        HttpWebResponse: DotNet npNetHttpWebResponse;
        JsonConvert: DotNet JsonConvert;
        MemoryStream: DotNet npNetMemoryStream;
        Stream: DotNet npNetStream;
        StreamReader: DotNet npNetStreamReader;
        XmlDoc2: DotNet npNetXmlDocument;
        XmlElement: DotNet npNetXmlElement;
        XmlException: DotNet npNetXmlException;
        XmlNodeList: DotNet npNetXmlNodeList;
        XmlElement2: DotNet npNetXmlElement;
        WebException: DotNet npNetWebException;
        i: Integer;
        APIUsername: Text;
        ElementName: Text;
        ExceptionMessage: Text;
        FaultCode: Text;
        FaultString: Text;
        JsonRequest: Text;
        Response: Text;
        IsJson: Boolean;
        Succes: Boolean;
        NetConvHelper: Variant;
    begin
        if not NpXmlTemplate."API Transfer" then
            exit;

        Field.Get(DATABASE::"NpXml Template", NpXmlTemplate.FieldNo("API Transfer"));
        AddTextToResponseTempBlob('<!-- [' + NpXmlTemplate.Code + '] ' + Field."Field Caption" + ': ' + NpXmlTemplate."API Url" + ' -->' + GetChar(13) + GetChar(10));

        if not IsNull(HttpWebRequest) then
            Clear(HttpWebRequest);
        HttpWebRequest := HttpWebRequest.Create(NpXmlTemplate."API Url");
        HttpWebRequest.Timeout := 1000 * 60 * 5;
        XmlDoc2 := XmlDoc2.XmlDocument;
        case NpXmlTemplate."API Type" of
            NpXmlTemplate."API Type"::"REST (Xml)", NpXmlTemplate."API Type"::"REST (Json)":
                begin
                    XmlDoc2 := XmlDoc;
                    AddXmlNamespaces(NpXmlTemplate, XmlDoc2);
                    if (NpXmlTemplate."Xml Root Namespace" <> '') and NpXmlNamespaces.Get(NpXmlTemplate.Code, NpXmlTemplate."Xml Root Namespace") then begin
                        XmlElement := XmlDoc2.DocumentElement;
                        NpXmlDomMgt.AddAttribute(XmlElement, 'xmlns', NpXmlNamespaces.Namespace);
                    end;
                    APIUsername := NpXmlTemplate.GetApiUsername();
                    if NpXmlTemplate."API Password" = '' then
                        HttpWebRequest.UseDefaultCredentials(true)
                    else begin
                        if NpXmlTemplate."API Username Type" = NpXmlTemplate."API Username Type"::Automatic then
                            HttpWebRequest.Headers.Add('Authorization', 'Basic ' + GetBasicAuthInfo(NpXmlTemplate.GetApiUsername(), NpXmlTemplate."API Password"))
                        else begin
                            HttpWebRequest.UseDefaultCredentials(false);
                            Credential := Credential.NetworkCredential(APIUsername, NpXmlTemplate."API Password");
                            HttpWebRequest.Credentials(Credential);
                        end;
                    end;
                    HttpWebRequest.Method := GetApiMethod(NpXmlTemplate);
                    HttpWebRequest.ContentType := 'navision/xml';
                    if NpXmlTemplate."API Content-Type" <> '' then
                        HttpWebRequest.ContentType := NpXmlTemplate."API Content-Type";
                    HttpWebRequest.Accept('application/xml');
                end;
            NpXmlTemplate."API Type"::SOAP:
                begin
                    APIUsername := NpXmlTemplate.GetApiUsername();
                    if NpXmlTemplate."API Password" = '' then
                        HttpWebRequest.UseDefaultCredentials(true)
                    else begin
                        if NpXmlTemplate."API Username Type" = NpXmlTemplate."API Username Type"::Automatic then
                            HttpWebRequest.Headers.Add('Authorization', 'Basic ' + GetBasicAuthInfo(NpXmlTemplate.GetApiUsername(), NpXmlTemplate."API Password"))
                        else begin
                            HttpWebRequest.UseDefaultCredentials(false);
                            Credential := Credential.NetworkCredential(APIUsername, NpXmlTemplate."API Password");
                            HttpWebRequest.Credentials(Credential);
                        end;
                    end;
                    XmlDoc2.LoadXml('<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">' +
                                    '   <soapenv:Body />' +
                                    '</soapenv:Envelope>');
                    XmlElement := XmlDoc2.DocumentElement.FirstChild;
                    AddXmlNamespaces(NpXmlTemplate, XmlDoc2);
                    if NpXmlNamespaces.Get(NpXmlTemplate.Code, NpXmlTemplate."Xml Root Namespace") then;

                    ElementName := NpXmlTemplate."API SOAP Action";
                    if NpXmlTemplate."Xml Root Namespace" <> '' then
                        ElementName := NpXmlTemplate."Xml Root Namespace" + ':' + NpXmlTemplate."API SOAP Action";
                    NpXmlDomMgt.AddElementNamespace(XmlElement, ElementName, NpXmlNamespaces.Namespace, XmlElement);

                    XmlNodeList := XmlDoc.DocumentElement.ChildNodes;
                    if not IsNull(XmlNodeList) then begin
                        for i := 0 to XmlNodeList.Count - 1 do begin
                            XmlElement2 := XmlNodeList.ItemOf(i);
                            XmlElement2 := XmlElement2.Clone();
                            XmlElement2 := XmlDoc2.ImportNode(XmlElement2, true);
                            XmlElement.AppendChild(XmlElement2);
                        end;
                    end;
                    HttpWebRequest.Method := 'POST';
                    HttpWebRequest.ContentType := 'text/xml; charset=utf-8';
                    //-NC2.20 [342115]
                    if not NpXmlApiHeader.Get(NpXmlTemplate.Code, 'SOAPAction') then
                        HttpWebRequest.Headers.Add('SOAPAction', NpXmlTemplate."API SOAP Action");
                    //+NC2.20 [342115]
                end;
        end;

        if NpXmlTemplate."API Content-Type" <> '' then
            HttpWebRequest.ContentType := NpXmlTemplate."API Content-Type";
        if NpXmlTemplate."API Authorization" <> '' then
            HttpWebRequest.Headers.Add('Authorization', NpXmlTemplate."API Authorization");
        if NpXmlTemplate."API Accept" <> '' then
            HttpWebRequest.Accept(NpXmlTemplate."API Accept");
        NpXmlApiHeader.SetRange("Xml Template Code", NpXmlTemplate.Code);
        if NpXmlApiHeader.FindSet then
            repeat
                AddApiHeader(NpXmlApiHeader, HttpWebRequest);
            until NpXmlApiHeader.Next = 0;
        //-NC2.22 [342115]
        NpXmlDomMgt.SetTrustedCertificateValidation(HttpWebRequest);
        //+NC2.22 [342115]
        IsJson := NpXmlTemplate."API Type" = NpXmlTemplate."API Type"::"REST (Json)";
        if IsJson then begin
            JsonRequest := Xml2Json(XmlDoc2, NpXmlTemplate);
            AddTextToOutputTempBlob(JsonRequest);
            Succes := NpXmlDomMgt.SendWebRequestText(JsonRequest, HttpWebRequest, HttpWebResponse, WebException);
        end else begin
            AddXmlToOutputTempBlob(XmlDoc2, 'Xml Template: ' + NpXmlTemplate.Code + ' || Api ' + Format(NpXmlTemplate."API Type") + ' Transfer: ' + NpXmlTemplate."API Url");
            Succes := NpXmlDomMgt.SendWebRequest(XmlDoc2, HttpWebRequest, HttpWebResponse, WebException);
        end;

        if not Succes then begin
            //-NC2.19 [345261]
            ExceptionMessage := NpXmlDomMgt.GetWebExceptionMessage(WebException);
            //+NC2.19 [345261]
            AddTextToResponseTempBlob(ExceptionMessage);
            Error('');
        end;

        Response := NpXmlDomMgt.GetWebResponseText(HttpWebResponse);

        if (NpXmlTemplate."API Response Path" <> '') and (Response <> '') and (not IsJson) then begin
            XmlDoc2 := XmlDoc2.XmlDocument;
            XmlDoc2.LoadXml(Response);
            //-NC2.19 [345261]
            if NpXmlDomMgt.RemoveNameSpaces(XmlDoc2) then;
            //+NC2.19 [345261]
            XmlElement := XmlDoc2.SelectSingleNode(NpXmlTemplate."API Response Path");
            if not IsNull(XmlElement) then
                Response := XmlElement.InnerXml;
        end;

        if not IsJson then
            Response := NpXmlDomMgt.PrettyPrintXml(Response);

        AddTextToResponseTempBlob(Response);

        if (NpXmlTemplate."API Response Success Path" <> '') and (Response <> '') then begin
            XmlDoc2 := XmlDoc2.XmlDocument;
            if IsJson then begin
                NetConvHelper := JsonConvert.DeserializeXmlNode(Response);
                XmlElement := NetConvHelper;
                XmlDoc2.LoadXml('<?xml version="1.0" encoding="utf-8"?>' + GetChar(13) + GetChar(10) +
                               '<response />');
                XmlDoc2.DocumentElement.AppendChild(XmlElement);
            end else
                XmlDoc2.LoadXml(Response);

            //-NC2.19 [345261]
            if NpXmlDomMgt.RemoveNameSpaces(XmlDoc2) then;
            //+NC2.19 [345261]
            NetConvHelper := XmlDoc2;
            if NpXmlDomMgt.GetXmlText(NetConvHelper, NpXmlTemplate."API Response Success Path", MaxStrLen(NpXmlTemplate."API Response Success Value"), false) <> NpXmlTemplate."API Response Success Value" then
                Error('');
        end;
    end;

    local procedure AddApiHeader(NpXmlApiHeader: Record "NpXml Api Header"; var HttpWebRequest: DotNet npNetHttpWebRequest)
    var
        BigIntBuffer: BigInteger;
        IntBuffer: Integer;
        DateTimeBuffer: DateTime;
        BoolBuffer: Boolean;
    begin
        case LowerCase(NpXmlApiHeader.Name) of
            'timeout':
                begin
                    Evaluate(IntBuffer, NpXmlApiHeader.Value);
                    HttpWebRequest.Timeout(IntBuffer);
                end;
            'accept':
                begin
                    HttpWebRequest.Accept(NpXmlApiHeader.Value);
                end;
            'connection':
                begin
                    HttpWebRequest.Connection(NpXmlApiHeader.Value);
                end;
            'content-length':
                begin
                    Evaluate(BigIntBuffer, NpXmlApiHeader.Value);
                    HttpWebRequest.ContentLength(BigIntBuffer);
                end;
            'content-type':
                begin
                    HttpWebRequest.ContentType(NpXmlApiHeader.Value);
                end;
            'date':
                begin
                    if not Evaluate(DateTimeBuffer, NpXmlApiHeader.Value, 9) then
                        Evaluate(DateTimeBuffer, NpXmlApiHeader.Value);
                    HttpWebRequest.Date(DateTimeBuffer);
                end;
            'expect':
                begin
                    HttpWebRequest.Expect(NpXmlApiHeader.Value);
                end;
            'host':
                begin
                    HttpWebRequest.Host(NpXmlApiHeader.Value);
                end;
            'if-modified-since':
                begin
                    if not Evaluate(DateTimeBuffer, NpXmlApiHeader.Value, 9) then
                        Evaluate(DateTimeBuffer, NpXmlApiHeader.Value);
                    HttpWebRequest.IfModifiedSince(DateTimeBuffer);
                end;
            'referer':
                begin
                    HttpWebRequest.Referer(NpXmlApiHeader.Value);
                end;
            'transfer-encoding':
                begin
                    HttpWebRequest.TransferEncoding(NpXmlApiHeader.Value);
                end;
            'user-agent':
                begin
                    HttpWebRequest.UserAgent(NpXmlApiHeader.Value);
                end;
            'expect100continue':
                begin
                    if not Evaluate(BoolBuffer, NpXmlApiHeader.Value, 9) then
                        if not Evaluate(BoolBuffer, NpXmlApiHeader.Value, 2) then
                            Evaluate(BoolBuffer, NpXmlApiHeader.Value);
                    HttpWebRequest.ServicePoint.Expect100Continue(BoolBuffer);
                end;
            else
                HttpWebRequest.Headers.Add(NpXmlApiHeader.Name, NpXmlApiHeader.Value);
        end;
    end;

    local procedure SendFtp(NPXmlTemplate: Record "NpXml Template"; var XmlDoc: DotNet npNetXmlDocument; Filename: Text)
    var
        "Field": Record "Field";
        Credential: DotNet npNetNetworkCredential;
        FtpWebRequest: DotNet npNetFtpWebRequest;
        MemoryStream: DotNet npNetMemoryStream;
    begin
        if not NPXmlTemplate."FTP Transfer" then
            exit;
        if NPXmlTemplate."FTP Server" = '' then
            exit;

        AddXmlToOutputTempBlob(XmlDoc, 'Xml Template: ' + NPXmlTemplate.Code + ' || Ftp Transfer: ' + NPXmlTemplate."FTP Server");

        Field.Get(DATABASE::"NpXml Template", NPXmlTemplate.FieldNo("FTP Transfer"));
        AddTextToResponseTempBlob('<!-- [' + NPXmlTemplate.Code + '] ' + Field."Field Caption" + ': ' + NPXmlTemplate."FTP Server" + ' -->' + GetChar(13) + GetChar(10));

        FtpWebRequest := FtpWebRequest.Create(NPXmlTemplate."FTP Server" + '/' + NPXmlTemplate."FTP Directory" + '/' + Filename);
        FtpWebRequest.Method := 'STOR'; //WebRequestMethods.Ftp.UploadFile
        FtpWebRequest.Credentials := Credential.NetworkCredential(NPXmlTemplate."FTP Username", NPXmlTemplate."FTP Password");
        MemoryStream := FtpWebRequest.GetRequestStream;
        XmlDoc.Save(MemoryStream);
        MemoryStream.Flush;
        MemoryStream.Close;
        Clear(MemoryStream);
    end;

    local procedure TransferXml(NpXmlTemplate: Record "NpXml Template"; var XmlDoc: DotNet npNetXmlDocument; Filename: Text[250]) Transfered: Boolean
    var
        Handled: Boolean;
    begin
        OnBeforeTransferXml(NpXmlTemplate, RecRef, XmlDoc, Filename, Handled);
        if not (NpXmlTemplate."File Transfer" or NpXmlTemplate."FTP Transfer" or NpXmlTemplate."API Transfer") then
            exit(false);

        if NpXmlTemplate."File Transfer" then
            ExportToFile(NpXmlTemplate, XmlDoc, Filename);

        if NpXmlTemplate."FTP Transfer" then
            SendFtp(NpXmlTemplate, XmlDoc, Filename);

        if NpXmlTemplate."API Transfer" then
            SendApi(NpXmlTemplate, XmlDoc);

        exit(true);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeTransferXml(var NpXmlTemplate: Record "NpXml Template"; var RootRecRef: RecordRef; var XmlDoc: DotNet npNetXmlDocument; var Filename: Text[250]; var Handled: Boolean)
    begin
    end;

    local procedure GetApiMethod(NpXmlTemplate: Record "NpXml Template"): Text
    begin
        case NpXmlTemplate."API Method" of
            NpXmlTemplate."API Method"::DELETE:
                exit('DELETE');
            NpXmlTemplate."API Method"::GET:
                exit('GET');
            NpXmlTemplate."API Method"::PATCH:
                exit('PATCH');
            NpXmlTemplate."API Method"::POST:
                exit('POST');
            NpXmlTemplate."API Method"::PUT:
                exit('PUT');
        end;
    end;

    procedure "--- Output"()
    begin
    end;

    local procedure AddTextToResponseTempBlob(Response: Text)
    var
        LF: Char;
        CR: Char;
    begin
        InitializeOutput();
        if ResponseTempBlob.HasValue then begin
            LF := 10;
            CR := 13;
            ResponseOutStr.WriteText(Format(CR) + Format(LF));
        end;
        ResponseOutStr.WriteText(Response);
    end;

    local procedure AddTextToOutputTempBlob(var OutputText: Text)
    begin
        InitializeOutput();
        if OutputTempBlob.HasValue then
            OutputOutStr.WriteText(GetChar(13) + GetChar(10) + GetChar(13) + GetChar(10));

        OutputOutStr.Write(OutputText);
    end;

    local procedure AddXmlToOutputTempBlob(var XmlDoc: DotNet npNetXmlDocument; Comment: Text)
    var
        MemoryStream: DotNet npNetMemoryStream;
        InStr: InStream;
    begin
        InitializeOutput();
        if OutputTempBlob.HasValue then begin
            OutputOutStr.WriteText(GetChar(13) + GetChar(10) + GetChar(13) + GetChar(10));
        end;
        if Comment <> '' then
            OutputOutStr.WriteText('<!--' + Comment + '-->' + GetChar(13) + GetChar(10));
        MemoryStream := MemoryStream.MemoryStream;
        XmlDoc.Save(MemoryStream);
        InStr := MemoryStream;
        CopyStream(OutputOutStr, InStr);
        MemoryStream.Flush;
        MemoryStream.Close;
        Clear(MemoryStream);
    end;

    procedure GetOutput(var TempBlob: Codeunit "Temp Blob") HasOutput: Boolean
    begin
        if not OutputInitialized then begin
            Clear(TempBlob);
            exit(false);
        end;
        TempBlob := OutputTempBlob;
        exit(TempBlob.HasValue);
    end;

    procedure GetResponse(var TempBlob: Codeunit "Temp Blob") HasOutput: Boolean
    begin
        if not OutputInitialized then begin
            Clear(TempBlob);
            exit(false);
        end;
        TempBlob := ResponseTempBlob;
        exit(TempBlob.HasValue);
    end;

    procedure InitializeOutput()
    begin
        if not OutputInitialized then begin
            Clear(OutputTempBlob);
            OutputTempBlob.CreateOutStream(OutputOutStr, TEXTENCODING::UTF8);

            Clear(ResponseTempBlob);
            ResponseTempBlob.CreateOutStream(ResponseOutStr, TEXTENCODING::UTF8);
        end;

        OutputInitialized := true;
    end;

    procedure ResetOutput()
    begin
        Clear(OutputTempBlob);

        Clear(ResponseTempBlob);
        OutputInitialized := false;
    end;

    local procedure "--- Dialog"()
    begin
    end;

    local procedure CloseDialog()
    begin
        if not UseDialog then
            exit;

        Window.Close;
    end;

    local procedure OpenDialog(Title: Text)
    begin
        if not UseDialog then
            exit;

        Window.Open(Title);
    end;

    local procedure UpdateDialog(Counter: Integer; Total: Integer; StartTime: Time; RecordPosition: Text[1024])
    var
        Runtime: Decimal;
    begin
        if not UseDialog then
            exit;

        if Total = 0 then
            Total := 1;
        Window.Update(2, Round((Counter / Total) * 10000, 1));
        if Counter mod 100 = 0 then begin
            Runtime := (Time - StartTime) / 1000;
            Window.Update(3, Round((Runtime * Total / Counter - Runtime) / 60, 0.01));
        end;
        Window.Update(4, RecordPosition);
    end;

    local procedure UseDialog(): Boolean
    begin
        exit(GuiAllowed and not HideDialog);
    end;

    procedure "--- Aux"()
    begin
    end;

    procedure GetAutomaticUsername(): Text
    var
        ActiveSession: Record "Active Session";
    begin
        ActiveSession.Get(ServiceInstanceId, SessionId);
        exit(LowerCase(ReplaceSpecialChar(ActiveSession."Database Name" + '_' + CompanyName)));
    end;

    procedure GetBasicAuthInfo(Username: Text; Password: Text): Text
    var
        Convert: DotNet npNetConvert;
        Encoding: DotNet npNetEncoding;
    begin
        exit(Convert.ToBase64String(Encoding.UTF8.GetBytes(Username + ':' + Password)));
    end;

    local procedure GetChar(CharInt: Integer): Text[1]
    var
        Char: Char;
    begin
        Char := CharInt;
        exit(Format(Char));
    end;

    local procedure GetFilename(XmlEntityType: Text[50]; PrimaryKeyValue: Text; RecordCounter: Integer): Text[1024]
    var
        Path: Text[1024];
    begin
        //-NC2.24 [373950]
        PrimaryKeyValue := ReplaceSpecialChar(PrimaryKeyValue);
        //+NC2.24 [373950]
        if PrimaryKeyValue <> '' then
            exit(Path + DelChr(Format(Today, 0, 9) + Format(Time), '=', ',.: ') + '-' + XmlEntityType + '-' +
                 PrimaryKeyValue + '.xml');

        exit(Path + DelChr(Format(Today, 0, 9) + Format(Time), '=', ',.: ') + '-' + XmlEntityType + '-' +
             PadStrLeft(Format(RecordCounter), 10, '0') + '.xml');
    end;

    local procedure GetXmlElementName(NpXmlElement: Record "NpXml Element"): Text
    var
        NpXmlNamespaces: Record "NpXml Namespace";
        NpXmlTemplate: Record "NpXml Template";
    begin
        if NpXmlElement.Namespace = '' then
            exit(NpXmlElement."Element Name");

        if not (NpXmlTemplate.Get(NpXmlElement."Xml Template Code") and NpXmlTemplate."Namespaces Enabled") then
            exit(NpXmlElement."Element Name");

        if not NpXmlNamespaces.Get(NpXmlElement."Xml Template Code", NpXmlElement.Namespace) then
            exit(NpXmlElement."Element Name");

        exit(NpXmlElement.Namespace + ':' + NpXmlElement."Element Name");
    end;

    local procedure GetXmlNamespace(NpXmlElement: Record "NpXml Element"): Text
    var
        NpXmlNamespaces: Record "NpXml Namespace";
        NpXmlTemplate: Record "NpXml Template";
    begin
        if NpXmlElement.Namespace = '' then
            exit('');

        if not (NpXmlTemplate.Get(NpXmlElement."Xml Template Code") and NpXmlTemplate."Namespaces Enabled") then
            exit('');
        if not NpXmlNamespaces.Get(NpXmlElement."Xml Template Code", NpXmlElement.Namespace) then
            exit('');

        exit(NpXmlNamespaces.Namespace);
    end;

    local procedure PadStrLeft(InputStr: Text[1024]; StrLength: Integer; PadChr: Char) Output: Text[1024]
    var
        PadLength: Integer;
        i: Integer;
        PadStr: Text[1024];
    begin
        PadLength := StrLength - StrLen(InputStr);
        PadStr := '';
        for i := 1 to PadLength do
            PadStr += Format(PadChr);

        exit(PadStr + InputStr);
    end;

    local procedure ReplaceSpecialChar(Input: Text) Output: Text
    var
        i: Integer;
    begin
        Output := '';
        for i := 1 to StrLen(Input) do
            case Input[i] of
                '0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
              'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J',
              'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T',
              'u', 'v', 'w', 'x', 'y', 'z', 'U', 'V', 'W', 'X', 'Y', 'Z', '-', '.', '_', ' ':
                    Output += Format(Input[i]);
                'æ':
                    Output += 'ae';
                'ø', 'ö':
                    Output += 'oe';
                'å', 'ä':
                    Output += 'aa';
                'è', 'é', 'ë', 'ê':
                    Output += 'e';
                'Æ':
                    Output += 'AE';
                'Ø', 'Ö':
                    Output += 'OE';
                'Å', 'Ä':
                    Output += 'AA';
                'É', 'È', 'Ë', 'Ê':
                    Output += 'E';
                else
                    Output += '-';
            end;

        exit(Output);
    end;

    local procedure MarkContainersAsArray(var XmlElement: DotNet npNetXmlElement)
    var
        XmlElementNextChild: DotNet npNetXmlElement;
        XmlElementChild: DotNet npNetXmlElement;
        XmlNodeList: DotNet npNetXmlNodeList;
        i: Integer;
    begin
        if IsNull(XmlElement) then
            exit;
        if NpXmlDomMgt.IsLeafNode(XmlElement) then
            exit;

        XmlNodeList := XmlElement.ChildNodes;
        XmlElementChild := XmlElement.FirstChild;
        repeat
            XmlElementNextChild := XmlElementChild.NextSibling;

            if XmlElementChild.Name = '#text' then
                XmlElement.RemoveChild(XmlElementChild)
            else
                MarkContainersAsArray(XmlElementChild);

            XmlElementChild := XmlElementNextChild;
        until IsNull(XmlElementChild);
    end;

    procedure Xml2Json(var XmlDoc: DotNet npNetXmlDocument; NpXmlTemplate: Record "NpXml Template") JsonString: Text
    var
        XmlDoc2: DotNet npNetXmlDocument;
        XmlElement: DotNet npNetXmlElement;
        JsonConvert: DotNet JsonConvert;
        JsonFormatting: DotNet npNetFormatting;
        XmlNodeList: DotNet npNetXmlNodeList;
        JToken: DotNet JToken;
        JContainer: DotNet npNetJContainer;
        JArray: DotNet JArray;
        RegEx: DotNet npNetRegex;
        i: Integer;
    begin
        XmlDoc2 := XmlDoc.Clone;
        XmlNodeList := XmlDoc2.DocumentElement.ChildNodes;
        for i := 0 to XmlNodeList.Count - 1 do begin
            XmlElement := XmlNodeList.Item(i);
            MarkContainersAsArray(XmlElement);
        end;
        if NpXmlTemplate."JSON Root is Array" then begin
            JsonString := JsonConvert.SerializeXmlNode(XmlDoc2.DocumentElement, JsonFormatting.Indented, false);
            JContainer := JContainer.Parse(JsonString);
            JArray := JContainer.SelectTokens(NpXmlTemplate."Xml Root Name", true);
            JsonString := JsonConvert.SerializeObject(JArray, JsonFormatting.Indented);
        end else
            JsonString := JsonConvert.SerializeXmlNode(XmlDoc2.DocumentElement, JsonFormatting.Indented, true);

        if NpXmlTemplate."Use JSON Numbers" then
            JsonString := RegEx.Replace(JsonString, '"(\d*\.?\d*)"(?!:)', '$1');

        JsonString := RegEx.Replace(JsonString, '(?i)#string#', '');

        exit(JsonString);
    end;

    procedure "--- UI"()
    begin
    end;

    procedure PreviewXml(NPXmlTemplateCode: Code[20])
    var
        NpXmlElement: Record "NpXml Element";
        NpXmlTemplate: Record "NpXml Template";
        TempBlob: Codeunit "Temp Blob";
        TempBlob2: Codeunit "Temp Blob";
        FileMgt: Codeunit "File Management";
        XmlDocNode: DotNet npNetXmlNode;
        XmlDoc: DotNet npNetXmlDocument;
        InStream: InStream;
        OutStream: OutStream;
        Filename: Text;
        JsonString: Text;
        FieldRef: FieldRef;
        RecRef2: RecordRef;
        Success: Boolean;
        Counter: Integer;
        Total: Integer;
        StartTime: Time;
    begin
        NpXmlTemplate.Get(NPXmlTemplateCode);
        NpXmlTemplate.TestField("Table No.");
        Clear(RecRef);
        RecRef.Open(NpXmlTemplate."Table No.");
        Counter := 0;
        Total := RecRef.Count;
        RecRef.FindSet;
        Success := false;

        StartTime := Time;
        OpenDialog(StrSubstNo(Text200, RecRef.Caption));
        while not Success do begin
            Counter += 1;
            UpdateDialog(Counter, Total, StartTime, RecRef.GetPosition);
            NpXmlElement.Reset;
            NpXmlElement.SetRange("Xml Template Code", NpXmlTemplate.Code);
            NpXmlElement.SetFilter("Parent Line No.", '=%1', 0);
            NpXmlElement.SetRange(Active, true);
            NpXmlElement.FindSet;
            repeat
                SetRecRefXmlFilter(NpXmlElement, RecRef, RecRef2);
                Success := RecRef2.FindFirst;
            until (NpXmlElement.Next = 0) or Success;
            if not Success then
                if RecRef.Next = 0 then
                    Error(Error002, RecRef.Caption);
        end;
        CloseDialog();

        PrimaryKeyValue := NpXmlValueMgt.GetPrimaryKeyValue(RecRef);
        Filename := GetFilename(NpXmlTemplate."Xml Root Name", PrimaryKeyValue, 1);
        NpXmlDomMgt.InitDoc(XmlDoc, XmlDocNode, NpXmlTemplate."Xml Root Name");

        NpXmlElement.Reset;
        NpXmlElement.SetRange("Xml Template Code", NpXmlTemplate.Code);
        NpXmlElement.SetFilter("Parent Line No.", '=%1', 0);
        NpXmlElement.SetRange(Active, true);
        if NpXmlElement.FindSet then
            repeat
                SetRecRefXmlFilter(NpXmlElement, RecRef, RecRef2);
                if RecRef2.FindSet then
                    repeat
                        Success := AddXmlElement(XmlDocNode, NpXmlElement, RecRef2, 0);
                    until (RecRef2.Next = 0) or not Success;
                RecRef2.Close;
            until NpXmlElement.Next = 0;
        RecRef.Close;

        AddXmlNamespaces(NpXmlTemplate, XmlDoc);
        Clear(TempBlob);
        TempBlob.CreateOutStream(OutStream);
        XmlDoc.Save(OutStream);
        if not TempBlob.HasValue then
            exit;

        if NpXmlTemplate."API Type" = NpXmlTemplate."API Type"::"REST (Json)" then begin
            JsonString := Xml2Json(XmlDoc, NpXmlTemplate);

            TempBlob.CreateInStream(InStream);
            TempBlob2.CreateOutStream(OutStream);

            CopyStream(OutStream, InStream);
            OutStream.Write(GetChar(13) + GetChar(10) + GetChar(13) + GetChar(10));
            OutStream.Write(JsonString);

            TempBlob := TempBlob2;
        end;
        TempBlob.CreateInStream(InStream);

        Filename := FileMgt.BLOBExport(TempBlob, Filename, false);
        NpXmlTemplateMgt.RunProcess('notepad.exe', Filename, false);
        Sleep(500);
        FileMgt.DeleteClientFile(Filename);
    end;
}

