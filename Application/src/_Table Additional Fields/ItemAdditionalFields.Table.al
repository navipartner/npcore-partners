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
    }

    keys
    {
        key(Key1; Id)
        {
            Clustered = true;
        }
    }
}