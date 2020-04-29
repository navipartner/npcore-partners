codeunit 6151573 "AF API - Spire Barcode"
{
    // NPR5.36/CLVA/20170710 CASE 269792 AF API - Spire


    trigger OnRun()
    begin
    end;

    procedure GenerateBarcode(var AFArgumentTableSpire: Record "AF Arguments - Spire Barcode" temporary): Boolean
    var
        AFAPISpire: Codeunit "AF API - Spire Barcode";
        AFSetup: Record "AF Setup";
    begin
        if AFArgumentTableSpire.Value = '' then
          exit;

        if not IsAFEnabled then
          exit;

        AFSetup.Get;
        AFSetup.TestField("Spire Barcode - API Key");
        AFSetup.TestField("Spire Barcode - Base Url");
        AFSetup.TestField("Spire Barcode - API Routing");

        AFArgumentTableSpire."API Key" := AFSetup."Spire Barcode - API Key";
        AFArgumentTableSpire."Base Url" := AFSetup."Spire Barcode - Base Url";
        AFArgumentTableSpire."API Routing" := AFSetup."Spire Barcode - API Routing";

        exit(BuildRequest(AFArgumentTableSpire));
    end;

    local procedure BuildRequest(var AFArgumentTableSpire: Record "AF Arguments - Spire Barcode"): Boolean
    var
        Parameters: DotNet npNetDictionary_Of_T_U;
        AFManagement: Codeunit "AF Management";
        AFHelperFunctions: Codeunit "AF Helper Functions";
        HttpResponseMessage: DotNet npNetHttpResponseMessage;
        Path: Text;
        Window: Dialog;
        WebUtility: DotNet npNetWebUtility;
        ImageStream: DotNet npNetMemoryStream;
        OutStr: OutStream;
        JObject: DotNet npNetJObject;
        JTokenWriter: DotNet npNetJTokenWriter;
        StringContent: DotNet npNetStringContent;
        Encoding: DotNet npNetEncoding;
    begin
        // Old functionality >>
        // Path := AFArgumentTableSpire."Base Url" + AFRequestUrl(AFArgumentTableSpire."API Key") + STRSUBSTNO('&type=%1&data=%2&imageformat=%3&showtext=%4&hasborder=%5&reversecolor=%6',
        //                              GetOptionStringValue(AFArgumentTableSpire.Type,AFArgumentTableSpire.FIELDNO(Type)),
        //                              WebUtility.UrlEncode(AFArgumentTableSpire.Value),
        //                              GetOptionStringValue(AFArgumentTableSpire."Image Type",AFArgumentTableSpire.FIELDNO("Image Type")),
        //                              FORMAT(AFArgumentTableSpire."Include Text",0,2),
        //                              FORMAT(AFArgumentTableSpire.Border,0,2),
        //                              FORMAT(AFArgumentTableSpire."Reverse Colors",0,2));
        // Old functionality <<

        JTokenWriter := JTokenWriter.JTokenWriter;
        with JTokenWriter do begin
          WriteStartObject;
          WritePropertyName('type');
          WriteValue(AFHelperFunctions.GetOptionStringValue(AFArgumentTableSpire.Type,AFArgumentTableSpire.FieldNo(Type),AFArgumentTableSpire));
          WritePropertyName('barcodevalue');
          //WriteValue(WebUtility.UrlEncode(AFArgumentTableSpire.Value));
          WriteValue(AFArgumentTableSpire.Value);
          WritePropertyName('barheight');
          WriteValue(Format(AFArgumentTableSpire."Barcode Height"));
          WritePropertyName('barsize');
          WriteValue(Format(AFArgumentTableSpire."Barcode Size"));
          WritePropertyName('hasborder');
          WriteValue(Format(AFArgumentTableSpire.Border,0,2));
          WritePropertyName('reversecolor');
          WriteValue(Format(AFArgumentTableSpire."Reverse Colors",0,2));
          WritePropertyName('showtext');
          WriteValue(Format(AFArgumentTableSpire."Include Text",0,2));
          WritePropertyName('showchecksumchar');
          WriteValue(Format(AFArgumentTableSpire."Show Checksum",0,2));
          WritePropertyName('imageformat');
          WriteValue(AFHelperFunctions.GetOptionStringValue(AFArgumentTableSpire."Image Type",AFArgumentTableSpire.FieldNo("Image Type"),AFArgumentTableSpire));
          WriteEndObject;
          JObject := Token;
        end;

        StringContent := StringContent.StringContent(JObject.ToString,Encoding.UTF8,'application/json');

        Parameters := Parameters.Dictionary();
        Parameters.Add('baseurl',AFArgumentTableSpire."Base Url");
        Parameters.Add('restmethod','POST');
        Parameters.Add('path',AFRequestUrl(AFArgumentTableSpire."API Routing",AFArgumentTableSpire."API Key"));
        Parameters.Add('httpcontent',StringContent);

        AFArgumentTableSpire."Request OK" := AFManagement.CallRESTWebService(Parameters,HttpResponseMessage);

        ImageStream := HttpResponseMessage.Content.ReadAsStreamAsync.Result;

        Clear(AFArgumentTableSpire.Image);

        AFArgumentTableSpire.Image.CreateOutStream(OutStr);
        ImageStream.WriteTo(OutStr);
    end;

    local procedure AFRequestUrl(APIRouting: Text;APIKey: Text): Text
    begin
        exit(APIRouting+'?code='+APIKey);
    end;

    local procedure IsAFEnabled(): Boolean
    var
        AFSetup: Record "AF Setup";
    begin
        if AFSetup.Get() then
          exit(AFSetup."Enable Azure Functions");

        exit(false);
    end;
}

