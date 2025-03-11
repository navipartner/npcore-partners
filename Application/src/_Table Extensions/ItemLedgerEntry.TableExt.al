tableextension 6014411 "NPR Item Ledger Entry" extends "Item Ledger Entry"
{
    keys
    {
#IF NOT (BC17 or BC18 or BC19 or BC20)
        key("NPR Key2"; SystemRowVersion)
        {
        }
#ENDIF
    }
}