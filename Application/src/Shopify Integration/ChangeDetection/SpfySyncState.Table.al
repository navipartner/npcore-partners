table 6059948 "NPR Spfy Sync State"
{
    Access = Internal;
    Caption = 'Shopify Sync State';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Table No."; Integer)
        {
            Caption = 'Table No.';
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Table));
        }
        field(2; "Entity System Id"; Guid)
        {
            Caption = 'Entity System Id';
        }
        field(3; "Shopify Store Code"; Code[20])
        {
            Caption = 'Shopify Store Code';
        }
        field(10; Parameters; Blob)
        {
            Caption = 'Parameters';
        }
        field(11; "Payload Version"; Integer)
        {
            Caption = 'Payload Version';
        }
    }

    keys
    {
        key(PK; "Table No.", "Entity System Id", "Shopify Store Code")
        {
            Clustered = true;
        }
    }
}
