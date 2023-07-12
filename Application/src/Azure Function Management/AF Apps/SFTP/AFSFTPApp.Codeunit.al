codeunit 6151072 "NPR SFTP App" implements "NPR IAF App"
{
    Access = Internal;

    procedure FunctionAppName(): Text;
    begin
        exit('SftpProxy');
    end;

    procedure FunctionActionNames(var fActions: List of [Text])
    begin
        fActions.AddRange(
            'DownloadFile',
            'UploadFile',
            'DeleteFile',
            'MoveFile',
            'CreateDirectory',
            'DeleteDirectory',
            'ListDirectory'
        );
    end;

    procedure FunctionAppVersion(): Integer;
    begin
        exit(1);
    end;

    procedure AzureVaultKeyNameForSubscription(): Text
    begin
        exit('AFSftpProxySub');
    end;
}