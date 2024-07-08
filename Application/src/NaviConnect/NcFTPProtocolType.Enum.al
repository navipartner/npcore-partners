enum 6151502 "NPR Nc FTP Protocol Type"
{
#IF NOT BC17
    Access = Internal;       
#ENDIF
    Extensible = true;

    value(0; FTP)
    {
        Caption = 'FTP';
    }
    value(1; SFTP)
    {
        Caption = 'SFTP';
    }
}