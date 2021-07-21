page 6014569 "NPR Package Shipping Agents"
{
    UsageCategory = Administration;

    CardPageID = "NPR Package Shipping agent";
    PageType = List;
    SourceTable = "NPR Package Shipping Agent";
    ApplicationArea = NPRRetail;
    Caption = 'Package Shipping Agents';

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {

                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Name; Rec.Name)
                {

                    ToolTip = 'Specifies the value of the Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Ship to Contact Mandatory"; Rec."Ship to Contact Mandatory")
                {

                    ToolTip = 'Specifies the value of the Ship to Contact Mandatory field';
                    ApplicationArea = NPRRetail;
                }
                field("Automatic Drop Point Service"; Rec."Automatic Drop Point Service")
                {

                    ToolTip = 'Specifies the value of the Automatic Drop Point Service field';
                    ApplicationArea = NPRRetail;
                }
                field("Email Mandatory"; Rec."Email Mandatory")
                {

                    ToolTip = 'Specifies if the E-mail is mandatory';
                    ApplicationArea = NPRRetail;
                }
                field("Phone Mandatory"; Rec."Phone Mandatory")
                {

                    ToolTip = 'Specifies if the Phone Number is mandatory';
                    ApplicationArea = NPRRetail;
                }
                field("Use own Agreement"; Rec."Use own Agreement")
                {

                    ToolTip = 'Specifies the value of the Use own Agreement field';
                    ApplicationArea = NPRRetail;
                }
                field("Package Type Required"; Rec."Package Type Required")
                {

                    ToolTip = 'Specifies the value of the Package Type Required field';
                    ApplicationArea = NPRRetail;
                }

            }
        }
    }

}

