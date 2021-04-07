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
                    ApplicationArea = All;
                    ToolTip = 'Executes the NPR Vendor Top/Sale action';
                }
                action("NPR Vendor/Item Group")
                {
                    Caption = 'NPR Vendor/Item Group';
                    Image = Report2;
                    Promoted = true; 
                    PromotedOnly = true; 
                    PromotedCategory = Report; 
                    RunObject = Report "NPR Vendor/Item Group";
                    ApplicationArea = All;
                    ToolTip = 'Executes the NPR Vendor/Item Group action';
                }
                action("NPR Vendor/Salesperson")
                {
                    Caption = 'NPR Vendor/Salesperson';
                    Image = Report2;
                    Promoted = true; 
                    PromotedOnly = true; 
                    PromotedCategory = Report; 
                    RunObject = Report "NPR Vendor/Salesperson";
                    ApplicationArea = All;
                    ToolTip = 'Executes the NPR Vendor/Salesperson action';
                }

                action("NPR Vendor Sales Stat")
                {
                    Caption = 'NPR Vendor Sales Stat';
                    Image = Report2;
                    Promoted = true; 
                    PromotedOnly = true; 
                    PromotedCategory = Report; 
                    RunObject = Report "NPR Vendor Sales Stat";
                    ApplicationArea = All;
                    ToolTip = 'Executes the NPR Vendor Sales Stat action';
                }
            }
        }
    }
}