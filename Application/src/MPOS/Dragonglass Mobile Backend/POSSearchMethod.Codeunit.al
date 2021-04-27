codeunit 6014564 "NPR POS Search Method"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS JavaScript Interface", 'OnCustomMethod', '', false, false)]
    local procedure OnPreSearch(Method: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean);
    var
        Json: Codeunit "NPR POS JSON Management";
        SearchType: Text;
        SearchTerm: Text;
        LastKey: Text;
        RetrievingSearchTypeLbl: Label 'Retrieving search type';
        RetrievingSearchTermLbl: Label 'Retrieving search term';
    begin
        if Method <> 'Search' then
            exit;

        Handled := true;

        Json.InitializeJObjectParser(Context, FrontEnd);
        SearchType := Json.GetStringOrFail('type', RetrievingSearchTypeLbl);
        SearchTerm := Json.GetStringOrFail('search', RetrievingSearchTermLbl);
        LastKey := Json.GetString('lastKey');

        case SearchType of
            'ITEM':
                SearchItem(SearchTerm, LastKey, FrontEnd);
        end
    end;

    local procedure NewLine(): Text;
    var
        LF: Char;
    begin
        exit(Format(LF, 0, '<CHAR>'));
    end;

    local procedure IsMatch(SearchTerm: Text; TextToSearch: Text): Boolean;
    var
        Word: Text;
        Words: List of [Text];
    begin
        Words := TextToSearch.ToLower().Split(' ');
        foreach Word in Words do begin
            if Word.StartsWith(SearchTerm) then
                exit(true);
        end;
    end;

    local procedure SearchItem(SearchTerm: Text; LastKey: Code[20]; FrontEnd: Codeunit "NPR POS Front End Management");
    var
        Item: Record Item;
        UpdateSearchRequest: Codeunit "NPR Front-End: UpdateSearch";
        Results: JsonArray;
        Result: JsonObject;
        Token: JsonToken;
        ResultCount: Integer;
        HasMore: Boolean;
    begin
        HasMore := true;
        if LastKey <> '' then
            Item.SetFilter("No.", '>%1', LastKey);
        Item.SetLoadFields("No.", Description, "Description 2", "Unit Price");
        if Item.FindSet(false) then begin
            repeat
                if IsMatch(SearchTerm, Item.Description) then begin
                    Clear(Result);
                    Result.Add('no', Item."No.");
                    Result.Add('name', Item.Description);
                    Result.Add('description', Item."Description 2");
                    Result.Add('price', Item."Unit Price");
                    Results.Add(Result);
                    ResultCount += 1;
                end;
                if ResultCount = 20 then
                    break;
                HasMore := Item.Next() > 0;
            until not HasMore;
        end;

        UpdateSearchRequest.SetResults(Results);
        UpdateSearchRequest.SetHasMore(HasMore);
        FrontEnd.InvokeFrontEndMethod(UpdateSearchRequest);
    end;
}
