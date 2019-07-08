codeunit 6184550 TDC
{
    // NPR5.23/BHR /20160325 CASE 222711 Phone lookup
    // NPR5.23/LS  /20160516 CASE 226819 Added Subscriber Function IdentifyMe_GetPhoneLookupCU
    // NPR5.23/LS  /20160617 CASE 226819 Modified DoLookupPhone function
    // NPR5.40/LS  /20180226  CASE 305526 Modified LoadToBuffer() to allow saving of Last Name and First Name

    TableNo = "Phone Lookup Buffer";

    trigger OnRun()
    begin
        DoLookupPhone(Rec);
    end;

    var
        Text001: Label 'No Person found with Telephone No. %1';

    procedure DoLookupPhone(var PhoneLookupBuf: Record "Phone Lookup Buffer" temporary)
    var
        IComm: Record "I-Comm";
        Result: Text;
        Encoding: DotNet Encoding;
        HttpWebRequest: DotNet HttpWebRequest;
        HttpWebResponse: DotNet HttpWebResponse;
        Stream: DotNet Stream;
        StreamReader: DotNet StreamReader;
    begin
        if not IComm.Get then
          exit;

        //-NPR5.23
        //Filepath := TEMPORARYPATH+'\TDC-' + PhoneLookupBuf."Phone No." + FORMAT(TODAY)+DELCHR(FORMAT(TIME),'=',':');
        //+NPR5.23

        if not IsNull(HttpWebRequest) then
          Clear(HttpWebRequest);

        HttpWebRequest := HttpWebRequest.Create(IComm."Tunnel URL Address" + '?PHONE=' + PhoneLookupBuf."Phone No.");
        HttpWebRequest.Method := 'GET';
        HttpWebRequest.ContentType :=  'text/xml;charset=iso-8859-9';
        HttpWebResponse := HttpWebRequest.GetResponse();
        Stream := HttpWebResponse.GetResponseStream;
        Encoding := Encoding.GetEncoding('ISO-8859-9');
        StreamReader := StreamReader.StreamReader(Stream,Encoding);
        Result := StreamReader.ReadToEnd;
        LoadToBuffer(Result,PhoneLookupBuf);
        Stream.Flush;
        Stream.Close;
        Clear(Stream);
        //-NPR5.23 [226819]
        //IF DotNetFileLibrary.ERASE(Filepath) THEN;
        //+NPR5.23 [226819]
    end;

    local procedure LoadToBuffer(var Stringtxt: Text;var TMPPhoneLookupBuf: Record "Phone Lookup Buffer")
    var
        SeperatorArray: DotNet Array;
        StringArray: DotNet Array;
        ResponseString: DotNet String;
        Space: Char;
        Tab: Char;
        i: Integer;
        IndexOf: Integer;
        NewString: Text;
    begin
        //-NPR4.14
        Tab := 9;
        Space := 32 ;
        ResponseString := Stringtxt;

        if ResponseString.Contains('RESULTS') then begin
          i := 0;
          while (ResponseString.Contains('RESULTS') and (ResponseString.Length <> 0)) do begin
            i := i+1;
            IndexOf := ResponseString.IndexOf('RESULTS');
            if IndexOf <> 0 then begin
              ResponseString := ResponseString.Remove(0,IndexOf+11);
              if not (ResponseString.Length <= 0) then
                IndexOf := ResponseString.IndexOf('RESULTS');

              if IndexOf >0  then
                NewString := ResponseString.Substring(0,IndexOf-1)
              else
                NewString := ResponseString;

              SeperatorArray := SeperatorArray.CreateInstance(GetDotNetType(Tab),1);
              SeperatorArray.SetValue(Tab,0);
              StringArray := ResponseString.Split(SeperatorArray);

              TMPPhoneLookupBuf.Init;
              TMPPhoneLookupBuf.ID := DelPreSpaces(Format(StringArray.GetValue(0)));
              TMPPhoneLookupBuf.Title := DelPreSpaces(Format(StringArray.GetValue(1)));
              TMPPhoneLookupBuf.Name := DelPreSpaces(Format(StringArray.GetValue(2)));
              TMPPhoneLookupBuf.Name += ' ' + DelPreSpaces(Format(StringArray.GetValue(3)));
              //-NPR5.40 [305526]
              TMPPhoneLookupBuf."First Name" := DelPreSpaces (DelPreSpaces(Format(StringArray.GetValue(2))));
              TMPPhoneLookupBuf."Last Name"  := DelPreSpaces (DelPreSpaces(Format(StringArray.GetValue(3))));
              //+NPR5.40 [305526]
              TMPPhoneLookupBuf."Post Code" := DelPreSpaces(Format(StringArray.GetValue(5)));
              TMPPhoneLookupBuf.City := DelPreSpaces(Format(StringArray.GetValue(6)));
              TMPPhoneLookupBuf.Address := DelPreSpaces(Format(StringArray.GetValue(7)));
              TMPPhoneLookupBuf."Phone No." := DelPreSpaces(Format(StringArray.GetValue(16)));
              TMPPhoneLookupBuf."E-Mail" := DelPreSpaces(Format(StringArray.GetValue(19)));
              TMPPhoneLookupBuf."Home Page" := DelPreSpaces(Format(StringArray.GetValue(20)));
              TMPPhoneLookupBuf."Country/Region Code" :=   DelPreSpaces(Format(StringArray.GetValue(21)));
              TMPPhoneLookupBuf.Insert;
              IndexOf := 0;
            end;
          end;
        end;
        //+NPR4.14
    end;

    procedure DelPreSpaces(TxtString: Text[250]) TxtResult: Text[250]
    var
        i: Integer;
        j: Integer;
        Out: Boolean;
    begin
        //DelPreSpaces
        TxtResult := TxtString;
        Out := false;

        repeat
          if CopyStr(TxtResult,1,1) = ' ' then
            TxtResult := CopyStr(TxtResult,2)
          else
            Out := true;
        until Out;
    end;

    [EventSubscriber(ObjectType::Page, 6014516, 'GetPhoneLookupCU', '', false, false)]
    local procedure IdentifyMe_GetPhoneLookupCU(var Sender: Page "I-Comm";var tmpAllObjWithCaption: Record AllObjWithCaption temporary)
    var
        AllObjWithCaption: Record AllObjWithCaption;
    begin
        //-NPR5.23 [226819]
        if tmpAllObjWithCaption.IsTemporary then begin
          AllObjWithCaption.Get(OBJECTTYPE::Codeunit, 6184550);
          tmpAllObjWithCaption.Init;
          tmpAllObjWithCaption."Object Type"  := AllObjWithCaption."Object Type" ;
          tmpAllObjWithCaption."Object ID" := AllObjWithCaption."Object ID";
          tmpAllObjWithCaption."Object Name" := AllObjWithCaption."Object Name";
          tmpAllObjWithCaption."Object Caption"  := AllObjWithCaption."Object Caption";
          tmpAllObjWithCaption.Insert;
        end;
        //+NPR5.23 [226819]
    end;
}

