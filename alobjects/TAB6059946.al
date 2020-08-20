table 6059946 "CashKeeper Transaction"
{
    // NPR5.29\CLVA\20161108 CASE 244944 Object Created
    // NPR5.30/TJ  /20170215 CASE 265504 Changed ENU captions on fields with word Register in their name
    // NPR5.40/CLVA/20180307 CASE 291921 Added field "Payment Type"

    Caption = 'CashKeeper Transaction';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Transaction No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Transaction No.';
            DataClassification = CustomerContent;
        }
        field(2; "Register No."; Code[10])
        {
            Caption = 'Cash Register No.';
            DataClassification = CustomerContent;
        }
        field(3; "Sales Ticket No."; Code[20])
        {
            Caption = 'Sales Ticket No.';
            DataClassification = CustomerContent;
        }
        field(4; "Sales Line No."; Integer)
        {
            Caption = 'Sales Line No.';
            DataClassification = CustomerContent;
        }
        field(10; "CK Error Code"; Integer)
        {
            Caption = 'CK Error Code';
            DataClassification = CustomerContent;
        }
        field(11; "CK Error Description"; Text[250])
        {
            Caption = 'CK Error Description';
            DataClassification = CustomerContent;
        }
        field(13; "Order ID"; Code[30])
        {
            Caption = 'Order ID';
            DataClassification = CustomerContent;
        }
        field(14; Amount; Decimal)
        {
            Caption = 'Amount';
            DataClassification = CustomerContent;
        }
        field(17; "Action"; Option)
        {
            Caption = 'Action';
            DataClassification = CustomerContent;
            OptionCaption = 'Capture,Pay,Setup';
            OptionMembers = Capture,Pay,Setup;
        }
        field(18; "Value In Cents"; Integer)
        {
            Caption = 'Value In Cents';
            DataClassification = CustomerContent;
        }
        field(19; "Paid In Value"; Integer)
        {
            Caption = 'Paid In Value';
            DataClassification = CustomerContent;
        }
        field(20; "Paid Out Value"; Integer)
        {
            Caption = 'Paid Out Value';
            DataClassification = CustomerContent;
        }
        field(50; Status; Option)
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
            OptionCaption = ''''',Ok,Error,Cancelled';
            OptionMembers = "''",Ok,Error,Cancelled;
        }
        field(51; Reversed; Boolean)
        {
            Caption = 'Reversed';
            DataClassification = CustomerContent;
        }
        field(52; "Payment Type"; Code[20])
        {
            Caption = 'Payment Type';
            DataClassification = CustomerContent;
            TableRelation = "Payment Type POS"."No.";
        }
    }

    keys
    {
        key(Key1; "Transaction No.")
        {
        }
        key(Key2; "Sales Ticket No.")
        {
        }
    }

    fieldgroups
    {
    }

    var
        Text10: Label 'Idle, no payment requests in queue';
        Text20: Label 'Payment request is sent to customer';
        Text30: Label 'Awaiting customer check-in';
        Text40: Label 'Customer has cancelled the payment request';
        Text50: Label 'Error';
        Text60: Label 'Awaiting a token-related payment request update';
        Text70: Label 'Awaiting a payment request by the customer';
        Text80: Label 'Payment request is accepted by the customer';
        Text100: Label 'Payment is confirmed';

    procedure GetPaymentStatusText(): Text
    begin
        case Status of
            //-MbP2.00
            //  10: EXIT('Idle');
            //  20: EXIT('Issued');
            //  30: EXIT('Await Check-In');
            //  40: EXIT('Cancel');
            //  50: EXIT('Error');
            //  60: EXIT('Await Token Recalc');
            //  70: EXIT('Await Payment Request');
            //  80: EXIT('Payment Accepted');
            //  100: EXIT('Done');
            //  ELSE
            //    EXIT('');
            0, 10:
                exit(Text10);
            20:
                exit(Text20);
            30:
                exit(Text30);
            40:
                exit(Text40);
            50:
                exit(Text50);
            60:
                exit(Text60);
            70:
                exit(Text70);
            80:
                exit(Text80);
            100:
                exit(Text100);
        //+MbP2.00
        end;
    end;
}

