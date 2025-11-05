#if not BC17
table 6151261 "NPR Spfy Data Sync. Pointer"
{
    Access = Internal;
    Caption = 'Shopify Data Sync. Pointer';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Shopify Store Code"; Code[20])
        {
            Caption = 'Shopify Store Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR Spfy Store".Code;
            NotBlank = true;
        }
        field(10; "Last Orders Imported At"; DateTime)
        {
            Caption = 'Last Orders Imported At';
            DataClassification = CustomerContent;
        }
#if not (BC18 or BC19 or BC20)
        field(20; "Last POS Entry Row Version"; BigInteger)
        {
            Caption = 'Last POS Entry Row Version';
            DataClassification = CustomerContent;
        }
#endif
    }
    keys
    {
        key(PK; "Shopify Store Code")
        {
            Clustered = true;
        }
    }

    trigger OnRename()
    var
        RecordCannotBeRenamedErr: Label '%1 record cannot be renamed.';
    begin
        Error(RecordCannotBeRenamedErr, Rec.TableCaption());
    end;
}
#endif