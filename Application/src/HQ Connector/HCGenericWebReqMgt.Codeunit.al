codeunit 6150911 "NPR HC Generic Web Req. Mgt."
{
    var
        ResponseStringTooLong: Label 'Response string too long.';

    [TryFunction]
    procedure TryProcessRequest(var TmpHCGenericWebRequest: Record "NPR HC Generic Web Request")
    var
        IsProcessed: Boolean;
    begin
        OnBeforeProcessRequest(TmpHCGenericWebRequest, IsProcessed);
        TmpHCGenericWebRequest.TestField("Request Code");
        if not IsProcessed then
            ProcessRequest(TmpHCGenericWebRequest, IsProcessed);
        TmpHCGenericWebRequest."Response Date" := CurrentDateTime;
        TmpHCGenericWebRequest."Response User ID" := CopyStr(UserId,1,50);
        TmpHCGenericWebRequest.Modify();
    end;

    local procedure ProcessRequest(var HCGenericWebRequest: Record "NPR HC Generic Web Request"; var IsProcessed: Boolean)
    var
        ParameterArray: array[6] of Text;
        ResponseArray: array[4] of Text;
    begin
        ParameterArray[1] := HCGenericWebRequest."Parameter 1";
        ParameterArray[2] := HCGenericWebRequest."Parameter 2";
        ParameterArray[3] := HCGenericWebRequest."Parameter 3";
        ParameterArray[4] := HCGenericWebRequest."Parameter 4";
        ParameterArray[5] := HCGenericWebRequest."Parameter 5";
        ParameterArray[6] := HCGenericWebRequest."Parameter 6";
        OnProcessRequest(
          HCGenericWebRequest."Request Code",
          ParameterArray,
          ResponseArray,
          IsProcessed,
          HCGenericWebRequest."Error Text");


        if HCGenericWebRequest."Error Text" <> '' then
            Error(HCGenericWebRequest."Error Text");

        if (StrLen(ResponseArray[1]) > MaxStrLen(HCGenericWebRequest."Response 1")) or
          (StrLen(ResponseArray[2]) > MaxStrLen(HCGenericWebRequest."Response 2")) or
          (StrLen(ResponseArray[3]) > MaxStrLen(HCGenericWebRequest."Response 3")) or
          (StrLen(ResponseArray[4]) > MaxStrLen(HCGenericWebRequest."Response 4")) then
            Error(ResponseStringTooLong);

        HCGenericWebRequest."Response 1" := ResponseArray[1];
        HCGenericWebRequest."Response 2" := ResponseArray[2];
        HCGenericWebRequest."Response 3" := ResponseArray[3];
        HCGenericWebRequest."Response 4" := ResponseArray[4];
        HCGenericWebRequest.Modify();
    end;

    [IntegrationEvent(FALSE, FALSE)]
    local procedure OnBeforeProcessRequest(var HCGenericWebRequest: Record "NPR HC Generic Web Request"; var IsProcessed: Boolean)
    begin
    end;

    [IntegrationEvent(FALSE, FALSE)]
    local procedure OnProcessRequest(RequestCode: Code[20]; Parameter: array[6] of Text; var Response: array[4] of Text; var IsProcessed: Boolean; var ErrorDescription: Text)
    begin
    end;
}

