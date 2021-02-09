page 6151453 "NPR Magento Payment Gateways"
{
    Caption = 'Payment Gateways';
    PageType = List;
    SourceTable = "NPR Magento Payment Gateway";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field("Api Url"; Rec."Api Url")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Api Url field';
                }
                field(Token; Token)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Api Token';
                }
                field("Api Username"; "Api Username")
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
                field("Merchant ID"; Rec."Merchant ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Merchant Id field';
                }
                field("Merchant Name"; Rec."Merchant Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Merchant Name field';
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Currency Code field';
                }
                field("Capture Codeunit Id"; Rec."Capture Codeunit Id")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Capture codeunit-id field';
                }
                field("Refund Codeunit Id"; Rec."Refund Codeunit Id")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Refund codeunit-id field';
                }
                field("Cancel Codeunit Id"; Rec."Cancel Codeunit Id")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Cancel Codeunit Id field';
                }
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
        Password: Text;
}