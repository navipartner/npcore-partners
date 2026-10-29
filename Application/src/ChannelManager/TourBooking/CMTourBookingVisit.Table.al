table 6060037 "NPR CMTourBookingVisit"
{
    Access = Internal;
    Caption = 'Tour Booking Visit';
    DataClassification = CustomerContent;
    TableType = Temporary;

    fields
    {
        field(1; LineNo; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Line No.';
        }
        field(2; SubLineNo; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Sub-line No.';
        }
        field(10; OrderId; Guid)
        {
            DataClassification = CustomerContent;
            Caption = 'Order Id';
        }
        field(20; ItemNo; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Item No.';
        }
        field(30; Description; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Description';
        }
        field(40; Indentation; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Indentation';
        }
        field(50; IsComponent; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Is Component';
        }
        field(60; VisitDate; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Visit Date';
        }
        field(61; VisitTime; Time)
        {
            DataClassification = CustomerContent;
            Caption = 'Visit Time';
        }
    }

    keys
    {
        key(Key1; LineNo, SubLineNo)
        {
            Clustered = true;
        }
    }
}
