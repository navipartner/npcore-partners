table 6014540 "NPR MobilePayV10 Refund"
{
    DataClassification = CustomerContent;
    Caption = 'MobilePayV10 Refund Detail';
    TableType = Temporary;

    fields
    {
        field(1; RefundId; Text[40])
        {
            DataClassification = CustomerContent;
        }
        field(5; PaymentId; Text[40])
        {
            DataClassification = CustomerContent;
        }
        field(20; RefundOrderId; Text[100])
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
        field(70; Status; Enum "NPR MobilePayV10 Result Code")
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
        key(PK; RefundId)
        {
            Clustered = true;
        }
    }
}