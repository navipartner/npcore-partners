codeunit 6059895 "NPR UPG NpXml Template"
{
    Access = Internal;
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgTagDef: Codeunit "NPR Upgrade Tag Definitions";
        UpgradeTagMgt: Codeunit "Upgrade Tag";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG NpXml Template', 'OnUpgradePerCompany');

        // Check whether the tag has been used before, and if so, don't run upgrade code
        if UpgradeTagMgt.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG NpXml Template")) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        // Run upgrade code
        Upgrade();

        // Insert the upgrade tag in table 9999 "Upgrade Tags" for future reference
        UpgradeTagMgt.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG NpXml Template"));

        LogMessageStopwatch.LogFinish();
    end;

    local procedure Upgrade()
    begin
        UpgradeFtpProtocolType();
        UpgradeFtpFieldsToNcEndpoint();
    end;

    local procedure UpgradeFtpProtocolType()
    var
        EndpointFtp: Record "NPR Nc Endpoint FTP";
    begin
        if EndpointFtp.FindSet() then
            repeat
                if EndpointFtp.Type = EndpointFtp.Type::DotNet then begin
                    EndpointFtp."Protocol Type" := EndpointFtp."Protocol Type"::FTP;
                    EndpointFtp.Modify();
                end;
                if EndpointFtp.Type = EndpointFtp.Type::SharpSFTP then begin
                    EndpointFtp."Protocol Type" := EndpointFtp."Protocol Type"::SFTP;
                    EndpointFtp.Modify();
                end;
            until EndpointFtp.Next() = 0;
    end;

    local procedure UpgradeFtpFieldsToNcEndpoint()
    var
        NpXmlTemplate: Record "NPR NpXml Template";
        NcEndpoint: Record "NPR Nc Endpoint";
        NcEndpointFtp: Record "NPR Nc Endpoint FTP";
        EndpointCode: Code[20];
        NcEndpointUpgAutoCreatedLbl: Label 'Came from UPG and Xml Template: %1', Comment = 'XML Template Code', MaxLength = 50;
    begin
        NpXmlTemplate.Reset();
        NpXmlTemplate.SetFilter("FTP Server", '<>%1', '');
        if NpXmlTemplate.FindSet() then
            repeat
                NcEndpointFtp.Reset();
                NcEndpointFtp.SetRange(Server, NpXmlTemplate."FTP Server");
                NcEndpointFtp.SetRange(Username, NpXmlTemplate."FTP Username");
                NcEndpointFtp.SetRange(Directory, NpXmlTemplate."FTP Directory");
                NcEndpointFtp.SetRange(Filename, NpXmlTemplate."FTP Filename (Fixed)");
                NcEndpointFtp.SetRange("Protocol Type", NcEndpointFtp."Protocol Type"::FTP);
                if not NcEndpointFtp.FindFirst() then begin
                    EndpointCode := GenerateNcEndpointCode(NpXmlTemplate);
                    if not NcEndpoint.Get(EndpointCode) then begin
                        NcEndpoint.Init();
                        NcEndpoint.Code := EndpointCode;
                        NcEndpoint.Description := CopyStr(StrSubstNo(NcEndpointUpgAutoCreatedLbl, NpXmlTemplate.Code), 1, MaxStrLen(NcEndpointFtp.Description));
                        NcEndpoint."Endpoint Type" := NcEndpointFtp.GetEndpointTypeCode();
                        NcEndpoint.Insert();
                    end;

                    NcEndpointFtp.Init();
                    NcEndpointFtp.Code := EndpointCode;
                    NcEndpointFtp.Description := CopyStr(StrSubstNo(NcEndpointUpgAutoCreatedLbl, NpXmlTemplate.Code), 1, MaxStrLen(NcEndpointFtp.Description));
                    NcEndpointFtp.Directory := NpXmlTemplate."FTP Directory";
                    NcEndpointFtp.Enabled := true;
                    NcEndpointFtp.EncMode := NpXmlTemplate."Ftp EncMode";
                    NcEndpointFtp."File Encoding" := NcEndpointFtp."File Encoding"::UTF8;
                    NcEndpointFtp.Filename := NpXmlTemplate."FTP Filename (Fixed)";
                    NcEndpointFtp."File Temporary Extension" := NpXmlTemplate."FTP Files temporrary extension";
                    NcEndpointFtp.Passive := NpXmlTemplate."FTP Passive";
                    NcEndpointFtp.Password := NpXmlTemplate."FTP Password";
                    NcEndpointFtp.Port := NpXmlTemplate."FTP Port";
                    NcEndpointFtp.Server := NpXmlTemplate."FTP Server";
                    NcEndpointFtp."Protocol Type" := NcEndpointFtp."Protocol Type"::FTP;
                    NcEndpointFtp.Validate(Username, NpXmlTemplate."FTP Username");
                    NcEndpointFtp.Insert();
                end;
                NpXmlTemplate."SFTP/FTP Nc Endpoint" := NcEndpointFtp.Code;
                NpXmlTemplate.Modify();
            until NpXmlTemplate.Next() = 0;
    end;

    local procedure GenerateNcEndpointCode(NpXmlTemplate: Record "NPR NpXml Template") EndpointCode: Code[20]
    var
        NcEndpointFtp: Record "NPR Nc Endpoint FTP";
        Number: Integer;
    begin
        Number := 1;
        EndpointCode := CopyStr(NpXmlTemplate."FTP Server", 1, 17) + '-' + Format(Number);

        if NcEndpointFtp.Get(EndpointCode) then
            repeat
                Number += 1;
                EndpointCode := CopyStr(NpXmlTemplate."FTP Server", 1, 17) + '-' + Format(Number);
            until not (NcEndpointFtp.Get(EndpointCode));
    end;
}
