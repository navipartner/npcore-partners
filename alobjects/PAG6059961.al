page 6059961 "CashKeeper Overview"
{
    // NPR5.43/CLVA/20180620 CASE 319764 Object created

    Caption = 'CashKeeper Overview';
    DelayedInsert = false;
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "CashKeeper Overview";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Transaction No.";"Transaction No.")
                {
                }
                field("Register No.";"Register No.")
                {
                }
                field("Total Amount";"Total Amount")
                {
                }
                field("Value In Cents";"Value In Cents")
                {
                }
                field(Salesperson;Salesperson)
                {
                }
                field("User Id";"User Id")
                {
                }
                field("Lookup Timestamp";"Lookup Timestamp")
                {
                }
                field("CashKeeper IP";"CashKeeper IP")
                {
                }
            }
        }
    }

    actions
    {
    }
}

