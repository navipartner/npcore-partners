table 6184501 "CleanCash Error List"
{
    // NPR4.21/JHL/20160302 CASE 222417 Table created to catch error received from CleanCash server
    // NPR5.29/JHL/20161028 CASE 256695 Change the Caption on field to be default
    // NPR5.31/JHL/20170223 CASE 256695 Removed space in option value, in field EventResponse

    Caption = 'CleanCash Error List';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(2; Date; Date)
        {
            Caption = 'Date';
            DataClassification = CustomerContent;
        }
        field(3; Time; Time)
        {
            Caption = 'Time';
            DataClassification = CustomerContent;
        }
        field(4; "Object Type"; Option)
        {
            Caption = 'Object Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Table,Page,Report,Codeunit, Query,XMLport';
            OptionMembers = "Table","Page","Report","Codeunit"," Query","XMLport";
        }
        field(5; "Object No."; Integer)
        {
            Caption = 'Object No.';
            DataClassification = CustomerContent;
        }
        field(6; "Object Name"; Text[50])
        {
            Caption = 'Object Name';
            DataClassification = CustomerContent;
        }
        field(7; EventResponse; Option)
        {
            Caption = 'Event Response';
            DataClassification = CustomerContent;
            OptionCaption = 'NotSet,FailOpen,FailCheckStatusEX,FailRegisterPos,FailCheckStatus,FailStartReceipt,FailSendReceiptEX,FailSendReceipt,ReceiptSend';
            OptionMembers = NotSet,FailOpen,FailCheckStatusEX,FailRegisterPos,FailCheckStatus,FailStartReceipt,FailSendReceiptEX,FailSendReceipt,ReceiptSend;
        }
        field(8; "Enum Type"; Text[50])
        {
            Caption = 'Enum Type';
            DataClassification = CustomerContent;
        }
        field(9; "Error Text"; Text[200])
        {
            Caption = 'Error Text';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
    }

    fieldgroups
    {
    }
}

