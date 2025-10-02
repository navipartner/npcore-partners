#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
codeunit 6248545 "NPR Inc Ecom Sales Webhooks"
{
    Access = Internal;

    [ExternalBusinessEvent('salesOrder_created', 'SalesOrder Created', 'Triggered when an IncEcom Sales Order is created', EventCategory::"NPR Sales Headers", '1.0')]
    procedure OnSalesOrderCreated(salesOrderId: Guid; externalDocumentNo: Code[35]; nprExternalOrderNo: Code[20]; ecommerceDocumentId: Guid)
    begin
    end;

    [ExternalBusinessEvent('salesReturnOrder_created', 'Sales Return Order Created', 'Triggered when an IncEcom Sales Return Order is created', EventCategory::"NPR Sales Headers", '1.0')]
    procedure OnSalesReturnOrderCreated(salesReturnOrderId: Guid; externalDocumentNo: Code[35]; nprExternalOrderNo: Code[20]; ecommerceDocumentId: Guid)
    begin
    end;

    [ExternalBusinessEvent('salesOrder_posted', 'SalesOrder Posted', 'Triggered when the related Sales Order is posted', EventCategory::"NPR Sales Headers", '1.0')]
    procedure OnSalesOrderPosted(salesOrderId: Guid; externalDocumentNo: Code[35]; nprExternalOrderNo: Code[20]; ecommerceDocumentId: Guid; postedStatus: Text[50])
    begin
    end;

    [ExternalBusinessEvent('salesReturnOrder_posted', 'Sales Return Order Posted', 'Triggered when the related Sales Return Order is posted', EventCategory::"NPR Sales Headers", '1.0')]
    procedure OnSalesReturnOrderPosted(salesReturnOrderId: Guid; externalDocumentNo: Code[35]; nprExternalOrderNo: Code[20]; ecommerceDocumentId: Guid; postedStatus: Text[50])
    begin
    end;

    [ExternalBusinessEvent('salesOrder_cancelled', 'SalesOrder Cancelled', 'Triggered when the related Sales Order is Cancelled', EventCategory::"NPR Sales Headers", '1.0')]
    procedure OnSalesOrderCancelled(salesOrderId: Guid; externalDocumentNo: Code[35]; nprExternalOrderNo: Code[20]; ecommerceDocumentId: Guid)
    begin
    end;

    [ExternalBusinessEvent('salesReturnOrder_cancelled', 'Sales Return Order Cancelled', 'Triggered when the related Sales Return Order is Cancelled', EventCategory::"NPR Sales Headers", '1.0')]
    procedure OnSalesReturnOrderCancelled(salesReturnOrderId: Guid; externalDocumentNo: Code[35]; nprExternalOrderNo: Code[20]; ecommerceDocumentId: Guid)
    begin
    end;
}
#endif