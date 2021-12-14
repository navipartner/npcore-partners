codeunit 6151450 "NPR Magento NpXml Setup Mgt"
{
    var
        NpXmlTemplateMgt: Codeunit "NPR NpXml Template Mgt.";

    procedure SetupExistingTemplate(TemplateCode: Code[20]; NewTemplate: Boolean)
    var
        MagentoSetup: Record "NPR Magento Setup";
        NcSetup: Record "NPR Nc Setup";
        NpXmlTemplate: Record "NPR NpXml Template";
        WebServiceAuthHelper: Codeunit "NPR Web Service Auth. Helper";
    begin
        if (TemplateCode = '') or (not MagentoSetup.Get()) then
            exit;

        if NcSetup.Get() then;

        NpXmlTemplate.Get(TemplateCode);
        NpXmlTemplate."File Transfer" := false;
        NpXmlTemplate."FTP Transfer" := false;
        NpXmlTemplate."API Transfer" := true;
        NpXmlTemplate."API Url" := CopyStr(MagentoSetup."Api Url" + NpXmlTemplate."Xml Root Name", 1, MaxStrLen(NpXmlTemplate."API Url"));
        NpXmlTemplate."API Url" := CopyStr(NpXmlTemplate."API Url".Replace('stock_updates', 'stock'), 1, MaxStrLen(NpXmlTemplate."API Url"));
        NpXmlTemplate.AuthType := MagentoSetup.AuthType;
        NpXmlTemplate."API Username" := MagentoSetup."Api Username";
        WebServiceAuthHelper.SetApiPassword(MagentoSetup.GetApiPassword(), NpXmlTemplate."API Password Key");
        NpXmlTemplate."API Authorization" := MagentoSetup."Api Authorization";
        NpXmlTemplate."OAuth2 Setup Code" := MagentoSetup."OAuth2 Setup Code";
        NpXmlTemplate."API Content-Type" := 'naviconnect/xml';
        NpXmlTemplate."API Accept" := 'naviconnect/xml';
        NpXmlTemplate."API Response Path" := '';
        NpXmlTemplate."API Response Success Value" := '';
        NpXmlTemplate."API Type" := NpXmlTemplate."API Type"::"REST (Xml)";
        NpXmlTemplate."Batch Task" := false;
        NpXmlTemplate."Transaction Task" := MagentoSetup."Magento Enabled";
        NpXmlTemplate."Task Processor Code" := NcSetup."Task Worker Group";
        NpXmlTemplate."Last Modified by" := CopyStr(UserId, 1, MaxStrLen(NpXmlTemplate."Last Modified by"));
        NpXmlTemplate."Last Modified at" := CreateDateTime(Today, Time);
        NpXmlTemplate.Modify();
        if NewTemplate and not NpXmlTemplate.VersionArchived() then begin
            if NpXmlTemplate."Version Description" = '' then begin
                NpXmlTemplate."Version Description" := 'Magento Standard';
                NpXmlTemplate.Modify();
            end;
            NpXmlTemplateMgt.Archive(NpXmlTemplate);
        end;
    end;
}