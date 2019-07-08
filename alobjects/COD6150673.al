codeunit 6150673 "Retail Model Script Library"
{
    // NPR5.47/MHA /20181026  CASE 326640 Object created - view Web Client Dependency


    trigger OnRun()
    begin
    end;

    procedure InitAngular() Angular: Text
    var
        WebClientDependency: Record "Web Client Dependency";
        MemoryStream: DotNet MemoryStream;
        StreamReader: DotNet StreamReader;
        Uri: DotNet Uri;
        WebClient: DotNet WebClient;
        InStr: InStream;
        OutStr: OutStream;
    begin
        if not WebClientDependency.Get(WebClientDependency.Type::JavaScript,'ANGULAR') then begin
          WebClient := WebClient.WebClient();
          Uri := Uri.Uri('https://ajax.googleapis.com/ajax/libs/angularjs/1.7.5/angular.min.js');
          MemoryStream := MemoryStream.MemoryStream(WebClient.DownloadData(Uri));

          WebClientDependency.Init;
          WebClientDependency.Type := WebClientDependency.Type::JavaScript;
          WebClientDependency.Code := 'ANGULAR';
          WebClientDependency.Description := 'angular 1.7.5';
          WebClientDependency.BLOB.CreateOutStream(OutStr);
          MemoryStream.WriteTo(OutStr);
          WebClientDependency.Insert(true);
        end;
        WebClientDependency.CalcFields(BLOB);
        WebClientDependency.BLOB.CreateInStream(InStr);
        StreamReader := StreamReader.StreamReader(InStr);
        Angular := StreamReader.ReadToEnd();
        exit(Angular);
    end;

    procedure InitJQueryUi() JQueryUI: Text
    var
        WebClientDependency: Record "Web Client Dependency";
        MemoryStream: DotNet MemoryStream;
        StreamReader: DotNet StreamReader;
        Uri: DotNet Uri;
        WebClient: DotNet WebClient;
        InStr: InStream;
        OutStr: OutStream;
    begin
        if not WebClientDependency.Get(WebClientDependency.Type::JavaScript,'JQUERY-UI') then begin
          WebClient := WebClient.WebClient();
          Uri := Uri.Uri('https://code.jquery.com/ui/1.12.1/jquery-ui.min.js');
          MemoryStream := MemoryStream.MemoryStream(WebClient.DownloadData(Uri));

          WebClientDependency.Init;
          WebClientDependency.Type := WebClientDependency.Type::JavaScript;
          WebClientDependency.Code := 'JQUERY-UI';
          WebClientDependency.Description := 'jQuery-ui 1.12.1';
          WebClientDependency.BLOB.CreateOutStream(OutStr);
          MemoryStream.WriteTo(OutStr);
          WebClientDependency.Insert(true);
        end;
        WebClientDependency.CalcFields(BLOB);
        WebClientDependency.BLOB.CreateInStream(InStr);
        StreamReader := StreamReader.StreamReader(InStr);
        JQueryUI := StreamReader.ReadToEnd();
        exit(JQueryUI);
    end;

    procedure InitTouchPunch() TouchPunch: Text
    var
        WebClientDependency: Record "Web Client Dependency";
        MemoryStream: DotNet MemoryStream;
        StreamReader: DotNet StreamReader;
        Uri: DotNet Uri;
        WebClient: DotNet WebClient;
        InStr: InStream;
        OutStr: OutStream;
    begin
        if not WebClientDependency.Get(WebClientDependency.Type::JavaScript,'TOUCHPUNCH') then begin
          WebClient := WebClient.WebClient();
          Uri := Uri.Uri('https://raw.githubusercontent.com/furf/jquery-ui-touch-punch/master/jquery.ui.touch-punch.min.js');
          MemoryStream := MemoryStream.MemoryStream(WebClient.DownloadData(Uri));

          WebClientDependency.Init;
          WebClientDependency.Type := WebClientDependency.Type::JavaScript;
          WebClientDependency.Code := 'TOUCHPUNCH';
          WebClientDependency.Description := 'touchpunch 0.2.3';
          WebClientDependency.BLOB.CreateOutStream(OutStr);
          MemoryStream.WriteTo(OutStr);
          WebClientDependency.Insert(true);
        end;
        WebClientDependency.CalcFields(BLOB);
        WebClientDependency.BLOB.CreateInStream(InStr);
        StreamReader := StreamReader.StreamReader(InStr);
        TouchPunch := StreamReader.ReadToEnd();
        exit(TouchPunch);
    end;

    procedure InitEscClose() Script: Text
    begin
        Script += '$(document).keydown(function(e) {' +
                    'if (e.which == 27) {' +
                      'n$.respondExplicit("close", {});' +
                    '}' +
                  '});';

        exit(Script);
    end;
}

