tableextension 6014478 "NPR Country/Region" extends "Country/Region"
{
    fields
    {
        field(6014400; "NPR HL Country ID"; Code[10])
        {
            Caption = 'HeyLoyalty Country ID';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'HeyLoyalty values are now stored in a dedicated mapping table 6059839 "NPR HL Mapped Value".';
        }
    }

    keys
    {
        key(HLCountryID; "NPR HL Country ID")
        {
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'HeyLoyalty values are now stored in a dedicated mapping table 6059839 "NPR HL Mapped Value".';
        }
    }
}
