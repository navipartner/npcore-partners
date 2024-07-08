enum 6014635 "NPR Vipps Mp WebhookEvents"
{
    Extensible = false;
#if not BC17
    Access = Internal;
#endif

    value(0; "EPAYMENT_CREATED")
    {
    }
    value(1; "EPAYMENT_ABORTED")
    {
    }
    value(2; "EPAYMENT_EXPIRED")
    {
    }
    value(3; "EPAYMENT_CANCELLED")
    {
    }
    value(4; "EPAYMENT_CAPTURED")
    {
    }
    value(5; "EPAYMENT_REFUNDED")
    {
    }
    value(6; "EPAYMENT_AUTHORIZED")
    {
    }
    value(7; "EPAYMENT_TERMINATED")
    {
    }
    value(8; "QR_CHECKED_IN")
    {
    }
}