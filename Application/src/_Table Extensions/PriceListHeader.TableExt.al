tableextension 6014458 "NPR Price List Header" extends "Price List Header"
{
    fields
    {
#IF NOT (BC17 or BC18 or BC19 or BC20)
        modify("Assign-to No.")
        {
            TableRelation = if ("Source Type" = const("NPR POS Price Profile")) "NPR POS Pricing Profile";
        }
#ENDIF
        field(6151479; "NPR Replication Counter"; BigInteger)
        {
            Caption = 'Replication Counter';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Replaced by SystemRowVersion';
        }
        field(6151480; "NPR Location Code"; Code[10])
        {
            Caption = 'Location Code';
            DataClassification = CustomerContent;
            TableRelation = Location where("NPR Retail Location" = const(true));
        }
        field(6151481; "NPR Retail Price List"; Boolean)
        {
            Caption = 'Retail Price List';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key("NPR Key1"; "NPR Replication Counter")
        {
            ObsoleteState = Pending;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Replaced by SystemRowVersion';
        }
#IF NOT (BC17 or BC18 or BC19 or BC20)
        key("NPR Key2"; SystemRowVersion)
        {
        }
#ENDIF
    }
}
