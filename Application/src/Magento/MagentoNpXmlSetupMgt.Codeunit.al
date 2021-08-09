codeunit 6151450 "NPR Magento NpXml Setup Mgt"
{
    var
        NpXmlTemplateMgt: Codeunit "NPR NpXml Template Mgt.";

    procedure SetupExistingTemplate(TemplateCode: Code[20]; NewTemplate: Boolean)
    var
        MagentoSetup: Record "NPR Magento Setup";
        NcSetup: Record "NPR Nc Setup";
        NpXmlTemplate: Record "NPR NpXml Template";
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
        case MagentoSetup."Api Username Type" of
            MagentoSetup."Api Username Type"::Automatic:
                NpXmlTemplate."API Username Type" := NpXmlTemplate."API Username Type"::Automatic;
            MagentoSetup."Api Username Type"::Custom:
                NpXmlTemplate."API Username Type" := NpXmlTemplate."API Username Type"::Custom;
        end;
        NpXmlTemplate."API Username" := MagentoSetup."Api Username";
        NpXmlTemplate."API Password" := CopyStr(MagentoSetup.GetApiPassword(), 1, MaxStrLen(NpXmlTemplate."API Password"));
        NpXmlTemplate."API Authorization" := MagentoSetup."Api Authorization";
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