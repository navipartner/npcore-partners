tableextension 6014429 "NPR Shipping Agent" extends "Shipping Agent"
{
    fields
    {
        field(6014440; "NPR Shipping Agent Demand"; Option)
        {
            Caption = 'Shipping Agent Demand';
            DataClassification = CustomerContent;
            Description = 'PS1.00';
            OptionCaption = ' ,Select a Service,Customs Information';
            OptionMembers = " ","Select a Service","Customs Information";
        }
        field(6014441; "NPR Pacsoft Product"; Boolean)
        {
            Caption = 'Pacsoft Product';
            DataClassification = CustomerContent;
            Description = 'PS1.00';
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Removing unnecesarry table extensions.';
        }
        field(6014442; "NPR Custom Print Layout"; Code[20])
        {
            Caption = 'Custom Print Layout';
            DataClassification = CustomerContent;
            TableRelation = "NPR RP Template Header".Code;
        }
        field(6014450; "NPR Shipping Method"; Option)
        {
            Caption = 'Shipping Method';
            DataClassification = CustomerContent;
            OptionCaption = ' ,GLS,PDK';
            OptionMembers = " ",GLS,PDK;
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Upgraded solution for shipmondo does not use this field';
        }
        field(6014451; "NPR Ship to Contact Mandatory"; Boolean)
        {
            Caption = 'Ship to Contact Mandatory';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Upgraded solution for shipmondo does not use this field';
        }
        field(6014452; "NPR Drop Point Service"; Boolean)
        {
            Caption = 'Drop Point Service';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Upgraded solution for shipmondo does not use this field';
        }
        field(6014453; "NPR Return Shipping agent"; Boolean)
        {
            Caption = 'Return Shipping agent';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Upgraded solution for shipmondo does not use this field';
        }
#if not BC17
        field(6151550; "NPR Spfy Tracking Company"; Enum "NPR Spfy Tracking Company")
        {
            Caption = 'Shopify Tracking Company';
            DataClassification = CustomerContent;
        }
#endif
    }
}
