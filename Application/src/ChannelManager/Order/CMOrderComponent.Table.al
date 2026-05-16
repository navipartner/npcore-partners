table 6059930 "NPR CMOrderComponent"
{
    Access = Internal;
    Caption = 'Channel Manager Order Component';
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

        field(3; ComponentNo; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Component No.';
        }

        field(10; ComponentItemNo; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Component Item No.';
            TableRelation = Item."No.";
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
    }

    keys
    {
        key(Key1; OrderId, LineNo, ComponentNo)
        {
            Clustered = true;
        }
    }
}
