table 6151201 "NPR NpCs Document Mapping"
{
    Caption = 'Collect Document Mapping';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR NpCs Document Mapping";
    LookupPageID = "NPR NpCs Document Mapping";

    fields
    {
        field(1; Type; Option)
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Customer No.,Item Cross Reference No.';
            OptionMembers = "Customer No.","Item Cross Reference No.";
        }
        field(5; "From Store Code"; Code[20])
        {
            Caption = 'From Store Code';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = "NPR NpCs Store".Code WHERE("Local Store" = CONST(false));
        }
        field(10; "From No."; Code[20])
        {
            Caption = 'From No.';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(50; "From Description"; Text[50])
        {
            Caption = 'From Description';
            DataClassification = CustomerContent;
        }
        field(55; "From Description 2"; Text[50])
        {
            Caption = 'From Description 2';
            DataClassification = CustomerContent;
        }
        field(100; "To No."; Code[50])
        {
            Caption = 'To No.';
            DataClassification = CustomerContent;
            TableRelation = IF (Type = CONST("Customer No.")) Customer
            ELSE
            IF (Type = CONST("Item Cross Reference No.")) "Item Reference"."Reference No." WHERE("Reference Type" = CONST("Bar Code"));

            trigger OnValidate()
            var
                Customer: Record Customer;
                Item: Record Item;
                ItemVariant: Record "Item Variant";
                ItemReference: Record "Item Reference";
            begin
                if "To No." = '' then begin
                    "To Description" := '';
                    "To Description 2" := '';
                    exit;
                end;

                case Type of
                    Type::"Customer No.":
                        begin
                            Customer.Get("To No.");
                            "To Description" := Customer.Name;
                            "To Description 2" := Customer."Name 2";
                        end;
                    Type::"Item Cross Reference No.":
                        begin
                            ItemReference.SetRange("Reference No.", "To No.");
                            ItemReference.SetRange("Discontinue Bar Code", false);
                            if not ItemReference.FindFirst then
                                ItemReference.SetRange("Discontinue Bar Code");
                            ItemReference.FindFirst;
                            Item.Get(ItemReference."Item No.");
                            if ItemVariant.Get(ItemReference."Item No.", ItemReference."Variant Code") then;
                            "To Description" := Item.Description;
                            "To Description 2" := CopyStr(ItemVariant.Description, 1, MaxStrLen("To Description 2"));
                        end;
                end;
            end;
        }
        field(150; "To Description"; Text[100])
        {
            Caption = 'To Description';
            DataClassification = CustomerContent;
        }
        field(155; "To Description 2"; Text[50])
        {
            Caption = 'To Description 2';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; Type, "From Store Code", "From No.")
        {
        }
    }
}

