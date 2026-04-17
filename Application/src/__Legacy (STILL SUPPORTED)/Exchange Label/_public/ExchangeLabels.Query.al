query 6014437 "NPR Exchange Labels"
{
    Caption = 'Exchange Labels';
    QueryType = Normal;
    ObsoleteState = Pending;
    ObsoleteTag = '2026-01-29';
    ObsoleteReason = 'This module is no longer being maintained';

    elements
    {
        dataitem(NPRExchangeLabel; "NPR Exchange Label")
        {
            column(Barcode; Barcode) { }
            column(BatchNo; "Batch No.") { }
            column(CompanyName; "Company Name") { }
            column(ItemNo; "Item No.") { }
            column(No; "No.") { }
            column(NoSeries; "No. Series") { }
            column(PackagedBatch; "Packaged Batch") { }
            column(PrintedDate; "Printed Date") { }
            column(Quantity; Quantity) { }
            column(RegisterNo; "Register No.") { }
            column(RetailCrossReferenceNo; "Retail Cross Reference No.") { }
            column(SalesHeaderNo; "Sales Header No.") { }
            column(SalesHeaderType; "Sales Header Type") { }
            column(SalesLineNo; "Sales Line No.") { }
            column(SalesPriceInclVat; "Sales Price Incl. Vat") { }
            column(SalesTicketNo; "Sales Ticket No.") { }
            column(StoreID; "Store ID") { }
            column(SystemCreatedAt; SystemCreatedAt) { }
            column(SystemCreatedBy; SystemCreatedBy) { }
            column(SystemId; SystemId) { }
            column(SystemModifiedAt; SystemModifiedAt) { }
            column(SystemModifiedBy; SystemModifiedBy) { }
            column(TableNo; "Table No.") { }
            column(UnitPrice; "Unit Price") { }
            column(UnitofMeasure; "Unit of Measure") { }
            column(ValidFrom; "Valid From") { }
            column(ValidTo; "Valid To") { }
            column(VariantCode; "Variant Code") { }
        }
    }
}