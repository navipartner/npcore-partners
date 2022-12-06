page 6059805 "NPR Item Variants Lookup"
{
    Extensible = true;
    Caption = 'Item Variants Lookup';
    PageType = List;
    SourceTable = "NPR Item Variant Buffer";
    SourceTableTemporary = true;
    Editable = false;
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Code"; Rec.Code)
                {
                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Description 2"; Rec."Description 2")
                {
                    Visible = true;
                    ToolTip = 'Specifies the value of the Description 2 field';
                    ApplicationArea = NPRRetail;
                }
                field(Inventory; Rec.Inventory)
                {
                    Caption = 'Inventory';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Inventory field';
                    ApplicationArea = NPRRetail;
                    Visible = ShowInventory;
                }
            }
        }
    }
    var
        VarietySetup: Record "NPR Variety Setup";
        ShowInventory: Boolean;

    trigger OnOpenPage()
    begin
        if not VarietySetup.Get() then
            VarietySetup.Init();
        ShowInventory := VarietySetup."Activate Inventory";
    end;
}
