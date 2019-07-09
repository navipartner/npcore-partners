codeunit 6151408 "Magento Inventory NpXml Value"
{
    // MAG1.22/MHA/20160421 CASE 236917 Object created
    // MAG1.22.01/MHA/20161005 CASE 236917 Added Invoke of SetTrustedCertificateValidation() in order to ignore SSL certificate validation and Credential Domain added
    // MAG2.00/MHA/20160525  CASE 242557 Magento Integration
    // MAG2.01/TS/20161108  CASE 257801 Added Location Filter if Intercompany is not enabled.

    TableNo = "NpXml Custom Value Buffer";

    trigger OnRun()
    var
        NpXmlElement: Record "NpXml Element";
        RecRef: RecordRef;
        OutStr: OutStream;
        CustomValue: Text;
        ItemNo: Code[20];
        VariantCode: Code[10];
    begin
        if not NpXmlElement.Get("Xml Template Code","Xml Element Line No.") then
          exit;
        Clear(RecRef);
        RecRef.Open("Table No.");
        RecRef.SetPosition("Record Position");

        if not  RecRef.Find then
          exit;

        SetRecInfo(RecRef,ItemNo,VariantCode);
        RecRef.Close;
        Clear(RecRef);

        CustomValue := Format(CalcMagentoInventory(ItemNo,VariantCode),0,9);

        Value.CreateOutStream(OutStr);
        OutStr.WriteText(CustomValue);
        Modify;
    end;

    var
        Text000: Label 'Magento Intercompany Inventory NpXml Error:\%1';

    local procedure CalcMagentoInventory(ItemNo: Code[20];VariantCode: Code[10]) Inventory: Decimal
    var
        MagentoInventoryCompany: Record "Magento Inventory Company";
        MagentoSetup: Record "Magento Setup";
        MagentoItemMgt: Codeunit "Magento Item Mgt.";
    begin
        if not (MagentoSetup.Get and MagentoSetup."Magento Enabled") then
          exit(0);

        if not MagentoSetup."Intercompany Inventory Enabled" then begin
          //-MAG2.01
          //Inventory := MagentoItemMgt.GetAvailInventory(ItemNo,VariantCode,'');
          Inventory := MagentoItemMgt.GetAvailInventory(ItemNo,VariantCode,MagentoSetup."Inventory Location Filter");
          //+MAG2.01

          exit(Inventory);
        end;

        Inventory := 0;
        if not MagentoInventoryCompany.FindSet then
          exit(0);

        repeat
          Inventory += CalcMagentoInventoryCompany(MagentoInventoryCompany,ItemNo,VariantCode);
        until MagentoInventoryCompany.Next = 0;
    end;

    procedure CalcMagentoInventoryCompany(MagentoInventoryCompany: Record "Magento Inventory Company";ItemNo: Code[20];VariantCode: Code[10]) Inventory: Decimal
    var
        MagentoItemMgt: Codeunit "Magento Item Mgt.";
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
        Response: Text;
        i: Integer;
    begin
        if MagentoInventoryCompany."Company Name" = CompanyName then begin
          Inventory := MagentoItemMgt.GetAvailInventory(ItemNo,VariantCode,MagentoInventoryCompany."Location Filter");
          exit(Inventory);
        end;

        Clear(HttpWebRequest);
        HttpWebRequest := HttpWebRequest.Create(MagentoInventoryCompany."Api Url");
        HttpWebRequest.Timeout := 5 * 1000;
        //-MAG1.22.01
        NpXmlDomMgt.SetTrustedCertificateValidation(HttpWebRequest);
        //+MAG1.22.01

        if MagentoInventoryCompany."Api Username" = '' then
          HttpWebRequest.UseDefaultCredentials(true)
        else begin
          HttpWebRequest.UseDefaultCredentials(false);
          Credential := Credential.NetworkCredential(MagentoInventoryCompany."Api Username",MagentoInventoryCompany."Api Password");
          HttpWebRequest.Credentials(Credential);
        end;

        Clear(XmlDoc);
        XmlDoc := XmlDoc.XmlDocument;
        XmlDoc.LoadXml('<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">' +
                       '  <soapenv:Header />' +
                       '  <soapenv:Body>' +
                       '    <GetItemInventory xmlns="urn:microsoft-dynamics-schemas/codeunit/magento_services">' +
                       '       <itemFilter />' +
                       '       <variantFilter />' +
                       '       <locationFilter />' +
                       '       <items />' +
                       '    </GetItemInventory>' +
                       '  </soapenv:Body>' +
                       '</soapenv:Envelope>');
        HttpWebRequest.Method := 'POST';
        HttpWebRequest.ContentType := 'text/xml; charset=utf-8';
        HttpWebRequest.Headers.Add('SOAPAction','GetItemInventory');
        XmlElement := XmlDoc.DocumentElement.LastChild.LastChild;


        XmlNamespaceManager := XmlNamespaceManager.XmlNamespaceManager(XmlDoc.NameTable);
        XmlNamespaceManager.AddNamespace('ms','urn:microsoft-dynamics-schemas/codeunit/magento_services');

        XmlElement2 := XmlElement.SelectSingleNode('ms:itemFilter',XmlNamespaceManager);
        XmlElement2.InnerText := ItemNo;
        XmlElement2 := XmlElement.SelectSingleNode('ms:variantFilter',XmlNamespaceManager);
        XmlElement2.InnerText := VariantCode;
        XmlElement2 := XmlElement.SelectSingleNode('ms:locationFilter',XmlNamespaceManager);
        XmlElement2.InnerText := MagentoInventoryCompany."Location Filter";
        if not NpXmlDomMgt.SendWebRequest(XmlDoc,HttpWebRequest,HttpWebResponse,WebException) then begin
          WebException := WebException.InnerException();
          Error(Text000,WebException.Message);
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
            if (XmlElement.GetAttribute('item_no') = ItemNo) and (XmlElement.GetAttribute('variant_code') = VariantCode) then begin
              Evaluate(Inventory,XmlElement.InnerText,9);
              exit(Inventory);
            end;
          end;

        exit(0);
    end;

    local procedure SetRecInfo(var RecRef: RecordRef;var ItemNo: Code[20];var VariantCode: Code[10]): Boolean
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
    begin
        case RecRef.Number of
          DATABASE::Item :
            begin
              RecRef.SetTable(Item);
              ItemNo := Item."No.";
              VariantCode := '';
              exit(true);
            end;
          DATABASE::"Item Variant" :
            begin
              RecRef.SetTable(ItemVariant);
              ItemNo := ItemVariant."Item No.";
              VariantCode := ItemVariant.Code;
              exit(true);
            end;
        end;

        exit(false);
    end;
}

