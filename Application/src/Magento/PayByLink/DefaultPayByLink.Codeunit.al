codeunit 6184959 "NPR Default PayByLink" implements "NPR Pay by Link"
{
    Access = Internal;
    procedure SetDocument(RecVariant: Variant)
    begin
    end;

    procedure SetShowDialog()
    begin
    end;

    procedure IssuePayByLink()
    begin
    end;

    procedure CancelPayByLink(var PaymentLine: Record "NPR Magento Payment Line")
    begin
    end;
}