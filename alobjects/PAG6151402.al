page 6151402 "Magento Inventory Companies"
{
    // MAG1.22/MHA/20160421 CASE 236917 Object created
    // MAG1.22.01/MHA/20160511 CASE 236917 Field 25 Api Domain added
    // MAG2.00/MHA/20160525  CASE 242557 Magento Integration

    Caption = 'Inventory Companies';
    DelayedInsert = true;
    PageType = ListPart;
    SourceTable = "Magento Inventory Company";

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
                field("Api Username";"Api Username")
                {
                }
                field("Api Password";"Api Password")
                {
                    ExtendedDatatype = Masked;
                }
                field("Api Url";"Api Url")
                {
                    Visible = false;
                }
                field("Api Domain";"Api Domain")
                {
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(TestApiUrl)
            {
                Caption = 'Test Api Url';
                Image = TestFile;
                Promoted = true;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    TestApi();
                end;
            }
        }
    }

    var
        Text000: Label 'Api Url OK';

    procedure TestApi()
    var
        Item: Record Item;
        MagentoInventoryNpXmlValue: Codeunit "Magento Inventory NpXml Value";
    begin
        if Item.ChangeCompany("Company Name") then;
        Item.FindFirst;
        MagentoInventoryNpXmlValue.CalcMagentoInventoryCompany(Rec,Item."No.",'');
        Message(Text000);
    end;
}

