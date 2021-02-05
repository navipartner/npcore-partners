page 6151402 "NPR Magento Inv. Companies"
{
    // MAG1.22/MHA/20160421 CASE 236917 Object created
    // MAG1.22.01/MHA/20160511 CASE 236917 Field 25 Api Domain added
    // MAG2.00/MHA/20160525  CASE 242557 Magento Integration

    Caption = 'Inventory Companies';
    DelayedInsert = true;
    PageType = ListPart;
    UsageCategory = Administration;
    ApplicationArea = All;
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
                    ToolTip = 'Specifies the value of the Company Name field';
                }
                field("Location Filter"; "Location Filter")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Location Filter field';
                }
                field("Api Username"; "Api Username")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Api Username field';
                }
                field("Api Password"; "Api Password")
                {
                    ApplicationArea = All;
                    ExtendedDatatype = Masked;
                    ToolTip = 'Specifies the value of the Api Password field';
                }
                field("Api Url"; "Api Url")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Api Url field';
                }
                field("Api Domain"; "Api Domain")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Api Domain field';
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
                PromotedCategory = Process;
                PromotedOnly = true;
                PromotedIsBig = true;
                ApplicationArea = All;
                ToolTip = 'Executes the Test Api Url action';

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

