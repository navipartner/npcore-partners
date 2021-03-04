page 6150738 "NPR POS Setup List"
{
    Caption = 'POS Setup List';
    CardPageID = "NPR POS Setup";
    PageType = List;
    UsageCategory = None;
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
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Primary Key field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Login Action Code"; Rec."Login Action Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Login Action Code field';
                }
                field("Text Enter Action Code"; Rec."Text Enter Action Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Text Enter Action Code field';
                }
                field("Item Insert Action Code"; Rec."Item Insert Action Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Item Insert Action Code field';
                }
                field("Payment Action Code"; Rec."Payment Action Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Payment Action Code field';
                }
                field("Customer Action Code"; Rec."Customer Action Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Customer Action Code field';
                }
                field("Lock POS Action Code"; Rec."Lock POS Action Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Lock POS Action Code field';
                }
                field("Unlock POS Action Code"; Rec."Unlock POS Action Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Unlock POS Action Code field';
                }
                field("OnBeforePaymentView Action"; Rec."OnBeforePaymentView Action")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the On Before Payment View Action Code field';
                }
                field("Admin Menu Action Code"; Rec."Admin Menu Action Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Admin Menu Action Code field';
                }
            }
        }
    }
}

