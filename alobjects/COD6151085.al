codeunit 6151085 "RIS Retail Inventory Set Mgt."
{
    // NPR5.40/MHA /20180320  CASE 307025 Object created - Retail Inventory Set
    // NPR5.49/MHA /20190226  CASE 335198 Url Parameters should be excluded from Service Namespace in TryRequestInventory()
    // NPR5.51/MHA /20190705  CASE 361164 Updated Exception Message parsing in TryRequestInventory()


    trigger OnRun()
    begin
    end;

    var
        Text000: Label 'Error for Company %1: %2';

    local procedure "--- Get"()
    begin
    end;

    procedure GetRetailInventoryEnabled(): Boolean
    var
        RetailInventorySet: Record "RIS Retail Inventory Set";
    begin
        exit(RetailInventorySet.FindFirst);
    end;

    local procedure "--- Process"()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnProcessInventorySetEntry(RetailInventorySetEntry: Record "RIS Retail Inventory Set Entry";var RetailInventoryBuffer: Record "RIS Retail Inventory Buffer" temporary;var Handled: Boolean)
    begin
    end;

    procedure RunProcessInventorySet(Item: Record Item)
    var
        ItemVariant: Record "Item Variant";
        RetailInventorySet: Record "RIS Retail Inventory Set";
        RetailInventoryBuffer: Record "RIS Retail Inventory Buffer" temporary;
        VariantFilter: Text;
    begin
        if PAGE.RunModal(0,RetailInventorySet) <> ACTION::LookupOK then
          exit;

        ItemVariant.SetRange("Item No.",Item."No.");
        if ItemVariant.FindFirst then begin
          if PAGE.RunModal(0,ItemVariant) = ACTION::LookupOK then
            VariantFilter := ItemVariant.Code;
        end;

        ProcessInventorySet(RetailInventorySet,Item."No.",VariantFilter,RetailInventoryBuffer);
        PAGE.Run(0,RetailInventoryBuffer);
    end;

    procedure TestProcessInventorySet(RetailInventorySet: Record "RIS Retail Inventory Set")
    var
        Item: Record Item;
        RetailInventoryBuffer: Record "RIS Retail Inventory Buffer" temporary;
    begin
        if PAGE.RunModal(0,Item) <> ACTION::LookupOK then
          exit;

        ProcessInventorySet(RetailInventorySet,Item."No.",'',RetailInventoryBuffer);
        PAGE.Run(0,RetailInventoryBuffer);
    end;

    local procedure "--- Processing Subscriber"()
    begin
    end;

    procedure ProcessInventorySet(RetailInventorySet: Record "RIS Retail Inventory Set";ItemFilter: Text;VariantFilter: Text;var RetailInventoryBuffer: Record "RIS Retail Inventory Buffer" temporary)
    var
        RetailInventorySetEntry: Record "RIS Retail Inventory Set Entry";
        Handled: Boolean;
    begin
        RetailInventoryBuffer.DeleteAll;

        RetailInventorySetEntry.SetRange("Set Code",RetailInventorySet.Code);
        RetailInventorySetEntry.SetRange(Enabled,true);
        if RetailInventorySetEntry.FindSet then
          repeat
            RetailInventoryBuffer.Init;
            RetailInventoryBuffer."Set Code" := RetailInventorySetEntry."Set Code";
            RetailInventoryBuffer."Line No." := RetailInventorySetEntry."Line No.";
            RetailInventoryBuffer."Item Filter" := ItemFilter;
            RetailInventoryBuffer."Variant Filter" := VariantFilter;
            RetailInventoryBuffer."Location Filter" := RetailInventorySetEntry."Location Filter";
            RetailInventoryBuffer."Company Name" := RetailInventorySetEntry."Company Name";
            RetailInventoryBuffer.Inventory := 0;
            RetailInventoryBuffer.Insert;

            Handled := false;
            OnProcessInventorySetEntry(RetailInventorySetEntry,RetailInventoryBuffer,Handled);
            if not Handled then
              ProcessInventorySetEntry(RetailInventorySetEntry,RetailInventoryBuffer,Handled);
          until RetailInventorySetEntry.Next = 0;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151085, 'OnProcessInventorySetEntry', '', true, true)]
    local procedure ProcessInventorySetEntry(RetailInventorySetEntry: Record "RIS Retail Inventory Set Entry";var RetailInventoryBuffer: Record "RIS Retail Inventory Buffer" temporary;var Handled: Boolean)
    var
        Inventory: Decimal;
    begin
        if Handled then
          exit;

        Handled := true;

        if RetailInventoryBuffer.Inventory <> 0 then begin
          RetailInventoryBuffer.Inventory := 0;
          RetailInventoryBuffer.Modify;
        end;

        if TryRequestInventory(RetailInventorySetEntry,RetailInventoryBuffer,Inventory) then
          RetailInventoryBuffer.Inventory := Inventory
        else begin
          RetailInventoryBuffer."Processing Error" := true;
          RetailInventoryBuffer."Processing Error Message" := CopyStr(GetLastErrorText,1,MaxStrLen(RetailInventoryBuffer."Processing Error Message"));
        end;

        RetailInventoryBuffer.Modify;
    end;

    [TryFunction]
    local procedure TryRequestInventory(RetailInventorySetEntry: Record "RIS Retail Inventory Set Entry";var RetailInventoryBuffer: Record "RIS Retail Inventory Buffer" temporary;var TotalInventory: Decimal)
    var
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        Credential: DotNet npNetNetworkCredential;
        HttpWebRequest: DotNet npNetHttpWebRequest;
        HttpWebResponse: DotNet npNetHttpWebResponse;
        MemoryStream: DotNet npNetMemoryStream;
        Stream: DotNet npNetStream;
        StreamReader: DotNet npNetStreamReader;
        WebException: DotNet npNetWebException;
        XmlNamespaceManager: DotNet npNetXmlNamespaceManager;
        XmlDoc: DotNet npNetXmlDocument;
        XmlElement: DotNet npNetXmlElement;
        XmlElement2: DotNet npNetXmlElement;
        XmlNodeList: DotNet npNetXmlNodeList;
        i: Integer;
        Position: Integer;
        Inventory: Decimal;
        ErrorMessage: Text;
        LastErrorMessage: Text;
        Response: Text;
        WsNamespace: Text;
    begin
        TotalInventory := 0;

        Clear(HttpWebRequest);
        HttpWebRequest := HttpWebRequest.Create(RetailInventorySetEntry."Api Url");
        HttpWebRequest.Timeout := 5 * 1000;
        NpXmlDomMgt.SetTrustedCertificateValidation(HttpWebRequest);

        if RetailInventorySetEntry."Api Username" = '' then
          HttpWebRequest.UseDefaultCredentials(true)
        else begin
          HttpWebRequest.UseDefaultCredentials(false);
          Credential := Credential.NetworkCredential(RetailInventorySetEntry."Api Username",RetailInventorySetEntry."Api Password");
          HttpWebRequest.Credentials(Credential);
        end;

        WsNamespace := RetailInventorySetEntry."Api Url";
        Position := StrPos(WsNamespace,'/');
        while Position > 0 do begin
          WsNamespace := DelStr(WsNamespace,1,Position);
          Position := StrPos(WsNamespace,'/');
        end;
        //-NPR5.49 [335198]
        Position := StrPos(WsNamespace,'?');
        if Position > 0 then
          WsNamespace := DelStr(WsNamespace,Position);
        //+NPR5.49 [335198]
        WsNamespace := 'urn:microsoft-dynamics-schemas/codeunit/' + WsNamespace;

        Clear(XmlDoc);
        XmlDoc := XmlDoc.XmlDocument;
        XmlDoc.LoadXml('<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">' +
                       '  <soapenv:Header />' +
                       '  <soapenv:Body>' +
                       '    <GetItemInventory xmlns="' + WsNamespace + '">' +
                       '       <itemFilter />' +
                       '       <variantFilter />' +
                       '       <locationFilter />' +
                       '       <items />' +
                       '    </GetItemInventory>' +
                       '  </soapenv:Body>' +
                       '</soapenv:Envelope>');
        HttpWebRequest.Method := 'RetailT';
        HttpWebRequest.ContentType := 'text/xml; charset=utf-8';
        HttpWebRequest.Headers.Add('SOAPAction','GetItemInventory');
        XmlElement := XmlDoc.DocumentElement.LastChild.LastChild;

        XmlNamespaceManager := XmlNamespaceManager.XmlNamespaceManager(XmlDoc.NameTable);
        XmlNamespaceManager.AddNamespace('ms',WsNamespace);

        XmlElement2 := XmlElement.SelectSingleNode('ms:itemFilter',XmlNamespaceManager);
        XmlElement2.InnerText := RetailInventoryBuffer."Item Filter";
        XmlElement2 := XmlElement.SelectSingleNode('ms:variantFilter',XmlNamespaceManager);
        XmlElement2.InnerText := RetailInventoryBuffer."Variant Filter";
        XmlElement2 := XmlElement.SelectSingleNode('ms:locationFilter',XmlNamespaceManager);
        XmlElement2.InnerText := RetailInventoryBuffer."Location Filter";
        if not NpXmlDomMgt.SendWebRequest(XmlDoc,HttpWebRequest,HttpWebResponse,WebException) then begin
          //-NPR5.51 [361164]
          ErrorMessage := NpXmlDomMgt.GetWebExceptionMessage(WebException);
          if NpXmlDomMgt.TryLoadXml(ErrorMessage,XmlDoc) then begin
            NpXmlDomMgt.RemoveNameSpaces(XmlDoc);
            if NpXmlDomMgt.FindNode(XmlDoc.DocumentElement,'//faultstring',XmlElement) then
              ErrorMessage := XmlElement.InnerText;
          end;
          Error(CopyStr(ErrorMessage,1,1000));
          //+NPR5.51 [361164]
        end;

        Stream := HttpWebResponse.GetResponseStream;
        StreamReader := StreamReader.StreamReader(Stream);
        Response := StreamReader.ReadToEnd;
        Stream.Flush;
        Stream.Close;
        Clear(Stream);
        HttpWebResponse.Close;

        Clear(XmlDoc);
        XmlDoc := XmlDoc.XmlDocument;
        XmlDoc.LoadXml(Response);
        NpXmlDomMgt.RemoveNameSpaces(XmlDoc);
        if NpXmlDomMgt.FindNodes(XmlDoc.DocumentElement,'item',XmlNodeList) then
          for i := 0 to XmlNodeList.Count - 1 do begin
            XmlElement := XmlNodeList.ItemOf(i);
            if Evaluate(Inventory,XmlElement.InnerText,9) then begin
              if Inventory < 0 then
                Inventory := 0;
              TotalInventory += Inventory;
            end;
          end;
    end;
}

