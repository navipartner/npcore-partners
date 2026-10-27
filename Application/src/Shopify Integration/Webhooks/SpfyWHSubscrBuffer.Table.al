#if not BC17
table 6060069 "NPR Spfy WH Subscr. Buffer"
{
    Access = Internal;
    Caption = 'Shopify Webhook Subscription Buffer';
    DataClassification = CustomerContent;
    TableType = Temporary;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(2; "Store Code"; Code[20])
        {
            Caption = 'Store Code';
            DataClassification = CustomerContent;
        }
        field(10; Status; Enum "NPR Spfy WH Subscr. Status")
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
        }
        field(11; Topic; Text[100])
        {
            Caption = 'Topic';
            DataClassification = CustomerContent;
        }
        field(12; "Webhook ID"; Text[50])
        {
            Caption = 'Webhook ID';
            DataClassification = CustomerContent;
        }
        field(13; "Destination Environment"; Text[100])
        {
            Caption = 'Destination Environment';
            DataClassification = CustomerContent;
        }
        field(14; "Destination Company"; Text[250])
        {
            Caption = 'Destination Company';
            DataClassification = CustomerContent;
        }
        field(15; "Destination Tenant ID"; Text[50])
        {
            Caption = 'Destination Tenant ID';
            DataClassification = CustomerContent;
        }
        field(16; "Address in Shopify"; Text[2048])
        {
            Caption = 'Address in Shopify';
            DataClassification = CustomerContent;
        }
        field(17; "Address in BC"; Text[2048])
        {
            Caption = 'Address in Business Central';
            DataClassification = CustomerContent;
        }
        field(18; "API Version in Shopify"; Text[20])
        {
            Caption = 'API Version in Shopify';
            DataClassification = CustomerContent;
        }
        field(19; "API Version in BC"; Text[20])
        {
            Caption = 'API Version in Business Central';
            DataClassification = CustomerContent;
        }
        field(20; "Created in Shopify"; DateTime)
        {
            Caption = 'Created in Shopify';
            DataClassification = CustomerContent;
        }
        field(21; Details; Text[250])
        {
            Caption = 'Details';
            DataClassification = CustomerContent;
        }
        field(22; "Delivers to This Company"; Boolean)
        {
            Caption = 'Delivers to This Company';
            DataClassification = CustomerContent;
        }
        field(23; "Exists in Shopify"; Boolean)
        {
            Caption = 'Exists in Shopify';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }

    /// <summary>True when this company has to act on the line. Another environment's or company's own subscription is expected and needs nothing from here.</summary>
    internal procedure NeedsAttention(): Boolean
    begin
        exit(IsRepairableByToggle() or IsForeignRecord());
    end;

    /// <summary>A problem that turning the related webhook setting off and on again repairs, because it only involves this company's own delivery.</summary>
    internal procedure IsRepairableByToggle(): Boolean
    begin
        case Status of
            Status::"Missing in Shopify":
                exit(true);
            Status::"Not Registered", Status::"Address Mismatch":
                exit("Delivers to This Company");
            else
                exit(false);
        end;
    end;

    /// <summary>This company has a record of the subscription, but Shopify delivers it elsewhere. Toggling only drops the record; only an explicit delete removes the subscription.</summary>
    internal procedure IsForeignRecord(): Boolean
    begin
        case Status of
            Status::"Delivers Elsewhere":
                exit(true);
            Status::"Address Mismatch":
                exit(not "Delivers to This Company");
            else
                exit(false);
        end;
    end;

    internal procedure CanDeleteInShopify(): Boolean
    begin
        exit("Exists in Shopify" and not "Delivers to This Company");
    end;

    internal procedure StatusStyleExpr(): Text
    begin
        if NeedsAttention() then
            exit(Format(PageStyle::Unfavorable));
        case Status of
            Status::OK:
                exit(Format(PageStyle::Favorable));
            Status::"Not Checked":
                exit(Format(PageStyle::Subordinate));
            else
                exit(Format(PageStyle::Ambiguous));
        end;
    end;
}
#endif
