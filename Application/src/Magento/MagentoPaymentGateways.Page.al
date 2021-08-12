page 6151453 "NPR Magento Payment Gateways"
{
    Caption = 'Payment Gateways';
    PageType = List;
    SourceTable = "NPR Magento Payment Gateway";
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {

                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Api Url"; Rec."Api Url")
                {

                    ToolTip = 'Specifies the value of the Api Url field';
                    ApplicationArea = NPRRetail;
                }
                field(Token; Rec.Token)
                {

                    ToolTip = 'Specifies the value of the Api Token';
                    ApplicationArea = NPRRetail;
                }
                field("Api Username"; Rec."Api Username")
                {

                    ToolTip = 'Specifies the value of the Api Username field';
                    ApplicationArea = NPRRetail;
                }
                field(Password; Password)
                {

                    Caption = 'Api Password';
                    ExtendedDatatype = Masked;
                    ToolTip = 'Specifies the value of the Api Password field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        Rec.SetApiPassword(Password);
                        Commit();
                    end;
                }
                field("Merchant ID"; Rec."Merchant ID")
                {

                    ToolTip = 'Specifies the value of the Merchant Id field';
                    ApplicationArea = NPRRetail;
                }
                field("Merchant Name"; Rec."Merchant Name")
                {

                    ToolTip = 'Specifies the value of the Merchant Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Currency Code"; Rec."Currency Code")
                {

                    ToolTip = 'Specifies the value of the Currency Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Capture Codeunit Id"; Rec."Capture Codeunit Id")
                {

                    ToolTip = 'Specifies the value of the Capture codeunit-id field';
                    ApplicationArea = NPRRetail;
                }
                field("Refund Codeunit Id"; Rec."Refund Codeunit Id")
                {

                    ToolTip = 'Specifies the value of the Refund codeunit-id field';
                    ApplicationArea = NPRRetail;
                }
                field("Cancel Codeunit Id"; Rec."Cancel Codeunit Id")
                {

                    ToolTip = 'Specifies the value of the Cancel Codeunit Id field';
                    ApplicationArea = NPRRetail;
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
        Password: Text[200];
}