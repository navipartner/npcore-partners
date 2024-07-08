codeunit 6014698 "NPR Page Background Task Mgt."
{
    Access = Internal;
    procedure FailedTaskError(CalledFromPageCaption: Text; ErrorCode: Text; ErrorText: Text)
    var
        BackgroundTaskErrorLbl: Label 'Page %1: background task ended with an error.\Error code: %2.\Error: %3', Comment = '%1 = called from page caption, %2 = error code, %3 = error text';
    begin
        Error(BackgroundTaskErrorLbl, CalledFromPageCaption, ErrorCode, ErrorText);
    end;

    procedure CopyTaskResults(FromResults: Dictionary of [Text, Text]; var ToResults: Dictionary of [Text, Text])
    var
        ResultKeyList: List of [Text];
        ResultKey: Text;
    begin
        Clear(ToResults);
        ResultKeyList := FromResults.Keys();
        foreach ResultKey in ResultKeyList do
            ToResults.Add(ResultKey, FromResults.Get(ResultKey));
    end;
}
