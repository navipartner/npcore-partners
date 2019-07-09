codeunit 6151507 "Nc Managed Nav Modules Mgt."
{
    // NC2.00/MHA/20160525  CASE 240005 NaviConnect


    trigger OnRun()
    begin
    end;

    procedure FindMissingObjects(VersionListId: Text;VersionNo: Text;Url: Text;Username: Text;Password: Text;var TempObject: Record "Object" temporary): Boolean
    var
        "Object": Record "Object";
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        HttpWebRequest: DotNet npNetHttpWebRequest;
        HttpWebResponse: DotNet npNetHttpWebResponse;
        WebException: DotNet npNetWebException;
        XmlDoc: DotNet npNetXmlDocument;
        XmlElement: DotNet npNetXmlElement;
        XmlNsManager: DotNet npNetXmlNamespaceManager;
        ResponseText: Text;
    begin
        if Url = '' then
          exit(false);

        VersionNo := VersionList2VersionNo(VersionNo,VersionListId);

        XmlDoc := XmlDoc.XmlDocument;
        XmlDoc.LoadXml('<soapenv:Envelope encoding="utf-8" xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:mnm="' + ManagedNavModulesNs() + '">' +
                       '   <soapenv:Body>' +
                       '      <mnm:FindMissingObjects>' +
                       '         <mnm:module_no>' + VersionListId + '</mnm:module_no>' +
                       '         <mnm:version_no>' + VersionNo + '</mnm:version_no>' +
                       '         <mnm:nav_objects />' +
                       '      </mnm:FindMissingObjects>' +
                       '   </soapenv:Body>' +
                       '</soapenv:Envelope>');
        XmlNsManager := XmlNsManager.XmlNamespaceManager(XmlDoc.NameTable);
        XmlNsManager.AddNamespace('soapenv','http://schemas.xmlsoap.org/soap/envelope/');
        XmlNsManager.AddNamespace('mnm',ManagedNavModulesNs());

        XmlElement := XmlDoc.DocumentElement.SelectSingleNode('soapenv:Body/mnm:FindMissingObjects/mnm:nav_objects',XmlNsManager);
        AppendNavObjects(VersionListId,XmlElement);

        InitMnmWebRequest(Url,Username,Password,'FindMissingObjects',HttpWebRequest);
        if not NpXmlDomMgt.SendWebRequest(XmlDoc,HttpWebRequest,HttpWebResponse,WebException) then begin
          ResponseText := NpXmlDomMgt.GetWebResponseText(HttpWebResponse);
          if ResponseText = '' then
            Error(WebException.Message);

          XmlDoc.LoadXml(ResponseText);
          XmlElement := XmlDoc.DocumentElement.FirstChild.LastChild.LastChild;
          Error(XmlElement.InnerText);
        end;
        XmlDoc.LoadXml(NpXmlDomMgt.GetWebResponseText(HttpWebResponse));
        XmlElement := XmlDoc.DocumentElement.SelectSingleNode('soapenv:Body/mnm:FindMissingObjects_Result/mnm:nav_objects/mnm:object',XmlNsManager);
        while not IsNull(XmlElement) do begin
          TempObject.Init;
          Evaluate(TempObject.Type,NpXmlDomMgt.GetXmlAttributeText(XmlElement,'type',true),9);
          TempObject."Company Name" := '';
          Evaluate(TempObject.ID,NpXmlDomMgt.GetXmlAttributeText(XmlElement,'id',true),9);
          TempObject.Name := NpXmlDomMgt.GetXmlTextNamespace(XmlElement,'mnm:name',XmlNsManager,MaxStrLen(TempObject.Name),true);
          TempObject."Version List" := NpXmlDomMgt.GetXmlTextNamespace(XmlElement,'mnm:version_list',XmlNsManager,MaxStrLen(TempObject."Version List"),true);
          Evaluate(TempObject.Date,NpXmlDomMgt.GetXmlTextNamespace(XmlElement,'mnm:date',XmlNsManager,0,true),9);
          Evaluate(TempObject.Time,NpXmlDomMgt.GetXmlTextNamespace(XmlElement,'mnm:time',XmlNsManager,0,true),9);
          TempObject.Insert;

          if Object.Get(TempObject.Type,TempObject."Company Name",TempObject.ID) then begin
            TempObject := Object;
            TempObject.Modify;
          end;

          XmlElement := XmlElement.NextSibling;
          if not IsNull(XmlElement) then
            if XmlElement.Name <> 'object' then
              Error(XmlElement.Name);
        end;

        exit(true);
    end;

    procedure GetVersionNo(VersionListId: Text;Url: Text;Username: Text;Password: Text) VersionNo: Text
    var
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        HttpWebRequest: DotNet npNetHttpWebRequest;
        HttpWebResponse: DotNet npNetHttpWebResponse;
        WebException: DotNet npNetWebException;
        XmlDoc: DotNet npNetXmlDocument;
        XmlElement: DotNet npNetXmlElement;
        XmlNsManager: DotNet npNetXmlNamespaceManager;
        ResponseText: Text;
    begin
        if Url = '' then
          exit('');

        XmlDoc := XmlDoc.XmlDocument;
        XmlDoc.LoadXml('<soapenv:Envelope encoding="utf-8" xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:mnm="' + ManagedNavModulesNs() + '">' +
                       '   <soapenv:Body>' +
                       '      <mnm:ModuleVersionNo>' +
                       '         <mnm:module_no>' + VersionListId + '</mnm:module_no>' +
                       '         <mnm:nav_objects />' +
                       '      </mnm:ModuleVersionNo>' +
                       '   </soapenv:Body>' +
                       '</soapenv:Envelope>');
        XmlNsManager := XmlNsManager.XmlNamespaceManager(XmlDoc.NameTable);
        XmlNsManager.AddNamespace('soapenv','http://schemas.xmlsoap.org/soap/envelope/');
        XmlNsManager.AddNamespace('mnm',ManagedNavModulesNs());

        XmlElement := XmlDoc.DocumentElement.SelectSingleNode('soapenv:Body/mnm:ModuleVersionNo/mnm:nav_objects',XmlNsManager);
        AppendNavObjects(VersionListId,XmlElement);

        InitMnmWebRequest(Url,Username,Password,'ModuleVersionNo',HttpWebRequest);
        if not NpXmlDomMgt.SendWebRequest(XmlDoc,HttpWebRequest,HttpWebResponse,WebException) then begin
          ResponseText := NpXmlDomMgt.GetWebResponseText(HttpWebResponse);
          if ResponseText = '' then
            Error(WebException.Message);
          XmlDoc.LoadXml(ResponseText);
          XmlElement := XmlDoc.DocumentElement.FirstChild.LastChild.LastChild;
          Error(XmlElement.InnerText);
        end;

        XmlDoc.LoadXml(NpXmlDomMgt.GetWebResponseText(HttpWebResponse));
        XmlElement := XmlDoc.DocumentElement.SelectSingleNode('soapenv:Body/mnm:ModuleVersionNo_Result/mnm:return_value',XmlNsManager);
        VersionNo := XmlElement.InnerText;

        exit(VersionNo);
    end;

    local procedure "--- WebRequest"()
    begin
    end;

    local procedure AppendNavObjects(VersionListId: Text;var XmlElement: DotNet npNetXmlElement)
    var
        "Object": Record "Object";
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        XmlElementObject: DotNet npNetXmlElement;
        XmlElementObjectField: DotNet npNetXmlElement;
    begin
        Object.SetFilter("Company Name",'=%1','');
        Object.SetFilter("Version List",'*' + VersionListId + '*');
        if not Object.FindSet then
          exit;

        repeat
          NpXmlDomMgt.AddElementNamespace(XmlElement,'mnm:object',ManagedNavModulesNs(),XmlElementObject);

          NpXmlDomMgt.AddAttribute(XmlElementObject,'type',Format(Object.Type,0,9));
          NpXmlDomMgt.AddAttribute(XmlElementObject,'id',Format(Object.ID,0,9));

          NpXmlDomMgt.AddElementNamespace(XmlElementObject,'mnm:name',ManagedNavModulesNs(),XmlElementObjectField);
          XmlElementObjectField.InnerText := Format(Object.Name,0,9);

          NpXmlDomMgt.AddElementNamespace(XmlElementObject,'mnm:version_list',ManagedNavModulesNs(),XmlElementObjectField);
          XmlElementObjectField.InnerText := Format(Object."Version List",0,9);

          NpXmlDomMgt.AddElementNamespace(XmlElementObject,'mnm:date',ManagedNavModulesNs(),XmlElementObjectField);
          XmlElementObjectField.InnerText := Format(Object.Date,0,9);

          NpXmlDomMgt.AddElementNamespace(XmlElementObject,'mnm:time',ManagedNavModulesNs(),XmlElementObjectField);
          XmlElementObjectField.InnerText := Format(Object.Time,0,9);
        until Object.Next = 0;
    end;

    local procedure InitMnmWebRequest(Url: Text;Username: Text;Password: Text;SoapAction: Text;var HttpWebRequest: DotNet npNetHttpWebRequest)
    var
        Credential: DotNet npNetNetworkCredential;
    begin
        HttpWebRequest := HttpWebRequest.Create(Url);
        HttpWebRequest.Timeout := 1000 * 20;
        HttpWebRequest.UseDefaultCredentials(false);
        Credential := Credential.NetworkCredential(Username,Password);
        HttpWebRequest.Credentials(Credential);
        HttpWebRequest.Method := 'POST';
        HttpWebRequest.ContentType := 'text/xml; charset=utf-8';
        HttpWebRequest.Headers.Add('SOAPAction',SoapAction);
    end;

    local procedure ManagedNavModulesNs(): Text
    begin
        exit('urn:microsoft-dynamics-schemas/codeunit/managed_nav_modules');
    end;

    local procedure "--- Aux"()
    begin
    end;

    local procedure VersionList2VersionNo(VersionList: Text;VersionListId: Text) VersionNo: Text
    var
        Length: Integer;
        Position: Integer;
    begin
        Length := StrLen(VersionListId);
        if (VersionList = '') or (Length = 0) or (Length > StrLen(VersionList)) then
          exit(VersionList);

        Position := StrPos(VersionList,VersionListId);
        if Position = 0 then
          exit(VersionList);

        VersionNo := DelStr(VersionList,Position,Length);
        exit(VersionNo);
    end;
}

