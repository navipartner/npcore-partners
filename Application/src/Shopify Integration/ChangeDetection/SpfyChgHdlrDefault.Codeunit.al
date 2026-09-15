codeunit 6151188 "NPR Spfy Chg Hdlr Default" implements "NPR Spfy Change Handler"
{
    Access = Internal;

    procedure ProcessChange(var DetectedChange: Codeunit "NPR Spfy Detected Change"): Boolean
    var
        NoHandlerErr: Label 'No Shopify change handler is mapped for table %1. This is a programming bug.', Comment = '%1 = table number';
    begin
        // Only reached if a polled table has no IntegrationAreaForTable mapping — a misconfiguration; fail loudly.
        Error(NoHandlerErr, DetectedChange.TableNo());
    end;
}
