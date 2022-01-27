page 6184852 "NPR FR POS Audit Log Aux. Info"
{
    Extensible = False;
    Caption = 'FR POS Audit Log Aux. Info';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR FR POS Audit Log Aux. Info";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("POS Entry No."; Rec."POS Entry No.")
                {

                    ToolTip = 'Specifies the value of the POS Entry No. field';
                    ApplicationArea = NPRRetail;
                }
                field("NPR Version"; Rec."NPR Version")
                {

                    ToolTip = 'Specifies the value of the NPR Version field';
                    ApplicationArea = NPRRetail;
                }
                field("Store Name"; Rec."Store Name")
                {

                    ToolTip = 'Specifies the value of the Store Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Store Name 2"; Rec."Store Name 2")
                {

                    ToolTip = 'Specifies the value of the Store Name 2 field';
                    ApplicationArea = NPRRetail;
                }
                field("Store Address"; Rec."Store Address")
                {

                    ToolTip = 'Specifies the value of the Store Address field';
                    ApplicationArea = NPRRetail;
                }
                field("Store Address 2"; Rec."Store Address 2")
                {

                    ToolTip = 'Specifies the value of the Store Address 2 field';
                    ApplicationArea = NPRRetail;
                }
                field("Store Post Code"; Rec."Store Post Code")
                {

                    ToolTip = 'Specifies the value of the Store Post Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Store City"; Rec."Store City")
                {

                    ToolTip = 'Specifies the value of the Store City field';
                    ApplicationArea = NPRRetail;
                }
                field("Store Siret"; Rec."Store Siret")
                {

                    ToolTip = 'Specifies the value of the Store Siret field';
                    ApplicationArea = NPRRetail;
                }
                field(APE; Rec.APE)
                {

                    ToolTip = 'Specifies the value of the APE field';
                    ApplicationArea = NPRRetail;
                }
                field("Intra-comm. VAT ID"; Rec."Intra-comm. VAT ID")
                {

                    ToolTip = 'Specifies the value of the Intra-comm. VAT ID field';
                    ApplicationArea = NPRRetail;
                }
                field("Salesperson Name"; Rec."Salesperson Name")
                {

                    ToolTip = 'Specifies the value of the Salesperson Name field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}
