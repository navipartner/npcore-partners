pageextension 6014455 "NPR Salesperson/Purchaser Card" extends "Salesperson/Purchaser Card"
{
    layout
    {
        addafter(Invoicing)
        {
            group("NPR Security")
            {
                Caption = 'Security';
                field("NPR Register Password"; Rec."NPR Register Password")
                {

                    ExtendedDatatype = Masked;
                    ToolTip = 'Enable defining a password for accessing a POS unit.';
                    ApplicationArea = NPRRetail;
                }
                field("NPR Supervisor POS"; Rec."NPR Supervisor POS")
                {

                    ToolTip = 'Enable specifying if the salesperson will be tagged as the Supervisor.';
                    ApplicationArea = NPRRetail;
                }
                field("NPR Locked-to Register No."; Rec."NPR Locked-to Register No.")
                {
                    ToolTip = 'Enable assigning the salesperson to a specific POS unit.';
                    ApplicationArea = NPRRetail;
                    Visible = false;
                    Enabled = false;
                    ObsoleteState = Pending;
                    ObsoleteTag = 'NPR23.0';
                    ObsoleteReason = 'Replaced with POS Unit Group field.';
                }
                field("NPR POS Unit Group"; Rec."NPR POS Unit Group")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the group of POS Units that Salesperson can access.';
                }
            }
        }
        addafter(Name)
        {
            field("NPR CRO OIB Code"; CROAuxSalespersonPurchaser."NPR CRO Salesperson OIB")
            {
                ToolTip = 'Specifies the value of the Salesperson OIB field.';
                Caption = 'Salesperson OIB';
                ApplicationArea = NPRCROFiscal;
                trigger OnValidate()
                begin
                    CROAuxSalespersonPurchaser.Validate("NPR CRO Salesperson OIB");
                    CROAuxSalespersonPurchaser.SaveCROAuxSalespersonFields();
                end;
            }
            field("NPR SI Tax Number"; SIAuxSalespersonPurchaser."NPR SI Salesperson Tax Number")
            {
                ToolTip = 'Specifies the value of the Salesperson Tax Number field.';
                Caption = 'Salesperson Tax Number';
                ApplicationArea = NPRSIFiscal;
                trigger OnValidate()
                begin
                    SIAuxSalespersonPurchaser.Validate("NPR SI Salesperson Tax Number");
                    SIAuxSalespersonPurchaser.SaveSIAuxSalespersonFields();
                end;
            }
        }
    }

    var
        CROAuxSalespersonPurchaser: Record "NPR CRO Aux Salesperson/Purch.";
        SIAuxSalespersonPurchaser: Record "NPR SI Aux Salesperson/Purch.";

    trigger OnAfterGetCurrRecord()
    begin
        CROAuxSalespersonPurchaser.ReadCROAuxSalespersonFields(Rec);
        SIAuxSalespersonPurchaser.ReadSIAuxSalespersonFields(Rec);
    end;
}
