codeunit 6014563 "NPR POS PreSearch Method"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS JavaScript Interface", 'OnCustomMethod', '', false, false)]
    local procedure OnPreSearch(Method: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean);
    var
        Json: Codeunit "NPR POS JSON Management";
        SearchType: Text;
        SearchTerm: Text;
        RetrievingSearchTypeLbl: Label 'Retrieving search type';
        RetrievingSearchTermLbl: Label 'Retrieving search term';
    begin
        if Method <> 'PreSearch' then
            exit;

        Handled := true;

        Json.InitializeJObjectParser(Context, FrontEnd);
        SearchType := Json.GetStringOrFail('type', RetrievingSearchTypeLbl);
        SearchTerm := Json.GetStringOrFail('search', RetrievingSearchTermLbl);

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
        FrontEnd.InvokeFrontEndMethod(UpdatePreSearchRequest);
    end;
}
