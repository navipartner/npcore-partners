table 6151206 "NpCs Store POS Relation"
{
    // NPR5.50/MHA /20190531  CASE 345261 Object created - Collect in Store

    Caption = 'Collect Store POS Relation';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Store Code"; Code[20])
        {
            Caption = 'Store Code';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = "NpCs Store";
        }
        field(5; Type; Option)
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
            OptionCaption = 'POS Store,POS Unit';
            OptionMembers = "POS Store","POS Unit";
        }
        field(10; "No."; Code[10])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = IF (Type = CONST("POS Store")) "POS Store"
            ELSE
            IF (Type = CONST("POS Unit")) "POS Unit";

            trigger OnValidate()
            var
                POSStore: Record "POS Store";
                POSUnit: Record "POS Unit";
            begin
                if "No." = '' then begin
                    Name := '';
                    exit;
                end;

                case Type of
                    Type::"POS Store":
                        begin
                            POSStore.Get("No.");
                            Name := POSStore.Name;
                        end;
                    Type::"POS Unit":
                        begin
                            POSUnit.Get("No.");
                            Name := POSUnit.Name;
                        end;
                end;
            end;
        }
        field(15; Name; Text[50])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Store Code", Type, "No.")
        {
        }
    }

    fieldgroups
    {
    }
}

