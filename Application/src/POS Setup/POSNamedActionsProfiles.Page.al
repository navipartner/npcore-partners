page 6150738 "NPR POS Named Actions Profiles"
{
    Caption = 'POS Actions Profiles';
    CardPageID = "NPR POS Named Actions Profile";
    ApplicationArea = NPRRetail;
    PageType = List;
    UsageCategory = Lists;
    SourceTable = "NPR POS Setup";
    Editable = false;
    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Primary Key"; Rec."Primary Key")
                {

                    ToolTip = 'Specifies the value of the Primary Key field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Login Action Code"; Rec."Login Action Code")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Login Action Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Text Enter Action Code"; Rec."Text Enter Action Code")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Text Enter Action Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Item Insert Action Code"; Rec."Item Insert Action Code")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Item Insert Action Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Payment Action Code"; Rec."Payment Action Code")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Payment Action Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Customer Action Code"; Rec."Customer Action Code")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Customer Action Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Lock POS Action Code"; Rec."Lock POS Action Code")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Lock POS Action Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Unlock POS Action Code"; Rec."Unlock POS Action Code")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Unlock POS Action Code field';
                    ApplicationArea = NPRRetail;
                }
                field("OnBeforePaymentView Action"; Rec."OnBeforePaymentView Action")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the On Before Payment View Action Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Admin Menu Action Code"; Rec."Admin Menu Action Code")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Admin Menu Action Code field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}

