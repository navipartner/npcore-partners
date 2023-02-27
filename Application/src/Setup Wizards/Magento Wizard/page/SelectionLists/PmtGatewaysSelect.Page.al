page 6014624 "NPR Pmt. Gateways Select"
{
    Extensible = False;
    Caption = 'Payment Gateways';
    PageType = List;
    UsageCategory = None;

    SourceTable = "NPR Magento Payment Gateway";
    SourceTableTemporary = true;

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
                field(Desctiption; Rec.Description)
                {

                    ToolTip = 'Specifies description';
                    ApplicationArea = NPRRetail;
                }
                field("Integration Type"; Rec."Integration Type")
                {

                    ToolTip = 'Specifies the payment gateway integration type';
                    ApplicationArea = NPRRetail;
                }
                field("Api Url"; Rec."Api Url")
                {
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Moved in custom integration table M2PGxxxx';
                    Visible = false;
                    ToolTip = 'Specifies the value of the Api Url field';
                    ApplicationArea = NPRRetail;
                }
                field("Api Username"; Rec."Api Username")
                {
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Moved in custom integration table M2PGxxxx';
                    Visible = false;
                    ToolTip = 'Specifies the value of the Api Username field';
                    ApplicationArea = NPRRetail;
                }
                field(Password; Password)
                {
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Moved in custom integration table M2PGxxxx';
                    Visible = false;
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
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Moved in custom integration table M2PGxxxx';
                    Visible = false;
                    ToolTip = 'Specifies the value of the Merchant Id field';
                    ApplicationArea = NPRRetail;
                }
                field("Merchant Name"; Rec."Merchant Name")
                {
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Moved in custom integration table M2PGxxxx';
                    Visible = false;
                    ToolTip = 'Specifies the value of the Merchant Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Moved in custom integration table M2PGxxxx';
                    Visible = false;
                    ToolTip = 'Specifies the value of the Currency Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Capture Codeunit Id"; Rec."Capture Codeunit Id")
                {
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Moved in custom integration table M2PGxxxx and replaced with boolean field [Enable Capture]';
                    Visible = false;
                    ToolTip = 'Specifies the value of the Capture codeunit-id field';
                    ApplicationArea = NPRRetail;
                }
                field("Refund Codeunit Id"; Rec."Refund Codeunit Id")
                {
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Moved in custom integration table M2PGxxxx and replaced with boolean field [Enable Refund]';
                    Visible = false;
                    ToolTip = 'Specifies the value of the Refund codeunit-id field';
                    ApplicationArea = NPRRetail;
                }
                field("Cancel Codeunit Id"; Rec."Cancel Codeunit Id")
                {
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Moved in custom integration table M2PGxxxx and replaced with boolean field [Enable Cancel]';
                    Visible = false;
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

    internal procedure SetRec(var TempPaymentGateway: Record "NPR Magento Payment Gateway")
    begin
        if TempPaymentGateway.FindSet() then
            repeat
                Rec := TempPaymentGateway;
                Rec.Insert();
            until TempPaymentGateway.Next() = 0;
    end;
}
