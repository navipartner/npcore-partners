enum 6014562 "NPR DE Export Exception"
{
#IF NOT BC17
    Access = Internal;
#ENDIF
    Caption = 'DE Export Exception';
    Extensible = true;

    value(0; " ")
    {
        Caption = ' ', Locked = true;
    }
    value(1; E_UNEXPECTED)
    {
        Caption = 'Unexpected Error';
    }
    value(2; E_ID_NOT_FOUND)
    {
        Caption = 'ID Not Found';
    }
    value(3; E_BAD_REQUEST)
    {
        Caption = 'Bad Request';
    }
    value(4; E_INTERNAL)
    {
        Caption = 'Internal Error';
    }
    value(5; E_TRANSACTION_ID_NOT_FOUND)
    {
        Caption = 'Transaction ID Not Found';
    }
    value(6; E_NO_DATA_AVAILABLE)
    {
        Caption = 'No Data Available';
    }
    value(7; E_TOO_MANY_RECORDS)
    {
        Caption = 'Too Many Records';
    }
    value(8; E_ALREADY_PROCESSING)
    {
        Caption = 'Already Processing';
    }
    value(9; E_LOGS_NOT_DELETED)
    {
        Caption = 'Logs Not Deleted';
    }
    value(10; E_EXPORT_PROCESSING_TIMEOUT)
    {
        Caption = 'Export Processing Timeout';
    }
}