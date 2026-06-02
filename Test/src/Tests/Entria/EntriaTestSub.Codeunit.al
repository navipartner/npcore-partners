#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 85261 "NPR Entria TestSub"
{
    // Captures Item OnAfterModifyEvent state so the EntriaTests codeunit can
    // verify that the production webhook subscriber's guards would evaluate as
    // expected. See the file-level comment in "NPR Entria Tests" for why we do
    // not subscribe directly to the EntriaIntegrWebhooks publisher.
    EventSubscriberInstance = Manual;

    var
        _OnAfterCalled: Boolean;
        _OnAfterCallCount: Integer;
        _OnAfterRecPrice: Decimal;
        _OnAfterXRecPrice: Decimal;
        _OnAfterXRecNo: Code[20];
        _OnAfterXRecLoaded: Boolean;
        _OnAfterRecEntriaProduct: Boolean;

    procedure Reset()
    begin
        _OnAfterCalled := false;
        _OnAfterCallCount := 0;
        _OnAfterRecPrice := 0;
        _OnAfterXRecPrice := 0;
        _OnAfterXRecNo := '';
        _OnAfterXRecLoaded := false;
        _OnAfterRecEntriaProduct := false;
    end;

    procedure WasOnAfterCalled(): Boolean
    begin
        exit(_OnAfterCalled);
    end;

    procedure GetOnAfterCallCount(): Integer
    begin
        exit(_OnAfterCallCount);
    end;

    procedure GetOnAfterRecPrice(): Decimal
    begin
        exit(_OnAfterRecPrice);
    end;

    procedure GetOnAfterXRecPrice(): Decimal
    begin
        exit(_OnAfterXRecPrice);
    end;

    procedure GetOnAfterXRecNo(): Code[20]
    begin
        exit(_OnAfterXRecNo);
    end;

    procedure GetOnAfterXRecLoaded(): Boolean
    begin
        exit(_OnAfterXRecLoaded);
    end;

    procedure GetOnAfterRecEntriaProduct(): Boolean
    begin
        exit(_OnAfterRecEntriaProduct);
    end;

    [EventSubscriber(ObjectType::Table, Database::Item, 'OnAfterModifyEvent', '', false, false)]
    local procedure CaptureAfterItemModify(var Rec: Record Item; var xRec: Record Item; RunTrigger: Boolean)
    begin
        _OnAfterCalled := true;
        _OnAfterCallCount += 1;
        _OnAfterRecPrice := Rec."Unit Price";
        _OnAfterXRecPrice := xRec."Unit Price";
        _OnAfterXRecNo := xRec."No.";
        _OnAfterXRecLoaded := xRec.AreFieldsLoaded("Unit Price");
        _OnAfterRecEntriaProduct := Rec."NPR Entria Product";
    end;
}
#endif
