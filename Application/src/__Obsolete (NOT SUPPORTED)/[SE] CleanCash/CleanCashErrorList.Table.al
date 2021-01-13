table 6184501 "NPR CleanCash Error List"
{
    Caption = 'CleanCash Error List';
    DataClassification = CustomerContent;
    ObsoleteReason = 'This table is not used anymore';
    ObsoleteState = Removed;
    ObsoleteTag = 'CleanCash To AL';

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(2; "Date"; Date)
        {
            Caption = 'Date';
            DataClassification = CustomerContent;
        }
        field(3; "Time"; Time)
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

