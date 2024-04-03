codeunit 6184835 "NPR KDS Frontend Assistant"
{
    Access = Public;

    var
        _KitchenAction: Option "Accept Change","Set Production Not Started","Start Production","End Production","Set OnHold","Resume","Set Served","Revoke Serving";

    procedure RefreshCustomerDisplayKitchenOrders(restaurantId: Text) Response: Text
    var
        KDSFrontendAssistImpl: Codeunit "NPR KDS Frontend Assist. Impl.";
    begin
        KDSFrontendAssistImpl.RefreshCustomerDisplayKitchenOrders(restaurantId).WriteTo(Response);
    end;

    procedure RefreshKDSData(restaurantId: Text; stationId: Text; includeFinished: Boolean; startingFrom: DateTime) Response: Text
    var
        KDSFrontendAssistImpl: Codeunit "NPR KDS Frontend Assist. Impl.";
    begin
        KDSFrontendAssistImpl.RefreshKDSData(restaurantId, stationId, includeFinished, startingFrom).WriteTo(Response);
    end;

    procedure GetSetups() Response: Text
    var
        KDSFrontendAssistImpl: Codeunit "NPR KDS Frontend Assist. Impl.";
    begin
        KDSFrontendAssistImpl.GetSetups().WriteTo(Response);
    end;

    procedure AcceptChange(restaurantId: Text; stationId: Text; kitchenRequestId: BigInteger; orderId: BigInteger)
    var
        KDSFrontendAssistImpl: Codeunit "NPR KDS Frontend Assist. Impl.";
    begin
        KDSFrontendAssistImpl.RunKitchenAction(restaurantId, stationId, kitchenRequestId, orderId, _KitchenAction::"Accept Change");
    end;

    procedure SetProductionNotStarted(restaurantId: Text; stationId: Text; kitchenRequestId: BigInteger; orderId: BigInteger)
    var
        KDSFrontendAssistImpl: Codeunit "NPR KDS Frontend Assist. Impl.";
    begin
        KDSFrontendAssistImpl.RunKitchenAction(restaurantId, stationId, kitchenRequestId, orderId, _KitchenAction::"Set Production Not Started");
    end;

    procedure SetProductionStarted(restaurantId: Text; stationId: Text; kitchenRequestId: BigInteger; orderId: BigInteger)
    var
        KDSFrontendAssistImpl: Codeunit "NPR KDS Frontend Assist. Impl.";
    begin
        KDSFrontendAssistImpl.RunKitchenAction(restaurantId, stationId, kitchenRequestId, orderId, _KitchenAction::"Start Production");
    end;

    procedure SetProductionFinished(restaurantId: Text; stationId: Text; kitchenRequestId: BigInteger; orderId: BigInteger)
    var
        KDSFrontendAssistImpl: Codeunit "NPR KDS Frontend Assist. Impl.";
    begin
        KDSFrontendAssistImpl.RunKitchenAction(restaurantId, stationId, kitchenRequestId, orderId, _KitchenAction::"End Production");
    end;

    procedure SetOnHold(restaurantId: Text; stationId: Text; kitchenRequestId: BigInteger; orderId: BigInteger)
    var
        KDSFrontendAssistImpl: Codeunit "NPR KDS Frontend Assist. Impl.";
    begin
        KDSFrontendAssistImpl.RunKitchenAction(restaurantId, stationId, kitchenRequestId, orderId, _KitchenAction::"Set OnHold");
    end;

    procedure Resume(restaurantId: Text; stationId: Text; kitchenRequestId: BigInteger; orderId: BigInteger)
    var
        KDSFrontendAssistImpl: Codeunit "NPR KDS Frontend Assist. Impl.";
    begin
        KDSFrontendAssistImpl.RunKitchenAction(restaurantId, stationId, kitchenRequestId, orderId, _KitchenAction::"Resume");
    end;

    procedure SetServed(restaurantId: Text; kitchenRequestId: BigInteger; orderId: BigInteger)
    var
        KDSFrontendAssistImpl: Codeunit "NPR KDS Frontend Assist. Impl.";
    begin
        KDSFrontendAssistImpl.RunKitchenAction(restaurantId, '', kitchenRequestId, orderId, _KitchenAction::"Set Served");
    end;

    procedure RevokeServing(restaurantId: Text; kitchenRequestId: BigInteger; orderId: BigInteger)
    var
        KDSFrontendAssistImpl: Codeunit "NPR KDS Frontend Assist. Impl.";
    begin
        KDSFrontendAssistImpl.RunKitchenAction(restaurantId, '', kitchenRequestId, orderId, _KitchenAction::"Revoke Serving");
    end;

    procedure CreateOrderReadyNotifications(orderId: BigInteger)
    var
        KDSFrontendAssistImpl: Codeunit "NPR KDS Frontend Assist. Impl.";
    begin
        KDSFrontendAssistImpl.CreateOrderReadyNotifications(orderId);
    end;
}