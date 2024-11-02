page 6184504 "NPR EFT Adyen Paym. Type Setup"
{
    Extensible = False;
    Caption = 'EFT Adyen Payment Type Setup';
    DelayedInsert = false;
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    PageType = Card;
    UsageCategory = None;
    ShowFilter = false;
    SourceTable = "NPR EFT Adyen Paym. Type Setup";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Transaction Condition"; Rec."Transaction Condition")
                {

                    ToolTip = 'Specifies the value of the Transaction Condition field';
                    ApplicationArea = NPRRetail;
                }
                field("Log Level"; Rec."Log Level")
                {

                    ToolTip = 'Specifies the value of the Log Level field';
                    ApplicationArea = NPRRetail;
                }
                field("Capture Delay Hours"; Rec."Capture Delay Hours")
                {

                    ToolTip = 'Specifies the value of the Capture Delay Hours field';
                    ApplicationArea = NPRRetail;
                }
                field("Manual Capture"; Rec."Manual Capture")
                {

                    ToolTip = 'Specifies the value of the Manual Capture field.';
                    ApplicationArea = NPRRetail;
                }
                field("Cashback Allowed"; Rec."Cashback Allowed")
                {

                    ToolTip = 'Specifies the value of the Cashback Allowed field';
                    ApplicationArea = NPRRetail;
                }
            }

            group(Cloud)
            {
                Caption = 'Cloud Integration';
                Visible = _IsCloud;

                field("API Key"; Rec."API Key")
                {

                    ToolTip = 'Specifies the value of the API Key field';
                    ApplicationArea = NPRRetail;
                }
                field(Environment; Rec.Environment)
                {

                    ToolTip = 'Specifies the value of the Environment field';
                    ApplicationArea = NPRRetail;
                }
            }

            group(LAN)
            {
                Caption = 'LAN Integration';
                Visible = _IsLocalOrMposLan;

                field("LAN Key Identifier"; Rec."Local Key Identifier")
                {
                    ToolTip = 'Specifies the value of the Local Key Identifier field';
                    ApplicationArea = NPRRetail;
                }
                field("LAN Key Passphrase"; Rec."Local Key Passphrase")
                {
                    ToolTip = 'Specifies the value of the Local Key Passphrase field';
                    ApplicationArea = NPRRetail;
                }
                field("LAN Key Version"; Rec."Local Key Version")
                {
                    ToolTip = 'Specifies the value of the Local Key Version field';
                    ApplicationArea = NPRRetail;
                }
                field("LAN: Environment"; Rec.Environment)
                {

                    ToolTip = 'Specifies the value of the Environment field';
                    ApplicationArea = NPRRetail;
                }
            }

            group("Tap-To-Pay")
            {
                Caption = 'Tap-To-Pay (TTP)';
                Visible = _IsTapToPay;
                field("API Key TTP"; Rec."API Key")
                {

                    ToolTip = 'Specifies the value of the API Key field';
                    ApplicationArea = NPRRetail;
                }

                field("TTP: EncKey Id"; Rec."Local Key Identifier")
                {
                    Caption = 'TTP Key Identifier';
                    ToolTip = 'Specifies the Encryption key Identifier.';
                    ApplicationArea = NPRRetail;
                }
                field("TTP: EncKey Pass"; Rec."Local Key Passphrase")
                {
                    Caption = 'TTP Key Passphrase';
                    ToolTip = 'Specifies the Encryption key Passphrase';
                    ApplicationArea = NPRRetail;
                }
                field("TTP: EncKey Version"; Rec."Local Key Version")
                {
                    Caption = 'TTP Key Version';
                    ToolTip = 'Specifies the Encryption key Version';
                    ApplicationArea = NPRRetail;
                }
                field("TTP: Environment"; Rec.Environment)
                {

                    ToolTip = 'Specifies the value of the Environment field';
                    ApplicationArea = NPRRetail;
                }
            }

            group(Loyalty)
            {
                Caption = 'Customer Loyalty';
                field("Merchant Account"; Rec."Merchant Account")
                {
                    ToolTip = 'Specifies the value of the Merchant Account field';
                    ApplicationArea = NPRRetail;
                }
                field("Create Recurring Contract"; Rec."Create Recurring Contract")
                {
                    ToolTip = 'Specifies the value of the Create Recurring Contract field';
                    ApplicationArea = NPRRetail;
                }
                field("Acquire Card First"; Rec."Acquire Card First")
                {
                    ToolTip = 'Specifies the value of the Acquire Card First field';
                    ApplicationArea = NPRRetail;
                }
                field("Silent Discount Allowed"; Rec."Silent Discount Allowed")
                {
                    ToolTip = 'Specifies the value of the Silent Discount Allowed field';
                    ApplicationArea = NPRRetail;
                }
                field("Recurring API URL Prefix"; Rec."Recurring API URL Prefix")
                {
                    ToolTip = 'Specifies the value of the Recurring API URL Prefix field';
                    ApplicationArea = NPRRetail;
                }
            }


        }
    }
    [Obsolete('Use SetCloud() instead', '2024-09-09')]
    procedure SetCloud(IsCloud: Boolean)
    begin
        _IsCloud := IsCloud;
        _IsLocalOrMposLan := not IsCloud;
        _IsTapToPay := not IsCloud;
    end;

    procedure SetCloud()
    begin
        _IsCloud := True;
        _IsLocalOrMposLan := False;
        _IsTapToPay := False;
    end;

    procedure SetLocal()
    begin
        _IsCloud := False;
        _IsLocalOrMposLan := True;
        _IsTapToPay := False;
    end;

    procedure SetMposTapToPay()
    begin
        _IsCloud := False;
        _IsLocalOrMposLan := False;
        _IsTapToPay := True;
    end;

    procedure SetMposLan()
    begin
        SetLocal();
    end;


    var
        _IsCloud: Boolean;
        _IsLocalOrMposLan: Boolean;
        _IsTapToPay: Boolean;
}