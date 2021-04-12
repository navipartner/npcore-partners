page 6151402 "NPR Magento Inv. Companies"
{
    Caption = 'Inventory Companies';
    DelayedInsert = true;
    PageType = ListPart;
    UsageCategory = None;
    SourceTable = "NPR Magento Inv. Company";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Company Name"; Rec."Company Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Company Name field';
                }
                field("Location Filter"; Rec."Location Filter")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Location Filter field';
                }
                field("Api Username"; Rec."Api Username")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Api Username field';
                }
                field(Password; Password)
                {
                    ApplicationArea = All;
                    Caption = 'Api Password';
                    ExtendedDatatype = Masked;
                    ToolTip = 'Specifies the value of the Api Password field';

                    trigger OnValidate()
                    begin
                        Rec.SetApiPassword(Password);
                        Commit();
                    end;
                }
                field("Api Url"; Rec."Api Url")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Api Url field';
                }
                field("Api Domain"; Rec."Api Domain")
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

    trigger OnAfterGetRecord()
    begin
        Password := '';
        if not IsNullGuid(Rec."Api Password Key") then
            Password := '***';
    end;

    var
        Password: Text[250];
        Text000: Label 'Api Url OK';

    procedure TestApi()
    var
        Item: Record Item;
        MagentoInventoryNpXmlValue: Codeunit "NPR Magento Inv. NpXml Value";
    begin
        if Item.ChangeCompany(Rec."Company Name") then;
        Item.FindFirst();
        MagentoInventoryNpXmlValue.CalcMagentoInventoryCompany(Rec, Item."No.", '');
        Message(Text000);
    end;
}