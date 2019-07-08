codeunit 6151402 "Magento Mgt."
{
    // MAG1.01/MHA /20150115  CASE 199932 Object Created - Connects Magento with NaviConnect and NpXml
    //                                    - NaviConnect References/Functions may be removed if [NC] is not installed
    //                                    - NpXml References/Functions may be removed if [NX] is not installed
    // MAG1.04/MHA /20150209  CASE 199932 Added Element Comment functionality and new Xml Templates and reworked Task Queue Setup
    // MAG1.05/MHA /20150220  CASE 206395 Changed prefix of NpXml Template Codes FROM DELETE/UPDATE to DEL/UPD
    //                                    Added functions:
    //                                    - SetupMagentoCustomerGroups()
    //                                    - SetupMagentoTaxClasses()
    //                                    Renamed function RunItemCard to RunSourceCard
    // MAG1.06/MHA /20150224  CASE 199932 Updated is_default when importing Websites
    //                                    Updated Task Queue Setup
    //                                    Created function SetupWebServices
    // MAG1.07/MHA /20150309  CASE 208253 Removed NaviConnectTask.CALCFIELDS("Table Name") as "Table Name" is not a flowfield
    // MAG1.09/MHA /20150313  CASE 208758 Added function GetBasicAuthInfo(), SetupNpXmlCredentials() and SetupMagentoCredentials()
    // MAG1.10/MHA /20150320  CASE 209616 Updated Magento Integration Setup
    // MAG1.11/MHA /20150325  CASE 209616 Updated Task Queue Setup
    // MAG1.12/MHA /20150410  CASE 210797 Reduced obsolete Tasks in Task Queue Init function
    // MAG1.13/MHA /20150401  CASE 210548 Changed Primary Key of Magento Store from Field1,Field5 to Field5
    // MAG1.13/MHA /20150414  CASE 211360 Restructured NpXml Codeunits. Independent functions moved to new codeunits
    // MAG1.14/MHA /20150415  CASE 211360 Added function InitFullSync functions
    // MAG1.14/MHA /20150422  CASE 211774 Added has_size_value and has_color_value to the standard product xml template
    // MAG1.16/TR  /20150424  CASE 210960 SetupNpXmlTemplates now also considders Variety - variation.
    // MAG1.16/TS  /20150428  CASE 212103 Added default Import Codeunits to InitSetup
    // MAG1.17/MHA /20150619  CASE 216851 Renamed codeunit and moved NaviConnect and NpXml modules to seperat setup table and codeunit
    // MAG1.22/MHA /20160427  CASE 240212 Deleted deprecated init functions - all but InitItemSync() where filter on Item."Internet Item" has been added
    // MAG2.00/MHA /20160525  CASE 242557 Magento Integration
    // MAG2.03/MHA /20170324  CASE 266871 Added function GetCustomerConfigTemplate()
    // MAG2.03/MHA /20170411  CASE 272066 Exception handling added to MagentoApiPost()
    // MAG2.05/MHA /20170714  CASE 283777 Moved Picture functionality to cu 6151419 and added "Api Authorization" in MagentoApiGet() and MagentoApiPost()
    // MAG2.18/MHA /20190314  CASE 348660 Increased return value of GetVATBusPostingGroup() from 10 to 20 as standard field is increased from NAV2018


    trigger OnRun()
    begin
    end;

    var
        MagentoSetup: Record "Magento Setup";
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        Text000: Label 'Magento returned the following Error:\\';

    procedure "--- Webservice Import"()
    begin
    end;

    procedure GetCustomerConfigTemplate(TaxClass: Text) ConfigTemplateCode: Code[10]
    var
        MagentoSetup: Record "Magento Setup";
        MagentoTaxClass: Record "Magento Tax Class";
    begin
        //-MAG2.03 [266871]
        if not MagentoSetup.Get then
          exit('');

        ConfigTemplateCode := MagentoSetup."Customer Config. Template Code";
        if MagentoTaxClass.Get(TaxClass,MagentoTaxClass.Type::Customer) and (MagentoTaxClass."Customer Config. Template Code" <> '') then
          ConfigTemplateCode := MagentoTaxClass."Customer Config. Template Code";

        exit(ConfigTemplateCode);
        //+MAG2.03 [266871]
    end;

    procedure GetVATBusPostingGroup(TaxClass: Text): Code[20]
    var
        MagentoVatBusGroup: Record "Magento VAT Business Group";
        VATBusPostingGroup: Record "VAT Business Posting Group";
    begin
        if TaxClass = '' then
          exit('');

        MagentoVatBusGroup.SetRange("Magento Tax Class",CopyStr(TaxClass,1,MaxStrLen(MagentoVatBusGroup."Magento Tax Class")));
        MagentoVatBusGroup.FindFirst;
        MagentoVatBusGroup.TestField("VAT Business Posting Group");
        VATBusPostingGroup.Get(MagentoVatBusGroup."VAT Business Posting Group");
        exit(VATBusPostingGroup.Code);
    end;

    procedure "--- Magento Api"()
    begin
    end;

    procedure MagentoApiGet(MagentoApiUrl: Text;Method: Text;var XmlDoc: DotNet XmlDocument) Result: Boolean
    var
        HttpWebRequest: DotNet HttpWebRequest;
        HttpWebResponse: DotNet HttpWebResponse;
        MemoryStream: DotNet MemoryStream;
    begin
        if MagentoApiUrl = '' then
          exit(false);

        if not IsNull(HttpWebRequest) then
          Clear(HttpWebRequest);
        HttpWebRequest := HttpWebRequest.Create(MagentoApiUrl + Method);
        HttpWebRequest.Timeout := 1000 * 60 * 5;

        HttpWebRequest.Method := 'GET';
        HttpWebRequest.ContentType := 'navision/xml';
        HttpWebRequest.Accept('navision/xml');

        MagentoSetup.Get;
        HttpWebRequest.Headers.Add('Authorization','Basic ' + MagentoSetup.GetBasicAuthInfo());
        //-MAG2.05 [283777]
        if MagentoSetup."Api Authorization" <> '' then begin
          HttpWebRequest.ContentType := 'naviconnect/xml';
          HttpWebRequest.Accept('application/xml');
          HttpWebRequest.Headers.Add('Authorization',MagentoSetup."Api Authorization");
        end;
        //+MAG2.05 [283777]

        HttpWebResponse := HttpWebRequest.GetResponse();
        MemoryStream := HttpWebResponse.GetResponseStream;

        XmlDoc := XmlDoc.XmlDocument;
        XmlDoc.Load(MemoryStream);

        MemoryStream.Flush;
        MemoryStream.Close;
        Clear(MemoryStream);

        NpXmlDomMgt.RemoveNameSpaces(XmlDoc);
        exit(true);
    end;

    procedure MagentoApiPost(MagentoApiUrl: Text;Method: Text;var XmlDoc: DotNet XmlDocument) Result: Boolean
    var
        HttpWebRequest: DotNet HttpWebRequest;
        HttpWebResponse: DotNet HttpWebResponse;
        WebException: DotNet WebException;
        ErrorMessage: Text;
    begin
        if MagentoApiUrl = '' then
          exit(false);

        if not IsNull(HttpWebRequest) then
          Clear(HttpWebRequest);
        HttpWebRequest := HttpWebRequest.Create(MagentoApiUrl + Method);
        HttpWebRequest.Timeout := 1000 * 60 * 5;

        HttpWebRequest.Method := 'POST';
        HttpWebRequest.ContentType := 'navision/xml';
        HttpWebRequest.Accept('navision/xml');

        MagentoSetup.Get;
        HttpWebRequest.Headers.Add('Authorization','Basic ' + MagentoSetup.GetBasicAuthInfo());
        //-MAG2.05 [283777]
        if MagentoSetup."Api Authorization" <> '' then begin
          HttpWebRequest.ContentType := 'naviconnect/xml';
          HttpWebRequest.Accept('application/xml');
          HttpWebRequest.Headers.Add('Authorization',MagentoSetup."Api Authorization");
        end;
        //+MAG2.05 [283777]

        //-MAG2.03 [272066]
        // MemoryStream := HttpWebRequest.GetRequestStream;
        // XmlDoc.Save(MemoryStream);
        // MemoryStream.Flush;
        // MemoryStream.Close;
        // CLEAR(MemoryStream);
        //
        // HttpWebResponse := HttpWebRequest.GetResponse();
        // MemoryStream := HttpWebResponse.GetResponseStream;
        //
        // XmlDoc := XmlDoc.XmlDocument;
        // XmlDoc.Load(MemoryStream);
        //
        // MemoryStream.Flush;
        // MemoryStream.Close;
        // CLEAR(MemoryStream);
        if not NpXmlDomMgt.SendWebRequest(XmlDoc,HttpWebRequest,HttpWebResponse,WebException) then begin
          ErrorMessage := NpXmlDomMgt.GetWebResponseText(HttpWebResponse);
          if ErrorMessage = '' then
            ErrorMessage := NpXmlDomMgt.GetWebExceptionInnerMessage(WebException);
          if ErrorMessage = '' then
            ErrorMessage := NpXmlDomMgt.GetWebExceptionMessage(WebException);
          ErrorMessage := Text000 + ErrorMessage;
          Error(CopyStr(ErrorMessage,1,1000));
        end;
        //+MAG2.03 [272066]
        NpXmlDomMgt.RemoveNameSpaces(XmlDoc);
        exit(true);
    end;

    procedure "--- Sync"()
    begin
    end;

    procedure InitItemSync()
    var
        Item: Record Item;
        RecRef: RecordRef;
        DataLogMgt: Codeunit "Data Log Management";
    begin
        Item.SetRange("Magento Item",true);
        if not Item.FindSet then
          exit;

        repeat
          RecRef.GetTable(Item);
          DataLogMgt.OnDatabaseInsert(RecRef);
        until Item.Next = 0;
    end;
}

