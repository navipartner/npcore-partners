page 6150738 "NPR POS Named Actions Profiles"
{
    Extensible = False;
    Caption = 'POS Actions Profiles';
    ContextSensitiveHelpPage = 'docs/retail/pos_profiles/how-to/pos_named_action_profile/pos_named_profile/';
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
                field("End of Day Action Code"; Rec."End of Day Action Code")
                {
                    Editable = false;
                    ToolTip = 'Specifies a POS action designed to perform end of day balancing of POS units. By default system uses ''BALANCE_V4'', if no value is specified in this field.', Comment = 'BALANCE_V4 is a POS action name. Do not translate it.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}

