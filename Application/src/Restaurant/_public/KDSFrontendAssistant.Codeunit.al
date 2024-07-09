codeunit 6184835 "NPR KDS Frontend Assistant"
{
    Access = Public;

    var
        _KitchenAction: Option "Accept Change","Set Production Not Started","Start Production","End Production","Set OnHold","Resume","Set Served","Revoke Serving";

    [Obsolete('Use the overload with the "lastServerId" parameter instead', '2024-06-28')]
    procedure RefreshCustomerDisplayKitchenOrders(restaurantId: Text) Response: Text
    begin
        Response := RefreshCustomerDisplayKitchenOrdersV2(restaurantId, '');
    end;

    procedure RefreshCustomerDisplayKitchenOrdersV2(restaurantId: Text; lastServerId: Text) Response: Text
    var
        KDSFrontendAssistImpl: Codeunit "NPR KDS Frontend Assist. Impl.";
    begin
        KDSFrontendAssistImpl.RefreshCustomerDisplayKitchenOrders(restaurantId, lastServerId).WriteTo(Response);
    end;

    [Obsolete('Use the overload with the "lastServerId" parameter instead', '2024-06-28')]
    procedure RefreshKDSData(restaurantId: Text; stationId: Text; includeFinished: Boolean; startingFrom: DateTime) Response: Text
    begin
        Response := RefreshKDSDataV2(restaurantId, stationId, includeFinished, startingFrom, '');
    end;

    procedure RefreshKDSDataV2(restaurantId: Text; stationId: Text; includeFinished: Boolean; startingFrom: DateTime; lastServerId: Text) Response: Text
    var
        KDSFrontendAssistImpl: Codeunit "NPR KDS Frontend Assist. Impl.";
    begin
        KDSFrontendAssistImpl.RefreshKDSData(restaurantId, stationId, includeFinished, startingFrom, lastServerId).WriteTo(Response);
    end;

    [Obsolete('Use the overload with the "lastServerId" parameter instead', '2024-06-28')]
    procedure GetFinishedOrders(restaurantId: Text; startingFrom: DateTime) Response: Text
    begin
        Response := GetFinishedOrdersV2(restaurantId, startingFrom, '');
    end;

    procedure GetFinishedOrdersV2(restaurantId: Text; startingFrom: DateTime; lastServerId: Text) Response: Text
    var
        KDSFrontendAssistImpl: Codeunit "NPR KDS Frontend Assist. Impl.";
    begin
        KDSFrontendAssistImpl.GetFinishedOrders(restaurantId, startingFrom, lastServerId).WriteTo(Response);
    end;

    [Obsolete('Use the overload with the "lastServerId" parameter instead', '2024-06-28')]
    procedure GetSetups() Response: Text
    begin
        Response := GetSetupsV2('');
    end;

    procedure GetSetupsV2(lastServerId: Text) Response: Text
    var
        KDSFrontendAssistImpl: Codeunit "NPR KDS Frontend Assist. Impl.";
    begin
        KDSFrontendAssistImpl.GetSetups(lastServerId).WriteTo(Response);
    end;

    [Obsolete('Use the overload with the "lastServerId" parameter and a return value instead', '2024-06-28')]
    procedure AcceptChange(restaurantId: Text; stationId: Text; kitchenRequestId: BigInteger; orderId: BigInteger)
    begin
        AcceptChangeV2(restaurantId, stationId, kitchenRequestId, orderId, '');
    end;

    procedure AcceptChangeV2(restaurantId: Text; stationId: Text; kitchenRequestId: BigInteger; orderId: BigInteger; lastServerId: Text) Response: Text
    var
        KDSFrontendAssistImpl: Codeunit "NPR KDS Frontend Assist. Impl.";
    begin
        KDSFrontendAssistImpl.RunKitchenAction(restaurantId, stationId, kitchenRequestId, orderId, _KitchenAction::"Accept Change", lastServerId).WriteTo(Response);
    end;

    [Obsolete('Use the overload with the "lastServerId" parameter and a return value instead', '2024-06-28')]
    procedure SetProductionNotStarted(restaurantId: Text; stationId: Text; kitchenRequestId: BigInteger; orderId: BigInteger)
    begin
        SetProductionNotStartedV2(restaurantId, stationId, kitchenRequestId, orderId, '');
    end;

    procedure SetProductionNotStartedV2(restaurantId: Text; stationId: Text; kitchenRequestId: BigInteger; orderId: BigInteger; lastServerId: Text) Response: Text
    var
        KDSFrontendAssistImpl: Codeunit "NPR KDS Frontend Assist. Impl.";
    begin
        KDSFrontendAssistImpl.RunKitchenAction(restaurantId, stationId, kitchenRequestId, orderId, _KitchenAction::"Set Production Not Started", lastServerId).WriteTo(Response);
    end;

    [Obsolete('Use the overload with the "lastServerId" parameter and a return value instead', '2024-06-28')]
    procedure SetProductionStarted(restaurantId: Text; stationId: Text; kitchenRequestId: BigInteger; orderId: BigInteger)
    begin
        SetProductionStartedV2(restaurantId, stationId, kitchenRequestId, orderId, '');
    end;

    procedure SetProductionStartedV2(restaurantId: Text; stationId: Text; kitchenRequestId: BigInteger; orderId: BigInteger; lastServerId: Text) Response: Text
    var
        KDSFrontendAssistImpl: Codeunit "NPR KDS Frontend Assist. Impl.";
    begin
        KDSFrontendAssistImpl.RunKitchenAction(restaurantId, stationId, kitchenRequestId, orderId, _KitchenAction::"Start Production", lastServerId).WriteTo(Response);
    end;

    [Obsolete('Use the overload with the "lastServerId" parameter and a return value instead', '2024-06-28')]
    procedure SetProductionFinished(restaurantId: Text; stationId: Text; kitchenRequestId: BigInteger; orderId: BigInteger)
    begin
        SetProductionFinishedV2(restaurantId, stationId, kitchenRequestId, orderId, '');
    end;

    procedure SetProductionFinishedV2(restaurantId: Text; stationId: Text; kitchenRequestId: BigInteger; orderId: BigInteger; lastServerId: Text) Response: Text
    var
        KDSFrontendAssistImpl: Codeunit "NPR KDS Frontend Assist. Impl.";
    begin
        KDSFrontendAssistImpl.RunKitchenAction(restaurantId, stationId, kitchenRequestId, orderId, _KitchenAction::"End Production", lastServerId).WriteTo(Response);
    end;

    [Obsolete('Use the overload with the "lastServerId" parameter and a return value instead', '2024-06-28')]
    procedure SetOnHold(restaurantId: Text; stationId: Text; kitchenRequestId: BigInteger; orderId: BigInteger)
    begin
        SetOnHoldV2(restaurantId, stationId, kitchenRequestId, orderId, '');
    end;

    procedure SetOnHoldV2(restaurantId: Text; stationId: Text; kitchenRequestId: BigInteger; orderId: BigInteger; lastServerId: Text) Response: Text
    var
        KDSFrontendAssistImpl: Codeunit "NPR KDS Frontend Assist. Impl.";
    begin
        KDSFrontendAssistImpl.RunKitchenAction(restaurantId, stationId, kitchenRequestId, orderId, _KitchenAction::"Set OnHold", lastServerId).WriteTo(Response);
    end;

    [Obsolete('Use the overload with the "lastServerId" parameter and a return value instead', '2024-06-28')]
    procedure Resume(restaurantId: Text; stationId: Text; kitchenRequestId: BigInteger; orderId: BigInteger)
    begin
        ResumeV2(restaurantId, stationId, kitchenRequestId, orderId, '');
    end;

    procedure ResumeV2(restaurantId: Text; stationId: Text; kitchenRequestId: BigInteger; orderId: BigInteger; lastServerId: Text) Response: Text
    var
        KDSFrontendAssistImpl: Codeunit "NPR KDS Frontend Assist. Impl.";
    begin
        KDSFrontendAssistImpl.RunKitchenAction(restaurantId, stationId, kitchenRequestId, orderId, _KitchenAction::"Resume", lastServerId).WriteTo(Response);
    end;

    [Obsolete('Use the overload with the "lastServerId" parameter and a return value instead', '2024-06-28')]
    procedure SetServed(restaurantId: Text; kitchenRequestId: BigInteger; orderId: BigInteger)
    begin
        SetServedV2(restaurantId, kitchenRequestId, orderId, '');
    end;

    procedure SetServedV2(restaurantId: Text; kitchenRequestId: BigInteger; orderId: BigInteger; lastServerId: Text) Response: Text
    var
        KDSFrontendAssistImpl: Codeunit "NPR KDS Frontend Assist. Impl.";
    begin
        KDSFrontendAssistImpl.RunKitchenAction(restaurantId, '', kitchenRequestId, orderId, _KitchenAction::"Set Served", lastServerId).WriteTo(Response);
    end;

    [Obsolete('Use the overload with the "lastServerId" parameter and a return value instead', '2024-06-28')]
    procedure RevokeServing(restaurantId: Text; kitchenRequestId: BigInteger; orderId: BigInteger)
    begin
        RevokeServingV2(restaurantId, kitchenRequestId, orderId, '');
    end;

    procedure RevokeServingV2(restaurantId: Text; kitchenRequestId: BigInteger; orderId: BigInteger; lastServerId: Text) Response: Text
    var
        KDSFrontendAssistImpl: Codeunit "NPR KDS Frontend Assist. Impl.";
    begin
        KDSFrontendAssistImpl.RunKitchenAction(restaurantId, '', kitchenRequestId, orderId, _KitchenAction::"Revoke Serving", lastServerId).WriteTo(Response);
    end;

    [Obsolete('Use the overload with the "lastServerId" parameter and a return value instead', '2024-06-28')]
    procedure CreateOrderReadyNotifications(orderId: BigInteger)
    begin
        CreateOrderReadyNotificationsV2(orderId, '');
    end;

    procedure CreateOrderReadyNotificationsV2(orderId: BigInteger; lastServerId: Text) Response: Text
    var
        KDSFrontendAssistImpl: Codeunit "NPR KDS Frontend Assist. Impl.";
    begin
        KDSFrontendAssistImpl.CreateOrderReadyNotifications(orderId, lastServerId).WriteTo(Response);
    end;
}