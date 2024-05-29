codeunit 6184835 "NPR KDS Frontend Assistant"
{
    Access = Public;

    var
        _KitchenAction: Option "Accept Change","Set Production Not Started","Start Production","End Production","Set OnHold","Resume","Set Served","Revoke Serving";

    [Obsolete('Use the overload with the "lastServerId" parameter instead', 'NPR35.0')]
    procedure RefreshCustomerDisplayKitchenOrders(restaurantId: Text) Response: Text
    begin
        Response := RefreshCustomerDisplayKitchenOrders(restaurantId, '');
    end;

    procedure RefreshCustomerDisplayKitchenOrders(restaurantId: Text; lastServerId: Text) Response: Text
    var
        KDSFrontendAssistImpl: Codeunit "NPR KDS Frontend Assist. Impl.";
    begin
        KDSFrontendAssistImpl.RefreshCustomerDisplayKitchenOrders(restaurantId, lastServerId).WriteTo(Response);
    end;

    [Obsolete('Use the overload with the "lastServerId" parameter instead', 'NPR35.0')]
    procedure RefreshKDSData(restaurantId: Text; stationId: Text; includeFinished: Boolean; startingFrom: DateTime) Response: Text
    begin
        Response := RefreshKDSData(restaurantId, stationId, includeFinished, startingFrom, '');
    end;

    procedure RefreshKDSData(restaurantId: Text; stationId: Text; includeFinished: Boolean; startingFrom: DateTime; lastServerId: Text) Response: Text
    var
        KDSFrontendAssistImpl: Codeunit "NPR KDS Frontend Assist. Impl.";
    begin
        KDSFrontendAssistImpl.RefreshKDSData(restaurantId, stationId, includeFinished, startingFrom, lastServerId).WriteTo(Response);
    end;

    [Obsolete('Use the overload with the "lastServerId" parameter instead', 'NPR35.0')]
    procedure GetFinishedOrders(restaurantId: Text; startingFrom: DateTime) Response: Text
    begin
        Response := GetFinishedOrders(restaurantId, startingFrom, '');
    end;

    procedure GetFinishedOrders(restaurantId: Text; startingFrom: DateTime; lastServerId: Text) Response: Text
    var
        KDSFrontendAssistImpl: Codeunit "NPR KDS Frontend Assist. Impl.";
    begin
        KDSFrontendAssistImpl.GetFinishedOrders(restaurantId, startingFrom, lastServerId).WriteTo(Response);
    end;

    [Obsolete('Use the overload with the "lastServerId" parameter instead', 'NPR35.0')]
    procedure GetSetups() Response: Text
    begin
        Response := GetSetups('');
    end;

    procedure GetSetups(lastServerId: Text) Response: Text
    var
        KDSFrontendAssistImpl: Codeunit "NPR KDS Frontend Assist. Impl.";
    begin
        KDSFrontendAssistImpl.GetSetups(lastServerId).WriteTo(Response);
    end;

    [Obsolete('Use the overload with the "lastServerId" parameter and a return value instead', 'NPR35.0')]
    procedure AcceptChange(restaurantId: Text; stationId: Text; kitchenRequestId: BigInteger; orderId: BigInteger)
    begin
        AcceptChange(restaurantId, stationId, kitchenRequestId, orderId, '');
    end;

    procedure AcceptChange(restaurantId: Text; stationId: Text; kitchenRequestId: BigInteger; orderId: BigInteger; lastServerId: Text) Response: Text
    var
        KDSFrontendAssistImpl: Codeunit "NPR KDS Frontend Assist. Impl.";
    begin
        KDSFrontendAssistImpl.RunKitchenAction(restaurantId, stationId, kitchenRequestId, orderId, _KitchenAction::"Accept Change", lastServerId).WriteTo(Response);
    end;

    [Obsolete('Use the overload with the "lastServerId" parameter and a return value instead', 'NPR35.0')]
    procedure SetProductionNotStarted(restaurantId: Text; stationId: Text; kitchenRequestId: BigInteger; orderId: BigInteger)
    begin
        SetProductionNotStarted(restaurantId, stationId, kitchenRequestId, orderId, '');
    end;

    procedure SetProductionNotStarted(restaurantId: Text; stationId: Text; kitchenRequestId: BigInteger; orderId: BigInteger; lastServerId: Text) Response: Text
    var
        KDSFrontendAssistImpl: Codeunit "NPR KDS Frontend Assist. Impl.";
    begin
        KDSFrontendAssistImpl.RunKitchenAction(restaurantId, stationId, kitchenRequestId, orderId, _KitchenAction::"Set Production Not Started", lastServerId).WriteTo(Response);
    end;

    [Obsolete('Use the overload with the "lastServerId" parameter and a return value instead', 'NPR35.0')]
    procedure SetProductionStarted(restaurantId: Text; stationId: Text; kitchenRequestId: BigInteger; orderId: BigInteger)
    begin
        SetProductionStarted(restaurantId, stationId, kitchenRequestId, orderId, '');
    end;

    procedure SetProductionStarted(restaurantId: Text; stationId: Text; kitchenRequestId: BigInteger; orderId: BigInteger; lastServerId: Text) Response: Text
    var
        KDSFrontendAssistImpl: Codeunit "NPR KDS Frontend Assist. Impl.";
    begin
        KDSFrontendAssistImpl.RunKitchenAction(restaurantId, stationId, kitchenRequestId, orderId, _KitchenAction::"Start Production", lastServerId).WriteTo(Response);
    end;

    [Obsolete('Use the overload with the "lastServerId" parameter and a return value instead', 'NPR35.0')]
    procedure SetProductionFinished(restaurantId: Text; stationId: Text; kitchenRequestId: BigInteger; orderId: BigInteger)
    begin
        SetProductionFinished(restaurantId, stationId, kitchenRequestId, orderId, '');
    end;

    procedure SetProductionFinished(restaurantId: Text; stationId: Text; kitchenRequestId: BigInteger; orderId: BigInteger; lastServerId: Text) Response: Text
    var
        KDSFrontendAssistImpl: Codeunit "NPR KDS Frontend Assist. Impl.";
    begin
        KDSFrontendAssistImpl.RunKitchenAction(restaurantId, stationId, kitchenRequestId, orderId, _KitchenAction::"End Production", lastServerId).WriteTo(Response);
    end;

    [Obsolete('Use the overload with the "lastServerId" parameter and a return value instead', 'NPR35.0')]
    procedure SetOnHold(restaurantId: Text; stationId: Text; kitchenRequestId: BigInteger; orderId: BigInteger)
    begin
        SetOnHold(restaurantId, stationId, kitchenRequestId, orderId, '');
    end;

    procedure SetOnHold(restaurantId: Text; stationId: Text; kitchenRequestId: BigInteger; orderId: BigInteger; lastServerId: Text) Response: Text
    var
        KDSFrontendAssistImpl: Codeunit "NPR KDS Frontend Assist. Impl.";
    begin
        KDSFrontendAssistImpl.RunKitchenAction(restaurantId, stationId, kitchenRequestId, orderId, _KitchenAction::"Set OnHold", lastServerId).WriteTo(Response);
    end;

    [Obsolete('Use the overload with the "lastServerId" parameter and a return value instead', 'NPR35.0')]
    procedure Resume(restaurantId: Text; stationId: Text; kitchenRequestId: BigInteger; orderId: BigInteger)
    begin
        Resume(restaurantId, stationId, kitchenRequestId, orderId, '');
    end;

    procedure Resume(restaurantId: Text; stationId: Text; kitchenRequestId: BigInteger; orderId: BigInteger; lastServerId: Text) Response: Text
    var
        KDSFrontendAssistImpl: Codeunit "NPR KDS Frontend Assist. Impl.";
    begin
        KDSFrontendAssistImpl.RunKitchenAction(restaurantId, stationId, kitchenRequestId, orderId, _KitchenAction::"Resume", lastServerId).WriteTo(Response);
    end;

    [Obsolete('Use the overload with the "lastServerId" parameter and a return value instead', 'NPR35.0')]
    procedure SetServed(restaurantId: Text; kitchenRequestId: BigInteger; orderId: BigInteger)
    begin
        SetServed(restaurantId, kitchenRequestId, orderId, '');
    end;

    procedure SetServed(restaurantId: Text; kitchenRequestId: BigInteger; orderId: BigInteger; lastServerId: Text) Response: Text
    var
        KDSFrontendAssistImpl: Codeunit "NPR KDS Frontend Assist. Impl.";
    begin
        KDSFrontendAssistImpl.RunKitchenAction(restaurantId, '', kitchenRequestId, orderId, _KitchenAction::"Set Served", lastServerId).WriteTo(Response);
    end;

    [Obsolete('Use the overload with the "lastServerId" parameter and a return value instead', 'NPR35.0')]
    procedure RevokeServing(restaurantId: Text; kitchenRequestId: BigInteger; orderId: BigInteger)
    begin
        RevokeServing(restaurantId, kitchenRequestId, orderId, '');
    end;

    procedure RevokeServing(restaurantId: Text; kitchenRequestId: BigInteger; orderId: BigInteger; lastServerId: Text) Response: Text
    var
        KDSFrontendAssistImpl: Codeunit "NPR KDS Frontend Assist. Impl.";
    begin
        KDSFrontendAssistImpl.RunKitchenAction(restaurantId, '', kitchenRequestId, orderId, _KitchenAction::"Revoke Serving", lastServerId).WriteTo(Response);
    end;

    [Obsolete('Use the overload with the "lastServerId" parameter and a return value instead', 'NPR35.0')]
    procedure CreateOrderReadyNotifications(orderId: BigInteger)
    begin
        CreateOrderReadyNotifications(orderId, '');
    end;

    procedure CreateOrderReadyNotifications(orderId: BigInteger; lastServerId: Text) Response: Text
    var
        KDSFrontendAssistImpl: Codeunit "NPR KDS Frontend Assist. Impl.";
    begin
        KDSFrontendAssistImpl.CreateOrderReadyNotifications(orderId, lastServerId).WriteTo(Response);
    end;
}