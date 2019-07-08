codeunit 6059997 "Scanner Service Functions"
{
    // NPR5.29/NPKNAV/20170127  CASE 252352 Transport NPR5.29 - 27 januar 2017


    trigger OnRun()
    begin
    end;

    procedure RemoveInvalidXmlChars(inString: Text): Text
    var
        newString: DotNet StringBuilder;
        ch: Char;
        i: Integer;
        XmlConvert: DotNet XmlConvert;
    begin
        if (inString = '') then
          exit(inString);

        newString := newString.StringBuilder;
        XmlConvert := XmlConvert.XmlConvert;
        i := 1;
        while (i <= StrLen(inString)) do begin
            ch := inString[i];
            i := i + 1;
            if (XmlConvert.IsXmlChar(ch)) then
              newString.Append(ch);
        end;

        exit(newString.ToString());
    end;

    procedure CreateLogEntry(var ScannerServiceLog: Record "Scanner Service Log";Request: BigText)
    var
        Ostream: OutStream;
        ScannerServiceSetup: Record "Scanner Service Setup";
    begin
        ScannerServiceSetup.FindFirst;
        if not ScannerServiceSetup."Log Request" then
          exit;

        ScannerServiceLog.Id := CreateGuid;
        ScannerServiceLog."Request Start" := CurrentDateTime;
        ScannerServiceLog."Request Data".CreateOutStream(Ostream);
        Request.Write(Ostream);
        ScannerServiceLog.Insert;
        Commit;
    end;

    procedure UpdateLogEntry(var DWLog: Record "Scanner Service Log";FunctionCalled: Text;IsInternalRequest: Boolean;InternalRequestId: Guid;Response: BigText)
    var
        lDWLog: Record "Scanner Service Log";
        Ostream: OutStream;
        DWSetup: Record "Scanner Service Setup";
    begin
        DWSetup.FindFirst;
        if not DWSetup."Log Request" then
          exit;

        DWLog."Request End" := CurrentDateTime;
        DWLog."Request Function" := FunctionCalled;
        DWLog."Internal Request" := IsInternalRequest;
        DWLog."Internal Log No." := InternalRequestId;
        DWLog."Current User" := UserId;
        DWLog."Response Data".CreateOutStream(Ostream);
        Response.Write(Ostream);

        DWLog.Modify(true);
    end;

    procedure InternalRequest(Request: Text;IsInternal: Boolean;InternalId: Guid): Text
    var
        DWService: Codeunit "Scanner Service WS";
        RequestBigtext: BigText;
        Response: Text;
    begin
        Clear(RequestBigtext);
        RequestBigtext.AddText(Request);
        DWService.IsInternalCall(IsInternal,InternalId);
        DWService.Process(RequestBigtext);
        RequestBigtext.GetSubText(Response,1);
        exit(Response);
    end;

    local procedure CreateTempFile(): Text
    var
        TempFIle: File;
        FileName: Text[250];
    begin
        TempFIle.CreateTempFile;
        FileName := TempFIle.Name;
        TempFIle.Close;

        exit(FileName);
    end;

    procedure Format2DecimalPlaces(Input: Decimal): Text
    begin
        exit(Format(Input,0,'<Precision,2:2><Standard Format,0>'));
    end;
}

