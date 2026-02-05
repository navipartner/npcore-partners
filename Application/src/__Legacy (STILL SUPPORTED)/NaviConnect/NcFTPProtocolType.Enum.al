enum 6151502 "NPR Nc FTP Protocol Type"
{
    ObsoleteState = Pending;
    ObsoleteTag = '2026-01-29';
    ObsoleteReason = 'This module is no longer being maintained';
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