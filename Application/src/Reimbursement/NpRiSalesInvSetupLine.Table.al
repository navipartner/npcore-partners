table 6151111 "NPR NpRi Sales Inv. Setup Line"
{
    Caption = 'Sales Invoice Reimbursement Setup Line';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Template Code"; Code[20])
        {
            Caption = 'Template Code';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = "NPR NpRi Reimbursement Templ.";
        }
        field(10; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(20; Type; Option)
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
            OptionCaption = ' ,G/L Account,Item,Resource,Fixed Asset,Charge (Item)';
            OptionMembers = " ","G/L Account",Item,Resource,"Fixed Asset","Charge (Item)";

            trigger OnValidate()
            begin
                case Type of
                    Type::" ":
                        begin
                            Quantity := 0;
                        end;
                    Type::"Charge (Item)":
                        begin
                            Quantity := 1;
                        end;
                    Type::"Fixed Asset":
                        begin
                            Quantity := 1;
                        end;
                    Type::"G/L Account":
                        begin
                            Quantity := 1;
                        end;
                    Type::Item:
                        begin
                            Quantity := 1;
                        end;
                    Type::Resource:
                        begin
                            Quantity := 1;
                        end;
                end;
            end;
        }
        field(30; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
            TableRelation = IF (Type = CONST(" ")) "Standard Text"
            ELSE
            IF (Type = CONST("G/L Account")) "G/L Account" WHERE("Direct Posting" = CONST(true),
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
                StandardText: Record "Standard Text";
            begin
                if "No." = '' then
                    exit;

                case Type of
                    Type::" ":
                        begin
                            StandardText.Get("No.");
                            Description := StandardText.Description;
                        end;
                    Type::"Charge (Item)":
                        begin
                            ItemCharge.Get("No.");
                            Description := ItemCharge.Description;
                        end;
                    Type::"Fixed Asset":
                        begin
                            FixedAsset.Get("No.");
                            Description := FixedAsset.Description;
                        end;
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
                end;
            end;
        }
        field(40; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(50; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
        }
        field(60; "Invoice %"; Decimal)
        {
            Caption = 'Invoice %';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Template Code", "Line No.")
        {
        }
    }
}

