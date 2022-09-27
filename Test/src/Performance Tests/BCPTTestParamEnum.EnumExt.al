#IF NOT BC17
enumextension 85000 "NPR BCPT Test Param. Enum" extends "BCPT Test Param. Enum"
{
    value(85058; "BCPT POS Direct Sale Cash")
    {
        Implementation = "BCPT Test Param. Provider" = "NPR BCPT POS Direct Sale Cash";
    }
    value(85059; "BCPT POS Direct Sale EFT")
    {
        Implementation = "BCPT Test Param. Provider" = "NPR BCPT POS Direct Sale EFT";
    }
    value(85062; "NPR BCPT POS Credit Sale")
    {
        Implementation = "BCPT Test Param. Provider" = "NPR BCPT POS Credit Sale";
    }
    value(85063; "NPR BCPT POS DS Voucher Issue")
    {
        Implementation = "BCPT Test Param. Provider" = "NPR BCPT POS DS Voucher Issue";
    }
    value(85064; "NPR BCPT POS DS Voucher Usage")
    {
        Implementation = "BCPT Test Param. Provider" = "NPR BCPT POS DS Voucher Usage";
    }
    value(85065; "NPR BCPT POS DS Ticket Issue")
    {
        Implementation = "BCPT Test Param. Provider" = "NPR BCPT POS DS Ticket Issue";
    }
    value(85077; "NPR BCPT POS DS Create Member")
    {
        Implementation = "BCPT Test Param. Provider" = "NPR BCPT POS DS Create Member";
    }
}
#ENDIF