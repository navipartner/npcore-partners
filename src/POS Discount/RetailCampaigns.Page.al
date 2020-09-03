page 6014610 "NPR Retail Campaigns"
{
    // NPR5.38.01/MHA /20171220  CASE 299436 Object created - Retail Campaign
    // MAG2.26/MHA /20200507  CASE 401235 Added field 6151414 "Magento Category Id"

    Caption = 'Retail Campaigns';
    CardPageID = "NPR Retail Campaign";
    Editable = false;
    PageType = List;
    SourceTable = "NPR Retail Campaign Header";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Code)
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Magento Category Id"; "Magento Category Id")
                {
                    ApplicationArea = All;
                    Visible = MagentoEnabled;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    var
        MagentoSetup: Record "NPR Magento Setup";
    begin
        //-MAG2.26 [401235]
        MagentoEnabled := MagentoSetup.Get and MagentoSetup."Magento Enabled";
        //+MAG2.26 [401235]
    end;

    var
        MagentoEnabled: Boolean;
}

