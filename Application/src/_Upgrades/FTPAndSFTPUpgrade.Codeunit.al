codeunit 6151065 "NPR FtpSftp Data Upgrade"
{
    Access = Internal;
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgradeTagMgt: Codeunit "Upgrade Tag";
        UpgTagDef: Codeunit "NPR Upgrade Tag Definitions";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), '"NPR FtpSftp Data Upgrade', 'OnUpgradePerCompany');

        if UpgradeTagMgt.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR FtpSftp Data Upgrade")) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;
        UpgradeImportTypes();
        UpgradeNcXmlTemplateAndEndpoints();
        UpgradeRemainingNcFTPEndpoints();

        UpgradeTagMgt.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR FtpSftp Data Upgrade"));
        LogMessageStopwatch.LogFinish();
    end;

    local procedure UpgradeImportTypes()
    var
        ImportTypes: Record "NPR Nc Import Type";
        FTPConn: Record "NPR FTP Connection";
        SFTPConn: Record "NPR SFTP Connection";
        Exists: Boolean;
        pathHelper: Text;
    begin
        ImportTypes.Reset();
        //Get all import types to iterate over.
        if (ImportTypes.FindSet()) then begin
            repeat
                //Check if the Import type has FTP(S)/SFTP
                if (IT_HasFtp(ImportTypes)) then begin
                    //Check if Import Type is SFTP
                    if (IT_IsSftpElseFtp(ImportTypes)) then begin
                        //Codeunit assigned no input as default. Just set default and let empty be error in future.
                        if (ImportTypes."Ftp Port" = 0) then begin
                            ImportTypes."Ftp Port" := 22;
                            ImportTypes.Modify();
                        end;
                        if (ImportTypes."Ftp Host".StartsWith('sftp://')) then begin
                            ImportTypes."Ftp Host" := CopyStr(ImportTypes."Ftp Host".Replace('sftp://', ''), 1, 250);
                            ImportTypes.Modify();
                        end;
                        Exists := False;
                        SFTPConn.Reset();
                        //Iterate over all SFTP Connections to find a match (avoid duplicates.)
                        SFTPConn.SetRange("Server Host", ImportTypes."Ftp Host");
                        SFTPConn.SetRange("Server Port", ImportTypes."Ftp Port");
                        SFTPConn.SetRange(Username, ImportTypes."Ftp User");
                        Exists := SFTPConn.FindFirst();
                        if (Exists) then begin
                            //Exists, only ref existing SFTP Connection
                            if (ImportTypes."SFTP Connection" = '') then begin
                                ///FTP Enabled was previosly the one toggling both enabled.
                                ImportTypes."Sftp Enabled" := ImportTypes."Ftp Enabled";
                                ImportTypes."Ftp Enabled" := False;
                                ImportTypes."SFTP Connection" := SFTPConn.Code;
                                if (not ImportTypes."Ftp Path".StartsWith('/')) then
                                    ImportTypes."Ftp Path" := CopyStr('/' + ImportTypes."Ftp Path", 1, 250);
                                if (not ImportTypes."Ftp Path".EndsWith('/')) then
                                    ImportTypes."Ftp Path" := CopyStr(ImportTypes."Ftp Path" + '/', 1, 250);
                                //This is done becuase one place in code on Import Type, and SFTP download where Backup was specified.
                                //It had Ftp Path + Ftp Backup Path + Filename.
                                //This combines the  two into a new backup field where we ensure absolute path to Dir, with
                                if (ImportTypes."Ftp Backup Path" <> '') then begin
                                    pathHelper := '/' + ImportTypes."Ftp Path" + '/' + ImportTypes."Ftp Backup Path" + '/';
                                    while pathHelper.Contains('//') do begin
                                        pathHelper := pathHelper.Replace('//', '/');
                                    end;
                                    ImportTypes."Ftp Backup Dir Path" := CopyStr(pathHelper, 1, 250);
                                end;
                                ImportTypes.Modify();
                            end;
                        end else begin
                            //Not exist, create new SFTP Connection and ref it.
                            IT_InsertNewSFTP(ImportTypes);
                        end;
                    end else begin
                        //Import Type is FTP
                        //Codeunit assigned no input as default. Just set default and let empty be error in future.
                        if (ImportTypes."Ftp Port" = 0) then begin
                            ImportTypes."Ftp Port" := 21;
                            ImportTypes.Modify();
                        end;
                        if (ImportTypes."Ftp Host".StartsWith('ftp://')) then begin
                            ImportTypes."Ftp Host" := CopyStr(ImportTypes."Ftp Host".Replace('ftp://', ''), 1, 250);
                            ImportTypes.Modify();
                        end;
                        Exists := False;
                        //Iterate over all FTP Connections to find match
                        FTPConn.SetRange("Server Host", ImportTypes."Ftp Host");
                        FTPConn.SetRange("Server Port", ImportTypes."Ftp Port");
                        FTPConn.SetRange(Username, ImportTypes."Ftp User");
                        Exists := FTPConn.FindFirst();
                        if (Exists) then begin
                            //If exists only ref existing conenction
                            if (ImportTypes."FTP Connection" = '') then begin
                                ImportTypes."Ftp Enabled" := ImportTypes."Ftp Enabled";
                                ImportTypes."FTP Connection" := FTPConn.Code;
                                if (not ImportTypes."Ftp Path".StartsWith('/')) then
                                    ImportTypes."Ftp Path" := CopyStr('/' + ImportTypes."Ftp Path", 1, 250);
                                if (not ImportTypes."Ftp Path".EndsWith('/')) then
                                    ImportTypes."Ftp Path" := CopyStr(ImportTypes."Ftp Path" + '/', 1, 250);
                                //This combines the  two into a new backup field where we ensure absolute path to Dir, with
                                if (ImportTypes."Ftp Backup Path" <> '') then begin
                                    pathHelper := '/' + ImportTypes."Ftp Backup Path" + '/';
                                    while pathHelper.Contains('//') do begin
                                        pathHelper := pathHelper.Replace('//', '/');
                                    end;
                                    ImportTypes."Ftp Backup Dir Path" := CopyStr(pathHelper, 1, 250);
                                end;
                                ImportTypes.Modify();
                            end;
                        end else begin
                            //Else create new and make ref to it.
                            IT_InsertNewFTP(ImportTypes);
                        end;
                    end;
                end;

            until (ImportTypes.Next() = 0);
        end;
    end;

    local procedure IT_HasFtp(ImportType: Record "NPR Nc Import Type"): Boolean
    begin
        exit(
            (ImportType."Ftp Host" <> '') and
            (ImportType."Ftp User" <> '') and
            (ImportType."Ftp Password" <> '')
        );
    end;

    local procedure IT_IsSftpElseFtp(ImportType: Record "NPR Nc Import Type"): Boolean
    begin
        //Only indicator for SFTP protocol
        exit(ImportType.Sftp);
    end;


    local procedure IT_InsertNewSFTP(var ImportType: Record "NPR Nc Import Type")
    var
        SftpConn: Record "NPR SFTP Connection";
        Counter: Integer;
        pathHelper: Text;

    begin
        Counter := 0;
        //Ensuring unique codes for similar connections
        while (SftpConn.Get(IT_GenCodeID(ImportType) + Format(Counter))) do begin
            Counter := Counter + 1;
        end;
        SFTPConn.Init();
        SFTPConn.Code := IT_GenCodeID(ImportType) + Format(Counter);
        SFTPConn."Server Host" := ImportType."Ftp Host";
        SFTPConn."Server Port" := ImportType."Ftp Port";
        SFTPConn.Username := ImportType."Ftp User";
        SFTPConn.Password := ImportType."Ftp Password";
        //Default is true in AF.
        SFTPConn."Force Behavior" := True;
        SFTPConn.Insert();
        ImportType."Sftp Enabled" := ImportType."Ftp Enabled";
        ImportType."Ftp Enabled" := False;
        ImportType."SFTP Connection" := IT_GenCodeID(ImportType) + Format(Counter);
        if (not ImportType."Ftp Path".StartsWith('/')) then
            ImportType."Ftp Path" := CopyStr('/' + ImportType."Ftp Path", 1, 250);
        if (not ImportType."Ftp Path".EndsWith('/')) then
            ImportType."Ftp Path" := CopyStr(ImportType."Ftp Path" + '/', 1, 250);
        //This is done becuase one place in code on Import Type, and SFTP download where Backup was specified.
        //It had Ftp Path + Ftp Backup Path + Filename.
        //This combines the  two into a new backup field where we ensure absolute path to Dir, with
        if (ImportType."Ftp Backup Path" <> '') then begin
            pathHelper := '/' + ImportType."Ftp Path" + '/' + ImportType."Ftp Backup Path" + '/';
            while pathHelper.Contains('//') do begin
                pathHelper := pathHelper.Replace('//', '/');
            end;
            ImportType."Ftp Backup Dir Path" := CopyStr(pathHelper, 1, 250);
        end;
        ImportType.Modify();
    end;

    local procedure IT_InsertNewFTP(var ImportType: Record "NPR Nc Import Type")
    var
        FtpConn: Record "NPR FTP Connection";
        Counter: Integer;
        pathHelper: Text;
    begin
        Counter := 0;
        //Ensuring unique codes for similar connections
        while (FtpConn.Get(IT_GenCodeID(ImportType) + Format(Counter))) do begin
            Counter := Counter + 1;
        end;
        FTPConn.Init();
        FTPConn.Code := IT_GenCodeID(ImportType) + Format(Counter);
        FTPConn."Server Host" := ImportType."Ftp Host";
        FTPConn."Server Port" := ImportType."Ftp Port";
        FTPConn.Username := ImportType."Ftp User";
        FTPConn.Password := ImportType."Ftp Password";
        FTPConn."FTP Passive Transfer Mode" := ImportType."Ftp Passive";
        FTPConn."FTP Enc. Mode" := ImportType."Ftp EncMode";
        //Default is false in AF.
        FTPConn."Force Behavior" := False;
        FTPConn.Insert();
        ImportType."Ftp Enabled" := ImportType."Ftp Enabled";
        ImportType."FTP Connection" := IT_GenCodeID(ImportType) + Format(Counter);
        if (not ImportType."Ftp Path".StartsWith('/')) then
            ImportType."Ftp Path" := CopyStr('/' + ImportType."Ftp Path", 1, 250);
        if (not ImportType."Ftp Path".EndsWith('/')) then
            ImportType."Ftp Path" := CopyStr(ImportType."Ftp Path" + '/', 1, 250);
        //This combines the  two into a new backup field where we ensure absolute path to Dir, with
        if (ImportType."Ftp Backup Path" <> '') then begin
            pathHelper := '/' + ImportType."Ftp Backup Path" + '/';
            while pathHelper.Contains('//') do begin
                pathHelper := pathHelper.Replace('//', '/');
            end;
            ImportType."Ftp Backup Dir Path" := CopyStr(pathHelper, 1, 250);
        end;
        ImportType.Modify();
    end;

    local procedure IT_GenCodeID(ImportType: Record "NPR Nc Import Type"): Text[20];
    begin
        exit(CopyStr(ImportType."Ftp User", 1, 8) + '-' + CopyStr(ImportType."Ftp Host", 1, 8));
    end;


    local procedure UpgradeNcXmlTemplateAndEndpoints()
    var
        Endpoint: Record "NPR Nc Endpoint FTP";
        XmlTemplates: Record "NPR NpXml Template";
        FTPConn: Record "NPR FTP Connection";
        SFTPConn: Record "NPR SFTP Connection";
        Exists: Boolean;
        pathHelper: Text;
    begin
        XmlTemplates.Reset();
        //Iterate over all Xml Templates
        if (XmlTemplates.FindSet()) then begin
            repeat
                //Determine if it has FTP(S)/SFTP 
                if (NCE_HasFtp(XmlTemplates)) then begin
                    Endpoint.Get(XmlTemplates."SFTP/FTP Nc Endpoint");
                    //Check if it is SFTP
                    if (NCE_IsSftpElseFtp(XmlTemplates)) then begin
                        //Remove empty input and making default
                        if (Endpoint.Port = 0) then begin
                            Endpoint.Port := 22;
                            Endpoint.Modify();
                        end;
                        Exists := False;
                        SFTPConn.SetRange("Server Host", Endpoint.Server);
                        SFTPConn.SetRange("Server Port", Endpoint.Port);
                        SFTPConn.SetRange(Username, Endpoint.Username);
                        Exists := SFTPConn.FindFirst();
                        if (Exists) then begin
                            //Insert ref, and move file info to xml tempalte.
                            XmlTemplates."SFTP Enabled" := Endpoint.Enabled;
                            XmlTemplates."SFTP Connection" := SFTPConn.Code;
                            if (Endpoint.Directory <> '') then begin
                                pathHelper := Endpoint.Directory.Replace('\', '/');
                                if (not pathHelper.StartsWith('/')) then
                                    pathHelper := '/' + pathHelper;
                                if (not pathHelper.EndsWith('/')) then
                                    pathHelper := pathHelper + '/';
                            end else begin
                                pathHelper := '/';
                            end;
                            XmlTemplates."FTP/SFTP Dir Path" := CopyStr(pathHelper, 1, 250);
                            XmlTemplates."FTP/SFTP Filename" := Endpoint.Filename;
                            XmlTemplates."Server File Encoding" := Endpoint."File Encoding";
                            XmlTemplates.Modify();

                        end else begin
                            //Create new connection
                            NCE_InsertNewSFTP(XmlTemplates);
                        end;
                    end else begin
                        //Else it is FTP(S)
                        //Replace  empty with default protocol value
                        if (Endpoint.Port = 0) then begin
                            Endpoint.Port := 21;
                            Endpoint.Modify();
                        end;
                        Exists := False;
                        FTPConn.SetRange("Server Host", Endpoint.Server);
                        FTPConn.SetRange("Server Port", Endpoint.Port);
                        FTPConn.SetRange(Username, Endpoint.Username);
                        Exists := FTPConn.FindFirst();
                        if (Exists) then begin
                            // If exist make ref to existing
                            XmlTemplates."Ftp Enabled" := Endpoint.Enabled;
                            XmlTemplates."FTP Connection" := FTPConn.Code;
                            if (Endpoint.Directory <> '') then begin
                                pathHelper := Endpoint.Directory.Replace('\', '/');
                                if (not pathHelper.StartsWith('/')) then
                                    pathHelper := '/' + pathHelper;
                                if (not pathHelper.EndsWith('/')) then
                                    pathHelper := pathHelper + '/';
                            end else begin
                                pathHelper := '/';
                            end;
                            XmlTemplates."FTP/SFTP Dir Path" := CopyStr(pathHelper, 1, 250);
                            XmlTemplates."FTP/SFTP Filename" := Endpoint.Filename;
                            XmlTemplates."Server File Encoding" := Endpoint."File Encoding";
                            XmlTemplates.Modify();

                        end else begin
                            // Else create new FTP Conenction and ref it.
                            NCE_InsertNewFTP(XmlTemplates);
                        end;
                    end;
                end;
            until (XmlTemplates.Next() = 0);
        end;
    end;

    local procedure NCE_HasFtp(XmlTemplates: Record "NPR NpXml Template"): Boolean
    var
        nce: Record "NPR Nc Endpoint FTP";
    begin
        if (XmlTemplates."SFTP/FTP Nc Endpoint" = '') then exit(false);
        if (not nce.Get(XmlTemplates."SFTP/FTP Nc Endpoint")) then exit(false);
        exit(
            (nce."Server" <> '') and
            (nce."Username" <> '') and
            (nce."Password" <> '')
        );
    end;

    local procedure NCE_IsSftpElseFtp(XmlTemplates: Record "NPR NpXml Template"): Boolean
    var
        nce: Record "NPR Nc Endpoint FTP";
    begin
        nce.Get(XmlTemplates."SFTP/FTP Nc Endpoint");
        exit(nce."Protocol Type" = nce."Protocol Type"::SFTP);
    end;

    local procedure NCE_InsertNewSFTP(var XmlTemplates: Record "NPR NpXml Template")
    var
        SftpConn: Record "NPR SFTP Connection";
        Counter: Integer;
        nce: Record "NPR Nc Endpoint FTP";
        pathHelper: Text;
    begin

        nce.Get(XmlTemplates."SFTP/FTP Nc Endpoint");
        Counter := 0;
        //Ensure unique code
        while (SftpConn.Get(NCE_GenCodeID(XmlTemplates) + Format(Counter))) do begin
            Counter := Counter + 1;
        end;
        SFTPConn.Init();
        SFTPConn.Code := NCE_GenCodeID(XmlTemplates) + Format(Counter);
        SFTPConn.Description := nce.Description;
        SFTPConn."Server Host" := nce.Server;
        SFTPConn."Server Port" := nce.Port;
        SFTPConn.Username := nce.Username;
        SFTPConn.Password := nce.Password;
        //Default is true in AF
        SFTPConn."Force Behavior" := True;
        SFTPConn.Insert();
        XmlTemplates."SFTP Enabled" := nce.Enabled;
        XmlTemplates."SFTP Connection" := NCE_GenCodeID(XmlTemplates) + Format(Counter);
        if (nce.Directory <> '') then begin
            pathHelper := nce.Directory.Replace('\', '/');
            if (not pathHelper.StartsWith('/')) then
                pathHelper := '/' + pathHelper;
            if (not pathHelper.EndsWith('/')) then
                pathHelper := pathHelper + '/';
        end else begin
            pathHelper := '/';
        end;
        XmlTemplates."FTP/SFTP Dir Path" := CopyStr(pathHelper, 1, 250);
        XmlTemplates."FTP/SFTP Filename" := nce.Filename;
        XmlTemplates."Server File Encoding" := nce."File Encoding";
        XmlTemplates.Modify();
    end;

    local procedure NCE_InsertNewFTP(var XmlTemplates: Record "NPR NpXml Template")
    var
        FtpConn: Record "NPR FTP Connection";
        Counter: Integer;
        nce: Record "NPR Nc Endpoint FTP";
        pathHelper: Text;
    begin
        nce.Get(XmlTemplates."SFTP/FTP Nc Endpoint");
        Counter := 0;
        //Ensure unique code
        while (FtpConn.Get(NCE_GenCodeID(XmlTemplates) + Format(Counter))) do begin
            Counter := Counter + 1;
        end;
        FTPConn.Init();
        FTPConn.Code := NCE_GenCodeID(XmlTemplates) + Format(Counter);
        FTPConn.Description := nce.Description;
        FTPConn."Server Host" := nce.Server;
        FTPConn."Server Port" := nce.Port;
        FTPConn.Username := nce.Username;
        FTPConn.Password := nce.Password;
        FTPConn."FTP Passive Transfer Mode" := nce.Passive;
        FTPConn."FTP Enc. Mode" := nce.EncMode;
        //Default is false in AF
        FTPConn."Force Behavior" := False;
        FTPConn.Insert();
        XmlTemplates."Ftp Enabled" := nce.Enabled;
        XmlTemplates."FTP Connection" := NCE_GenCodeID(XmlTemplates) + Format(Counter);
        if (nce.Directory <> '') then begin
            pathHelper := nce.Directory.Replace('\', '/');
            if (not pathHelper.StartsWith('/')) then
                pathHelper := '/' + pathHelper;
            if (not pathHelper.EndsWith('/')) then
                pathHelper := pathHelper + '/';
        end else begin
            pathHelper := '/';
        end;
        XmlTemplates."FTP/SFTP Dir Path" := CopyStr(pathHelper, 1, 250);
        XmlTemplates."FTP/SFTP Filename" := nce.Filename;
        XmlTemplates."Server File Encoding" := nce."File Encoding";
        XmlTemplates.Modify();
    end;

    local procedure NCE_GenCodeID(XmlTemplates: Record "NPR NpXml Template"): Text[20];
    var
        nce: Record "NPR Nc Endpoint FTP";
    begin
        nce.Get(XmlTemplates."SFTP/FTP Nc Endpoint");
        exit(CopyStr(nce.Username, 1, 8) + '-' + CopyStr(nce.Server, 1, 8));
    end;

    local procedure UpgradeRemainingNcFTPEndpoints()
    var
        Endpoint: Record "NPR Nc Endpoint FTP";
        FTPConn: Record "NPR FTP Connection";
        SFTPConn: Record "NPR SFTP Connection";
        Exists: Boolean;
    begin
        Endpoint.Reset();
        //Iterate over all Xml Templates
        if (Endpoint.FindSet()) then begin
            repeat
                //Check if it is SFTP
                if (Endpoint."Protocol Type" = Endpoint."Protocol Type"::SFTP) then begin
                    //Remove empty input and making default
                    if (Endpoint.Port = 0) then begin
                        Endpoint.Port := 22;
                        Endpoint.Modify();
                    end;
                    Exists := False;
                    //Iterate over SFTP Connections to find match
                    SFTPConn.SetRange("Server Host", Endpoint.Server);
                    SFTPConn.SetRange("Server Port", Endpoint.Port);
                    SFTPConn.SetRange(Username, Endpoint.Username);
                    Exists := SFTPConn.FindFirst();
                    if (not Exists) then
                        NCEFTP_InsertNewSFTP(Endpoint);

                end else begin
                    //Else it is FTP(S)
                    //Replace  empty with default protocol value
                    if (Endpoint.Port = 0) then begin
                        Endpoint.Port := 21;
                        Endpoint.Modify();
                    end;
                    Exists := False;
                    FTPConn.SetRange("Server Host", Endpoint.Server);
                    FTPConn.SetRange("Server Port", Endpoint.Port);
                    FTPConn.SetRange(Username, Endpoint.Username);
                    Exists := FTPConn.FindFirst();
                    if (not Exists) then
                        NCEFTP_InsertNewFTP(Endpoint);
                end;
            until (Endpoint.Next() = 0);
        end;
    end;

    local procedure NCEFTP_InsertNewSFTP(nce: Record "NPR Nc Endpoint FTP")
    var
        SftpConn: Record "NPR SFTP Connection";
        Counter: Integer;
    begin
        Counter := 0;
        //Ensure unique code
        while (SftpConn.Get(NCEFTP_GenCodeID(nce) + Format(Counter))) do begin
            Counter := Counter + 1;
        end;
        SftpConn.Init();
        SftpConn.Code := NCEFTP_GenCodeID(nce) + Format(Counter);
        SftpConn.Description := nce.Description;
        SftpConn."Server Host" := nce.Server;
        SftpConn."Server Port" := nce.Port;
        SftpConn.Username := nce.Username;
        SftpConn.Password := nce.Password;
        SftpConn."Force Behavior" := True;
        SftpConn.Insert();
    end;

    local procedure NCEFTP_InsertNewFTP(nce: Record "NPR Nc Endpoint FTP")
    var
        FtpConn: Record "NPR FTP Connection";
        Counter: Integer;
    begin
        Counter := 0;
        //Ensure unique code
        while (FtpConn.Get(NCEFTP_GenCodeID(nce) + Format(Counter))) do begin
            Counter := Counter + 1;
        end;
        FTPConn.Init();
        FTPConn.Code := NCEFTP_GenCodeID(nce) + Format(Counter);
        FTPConn.Description := nce.Description;
        FTPConn."Server Host" := nce.Server;
        FTPConn."Server Port" := nce.Port;
        FTPConn.Username := nce.Username;
        FTPConn.Password := nce.Password;
        FTPConn."FTP Passive Transfer Mode" := nce.Passive;
        FTPConn."FTP Enc. Mode" := nce.EncMode;
        FTPConn."Force Behavior" := True;
        FTPConn.Insert();
    end;

    local procedure NCEFTP_GenCodeID(nce: Record "NPR Nc Endpoint FTP"): Text[20]
    begin
        exit(CopyStr(nce.Username, 1, 8) + '-' + CopyStr(nce.Server, 1, 8));
    end;
}