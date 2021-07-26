codeunit 85043 "Replication API Mock Handler"
{
    EventSubscriberInstance = Manual;

    var
        NoOfPages: Integer;
        TestFunction: Text;
        Code20List: List OF [Code[20]]; // we set here the UOM Code for example

    procedure SetTestFunctionName(pTestFunction: Text)
    begin
        TestFunction := pTestFunction;
    end;

    procedure SetNoOfPages(pNoOfPages: Integer)
    begin
        NoOfPages := pNoOfPages;
    end;

    procedure SetCode20List(pCode20List: List OF [Code[20]])
    begin
        Code20List := pCode20List;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Replication API", 'OnBeforeSendWebRequest', '', true, true)]
    local procedure CreateMockData(var Response: Codeunit "Temp Blob"; var NextLinkURI: Text; var IsHandled: Boolean)
    var
        Json: Text;
        OutStr: OutStream;
    begin
        IF NoOfPages > 1 then
            NextLinkURI := 'DummyNextLink'
        else
            NextLinkURI := '';

        case TestFunction of
            'VerifyDataIsReplicatedUOM', 'VerifyEncouteredErrorStopsFurtherImportUOM':
                Json := GetJsonUOM(NoOfPages);
        end;

        Response.CreateOutStream(OutStr);
        OutStr.WriteText(Json);

        NoOfPages -= 1;
        IsHandled := true;
    end;

    local procedure GetJsonUOM(NoOfPages: Integer): Text
    var
        JsonTxt: Text;
    begin
        Case NoOfPages OF
            3:
                begin
                    JsonTxt := '{' +
                        '"value": [' +
                            '{' +
                                '"id": "' + CreateGUID() + '",' +
                                '"code":"' + Code20List.Get(1) + '",' +
                                '"displayName": "AAA",' +
                                '"internationalStandardCode": "",' +
                                '"symbol": "",' +
                                '"lastModifiedDateTime": "2020-09-23T15:14:08.447Z",' +
                                '"replicationCounter": 1' +
                            '},' +
                            '{' +
                                 '"id": "' + CreateGUID() + '",' +
                                '"code":"' + Code20List.Get(2) + '",' +
                                '"displayName": "BBB",' +
                                '"internationalStandardCode": "",' +
                                '"symbol": "",' +
                                '"lastModifiedDateTime": "2020-09-23T15:14:08.447Z",' +
                                '"replicationCounter": 2' +
                            '},' +
                        ']' +
                    '}'
                end;
            2:
                begin
                    JsonTxt := '{' +
                        '"value": [' +
                            '{' +
                                 '"id": "",' +
                                '"code":"' + Code20List.Get(3) + '",' +
                                '"displayName": "CCC",' +
                                '"internationalStandardCode": "",' +
                                '"symbol": "",' +
                                '"lastModifiedDateTime": "2020-09-23T15:14:08.447Z",' +
                                '"replicationCounter": 3' +
                            '},' +
                            '{' +
                                 '"id": "",' +
                                '"code":"' + Code20List.Get(4) + '",' +
                                '"displayName": "DDD",' +
                                '"internationalStandardCode": "",' +
                                '"symbol": "",' +
                                '"lastModifiedDateTime": "2020-09-23T15:14:08.447Z",' +
                                '"replicationCounter": 4' +
                            '},' +
                        ']' +
                    '}'
                end;
            1:
                begin
                    JsonTxt := '{' +
                       '"value": [' +
                           '{' +
                                '"id": "",' +
                                '"code":"' + Code20List.Get(5) + '",' +
                                '"displayName": "EEE",' +
                                '"internationalStandardCode": "",' +
                                '"symbol": "",' +
                                '"lastModifiedDateTime": "2020-09-23T15:14:08.447Z",' +
                                '"replicationCounter": 5' +
                           '},' +
                           '{' +
                                '"id": "",' +
                                '"code":"' + Code20List.Get(6) + '",' +
                                '"displayName": "FFF",' +
                                '"internationalStandardCode": "",' +
                                '"symbol": "",' +
                                '"lastModifiedDateTime": "2020-09-23T15:14:08.447Z",' +
                                '"replicationCounter": 6' +
                           '},' +
                       ']' +
                   '}'
                end;
        End;
        exit(JsonTxt);
    end;

}
