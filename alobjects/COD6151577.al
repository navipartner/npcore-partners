codeunit 6151577 "AF API - OIO Validation"
{
    // NPR5.38/NPKNAV/20180126  CASE 279861 Transport NPR5.38 - 26 January 2018


    trigger OnRun()
    begin
    end;

    procedure ValidateInvoice()
    var
        Parameters: DotNet Dictionary_Of_T_U;
        AFManagement: Codeunit "AF Management";
        AFHelperFunctions: Codeunit "AF Helper Functions";
        HttpResponseMessage: DotNet HttpResponseMessage;
        Path: Text;
        Window: Dialog;
        OutStr: OutStream;
        JObject: DotNet JObject;
        JTokenWriter: DotNet JTokenWriter;
        StringContent: DotNet StringContent;
        Ostream: OutStream;
        TextString: Text;
        Status: Boolean;
        Encoding: DotNet Encoding;
    begin
        JTokenWriter := JTokenWriter.JTokenWriter;
        with JTokenWriter do begin
          WriteStartObject;
          WritePropertyName('Type');
          WriteValue('Invoice');
          WritePropertyName('SiteImage');
          //WriteValue(GetPDFSiteImage(AFSetup,0));
          WriteEndObject;
          JObject := Token;
        end;

        StringContent := StringContent.StringContent(JObject.ToString,Encoding.UTF8,'application/json');

        Parameters := Parameters.Dictionary();
        //Parameters.Add('baseurl',AFSetup."Msg Service - Base Url");
        Parameters.Add('restmethod','POST');
        //Parameters.Add('path',AFRequestUrl(AFSetup."Msg Service - API Routing",AFSetup."Msg Service - API Key"));
        Parameters.Add('httpcontent',StringContent);

        Status := AFManagement.CallRESTWebService(Parameters,HttpResponseMessage);

        if Status then begin
          //AFSetup."Msg Service - Site Created" := TRUE;
          //AFSetup.MODIFY(TRUE);
          //SiteUrl := AFSetup."Msg Service - Base Web Url" + AFSetup."Msg Service - Name";
          //HYPERLINK(SiteUrl);
        end else begin
          TextString := HttpResponseMessage.Content.ReadAsStringAsync.Result;
          Error(TextString);
        end;
    end;
}

