#if not BC17
table 6150886 "NPR Spfy Webhook Subscription"
{
    Access = Internal;
    Caption = 'Shopify Webhook Subscription';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; BigInteger)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
            AutoIncrement = true;
        }
        field(10; "Webhook ID"; Text[50])
        {
            Caption = 'Webhook ID';
            DataClassification = CustomerContent;
        }
        field(11; Topic; Enum "NPR Spfy Webhook Topic")
        {
            Caption = 'Topic';
            DataClassification = CustomerContent;
        }
        field(12; "Store Code"; Code[20])
        {
            Caption = 'Store Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR Spfy Store".Code;
        }
        field(13; "Api Version"; Text[10])
        {
            Caption = 'Api Version';
            DataClassification = CustomerContent;
        }
        field(14; Address; Text[2048])
        {
            Caption = 'Address';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(ShopifyStore; "Store Code", Topic, "Webhook ID") { }
        key(ShopifyWebhookID; "Webhook ID") { }
    }
}
#endif