codeunit 6151506 "Nc Gambit Management"
{
    // NC1.01/MH/20150201  CASE 199932 Error-, Status- and Case reporting to NaviPartner
    // NC1.11/MH/20150325  CASE 209616 Replaced ServerInstance Name with Database Name and RetailList with Attachment
    // NC1.13/MH/20150414  CASE 211360 Implemented WebRequest wrapper for exception handling
    // CASE277358/TTH/20151120 CASE 227358 Type replaced with "Import Type" in "NaviConnect Import Entry"
    // NC1.21/MHA/20151120  CASE 227358 NaviConnect
    // NC2.00/MHA/20160525  CASE 240005 NaviConnect

    TableNo = "Nc Import Entry";

    trigger OnRun()
    begin
        InsertEntryImportEntry(Rec);
    end;

    var
        Error001: Label 'Woops, something went wrong...';
        Text001: Label 'Create case in NaviPartners Case system?';
        Text002: Label 'A case has already been created for this task\\Create a new case?';
        Text003: Label 'A case has already been created for this %1 Import\\Create a new case?';
        Text005: Label 'Created by: %1';
        Text006: Label 'NaviConnect Task';
        Text007: Label 'NaviConnect %1 Import';
        Text008: Label 'Case %1 has been created';
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";

    procedure InsertEntry("Code": Code[50];TableNo: Integer;FieldNo: Integer;ID: Code[100];Description: Text[1024];Critical: Boolean)
    var
        ActiveSession: Record "Active Session";
        HttpWebResponse: DotNet npNetHttpWebResponse;
        WebException: DotNet npNetWebException;
        XmlDoc: DotNet npNetXmlDocument;
        XmlDocResponse: DotNet npNetXmlDocument;
        XmlElement: DotNet npNetXmlElement;
        XmlElement2: DotNet npNetXmlElement;
        XmlNamespaceManager: DotNet npNetXmlNamespaceManager;
    begin
        if not IsNull(XmlDoc) then
          Clear(XmlDoc);
        XmlDoc := XmlDoc.XmlDocument;
        XmlDoc.LoadXml('<?xml version="1.0" encoding="utf-8"?>' +
                       '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">' +
                         '<soap:Body>' +
                           '<InsertEntry xmlns="urn:microsoft-dynamics-schemas/codeunit/Gambit">' +
                             '<code />' +
                             '<tableNo />' +
                             '<fieldNo />' +
                             '<description />' +
                             '<iD />' +
                             '<critical />' +
                             '<navServerName>NAV2013</navServerName>' +
                             '<navDatabaseName />' +
                             '<navCompanyName />' +
                             '<navUsername />' +
                           '</InsertEntry>' +
                         '</soap:Body>' +
                       '</soap:Envelope>');
        XmlNamespaceManager := XmlNamespaceManager.XmlNamespaceManager(XmlDoc.NameTable);
        XmlNamespaceManager.AddNamespace('soap','http://schemas.xmlsoap.org/soap/envelope/');
        XmlNamespaceManager.AddNamespace('xsi','"http://www.w3.org/2001/XMLSchema-instance');
        XmlNamespaceManager.AddNamespace('xsd','http://www.w3.org/2001/XMLSchema');
        XmlNamespaceManager.AddNamespace('gambit','urn:microsoft-dynamics-schemas/codeunit/Gambit');
        XmlElement := XmlDoc.DocumentElement;
        XmlElement := XmlElement.SelectSingleNode('soap:Body/gambit:InsertEntry',XmlNamespaceManager);

        XmlElement2 := XmlElement.SelectSingleNode('gambit:code',XmlNamespaceManager);
        XmlElement2.InnerText := Code;
        XmlElement2 := XmlElement.SelectSingleNode('gambit:tableNo',XmlNamespaceManager);
        XmlElement2.InnerText := Format(TableNo,0,9);
        XmlElement2 := XmlElement.SelectSingleNode('gambit:fieldNo',XmlNamespaceManager);
        XmlElement2.InnerText := Format(FieldNo,0,9);
        XmlElement2 := XmlElement.SelectSingleNode('gambit:iD',XmlNamespaceManager);
        XmlElement2.InnerText := Format(ID,0,9);
        XmlElement2 := XmlElement.SelectSingleNode('gambit:description',XmlNamespaceManager);
        XmlElement2.InnerText := Description;
        XmlElement2 := XmlElement.SelectSingleNode('gambit:critical',XmlNamespaceManager);
        XmlElement2.InnerText := Format(Critical,0,9);

        XmlElement2 := XmlElement.SelectSingleNode('gambit:navDatabaseName',XmlNamespaceManager);
        //-NC1.11
        //ServerInstance.GET(SERVICEINSTANCEID);
        //XmlElement2.InnerText := ServerInstance."Server Instance Name";
        ActiveSession.Get(ServiceInstanceId,SessionId);
        XmlElement2.InnerText := ActiveSession."Database Name";
        //+NC1.11
        XmlElement2 := XmlElement.SelectSingleNode('gambit:navCompanyName',XmlNamespaceManager);
        XmlElement2.InnerText := CompanyName;
        XmlElement2 := XmlElement.SelectSingleNode('gambit:navUsername',XmlNamespaceManager);
        XmlElement2.InnerText := GetShortUserId();

        SendAPI(XmlDoc,'InsertEntry',XmlDocResponse);
        Clear(XmlDoc);
    end;

    procedure InsertEntryImportEntry(ImportLog: Record "Nc Import Entry")
    var
        ErrorText: Text[1024];
        InStr: InStream;
    begin
        if not ImportLog.Find then
          exit;

        ErrorText := '';
        ImportLog.CalcFields("Last Error Message");
        if ImportLog."Last Error Message".HasValue then begin
          ImportLog."Last Error Message".CreateInStream(InStr);
          InStr.ReadText(ErrorText);
        end;
        InsertEntry('MAGENTO_IMPORT',0,0,ImportLog."Document Name",ErrorText,true);
    end;

    procedure InsertCase(Description: Text;Description2: Text;Description3: Text;Description4: Text;Description5: Text;var TempAttachment: Record Attachment temporary) JobNo: Code[20]
    var
        ActiveSession: Record "Active Session";
        TempCommentLine: Record "Comment Line" temporary;
        BinaryReader: DotNet npNetBinaryReader;
        Convert: DotNet npNetConvert;
        MemoryStream: DotNet npNetMemoryStream;
        HttpWebResponse: DotNet npNetHttpWebResponse;
        WebException: DotNet npNetWebException;
        XmlDoc: DotNet npNetXmlDocument;
        XmlDocResponse: DotNet npNetXmlDocument;
        XmlElement: DotNet npNetXmlElement;
        XmlElement2: DotNet npNetXmlElement;
        XmlElementAttachment: DotNet npNetXmlElement;
        XmlElementAttachmentData: DotNet npNetXmlElement;
        XmlElementAttachmentDataEntry: DotNet npNetXmlElement;
        XmlElementComment: DotNet npNetXmlElement;
        XmlElementCommentLine: DotNet npNetXmlElement;
        XmlNamespaceManager: DotNet npNetXmlNamespaceManager;
        RecRef: RecordRef;
        RecordID: RecordID;
        InStr: InStream;
        CommentLine: Text;
        XmlNsCase: Text;
        i: Integer;
    begin
        TempCommentLine.DeleteAll;
        if PAGE.RunModal(PAGE::"Comment Sheet",TempCommentLine) <> ACTION::LookupOK then
          exit('');

        Clear(XmlDoc);
        XmlDoc := XmlDoc.XmlDocument;
        XmlDoc.LoadXml('<?xml version="1.0" encoding="utf-8"?>' +
                       '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">' +
                         '<soap:Body>' +
                           '<InsertCase xmlns="urn:microsoft-dynamics-schemas/codeunit/Gambit">' +
                             '<cases>' +
                               '<case xmlns="urn:microsoft-dynamics-nav/xmlports/gambit">' +
                                 '<group>NAVICONNECT</group>' +
                                 '<contact_server>NAV2013</contact_server>' +
                                 '<contact_database />' +
                                 '<contact_company />' +
                                 '<user_id />' +
                                 '<description />' +
                                 '<description_2 />' +
                                 '<description_3 />' +
                                 '<description_4 />' +
                                 '<description_5 />' +
                                 '<comments />' +
                                 '<attachments />' +
                               '</case>' +
                             '</cases>' +
                           '</InsertCase>' +
                         '</soap:Body>' +
                       '</soap:Envelope>');
        XmlNamespaceManager := XmlNamespaceManager.XmlNamespaceManager(XmlDoc.NameTable);
        XmlNamespaceManager.AddNamespace('soap','http://schemas.xmlsoap.org/soap/envelope/');
        XmlNamespaceManager.AddNamespace('xsi','"http://www.w3.org/2001/XMLSchema-instance');
        XmlNamespaceManager.AddNamespace('xsd','http://www.w3.org/2001/XMLSchema');
        XmlNamespaceManager.AddNamespace('gambit','urn:microsoft-dynamics-schemas/codeunit/Gambit');
        XmlNsCase := 'urn:microsoft-dynamics-nav/xmlports/gambit';
        XmlNamespaceManager.AddNamespace('case',XmlNsCase);
        XmlElement := XmlDoc.DocumentElement;
        XmlElement := XmlElement.SelectSingleNode('soap:Body/gambit:InsertCase/gambit:cases/case:case',XmlNamespaceManager);

        //-NC1.11
        //ServerInstance.GET(SERVICEINSTANCEID);
        //XmlElement2 := XmlElement.SelectSingleNode('case:contact_database',XmlNamespaceManager);
        //XmlElement2.InnerText := ServerInstance."Server Instance Name";
        XmlElement2 := XmlElement.SelectSingleNode('case:contact_database',XmlNamespaceManager);
        ActiveSession.Get(ServiceInstanceId,SessionId);
        XmlElement2.InnerText := ActiveSession."Database Name";
        //+NC1.11
        XmlElement2 := XmlElement.SelectSingleNode('case:contact_company',XmlNamespaceManager);
        XmlElement2.InnerText := CompanyName;
        XmlElement2 := XmlElement.SelectSingleNode('case:user_id',XmlNamespaceManager);
        XmlElement2.InnerText := GetShortUserId();

        XmlElement2 := XmlElement.SelectSingleNode('case:description',XmlNamespaceManager);
        XmlElement2.InnerText := Description;
        XmlElement2 := XmlElement.SelectSingleNode('case:description_2',XmlNamespaceManager);
        XmlElement2.InnerText := Description2;
        XmlElement2 := XmlElement.SelectSingleNode('case:description_3',XmlNamespaceManager);
        XmlElement2.InnerText := Description3;
        XmlElement2 := XmlElement.SelectSingleNode('case:description_4',XmlNamespaceManager);
        XmlElement2.InnerText := Description4;
        XmlElement2 := XmlElement.SelectSingleNode('case:description_5',XmlNamespaceManager);
        XmlElement2.InnerText := Description5;

        if TempCommentLine.FindSet then begin
          XmlElement2 := XmlElement.SelectSingleNode('case:comments',XmlNamespaceManager);
          repeat
            AddElement(XmlElement2,'comment_line',XmlElementCommentLine,XmlNsCase);
            AddElement(XmlElementCommentLine,'comment',XmlElementComment,XmlNsCase);
            XmlElementComment.InnerXml := TempCommentLine.Comment;
          until TempCommentLine.Next = 0;
        end;

        //-NC1.11
        //IF TempBlob.FINDSET THEN
        //  REPEAT
        //    TempBlob.CALCFIELDS(Blob);
        //    IF TempBlob.Blob.HASVALUE AND TempRetailList.GET(TempBlob."Primay Key") THEN BEGIN
        //      XmlElement2 := XmlElement.SelectSingleNode('case:attachments',XmlNamespaceManager);
        //      AddElement(XmlElement2,'attachment',XmlElementAttachment,XmlNsCase);
        //      AddAttribute(XmlElementAttachment,'name',TempRetailList.Value);
        //
        //      AddElement(XmlElementAttachment,'data',XmlElementAttachmentData,XmlNsCase);
        //      TempBlob.Blob.CREATEINSTREAM(InStr);
        //      MemoryStream := InStr;
        //      BinaryReader := BinaryReader.BinaryReader(InStr);
        //      i := 0;
        //      WHILE i < MemoryStream.Length DO BEGIN
        //        AddElement(XmlElementAttachmentData,'data_entry',XmlElementAttachmentDataEntry,XmlNsCase);
        //        XmlElementAttachmentDataEntry.InnerText := Convert.ToBase64String(BinaryReader.ReadBytes(128));
        //        i += 128;
        //      END;
        //      MemoryStream.Flush;
        //      MemoryStream.Close;
        //      CLEAR(MemoryStream);
        //    END;
        //  UNTIL TempBlob.NEXT = 0;
        if TempAttachment.FindSet then
          repeat
            TempAttachment.CalcFields("Attachment File");
            if TempAttachment."Attachment File".HasValue and (TempAttachment."File Extension" <> '') then begin
              XmlElement2 := XmlElement.SelectSingleNode('case:attachments',XmlNamespaceManager);
              AddElement(XmlElement2,'attachment',XmlElementAttachment,XmlNsCase);
              AddAttribute(XmlElementAttachment,'name',TempAttachment."File Extension");

              AddElement(XmlElementAttachment,'data',XmlElementAttachmentData,XmlNsCase);
              TempAttachment."Attachment File".CreateInStream(InStr);
              MemoryStream := InStr;
              BinaryReader := BinaryReader.BinaryReader(InStr);
              i := 0;
              while i < MemoryStream.Length do begin
                AddElement(XmlElementAttachmentData,'data_entry',XmlElementAttachmentDataEntry,XmlNsCase);
                XmlElementAttachmentDataEntry.InnerText := Convert.ToBase64String(BinaryReader.ReadBytes(128));
                i += 128;
              end;
              MemoryStream.Flush;
              MemoryStream.Close;
              Clear(MemoryStream);
            end;
          until TempAttachment.Next = 0;
        //+NC1.11

        if not SendAPI(XmlDoc,'InsertCase',XmlDocResponse) then begin
          XmlNamespaceManager.AddNamespace('s','http://schemas.xmlsoap.org/soap/envelope/');
          XmlElement := XmlDocResponse.SelectSingleNode('s:Envelope/s:Body/s:Fault',XmlNamespaceManager);
          if not IsNull(XmlElement) then
            XmlElement := XmlElement.LastChild;
          if not IsNull(XmlElement) then
            Error(Error001 + '\\' + XmlElement.InnerText)
          else
            Error(Error001);
        end;

        XmlElement := XmlDocResponse.DocumentElement;
        XmlElement2 := XmlElement.SelectSingleNode('soap:Body/gambit:InsertCase_Result/gambit:return_value',XmlNamespaceManager);

        JobNo := XmlElement2.InnerXml;
        exit(JobNo);
    end;

    procedure InsertCaseTask(var Task: Record "Nc Task")
    var
        TempAttachment: Record Attachment temporary;
        RecRef: RecordRef;
        RecordID: RecordID;
        Description: Text;
        Description2: Text;
        Description3: Text;
        Description4: Text;
        Description5: Text;
        JobNo: Code[20];
    begin
        if Task."NaviPartner Case Url" = '' then begin
          if not Confirm(Text001,true) then
            exit;
        end else begin
          if not Confirm(Text002,false) then
            exit;
        end;
        //-NC1.11
        //TempBlob.DELETEALL;
        //TempRetailList.DELETEALL;
        //Task.CALCFIELDS("Data Output",Response);
        //IF Task."Data Output".HASVALUE THEN BEGIN
        //  TempBlob.INIT;
        //  TempBlob."Primay Key" := 1;
        //  TempBlob.Blob := Task."Data Output";
        //  TempBlob.INSERT;
        //
        //  TempRetailList.INIT;
        //  TempRetailList.Number := 1;
        //  TempRetailList.Value := 'Output.txt';
        //  TempRetailList.INSERT;
        //END;
        //IF Task.Response.HASVALUE THEN BEGIN
        //  TempBlob.INIT;
        //  TempBlob."Primay Key" := 2;
        //  TempBlob.Blob := Task.Response;
        //  TempBlob.INSERT;
        //
        //  TempRetailList.INIT;
        //  TempRetailList.Number := 2;
        //  TempRetailList.Value := 'Response.txt';
        //  TempRetailList.INSERT;
        //END;
        TempAttachment.DeleteAll;
        Task.CalcFields("Data Output",Response);
        if Task."Data Output".HasValue then begin
          TempAttachment.Init;
          TempAttachment."No." := 1;

          TempAttachment."Attachment File" := Task."Data Output";
          TempAttachment."File Extension" := 'Output.txt';
          TempAttachment.Insert;
        end;
        if Task.Response.HasValue then begin
          TempAttachment.Init;
          TempAttachment."No." := 2;
          TempAttachment."Attachment File" := Task.Response;
          TempAttachment."File Extension" := 'Response.txt';
          TempAttachment.Insert;
        end;
        //+NC1.11

        Description := Text006 + ' - ' + Format(Task."Entry No.") + ' - ' + Format(Task.Type);
        Description2 := '';
        if (Task."Table No." > 0) and (Task."Record Position" <> '') then begin
          Clear(RecRef);
          RecRef.Open(Task."Table No.");
          RecRef.SetPosition(Task."Record Position");
          RecordID := RecRef.RecordId;

          Description2 := Format(RecordID);

          RecRef.Close;
        end;
        Description3 := Format(Task."Log Date");
        Description4 := '';
        Description5 := StrSubstNo(Text005,LowerCase(GetShortUserId()));

        //-NC1.11
        //JobNo := InsertCase(Description,Description2,Description3,Description4,Description5,TempBlob,TempRetailList);
        JobNo := InsertCase(Description,Description2,Description3,Description4,Description5,TempAttachment);
        //+NC1.11
        if JobNo <> '' then begin
          Task."NaviPartner Case Url" := 'http://extranet.np-retail.dk?issueId=' + JobNo;
          Task.Modify(true);
          Message(StrSubstNo(Text008,JobNo));
        end else
            Message(Error001);
    end;

    procedure InsertCaseImportEntry(var ImportEntry: Record "Nc Import Entry")
    var
        TempAttachment: Record Attachment temporary;
        RecRef: RecordRef;
        RecordID: RecordID;
        Description: Text;
        Description2: Text;
        Description3: Text;
        Description4: Text;
        Description5: Text;
        JobNo: Code[20];
    begin
        if ImportEntry."NaviPartner Case Url" = '' then begin
          if not Confirm(Text001,true) then
            exit;
        end else begin
          //-CASE277358
          if not Confirm(StrSubstNo(Text003,ImportEntry."Import Type"),false) then
          //IF NOT CONFIRM(STRSUBSTNO(Text003,FORMAT(ImportEntry.Type)),FALSE) THEN
          //+CASE277358
            exit;
        end;
        //-NC1.11
        //TempBlob.DELETEALL;
        //ImportEntry.CALCFIELDS("Document Source","Last Error Message");
        //IF ImportEntry."Document Source".HASVALUE THEN BEGIN
        //  TempBlob.INIT;
        //  TempBlob."Primay Key" := 1;
        //  TempBlob.Blob := ImportEntry."Document Source";
        //  TempBlob.INSERT;
        //
        //  TempRetailList.INIT;
        //  TempRetailList.Number := 1;
        //  TempRetailList.Value := 'Input.txt';
        //  TempRetailList.INSERT;
        //END;
        //IF ImportEntry."Last Error Message".HASVALUE THEN BEGIN
        //  TempBlob.INIT;
        //  TempBlob."Primay Key" := 2;
        //  TempBlob.Blob := ImportEntry."Last Error Message";
        //  TempBlob.INSERT;
        //
        //  TempRetailList.INIT;
        //  TempRetailList.Number := 2;
        //  TempRetailList.Value := 'Result.txt';
        //  TempRetailList.INSERT;
        //END;
        TempAttachment.DeleteAll;
        ImportEntry.CalcFields("Document Source","Last Error Message");
        if ImportEntry."Document Source".HasValue then begin
          TempAttachment.Init;
          TempAttachment."No." := 1;
          TempAttachment."Attachment File" := ImportEntry."Document Source";
          TempAttachment."File Extension" := 'Input.txt';
          TempAttachment.Insert;
        end;
        if ImportEntry."Last Error Message".HasValue then begin
          TempAttachment.Init;
          TempAttachment."No." := 2;
          TempAttachment."Attachment File" := ImportEntry."Last Error Message";
          TempAttachment."File Extension" := 'Result.txt';
          TempAttachment.Insert;
        end;
        //+NC1.11
        //-NC1.21
        //Description := STRSUBSTNO(Text007,FORMAT(ImportEntry.Type)) + ' - ' + FORMAT(ImportEntry."Entry No.");
        Description := StrSubstNo(Text007,Format(ImportEntry."Import Type")) + ' - ' + Format(ImportEntry."Entry No.");
        //-NC1.21
        Description2 := ImportEntry."Document Name";
        Description3 := Format(ImportEntry.Date);
        Description4 := '';
        Description5 := StrSubstNo(Text005,LowerCase(GetShortUserId()));

        //-NC1.11
        //JobNo := InsertCase(Description,Description2,Description3,Description4,Description5,TempBlob,TempRetailList);
        JobNo := InsertCase(Description,Description2,Description3,Description4,Description5,TempAttachment);
        //+NC1.11
        if JobNo <> '' then begin
          ImportEntry."NaviPartner Case Url" := 'http://extranet.np-retail.dk?issueId=' + JobNo;
          ImportEntry.Modify(true);
          Message(StrSubstNo(Text008,JobNo));
        end else
            Message(Error001);
    end;

    local procedure SendAPI(var XmlDoc: DotNet npNetXmlDocument;SoapAction: Text;var XmlDocResponse: DotNet npNetXmlDocument) Result: Boolean
    var
        Credential: DotNet npNetNetworkCredential;
        HttpWebRequest: DotNet npNetHttpWebRequest;
        HttpWebResponse: DotNet npNetHttpWebResponse;
        MemoryStream: DotNet npNetMemoryStream;
        WebException: DotNet npNetWebException;
        XmlException: DotNet npNetXmlException;
    begin
        HttpWebRequest := HttpWebRequest.Create('http://nst.np-retail.dk:7047/DynamicsNAV/ws/Navi%20Partner%20K%C3%B8benhavn%20ApS/Codeunit/Gambit');
        HttpWebRequest.UseDefaultCredentials(false);
        Credential := Credential.NetworkCredential('wslogin@navikbh','be/ikCVS+1');
        HttpWebRequest.Credentials(Credential);
        HttpWebRequest.Method := 'POST';
        HttpWebRequest.ContentType := 'text/xml; charset=utf-8';
        HttpWebRequest.Headers.Add('SOAPAction',SoapAction);
        //-NC1.13
        //NPWebRequest := NPWebRequest.NPWebRequest;
        //Result := NPWebRequest.SendWebRequest(XmlDoc,HttpWebRequest,HttpWebResponse,WebException);
        Result := NpXmlDomMgt.SendWebRequest(XmlDoc,HttpWebRequest,HttpWebResponse,WebException);
        //+NC1.13
        MemoryStream := HttpWebResponse.GetResponseStream();
        XmlDocResponse := XmlDocResponse.XmlDocument;
        XmlDocResponse.Load(MemoryStream);
        MemoryStream.Flush;
        MemoryStream.Close;
        Clear(MemoryStream);
        exit(Result);
    end;

    local procedure "--- Create Xml"()
    begin
    end;

    local procedure AddElement(var XmlElement: DotNet npNetXmlElement;ElementName: Text[250];var CreatedXmlElement: DotNet npNetXmlElement;NameSpace: Text)
    var
        NewChildXmlElement: DotNet npNetXmlElement;
        XmlNodeType: DotNet npNetXmlNodeType;
    begin
        NewChildXmlElement := XmlElement.OwnerDocument.CreateNode(XmlNodeType.Element,LowerCase(ElementName),NameSpace);
        XmlElement.AppendChild(NewChildXmlElement);
        CreatedXmlElement := NewChildXmlElement;
    end;

    local procedure AddAttribute(var XmlNode: DotNet npNetXmlNode;Name: Text[260];NodeValue: Text[260]) ExitStatus: Integer
    var
        NewAttributeXmlNode: DotNet npNetXmlNode;
    begin
        Name := LowerCase(Name);
        NewAttributeXmlNode := XmlNode.OwnerDocument.CreateAttribute(Name);

        if IsNull(NewAttributeXmlNode) then begin
          ExitStatus := 60;
          exit(ExitStatus);
        end;

        if NodeValue <> '' then
          NewAttributeXmlNode.InnerText := NodeValue;

        XmlNode.Attributes.SetNamedItem(NewAttributeXmlNode);
    end;

    procedure "--- Get"()
    begin
    end;

    procedure GetShortUserId() ShortUserId: Text
    begin
        ShortUserId := UserId;
        if StrPos(ShortUserId,'\') <> 0 then
          ShortUserId := CopyStr(ShortUserId,StrPos(ShortUserId,'\') + 1);
        exit(ShortUserId);
    end;

    local procedure GetBase64(TempBlob: Record TempBlob temporary) Value: Text
    var
        BinaryReader: DotNet npNetBinaryReader;
        Convert: DotNet npNetConvert;
        MemoryStream: DotNet npNetMemoryStream;
        TextEncoding: DotNet npNetEncoding;
        InStr: InStream;
    begin
        Value := '';

        TempBlob.Blob.CreateInStream(InStr);
        MemoryStream := InStr;
        BinaryReader := BinaryReader.BinaryReader(MemoryStream);
        Value := Convert.ToBase64String(BinaryReader.ReadBytes(MemoryStream.Length));
        MemoryStream.Flush;
        MemoryStream.Close;
        Clear(MemoryStream);
        exit(Value);
    end;
}

