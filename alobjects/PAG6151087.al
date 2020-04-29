page 6151087 "RIS Retail Inventory Set Sub."
{
    // NPR5.40/MHA /20180320  CASE 307025 Object created - POS Inventory Set

    AutoSplitKey = true;
    Caption = 'Inventory Set Entries';
    DelayedInsert = true;
    PageType = ListPart;
    SourceTable = "RIS Retail Inventory Set Entry";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Company Name";"Company Name")
                {
                }
                field("Location Filter";"Location Filter")
                {
                }
                field(Enabled;Enabled)
                {
                }
                field("Api Url";"Api Url")
                {
                }
                field("Api Username";"Api Username")
                {
                }
                field("Api Password";"Api Password")
                {
                }
                field("Api Domain";"Api Domain")
                {
                }
                field("Processing Function";"Processing Function")
                {
                }
                field("Processing Codeunit ID";"Processing Codeunit ID")
                {
                    Visible = false;
                }
                field("Processing Codeunit Name";"Processing Codeunit Name")
                {
                }
            }
        }
    }

    actions
    {
    }
}

