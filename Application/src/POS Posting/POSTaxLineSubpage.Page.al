page 6150722 "NPR POS Tax Line Subpage"
{
    Extensible = False;
    Caption = 'POS Tax Line Subpage';
    Editable = false;
    PageType = ListPart;
    UsageCategory = Administration;
    SourceTable = "NPR POS Entry Tax Line";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Tax Base Amount"; Rec."Tax Base Amount")
                {

                    ToolTip = 'Specifies the value of the Tax Base Amount field';
                    ApplicationArea = NPRRetail;
                }
                field("Tax %"; Rec."Tax %")
                {

                    ToolTip = 'Specifies the value of the Tax % field';
                    ApplicationArea = NPRRetail;
                }
                field("Tax Amount"; Rec."Tax Amount")
                {

                    ToolTip = 'Specifies the value of the Tax Amount field';
                    ApplicationArea = NPRRetail;
                }
                field("Amount Including Tax"; Rec."Amount Including Tax")
                {

                    ToolTip = 'Specifies the value of the Amount Including Tax field';
                    ApplicationArea = NPRRetail;
                }
                field("VAT Identifier"; Rec."VAT Identifier")
                {

                    ToolTip = 'Specifies the value of the Tax Identifier field';
                    ApplicationArea = NPRRetail;
                }
                field("Tax Calculation Type"; Rec."Tax Calculation Type")
                {

                    ToolTip = 'Specifies the value of the VAT Calculation Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Tax Jurisdiction Code"; Rec."Tax Jurisdiction Code")
                {
                    Visible = NALocalizationEnabled;
                    ToolTip = 'Specifies the value of the Tax Jurisdiction Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Tax Area Code"; Rec."Tax Area Code")
                {
                    Visible = NALocalizationEnabled;
                    ToolTip = 'Specifies the value of the Tax Area Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Tax Group Code"; Rec."Tax Group Code")
                {
                    Visible = NALocalizationEnabled;
                    ToolTip = 'Specifies the value of the Tax Group Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Calc. for Maximum Amount/Qty."; Rec."Calc. for Maximum Amount/Qty.")
                {
                    Visible = NALocalizationEnabled;
                    ToolTip = 'Specifies wheter calculation of tax is performed including Maximum Amount (or Quantity) from Tax Details or not.';
                    ApplicationArea = NPRRetail;
                }
                field(Quantity; Rec.Quantity)
                {
                    ToolTip = 'Specifies the value of the Quantity field';
                    ApplicationArea = NPRRetail;
                }
                field("Use Tax"; Rec."Use Tax")
                {
                    ToolTip = 'Specifies the value of the Use Tax field';
                    ApplicationArea = NPRRetail;
                }
                field("Print Description"; Rec."Print Description")
                {
                    ToolTip = 'Specifies the value of the Print Description field. Value can be transferred from Tax Area > Description or Tax Jurisdiction > Print Description.';
                    ApplicationArea = NPRRetail;
                    Visible = NALocalizationEnabled;
                }
            }
        }
    }
    var
        NALocalizationEnabled: Boolean;

    trigger OnOpenPage()
    begin
        OnNALocalizationEnabled(NALocalizationEnabled);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnNALocalizationEnabled(var _NALocalizationEnabled: Boolean)
    begin
    end;
}

