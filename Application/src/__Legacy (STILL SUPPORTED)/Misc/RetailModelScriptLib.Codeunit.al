codeunit 6150673 "NPR Retail Model Script Lib."
{
    ObsoleteState = Pending;
    ObsoleteReason = 'Codeunit is one big hack. It abuses huge JS frameworks for no good reason. Depends on github URLs not guaranteed to be static and abuses a table that was built for a different purpose. Replace with built-in UI in dragonglass.';

    trigger OnRun()
    begin
    end;

    procedure InitAngular() Angular: Text
    var
        WebClientDependency: Record "NPR Web Client Dependency";
        WebClient: HttpClient;
        InStr: InStream;
        OutStr: OutStream;
        WebResponce: HttpResponseMessage;
        TempBlob: Codeunit "Temp Blob";
    begin
        if not WebClientDependency.Get(WebClientDependency.Type::JavaScript, 'ANGULAR') then begin
            WebClient.Get('https://ajax.googleapis.com/ajax/libs/angularjs/1.7.5/angular.min.js', WebResponce);
            if WebResponce.IsSuccessStatusCode then begin
                WebResponce.Content.ReadAs(InStr);

                WebClientDependency.Init();
                WebClientDependency.Type := WebClientDependency.Type::JavaScript;
                WebClientDependency.Code := 'ANGULAR';
                WebClientDependency.Description := 'angular 1.7.5';
                WebClientDependency.BLOB.CreateOutStream(OutStr);
                CopyStream(OutStr, InStr);
                WebClientDependency.Insert(true);
            end else
                Error(WebResponce.ReasonPhrase);
        end;
        WebClientDependency.CalcFields(BLOB);
        WebClientDependency.BLOB.CreateInStream(InStr);
        InStr.ReadText(Angular);
    end;

    procedure InitJQueryUi() JQueryUI: Text
    var
        WebClientDependency: Record "NPR Web Client Dependency";
        WebClient: HttpClient;
        InStr: InStream;
        OutStr: OutStream;
        WebResponce: HttpResponseMessage;
    begin
        if not WebClientDependency.Get(WebClientDependency.Type::JavaScript, 'JQUERY-UI') then begin
            WebClient.Get('https://code.jquery.com/ui/1.12.1/jquery-ui.min.js', WebResponce);
            if WebResponce.IsSuccessStatusCode then begin
                WebResponce.Content.ReadAs(InStr);

                WebClientDependency.Init();
                WebClientDependency.Type := WebClientDependency.Type::JavaScript;
                WebClientDependency.Code := 'JQUERY-UI';
                WebClientDependency.Description := 'jQuery-ui 1.12.1';
                WebClientDependency.BLOB.CreateOutStream(OutStr);
                CopyStream(OutStr, InStr);
                WebClientDependency.Insert(true);
            end else
                Error(WebResponce.ReasonPhrase);
        end;
        WebClientDependency.CalcFields(BLOB);
        WebClientDependency.BLOB.CreateInStream(InStr);
        InStr.ReadText(JQueryUI);
    end;

    procedure InitTouchPunch() TouchPunch: Text
    var
        WebClientDependency: Record "NPR Web Client Dependency";
        WebClient: HttpClient;
        InStr: InStream;
        OutStr: OutStream;
        WebResponce: HttpResponseMessage;
    begin
        if not WebClientDependency.Get(WebClientDependency.Type::JavaScript, 'TOUCHPUNCH') then begin
            WebClient.Get('https://raw.githubusercontent.com/furf/jquery-ui-touch-punch/master/jquery.ui.touch-punch.min.js', WebResponce);
            if WebResponce.IsSuccessStatusCode then begin
                WebResponce.Content.ReadAs(InStr);

                WebClientDependency.Init();
                WebClientDependency.Type := WebClientDependency.Type::JavaScript;
                WebClientDependency.Code := 'TOUCHPUNCH';
                WebClientDependency.Description := 'touchpunch 0.2.3';
                WebClientDependency.BLOB.CreateOutStream(OutStr);
                CopyStream(OutStr, InStr);
                WebClientDependency.Insert(true);
            end;
        end;
        WebClientDependency.CalcFields(BLOB);
        WebClientDependency.BLOB.CreateInStream(InStr);
        InStr.ReadText(TouchPunch);
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

