#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
page 6150949 "NPR Ecom Wallet Sub"
{
    Caption = 'Wallets';
    Extensible = false;
    PageType = ListPart;
    SourceTable = "NPR AttractionWallet";
    SourceTableTemporary = true;
    Editable = false;
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;
    ApplicationArea = NPRRetail;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(ReferenceNumber; Rec.ReferenceNumber)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the customer-facing reference number for this wallet.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the wallet description.';
                }
                field(OriginatesFromItemNo; Rec.OriginatesFromItemNo)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the item number this wallet was created from.';
                }
                field(ExpirationDate; Rec.ExpirationDate)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies when the wallet expires.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(OpenWallet)
            {
                Caption = 'Open';
                ApplicationArea = NPRRetail;
                Image = ViewDetails;
                ToolTip = 'Open the selected wallet to see full details.';

                trigger OnAction()
                var
                    EcomCreateWalletMgt: Codeunit "NPR EcomCreateWalletMgt";
                begin
                    EcomCreateWalletMgt.OpenWalletCardForSystemId(Rec.SystemId);
                end;
            }
        }
    }

    internal procedure ClearContents()
    begin
        Rec.Reset();
        Rec.DeleteAll();
        CurrPage.Update(false);
    end;

    internal procedure PopulateFromJsonText(JsonText: Text)
    var
        WalletsJson: JsonArray;
    begin
        Rec.Reset();
        Rec.DeleteAll();
        if (JsonText <> '') and WalletsJson.ReadFrom(JsonText) then
            PopulateBufferFromJson(WalletsJson);
        if Rec.FindFirst() then;
        CurrPage.Update(false);
    end;

    local procedure PopulateBufferFromJson(WalletsJson: JsonArray)
    var
        WalletToken: JsonToken;
        WalletObj: JsonObject;
        FieldToken: JsonToken;
        ParsedSystemId: Guid;
    begin
        foreach WalletToken in WalletsJson do begin
            WalletObj := WalletToken.AsObject();
            Rec.Init();
            if WalletObj.Get('No', FieldToken) then
                Rec.EntryNo := FieldToken.AsValue().AsInteger();
            if WalletObj.Get('Ref', FieldToken) then
                Rec.ReferenceNumber := CopyStr(FieldToken.AsValue().AsText(), 1, MaxStrLen(Rec.ReferenceNumber));
            if WalletObj.Get('Desc', FieldToken) then
                Rec.Description := CopyStr(FieldToken.AsValue().AsText(), 1, MaxStrLen(Rec.Description));
            if WalletObj.Get('Item', FieldToken) then
                Rec.OriginatesFromItemNo := CopyStr(FieldToken.AsValue().AsText(), 1, MaxStrLen(Rec.OriginatesFromItemNo));
            if WalletObj.Get('Exp', FieldToken) then
                Rec.ExpirationDate := FieldToken.AsValue().AsDateTime();
            if WalletObj.Get('Sid', FieldToken) then
                if Evaluate(ParsedSystemId, FieldToken.AsValue().AsText()) then
                    Rec.SystemId := ParsedSystemId;
            Rec.Insert(false, true);
        end;
    end;
}
#endif
