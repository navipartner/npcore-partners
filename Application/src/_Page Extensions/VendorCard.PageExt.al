pageextension 6014404 "NPR Vendor Card" extends "Vendor Card"
{

    actions
    {
        addafter("Ven&dor")
        {

            group("NPR Reports")
            {
                Caption = 'Reports';
                Image = Report;
                action("NPR Vendor Top/Sale")
                {
                    Caption = 'NPR Vendor Top/Sale';
                    Image = Report2;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Report;
                    RunObject = Report "NPR Vendor Top/Sale";

                    ToolTip = 'Executes the NPR Vendor Top/Sale action';
                    ApplicationArea = NPRRetail;
                }
                action("NPR Vendor/Item Group")
                {
                    Caption = 'NPR Vendor/Item Group';
                    Image = Report2;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Report;
                    RunObject = Report "NPR Vendor/Item Group";

                    ToolTip = 'Executes the NPR Vendor/Item Group action';
                    ApplicationArea = NPRRetail;
                }
                action("NPR Vendor/Salesperson")
                {
                    Caption = 'NPR Vendor/Salesperson';
                    Image = Report2;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Report;
                    RunObject = Report "NPR Vendor/Salesperson";

                    ToolTip = 'Executes the NPR Vendor/Salesperson action';
                    ApplicationArea = NPRRetail;
                }

                action("NPR Vendor Sales Stat")
                {
                    Caption = 'NPR Vendor Sales Stat';
                    Image = Report2;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Report;
                    RunObject = Report "NPR Vendor Sales Stat";

                    ToolTip = 'Executes the NPR Vendor Sales Stat action';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}