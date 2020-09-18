page 6151402 "NPR Magento Inv. Companies"
{
    // MAG1.22/MHA/20160421 CASE 236917 Object created
    // MAG1.22.01/MHA/20160511 CASE 236917 Field 25 Api Domain added
    // MAG2.00/MHA/20160525  CASE 242557 Magento Integration

    Caption = 'Inventory Companies';
    DelayedInsert = true;
    PageType = ListPart;
    UsageCategory = Administration;
    SourceTable = "NPR Magento Inv. Company";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Company Name"; "Company Name")
                {
                    ApplicationArea = All;
                }
                field("Location Filter"; "Location Filter")
                {
                    ApplicationArea = All;
                }
                field("Api Username"; "Api Username")
                {
                    ApplicationArea = All;
                }
                field("Api Password"; "Api Password")
                {
                    ApplicationArea = All;
                    ExtendedDatatype = Masked;
                }
                field("Api Url"; "Api Url")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Api Domain"; "Api Domain")
                {
                    ApplicationArea = All;
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
                ApplicationArea = All;

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
        MagentoInventoryNpXmlValue: Codeunit "NPR Magento Inv. NpXml Value";
    begin
        if Item.ChangeCompany("Company Name") then;
        Item.FindFirst;
        MagentoInventoryNpXmlValue.CalcMagentoInventoryCompany(Rec, Item."No.", '');
        Message(Text000);
    end;
}

