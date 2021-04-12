codeunit 6184550 "NPR TDC Phone Lookup"
{
    TableNo = "NPR Phone Lookup Buffer";

    trigger OnRun()
    begin
        DoLookupPhone(Rec);
    end;

    procedure DoLookupPhone(var PhoneLookupBuf: Record "NPR Phone Lookup Buffer" temporary)
    var
        IComm: Record "NPR I-Comm";
        Result: Text;
        HttpWebRequest: HttpRequestMessage;
        HttpWebResponse: HttpResponseMessage;
        Content: HttpContent;
        Client: HttpClient;
        Headers: HttpHeaders;
    begin
        if not IComm.Get() then
            exit;

        Clear(HttpWebRequest);
        Content.GetHeaders(Headers);
        Headers.Clear();
        Headers.Add('Content-Type', 'text/xml; charset="iso-8859-9"');
        HttpWebRequest.SetRequestUri(IComm."Tunnel URL Address" + '?PHONE=' + PhoneLookupBuf."Phone No.");
        HttpWebRequest.Method := 'GET';
        Client.Send(HttpWebRequest, HttpWebResponse);
        HttpWebResponse.Content.ReadAs(Result);
        LoadToBuffer(Result, PhoneLookupBuf);
    end;

    local procedure LoadToBuffer(var Stringtxt: Text; var TMPPhoneLookupBuf: Record "NPR Phone Lookup Buffer")
    var
        Seperator: Char;
        StringArray: array[22] of Text;
        ResponseString: Text;
        Tab: Char;
        i: Integer;
        Pos: Integer;
        IndexOf: Integer;
        NewString: Text;
    begin
        Tab := 9;
        ResponseString := Stringtxt;

        if ResponseString.Contains('RESULTS') then begin
            i := 0;
            while (ResponseString.Contains('RESULTS') and (StrLen(ResponseString) <> 0)) do begin
                i := i + 1;
                IndexOf := ResponseString.IndexOf('RESULTS');
                if IndexOf <> 0 then begin
                    ResponseString := ResponseString.Remove(1, IndexOf + 11);
                    if not (StrLen(ResponseString) <= 0) then
                        IndexOf := ResponseString.IndexOf('RESULTS');

                    if IndexOf > 0 then
                        NewString := ResponseString.Substring(1, IndexOf - 1)
                    else
                        NewString := ResponseString;

                    Seperator := Tab;

                    Pos := StrPos(ResponseString, Seperator);
                    if Pos > 0 then begin
                        for i := 1 to 22 do begin

                            StringArray[i] := CopyStr(ResponseString, 1, Pos - 1);
                            ResponseString := CopyStr(ResponseString, Pos + 1, MaxStrLen(ResponseString));
                            i += 1;
                        end;

                        TMPPhoneLookupBuf.Init();
                        TMPPhoneLookupBuf.ID := DelPreSpaces(Format(StringArray[1]));
                        TMPPhoneLookupBuf.Title := DelPreSpaces(Format(StringArray[2]));
                        TMPPhoneLookupBuf.Name := DelPreSpaces(Format(StringArray[3]));
                        TMPPhoneLookupBuf.Name += ' ' + DelPreSpaces(Format(StringArray[4]));
                        TMPPhoneLookupBuf."First Name" := CopyStr(DelPreSpaces(DelPreSpaces(Format(StringArray[3]))), 1, 50);
                        TMPPhoneLookupBuf."Last Name" := CopyStr(DelPreSpaces(DelPreSpaces(Format(StringArray[4]))), 1, 50);
                        TMPPhoneLookupBuf."Post Code" := DelPreSpaces(Format(StringArray[6]));
                        TMPPhoneLookupBuf.City := DelPreSpaces(Format(StringArray[7]));
                        TMPPhoneLookupBuf.Address := DelPreSpaces(Format(StringArray[8]));
                        TMPPhoneLookupBuf."Phone No." := DelPreSpaces(Format(StringArray[17]));
                        TMPPhoneLookupBuf."E-Mail" := DelPreSpaces(Format(StringArray[20]));
                        TMPPhoneLookupBuf."Home Page" := DelPreSpaces(Format(StringArray[21]));
                        TMPPhoneLookupBuf."Country/Region Code" := DelPreSpaces(Format(StringArray[22]));
                        TMPPhoneLookupBuf.Insert();
                        IndexOf := 1;
                    end;
                end;
            end;
        end;
    end;

    procedure DelPreSpaces(TxtString: Text[250]) TxtResult: Text[250]
    var
        Out: Boolean;
    begin
        //DelPreSpaces
        TxtResult := TxtString;
        Out := false;

        repeat
            if CopyStr(TxtResult, 1, 1) = ' ' then
                TxtResult := CopyStr(TxtResult, 2)
            else
                Out := true;
        until Out;
    end;

    [EventSubscriber(ObjectType::Page, Page::"NPR I-Comm", 'GetPhoneLookupCU', '', false, false)]
    local procedure IdentifyMe_GetPhoneLookupCU(var Sender: Page "NPR I-Comm"; var tmpAllObjWithCaption: Record AllObjWithCaption temporary)
    var
        AllObjWithCaption: Record AllObjWithCaption;
    begin
        if tmpAllObjWithCaption.IsTemporary() then begin
            AllObjWithCaption.Get(OBJECTTYPE::Codeunit, 6184550);
            tmpAllObjWithCaption.Init();
            tmpAllObjWithCaption."Object Type" := AllObjWithCaption."Object Type";
            tmpAllObjWithCaption."Object ID" := AllObjWithCaption."Object ID";
            tmpAllObjWithCaption."Object Name" := AllObjWithCaption."Object Name";
            tmpAllObjWithCaption."Object Caption" := AllObjWithCaption."Object Caption";
            tmpAllObjWithCaption.Insert();
        end;
    end;
}

