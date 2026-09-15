table 6151227 "NPR Spfy Deletion Log"
{
    Access = Internal;
    Caption = 'Shopify Deletion Log';
    DataClassification = CustomerContent;
    DataPerCompany = true;

    fields
    {
        field(1; "Entry No."; BigInteger)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
        }
        field(4; "Table No."; Integer)
        {
            Caption = 'Table No.';
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Table));
        }
        field(5; "Record ID"; RecordId)
        {
            Caption = 'Record ID';
        }
        field(6; "Entity System Id"; Guid)
        {
            Caption = 'Entity System Id';
        }
        field(7; Status; Option)
        {
            Caption = 'Status';
            OptionMembers = Pending,Cancelled,Processed;
            OptionCaption = 'Pending,Cancelled,Processed';
        }
        field(9; "NC Task Entry No."; BigInteger)
        {
            Caption = 'NC Task Entry No.';
        }
        field(10; "Item No."; Code[20])
        {
            Caption = 'Item No.';
        }
        field(11; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
        }
        field(12; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
        }
        field(20; "Shopify Store Code"; Code[20])
        {
            Caption = 'Shopify Store Code';
        }
        field(21; "Shopify ID Type"; Enum "NPR Spfy ID Type")
        {
            Caption = 'Shopify ID Type';
        }
        field(22; "Shopify ID"; Text[30])
        {
            Caption = 'Shopify ID';
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(Queue; Status, "Entry No.")
        {
        }
        key(Dedup; "Table No.", "Shopify ID Type", "Shopify ID", "Shopify Store Code", Status)
        {
        }
        key(Entity; "Table No.", "Entity System Id", "Shopify Store Code", Status)
        {
        }
    }
}
