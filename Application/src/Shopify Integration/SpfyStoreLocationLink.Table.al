#if not BC17
table 6150812 "NPR Spfy Store-Location Link"
{
    Access = Internal;
    Caption = 'Shopify Store-Location Link';
    DataClassification = CustomerContent;
    DrillDownPageId = "NPR Spfy Store-Location Links";
    LookupPageId = "NPR Spfy Store-Location Links";

    fields
    {
        field(10; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            DataClassification = CustomerContent;
            TableRelation = Location where("Use As In-Transit" = const(false));
            NotBlank = true;
        }
        field(20; "Shopify Store Code"; Code[20])
        {
            Caption = 'Shopify Store Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR Spfy Store".Code;
            NotBlank = true;
        }
        field(30; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; "Location Code", "Shopify Store Code", "Line No.")
        {
            Clustered = true;
        }
        key(StoreLocations; "Shopify Store Code") { }
    }

    trigger OnDelete()
    var
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
    begin
        SpfyAssignedIDMgt.RemoveAssignedShopifyID(Rec.RecordId(), "NPR Spfy ID Type"::"Entry ID");
    end;

    trigger OnRename()
    var
        CannotChangeErr: Label 'cannot be changed';
    begin
        if Rec."Shopify Store Code" <> xRec."Shopify Store Code" then
            Rec.FieldError("Shopify Store Code", CannotChangeErr);
    end;
}
#endif