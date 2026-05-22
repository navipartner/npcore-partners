table 6059929 "NPR CMOrderLine"
{
    Access = Internal;
    Caption = 'OTA Channel Manager Order Line';
    DataClassification = CustomerContent;

    fields
    {
        field(1; OrderId; Guid)
        {
            DataClassification = CustomerContent;
            Caption = 'Order Id';
            NotBlank = true;
            TableRelation = "NPR CMOrder".OrderId;
        }

        field(2; LineNo; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Line No.';
        }

        field(10; ItemNo; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Item No.';
            TableRelation = Item."No.";
        }

        field(15; IsPackage; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Is Package';
        }

        field(16; IsGroupTicket; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Is Group Ticket';
        }

        field(20; Quantity; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Quantity';
            MinValue = 1;
            InitValue = 1;
        }

        field(30; VisitDate; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Visit Date';
        }

        field(31; VisitTime; Time)
        {
            DataClassification = CustomerContent;
            Caption = 'Visit Time';
        }

        field(40; NotificationAddress; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Notification Address';
            ExtendedDatatype = EMail;
        }

        field(50; Name; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Name';
        }

        field(60; Language; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Language';
            TableRelation = Language.Code;
        }
    }

    keys
    {
        key(Key1; OrderId, LineNo)
        {
            Clustered = true;
        }

        key(Key2; ItemNo)
        {
            Clustered = false;
        }
    }
}
