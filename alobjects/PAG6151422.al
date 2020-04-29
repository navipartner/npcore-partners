page 6151422 "Magento Setup Event Subs."
{
    // MAG2.05/MHA /20170714  CASE 283777 Object created

    Caption = 'Magento Setup Event Subscriptions';
    DelayedInsert = true;
    PageType = List;
    SourceTable = "Magento Setup Event Sub.";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Type;Type)
                {
                }
                field("Codeunit ID";"Codeunit ID")
                {
                }
                field("Function Name";"Function Name")
                {
                }
                field(Enabled;Enabled)
                {
                }
                field("Codeunit Name";"Codeunit Name")
                {
                }
            }
        }
    }

    actions
    {
    }
}

