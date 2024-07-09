﻿table 6014576 "NPR Services Combination"
{
    Access = Public;
    Caption = 'Services Combination';
    ObsoleteState = Removed;
    ObsoleteTag = '2023-06-28';
    ObsoleteReason = 'Table replaced by table 6014692 NPR Shipping Provider Services';
    fields
    {
        field(1; "Shipping Agent"; Code[10])
        {
            TableRelation = "NPR Package Shipping Agent";
            DataClassification = CustomerContent;
        }
        field(2; "Shipping Service"; Code[10])
        {
            TableRelation = "Shipping Agent Services".Code WHERE("Shipping Agent Code" = FIELD("Shipping Agent"));
            DataClassification = CustomerContent;
        }
        field(3; "Service Code"; Code[10])
        {
            DataClassification = CustomerContent;
        }
        field(4; "Service Description"; Text[50])
        {
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Shipping Agent", "Shipping Service", "Service Code")
        {
        }
    }

    fieldgroups
    {
    }
}

