codeunit 6150782 "NPR Front-End: SetView" implements "NPR Front-End Async Request"
{
    var
        _view: Codeunit "NPR POS View";
        _content: JsonObject;

    procedure InitializeAsLogin();
    var
        ViewType: Enum "NPR View Type";
    begin
        _view.SetType(ViewType::Login);
        _view.SetCanCache(true);
    end;

    procedure InitializeAsSale();
    var
        ViewType: Enum "NPR View Type";
    begin
        _view.SetType(ViewType::Sale);
        _view.SetCanCache(true);
    end;

    procedure InitializeAsPayment();
    var
        ViewType: Enum "NPR View Type";
    begin
        _view.SetType(ViewType::Payment);
        _view.SetCanCache(true);
    end;

    procedure InitializeAsBalanceRegister();
    var
        ViewType: Enum "NPR View Type";
    begin
        _view.SetType(ViewType::BalanceRegister);
        _view.SetCanCache(true);
    end;

    procedure InitializeAsLocked();
    var
        ViewType: Enum "NPR View Type";
    begin
        _view.SetType(ViewType::Locked);
        _view.SetCanCache(true);
    end;

    procedure InitializeAsRestaurant();
    var
        ViewType: Enum "NPR View Type";
    begin
        _view.SetType(ViewType::Restaurant);
        _view.SetCanCache(true);
    end;

    procedure SetView(NewView: Codeunit "NPR POS View")
    begin
        _view := NewView;
    end;

    procedure GetView(var ViewOut: Codeunit "NPR POS View");
    begin
        ViewOut := _view;
    end;

    procedure GetJson() Json: JsonObject
    begin
        Json.Add('Method', 'SetView');
        Json.Add('View', _view.GetJson());
        Json.Add('Content', _content);
    end;

    procedure GetContent(): JsonObject
    begin
        exit(_content);
    end;
}
