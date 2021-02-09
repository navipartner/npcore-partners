table 6151462 "NPR Magento PostOnImport Setup"
{
    Caption = 'Magento Post on Import Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; Type; enum "Sales Line Type")
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
            InitValue = Item;
            NotBlank = true;
        }
        field(10; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = IF (Type = CONST("G/L Account")) "G/L Account" WHERE("Direct Posting" = CONST(true),
                                                                                "Account Type" = CONST(Posting),
                                                                                Blocked = CONST(false))
            ELSE
            IF (Type = CONST(Item)) Item
            ELSE
            IF (Type = CONST(Resource)) Resource
            ELSE
            IF (Type = CONST("Fixed Asset")) "Fixed Asset"
            ELSE
            IF (Type = CONST("Charge (Item)")) "Item Charge";

            trigger OnValidate()
            var
                FixedAsset: Record "Fixed Asset";
                GLAccount: Record "G/L Account";
                Item: Record Item;
                ItemCharge: Record "Item Charge";
                Resource: Record Resource;
            begin
                if "No." = '' then begin
                    Description := '';
                    exit;
                end;

                case Type of
                    Type::"G/L Account":
                        begin
                            GLAccount.Get("No.");
                            Description := GLAccount.Name;
                        end;
                    Type::Item:
                        begin
                            Item.Get("No.");
                            Description := Item.Description;
                        end;
                    Type::Resource:
                        begin
                            Resource.Get("No.");
                            Description := Resource.Name;
                        end;
                    Type::"Fixed Asset":
                        begin
                            FixedAsset.Get("No.");
                            Description := FixedAsset.Description;
                        end;
                    Type::"Charge (Item)":
                        begin
                            ItemCharge.Get("No.");
                            Description := ItemCharge.Description;
                        end;
                end;
            end;
        }
        field(20; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; Type, "No.")
        {
        }
    }
}