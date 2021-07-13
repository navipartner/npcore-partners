page 6150721 "NPR POS Keyboard Bind. Setup"
{
    Caption = 'POS Keyboard Binding Setup';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = List;
    SourceTable = "NPR POS Keyboard Bind. Setup";
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Action Code"; Rec."Action Code")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Action Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Key Bind"; Rec."Key Bind")
                {

                    ToolTip = 'Specifies the value of the Key Bind field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field(Enabled; Rec.Enabled)
                {

                    ToolTip = 'Specifies the value of the Enabled field';
                    ApplicationArea = NPRRetail;
                }
                field("Default Key Bind"; Rec."Default Key Bind")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Default Key Bind field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(RestoreDefaultKeyBind)
            {
                Caption = 'Restore Default Key Bind';
                Ellipsis = true;
                Image = Restore;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                ToolTip = 'Executes the Restore Default Key Bind action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                begin
                    POSKeyboardBindingMgt.RestoreDefaultKeyBind(Rec);
                end;
            }
        }
    }

    var
        POSKeyboardBindingMgt: Codeunit "NPR POS Keyboard Binding Mgt.";
}
