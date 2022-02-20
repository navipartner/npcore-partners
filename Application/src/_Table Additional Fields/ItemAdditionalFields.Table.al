table 6014635 "NPR Item Additional Fields"
{
    Access = Internal;
    Caption = 'Item Table Relation';
    DataClassification = CustomerContent;

    fields
    {
        field(1; Id; Guid)
        {
            Caption = 'Item No.';
            DataClassification = CustomerContent;
        }
        field(10; "Item Addon No."; Code[20])
        {
            Caption = 'Item AddOn No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR NpIa Item AddOn";
        }
        field(30; "NPRE Item Routing Profile"; Code[20])
        {
            Caption = 'Rest. Item Routing Profile';
            DataClassification = CustomerContent;
            TableRelation = "NPR NPRE Item Routing Profile";
        }
    }

    keys
    {
        key(Key1; Id)
        {
            Clustered = true;
        }
    }
}