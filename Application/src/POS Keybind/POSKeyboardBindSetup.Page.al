page 6150721 "NPR POS Keyboard Bind. Setup"
{
    Caption = 'POS Keyboard Binding Setup';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = List;
    SourceTable = "NPR POS Keyboard Bind. Setup";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Action Code"; Rec."Action Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Action Code field';
                }
                field("Key Bind"; Rec."Key Bind")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Key Bind field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field(Enabled; Rec.Enabled)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Enabled field';
                }
                field("Default Key Bind"; Rec."Default Key Bind")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Default Key Bind field';
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
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                ToolTip = 'Executes the Restore Default Key Bind action';

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