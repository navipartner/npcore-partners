codeunit 85043 "NPR Replication API Mock Hndlr"
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
#IF (BC17 or BC18 or BC19 or BC20)
                                '"replicationCounter": 1' +
#ELSE
                                '"systemRowVersion": 1' +
#ENDIF
                            '},' +
                            '{' +
                                 '"id": "' + CreateGUID() + '",' +
                                '"code":"' + Code20List.Get(2) + '",' +
                                '"displayName": "BBB",' +
                                '"internationalStandardCode": "",' +
                                '"symbol": "",' +
                                '"lastModifiedDateTime": "2020-09-23T15:14:08.447Z",' +
#IF (BC17 or BC18 or BC19 or BC20)
                                '"replicationCounter": 2' +
#ELSE
                                '"systemRowVersion": 2' +
#ENDIF
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
#IF (BC17 or BC18 or BC19 or BC20)
                                '"replicationCounter": 3' +
#ELSE
                                '"systemRowVersion": 3' +
#ENDIF
                            '},' +
                            '{' +
                                 '"id": "",' +
                                '"code":"' + Code20List.Get(4) + '",' +
                                '"displayName": "DDD",' +
                                '"internationalStandardCode": "",' +
                                '"symbol": "",' +
                                '"lastModifiedDateTime": "2020-09-23T15:14:08.447Z",' +
#IF (BC17 or BC18 or BC19 or BC20)
                                '"replicationCounter": 4' +
#ELSE
                                '"systemRowVersion": 4' +
#ENDIF
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
#IF (BC17 or BC18 or BC19 or BC20)
                                '"replicationCounter": 5' +
#ELSE
                                '"systemRowVersion": 5' +
#ENDIF
                           '},' +
                           '{' +
                                '"id": "",' +
                                '"code":"' + Code20List.Get(6) + '",' +
                                '"displayName": "FFF",' +
                                '"internationalStandardCode": "",' +
                                '"symbol": "",' +
                                '"lastModifiedDateTime": "2020-09-23T15:14:08.447Z",' +
#IF (BC17 or BC18 or BC19 or BC20)
                                '"replicationCounter": 6' +
#ELSE
                                '"systemRowVersion": 6' +
#ENDIF
                           '},' +
                       ']' +
                   '}'
                end;
        End;
        exit(JsonTxt);
    end;

}
