codeunit 6184957 "NPR Unknown PayByLink" implements "NPR Pay by Link"
{
    Access = Internal;
    procedure SetDocument(RecVariant: Variant)
    begin
        Error('Cannot register unknown Pay By Link');
    end;

    procedure SetShowDialog()
    begin
        Error('Cannot register unknown Pay By Link');
    end;

    procedure IssuePayByLink()
    begin
        Error('Cannot register unknown Pay By Link');
    end;

    procedure CancelPayByLink(var PaymentLine: Record "NPR Magento Payment Line")
    begin
        Error('Cannot register unknown Pay By Link');
    end;
}