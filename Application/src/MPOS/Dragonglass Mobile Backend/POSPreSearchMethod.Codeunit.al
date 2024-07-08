﻿codeunit 6014563 "NPR POS PreSearch Method"
{
    Access = Internal;
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS JavaScript Interface", 'OnCustomMethod', '', false, false)]
    local procedure OnPreSearch(Method: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean);
    var
        JsonHelper: Codeunit "NPR POS JSON Helper";
        SearchType: Text;
        SearchTerm: Text;
    begin
        if Method <> 'PreSearch' then
            exit;

        Handled := true;

        JsonHelper.InitializeJObjectParser(Context);
        SearchType := JsonHelper.GetString('type');
        SearchTerm := JsonHelper.GetString('search');

        case SearchType of
            'ITEM':
                PreSearchItem(SearchTerm, FrontEnd);
        end
    end;

    local procedure PreSearchItem(SearchTerm: Text; FrontEnd: Codeunit "NPR POS Front End Management");
    var
        Item: Record Item;
        UpdatePreSearchRequest: Codeunit "NPR Front-End: UpdatePreSearch";
        Results: JsonObject;
        Word: Text;
        Words: List of [Text];
        Token: JsonToken;
    begin
        Item.SetLoadFields(Description, "Description 2");
        if Item.FindSet(false) then
            repeat
                Words := Item.Description.Split(' ');
                foreach Word in Words do begin
                    Word := Word.ToLower();
                    if Word.StartsWith(SearchTerm) then begin
                        if Results.Contains(Word) then begin
                            Results.Get(Word, Token);
                            Results.Replace(Word, Token.AsValue().AsInteger() + 1);
                        end else begin
                            Results.Add(Word, 1);
                        end;
                    end;
                end;
            until Item.Next() = 0;

        UpdatePreSearchRequest.SetResults(Results);
        FrontEnd.InvokeFrontEndMethod2(UpdatePreSearchRequest);
    end;
}
