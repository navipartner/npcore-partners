table 6014543 "NPR MobilePayV10 Payment"
{
    DataClassification = CustomerContent;
    Caption = 'MobilePayV10 Payment Detail';
    TableType = Temporary;

    fields
    {
        field(1; PaymentId; Text[40])
        {
            DataClassification = CustomerContent;
        }
        field(10; PosId; Text[40])
        {
            DataClassification = CustomerContent;
        }
        field(20; OrderId; Text[100])
        {
            DataClassification = CustomerContent;
        }
        field(30; Amount; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(40; CurrencyCode; Code[10])
        {
            DataClassification = CustomerContent;
        }
        field(50; MerchantPaymentLabel; Text[100])
        {
            DataClassification = CustomerContent;
        }
        field(60; PlannedCaptureDelay; Text[50])
        {
            DataClassification = CustomerContent;
        }
        field(70; Status; Enum "NPR MobilePayV10 Result Code")
        {
            DataClassification = CustomerContent;
        }
        field(80; PaymentExpiresAt; Text[50])
        {
            DataClassification = CustomerContent;
        }
        field(90; PollDelayInMs; Integer)
        {
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; PaymentId)
        {
            Clustered = true;
        }
    }
}
