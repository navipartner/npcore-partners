codeunit 6151224 "NPR Spfy Task Send Bnd Impl" implements "NPR Spfy Task Send Boundary"
{
    Access = Internal;

    procedure Dispatch(var SpfyTaskWork: Record "NPR Spfy Task"; var ErrorText: Text): Boolean
    var
        Sentry: Codeunit "NPR Sentry";
        UnmappedTaskKindErr: Label 'Shopify task list has no send codeunit mapped for table %1. This is a programming bug, not a user error. Please contact system vendor.', Locked = true;
    begin
        Clear(ErrorText);
        ClearLastError();
        case SpfyTaskWork."Table No." of
            Database::Item,
            Database::"Item Variant",
            Database::"Inventory Buffer",
            Database::"NPR Spfy Tag Update Request",
            Database::"NPR Spfy Inventory Level",
            Database::"NPR Spfy Item Price",
            Database::"NPR Spfy Inv Item Location":
                begin
                    if Codeunit.Run(Codeunit::"NPR Spfy Task Send Items&Inv", SpfyTaskWork) then
                        exit(true);
                    ErrorText := GetLastErrorText();
                    exit(false);
                end;
            Database::Customer:
                begin
                    if Codeunit.Run(Codeunit::"NPR Spfy Task Send Customers", SpfyTaskWork) then
                        exit(true);
                    ErrorText := GetLastErrorText();
                    exit(false);
                end;
            Database::"NPR Spfy Entity Metafield":
                begin
                    if Codeunit.Run(Codeunit::"NPR Spfy Task Send Metafields", SpfyTaskWork) then
                        exit(true);
                    ErrorText := GetLastErrorText();
                    exit(false);
                end;
            Database::"NPR NpRv Voucher",
            Database::"NPR NpRv Voucher Entry",
            Database::"NPR NpRv Arch. Voucher":
                begin
                    if Codeunit.Run(Codeunit::"NPR Spfy Task Send Voucher", SpfyTaskWork) then
                        exit(true);
                    ErrorText := GetLastErrorText();
                    exit(false);
                end;
            Database::"Sales Shipment Header",
            Database::"Return Receipt Header":
                begin
                    if Codeunit.Run(Codeunit::"NPR Spfy Task Send Fulfillment", SpfyTaskWork) then
                        exit(true);
                    ErrorText := GetLastErrorText();
                    exit(false);
                end;
            Database::"NPR NpCs Document":
                begin
                    if Codeunit.Run(Codeunit::"NPR Spfy Task Ready For Pickup", SpfyTaskWork) then
                        exit(true);
                    ErrorText := GetLastErrorText();
                    exit(false);
                end;
            Database::"Sales Header":
                begin
                    if Codeunit.Run(Codeunit::"NPR Spfy Task Close Order", SpfyTaskWork) then
                        exit(true);
                    ErrorText := GetLastErrorText();
                    exit(false);
                end;
            Database::"Sales Invoice Header",
            Database::"NPR Magento Payment Line":
                begin
                    if Codeunit.Run(Codeunit::"NPR Spfy Task Capture Payment", SpfyTaskWork) then
                        exit(true);
                    ErrorText := GetLastErrorText();
                    exit(false);
                end;
            Database::"NPR POS Entry":
                begin
                    if Codeunit.Run(Codeunit::"NPR Spfy Task Send POS Entry", SpfyTaskWork) then
                        exit(true);
                    ErrorText := GetLastErrorText();
                    exit(false);
                end;
            else begin
                ErrorText := StrSubstNo(UnmappedTaskKindErr, SpfyTaskWork."Table No.");
                Sentry.InitScopeAndTransaction('Shopify task list unmapped task kind', 'bc.spfy.task_list.unmapped_kind');
                Sentry.AddError(ErrorText);
                Sentry.FinalizeScope();
                exit(false);
            end;
        end;
    end;
}
