interface "NPR Pay by Link"
{
    procedure SetDocument(RecVariant: Variant);
    procedure SetShowDialog();
    procedure IssuePayByLink();
    procedure CancelPayByLink(var PaymentLine: Record "NPR Magento Payment Line")
}